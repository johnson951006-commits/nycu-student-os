import { Global, Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';
import { PubSubModule } from './pubsub/pubsub.module';
import { CryptoModule } from './crypto/crypto.module';

/**
 * The cross-cutting infrastructure bundle (BIS §1.1). Aggregates the globally-scoped
 * data/messaging/crypto modules so a consumer (a profile's module set, a feature
 * module) imports one thing and every shared service becomes injectable. HTTP-only
 * concerns — the health endpoints and the global exception filter — are wired by the
 * api profile, not here, so worker profiles stay port-less.
 */
@Global()
@Module({
  imports: [PrismaModule, RedisModule, PubSubModule, CryptoModule],
  exports: [PrismaModule, RedisModule, PubSubModule, CryptoModule],
})
export class SharedModule {}
