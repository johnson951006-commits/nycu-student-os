import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import type { Redis } from 'ioredis';
import { REDIS_CLIENT } from './redis.service';

/** Handle proving ownership of an acquired lock; required to heartbeat or release. */
export interface LockHandle {
  readonly key: string;
  readonly token: string;
}

// Owner-checked operations run as Lua so the get-and-act is atomic (BIS §1.8): a
// lock is only extended or released by the holder that currently owns the token.
const PEXPIRE_IF_OWNER = `
if redis.call('get', KEYS[1]) == ARGV[1] then
  return redis.call('pexpire', KEYS[1], ARGV[2])
else
  return 0
end`;

const DEL_IF_OWNER = `
if redis.call('get', KEYS[1]) == ARGV[1] then
  return redis.call('del', KEYS[1])
else
  return 0
end`;

/**
 * Distributed mutex (BIS §1.8): `SET key token PX ttl NX` acquires, a per-holder
 * token guards heartbeat/release so a slow holder can never delete a lock a peer
 * has since taken over. Used to serialise per-user sync runs across worker replicas.
 */
@Injectable()
export class DistributedLock {
  constructor(@Inject(REDIS_CLIENT) private readonly client: Redis) {}

  async acquire(key: string, ttlMs: number): Promise<LockHandle | null> {
    const token = randomUUID();
    const res = await this.client.set(key, token, 'PX', ttlMs, 'NX');
    return res === 'OK' ? { key, token } : null;
  }

  /** Extend the TTL only while still the owner (the heartbeat). */
  async heartbeat(handle: LockHandle, ttlMs: number): Promise<boolean> {
    const res = await this.client.eval(
      PEXPIRE_IF_OWNER,
      1,
      handle.key,
      handle.token,
      String(ttlMs),
    );
    return res === 1;
  }

  /** Release only if still the owner; a stale holder's release is a no-op. */
  async release(handle: LockHandle): Promise<boolean> {
    const res = await this.client.eval(DEL_IF_OWNER, 1, handle.key, handle.token);
    return res === 1;
  }
}

export interface RateLimitResult {
  readonly allowed: boolean;
  readonly remaining: number;
}

/**
 * Sliding-window rate limiter (BIS §1.10) backed by a per-subject sorted set of
 * request timestamps. Each check trims the window, records the hit, and counts —
 * giving a true rolling window rather than a fixed-bucket approximation. Enforces
 * limits such as the manual-sync cooldown (SYNC_COOLDOWN).
 */
@Injectable()
export class SlidingWindowLimiter {
  constructor(@Inject(REDIS_CLIENT) private readonly client: Redis) {}

  async hit(key: string, limit: number, windowMs: number): Promise<RateLimitResult> {
    const now = Date.now();
    const member = `${now}-${randomUUID()}`;
    const results = await this.client
      .multi()
      .zremrangebyscore(key, 0, now - windowMs)
      .zadd(key, now, member)
      .zcard(key)
      .pexpire(key, windowMs)
      .exec();

    const count = Number(results?.[2]?.[1] ?? 0);
    return { allowed: count <= limit, remaining: Math.max(0, limit - count) };
  }
}
