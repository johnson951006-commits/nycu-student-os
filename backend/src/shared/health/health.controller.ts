import { Controller, Get } from '@nestjs/common';
import {
  HealthCheck,
  HealthCheckService,
  type HealthCheckResult,
} from '@nestjs/terminus';
import {
  ConfigHealthIndicator,
  DatabaseHealthIndicator,
  RedisHealthIndicator,
} from './health.indicators';

/**
 * Kubernetes/Cloud Run probes (BIS §1.13). `/healthz` is liveness — the process is
 * up and the event loop responsive, with no dependency calls so a transient DB blip
 * never restarts the pod. `/readyz` is readiness — every backing service the request
 * path needs is reachable and configured before traffic is routed.
 */
@Controller()
export class HealthController {
  constructor(
    private readonly health: HealthCheckService,
    private readonly db: DatabaseHealthIndicator,
    private readonly redis: RedisHealthIndicator,
    private readonly config: ConfigHealthIndicator,
  ) {}

  @Get('healthz')
  @HealthCheck()
  liveness(): Promise<HealthCheckResult> {
    return this.health.check([]);
  }

  @Get('readyz')
  @HealthCheck()
  readiness(): Promise<HealthCheckResult> {
    return this.health.check([
      () => this.db.check(),
      () => this.redis.check(),
      () => this.config.check('pubsub', ['PUBSUB_TOPIC_PREFIX']),
      () => this.config.check('kms', ['KMS_KEY_NAME']),
    ]);
  }
}
