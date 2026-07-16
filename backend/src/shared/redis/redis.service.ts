import { Inject, Injectable, type OnModuleDestroy } from '@nestjs/common';
import type { Redis } from 'ioredis';

/** DI token for the shared ioredis connection (BIS §1.8). */
export const REDIS_CLIENT = Symbol('REDIS_CLIENT');

/**
 * Typed Redis key registry (BIS §1.8): every key the backend uses is built here so
 * namespaces stay collision-free and greppable. Feature modules extend this rather
 * than hand-concatenating strings.
 */
export const RedisKeys = {
  cache: (scope: string, id: string): string => `cache:${scope}:${id}`,
  lock: (resource: string): string => `lock:${resource}`,
  rateLimit: (bucket: string, subject: string): string => `rl:${bucket}:${subject}`,
} as const;

/**
 * Thin, injectable wrapper over the shared Redis connection providing JSON cache
 * helpers with TTL. Lock and rate-limit primitives live in their own classes so
 * their semantics stay explicit; this service is only the cache surface plus raw
 * client access for those primitives.
 */
@Injectable()
export class RedisService implements OnModuleDestroy {
  constructor(@Inject(REDIS_CLIENT) readonly client: Redis) {}

  async getJson<T>(key: string): Promise<T | null> {
    const raw = await this.client.get(key);
    return raw === null ? null : (JSON.parse(raw) as T);
  }

  async setJson(key: string, value: unknown, ttlSeconds?: number): Promise<void> {
    const payload = JSON.stringify(value);
    if (ttlSeconds && ttlSeconds > 0) {
      await this.client.set(key, payload, 'EX', ttlSeconds);
    } else {
      await this.client.set(key, payload);
    }
  }

  async del(...keys: string[]): Promise<number> {
    return keys.length ? this.client.del(...keys) : 0;
  }

  async ping(): Promise<boolean> {
    return (await this.client.ping()) === 'PONG';
  }

  async onModuleDestroy(): Promise<void> {
    // `quit` drains in-flight commands before closing (unlike `disconnect`).
    if (this.client.status === 'ready' || this.client.status === 'connecting') {
      await this.client.quit();
    }
  }
}
