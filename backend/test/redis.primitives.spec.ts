import RedisMock from 'ioredis-mock';
import type { Redis } from 'ioredis';
import {
  DistributedLock,
  SlidingWindowLimiter,
  type LockHandle,
} from '../src/shared/redis/redis.primitives';

/**
 * INFRA-006 Required Test: distributed lock heartbeat + owner-scoped release, and
 * the sliding-window limiter. Runs against an in-memory Redis (ioredis-mock) so the
 * SET NX / Lua owner-check semantics are exercised without a live server.
 */
describe('DistributedLock (BIS §1.8)', () => {
  let client: Redis;
  let lock: DistributedLock;

  beforeEach(() => {
    client = new RedisMock() as unknown as Redis;
    lock = new DistributedLock(client);
  });

  it('grants the lock once, then refuses concurrent acquisition', async () => {
    const first = await lock.acquire('lock:sync:user-1', 1_000);
    const second = await lock.acquire('lock:sync:user-1', 1_000);
    expect(first).not.toBeNull();
    expect(second).toBeNull();
  });

  it('heartbeats only for the current owner', async () => {
    const handle = (await lock.acquire('lock:sync:user-1', 1_000)) as LockHandle;
    expect(await lock.heartbeat(handle, 5_000)).toBe(true);

    const impostor: LockHandle = { key: handle.key, token: 'not-the-owner' };
    expect(await lock.heartbeat(impostor, 5_000)).toBe(false);
  });

  it('releases only for the owner, leaving a stale holder a no-op', async () => {
    const handle = (await lock.acquire('lock:sync:user-1', 1_000)) as LockHandle;

    const impostor: LockHandle = { key: handle.key, token: 'not-the-owner' };
    expect(await lock.release(impostor)).toBe(false);
    // still held → a fresh acquire must fail
    expect(await lock.acquire('lock:sync:user-1', 1_000)).toBeNull();

    expect(await lock.release(handle)).toBe(true);
    // now free → acquire succeeds
    expect(await lock.acquire('lock:sync:user-1', 1_000)).not.toBeNull();
  });
});

describe('SlidingWindowLimiter (BIS §1.10)', () => {
  let client: Redis;
  let limiter: SlidingWindowLimiter;

  beforeEach(() => {
    client = new RedisMock() as unknown as Redis;
    limiter = new SlidingWindowLimiter(client);
  });

  it('allows up to the limit within the window, then blocks', async () => {
    const key = 'rl:sync:user-1';
    const r1 = await limiter.hit(key, 2, 60_000);
    const r2 = await limiter.hit(key, 2, 60_000);
    const r3 = await limiter.hit(key, 2, 60_000);

    expect(r1.allowed).toBe(true);
    expect(r2.allowed).toBe(true);
    expect(r3.allowed).toBe(false);
    expect(r3.remaining).toBe(0);
  });
});
