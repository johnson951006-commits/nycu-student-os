import { Global, Module, type Provider } from '@nestjs/common';
import IORedis from 'ioredis';
import { DistributedLock, SlidingWindowLimiter } from './redis.primitives';
import { REDIS_CLIENT, RedisService } from './redis.service';

/**
 * Shared ioredis connection (BIS §1.8). `lazyConnect` defers the socket until the
 * first command, so importing this module never blocks boot or requires Redis to be
 * up during unit boot — the connection opens when a primitive first runs.
 */
const redisClientProvider: Provider = {
  provide: REDIS_CLIENT,
  useFactory: () =>
    new IORedis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
      lazyConnect: true,
      maxRetriesPerRequest: 3,
      enableReadyCheck: true,
    }),
};

@Global()
@Module({
  providers: [
    redisClientProvider,
    RedisService,
    DistributedLock,
    SlidingWindowLimiter,
  ],
  exports: [REDIS_CLIENT, RedisService, DistributedLock, SlidingWindowLimiter],
})
export class RedisModule {}
