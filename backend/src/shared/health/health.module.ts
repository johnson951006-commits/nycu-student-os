import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health.controller';
import {
  ConfigHealthIndicator,
  DatabaseHealthIndicator,
  RedisHealthIndicator,
} from './health.indicators';

/**
 * Health endpoints for the api profile (BIS §1.13). Depends on the globally-provided
 * Prisma and Redis services; register this module only where an HTTP server exists
 * (the api profile), since workers expose no port.
 */
@Module({
  imports: [TerminusModule],
  controllers: [HealthController],
  providers: [DatabaseHealthIndicator, RedisHealthIndicator, ConfigHealthIndicator],
})
export class HealthModule {}
