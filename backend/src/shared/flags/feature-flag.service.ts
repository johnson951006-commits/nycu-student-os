import { createHash } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { childLogger } from '../logging/logger';
import { PrismaService } from '../prisma/prisma.service';
import {
  FLAG_PREFIX,
  FLAG_REGISTRY,
  FlagType,
  flagDefinition,
} from './registry';

/** Runtime row shape stored in system_settings JSONB (BIS §12.4). */
interface FlagRow {
  value?: boolean | number | string;
  rollout?: number;
  salt?: string;
}

const CACHE_TTL_MS = 30_000;

/**
 * Feature-flag evaluation (BIS §12.4): reads `flag:*` rows from
 * `system_settings` through a 30s in-memory cache per instance, so evaluation
 * is local and synchronous after the first read — flag checks are free to
 * sprinkle. A failed read degrades to each flag's registry SAFE default
 * (fail-closed for senders, fail-open for core reads) and logs
 * `flag.read_degraded`, never throws into the caller.
 */
@Injectable()
export class FeatureFlagService {
  private readonly log = childLogger('flags');
  private cache: { at: number; rows: Map<string, FlagRow> } | null = null;
  private degraded = false;

  constructor(private readonly prisma: PrismaService) {}

  /** Boolean flag verdict (kill switches ride this type). */
  async isEnabled(key: string): Promise<boolean> {
    const def = this.require(key, FlagType.boolFlag);
    const rows = await this.rows();
    if (rows === null) {
      return def.safeDefault as boolean;
    }
    const value = rows.get(key)?.value;
    return typeof value === 'boolean' ? value : (def.defaultValue as boolean);
  }

  /**
   * Percent-rollout verdict: deterministic bucketing
   * `hash(userId + key + salt) % 100 < rollout` (BIS §12.4) — the same user
   * always gets the same verdict; changing the salt reshuffles deliberately.
   */
  async percentOf(key: string, userId: string): Promise<boolean> {
    const def = this.require(key, FlagType.percentRollout);
    const rows = await this.rows();
    if (rows === null) {
      return this.bucket(userId, key, def.salt ?? '') < (def.safeDefault as number);
    }
    const row = rows.get(key);
    const rollout =
      typeof row?.rollout === 'number' ? row.rollout : (def.defaultValue as number);
    const salt = row?.salt ?? def.salt ?? '';
    return this.bucket(userId, key, salt) < rollout;
  }

  /** Typed remote-config value. */
  async config<T extends boolean | number | string>(key: string): Promise<T> {
    const def = this.require(key, FlagType.remoteConfig);
    const rows = await this.rows();
    if (rows === null) {
      return def.safeDefault as T;
    }
    const value = rows.get(key)?.value;
    return (value ?? def.defaultValue) as T;
  }

  /**
   * Every registered flag evaluated to its client verdict (`GET /v1/config`,
   * BIS §12.4 Remote Config): percent flags arrive as the user's bucketed
   * boolean — the client NEVER computes cohorts (FES §10).
   */
  async evaluateAll(userId: string): Promise<Record<string, boolean | number | string>> {
    const verdicts: Record<string, boolean | number | string> = {};
    for (const def of FLAG_REGISTRY) {
      switch (def.type) {
        case FlagType.boolFlag:
          verdicts[def.key] = await this.isEnabled(def.key);
          break;
        case FlagType.percentRollout:
          verdicts[def.key] = await this.percentOf(def.key, userId);
          break;
        case FlagType.remoteConfig:
          verdicts[def.key] = await this.config(def.key);
          break;
        default: {
          const exhaustive: never = def.type;
          throw new Error(`flags: unhandled type ${String(exhaustive)}`);
        }
      }
    }
    return verdicts;
  }

  /** Test/ops hook: drop the cache so the next read hits the store. */
  invalidate(): void {
    this.cache = null;
  }

  private require(key: string, type: FlagType) {
    const def = flagDefinition(key);
    if (!def || def.type !== type) {
      // Registry misuse is a programmer error — fail loud in every lane.
      throw new Error(`flags: ${key} is not a registered ${FlagType[type]} flag`);
    }
    return def;
  }

  private bucket(userId: string, key: string, salt: string): number {
    const digest = createHash('sha256').update(userId + key + salt).digest();
    return digest.readUInt32BE(0) % 100;
  }

  private async rows(): Promise<Map<string, FlagRow> | null> {
    const now = Date.now();
    if (this.cache && now - this.cache.at < CACHE_TTL_MS) {
      return this.cache.rows;
    }
    try {
      const settings = await this.prisma.systemSetting.findMany({
        where: { key: { startsWith: FLAG_PREFIX } },
      });
      const rows = new Map<string, FlagRow>();
      for (const s of settings) {
        rows.set(s.key.slice(FLAG_PREFIX.length), s.value as FlagRow);
      }
      this.cache = { at: now, rows };
      this.degraded = false;
      return rows;
    } catch (error) {
      if (!this.degraded) {
        this.log.warn({ err: error }, 'flag.read_degraded');
        this.degraded = true;
      }
      return null;
    }
  }
}
