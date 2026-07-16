import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { Test } from '@nestjs/testing';
import { FeatureFlagService } from '../src/shared/flags/feature-flag.service';
import { FlagsController } from '../src/shared/flags/flags.controller';
import { FLAG_REGISTRY, FlagType } from '../src/shared/flags/registry';
import { PrismaService } from '../src/shared/prisma/prisma.service';

/**
 * INFRA-010 Required Tests: flag-registry cross-check (client ↔ server ↔
 * OpenAPI) + config-endpoint test; plus BIS §12.4 semantics — deterministic
 * bucketing, kill-switch fail-safe direction, expiry hygiene (FES §10).
 */
describe('flag registry (BIS §12.4 / FES §10)', () => {
  const serverKeys = FLAG_REGISTRY.map((f) => f.key);

  it('cross-checks server ↔ client ↔ OpenAPI key sets', () => {
    const dart = readFileSync(
      join(__dirname, '..', '..', 'app', 'lib', 'core', 'flags', 'registry.dart'),
      'utf8',
    );
    const clientKeys = [...dart.matchAll(/key: '([a-z0-9_]+)'/g)].map((m) => m[1]);

    const openapi = readFileSync(
      join(__dirname, '..', '..', 'contracts', 'openapi', 'openapi.yaml'),
      'utf8',
    );
    const flagsBlock = openapi.split('ConfigResponse:')[1] ?? '';
    const contractKeys = serverKeys.filter((k) =>
      new RegExp(`${k}: \\{ type:`).test(flagsBlock),
    );

    expect([...clientKeys].sort()).toEqual([...serverKeys].sort());
    expect([...contractKeys].sort()).toEqual([...serverKeys].sort());
  });

  it('gives every flag an owner and expiry discipline (FES §10)', () => {
    for (const def of FLAG_REGISTRY) {
      expect(def.owner.length).toBeGreaterThan(0);
      if (def.permanent) {
        expect(def.expiresAt).toBeNull();
      } else {
        expect(def.expiresAt).not.toBeNull();
      }
      if (def.type === FlagType.percentRollout) {
        expect(def.salt).toBeDefined();
      }
    }
  });

  it('fails CI when a non-permanent flag is past its expiry (stale-flag report)', () => {
    const now = new Date();
    for (const def of FLAG_REGISTRY) {
      if (!def.permanent && def.expiresAt) {
        expect(new Date(def.expiresAt).getTime()).toBeGreaterThan(now.getTime());
      }
    }
  });
});

describe('FeatureFlagService', () => {
  function service(rows: Array<{ key: string; value: unknown }> | Error) {
    const prisma = {
      systemSetting: {
        findMany: async () => {
          if (rows instanceof Error) throw rows;
          return rows;
        },
      },
    } as unknown as PrismaService;
    return new FeatureFlagService(prisma);
  }

  it('returns the stored value, else the registry default', async () => {
    const svc = service([
      { key: 'flag:grades_sync', value: { type: 'bool', default: false, value: true } },
    ]);
    expect(await svc.isEnabled('grades_sync')).toBe(true);
    expect(await svc.isEnabled('sec_pinning_enforced')).toBe(true); // default
  });

  it('kill switches fail to the SAFE state on read failure', async () => {
    const svc = service(new Error('connection refused'));
    expect(await svc.isEnabled('grades_sync')).toBe(false); // fail-closed
    expect(await svc.isEnabled('sec_pinning_enforced')).toBe(true); // fail-closed = keep enforcing
    expect(await svc.config('sec_min_supported_version')).toBe('0.0.0'); // fail-open
  });

  it('buckets deterministically and reshuffles on salt change', async () => {
    const svc = service([
      { key: 'flag:notif_digest_batching', value: { rollout: 50 } },
    ]);
    const first = await svc.percentOf('notif_digest_batching', 'user-123');
    for (let i = 0; i < 5; i++) {
      expect(await svc.percentOf('notif_digest_batching', 'user-123')).toBe(first);
    }

    const reshuffled = service([
      { key: 'flag:notif_digest_batching', value: { rollout: 50, salt: 'V2' } },
    ]);
    const verdicts = new Set<boolean>();
    for (let u = 0; u < 64; u++) {
      verdicts.add(await reshuffled.percentOf('notif_digest_batching', `user-${u}`));
    }
    expect(verdicts.size).toBe(2); // ~50% rollout hits both verdicts across users
  });

  it('distributes buckets roughly uniformly', async () => {
    const svc = service([
      { key: 'flag:notif_digest_batching', value: { rollout: 50 } },
    ]);
    let enabled = 0;
    const n = 2000;
    for (let u = 0; u < n; u++) {
      if (await svc.percentOf('notif_digest_batching', `uid-${u}`)) enabled++;
    }
    expect(enabled / n).toBeGreaterThan(0.42);
    expect(enabled / n).toBeLessThan(0.58);
  });

  it('rejects unregistered keys loudly', async () => {
    const svc = service([]);
    await expect(svc.isEnabled('not_a_flag')).rejects.toThrow('not a registered');
  });
});

describe('GET /v1/config (config-endpoint test)', () => {
  it('returns every registered flag evaluated', async () => {
    const moduleRef = await Test.createTestingModule({
      controllers: [FlagsController],
      providers: [
        FeatureFlagService,
        {
          provide: PrismaService,
          useValue: {
            systemSetting: {
              findMany: async () => [
                {
                  key: 'flag:grades_sync',
                  value: { type: 'bool', default: false, value: true },
                },
              ],
            },
          },
        },
      ],
    }).compile();

    const controller = moduleRef.get(FlagsController);
    const body = await controller.getConfig();

    expect(Object.keys(body.flags).sort()).toEqual(
      FLAG_REGISTRY.map((f) => f.key).sort(),
    );
    expect(body.flags['grades_sync']).toBe(true);
    expect(body.flags['sec_min_supported_version']).toBe('0.0.0');
    expect(typeof body.flags['notif_digest_batching']).toBe('boolean');
    expect(new Date(body.evaluatedAt).getTime()).not.toBeNaN();

    await moduleRef.close();
  });
});
