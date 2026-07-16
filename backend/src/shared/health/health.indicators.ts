import { Injectable } from '@nestjs/common';
import {
  HealthIndicator,
  type HealthIndicatorResult,
  HealthCheckError,
} from '@nestjs/terminus';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';

/**
 * Readiness probes for the backing services (BIS §1.13). Each returns a Terminus
 * result so `/readyz` aggregates them; a failing dependency yields an unhealthy
 * result with no sensitive detail. Liveness (`/healthz`) does not call these.
 */
@Injectable()
export class DatabaseHealthIndicator extends HealthIndicator {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async check(key = 'database'): Promise<HealthIndicatorResult> {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return this.getStatus(key, true);
    } catch (error) {
      throw new HealthCheckError(
        'database unavailable',
        this.getStatus(key, false, { message: (error as Error).message }),
      );
    }
  }
}

@Injectable()
export class RedisHealthIndicator extends HealthIndicator {
  constructor(private readonly redis: RedisService) {
    super();
  }

  async check(key = 'redis'): Promise<HealthIndicatorResult> {
    try {
      const ok = await this.redis.ping();
      if (!ok) {
        throw new Error('ping did not return PONG');
      }
      return this.getStatus(key, true);
    } catch (error) {
      throw new HealthCheckError(
        'redis unavailable',
        this.getStatus(key, false, { message: (error as Error).message }),
      );
    }
  }
}

/**
 * Config-presence probes for Pub/Sub and KMS (BIS §1.13). Liveness of these managed
 * services is verified at deploy; readiness here confirms the process was handed the
 * configuration it needs to reach them, catching misconfigured revisions early.
 */
@Injectable()
export class ConfigHealthIndicator extends HealthIndicator {
  check(key: string, requiredEnv: string[]): HealthIndicatorResult {
    const missing = requiredEnv.filter((name) => !process.env[name]);
    if (missing.length === 0) {
      return this.getStatus(key, true);
    }
    throw new HealthCheckError(
      `${key} misconfigured`,
      this.getStatus(key, false, { missing }),
    );
  }
}
