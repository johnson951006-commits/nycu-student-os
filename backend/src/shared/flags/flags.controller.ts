import { Controller, Get } from '@nestjs/common';
import { FeatureFlagService } from './feature-flag.service';

/** `GET /v1/config` response body (mirrored in OpenAPI `ConfigResponse`). */
export interface ConfigResponse {
  flags: Record<string, boolean | number | string>;
  evaluatedAt: string;
}

/**
 * Remote Config endpoint (BIS §12.4): returns the caller's EVALUATED flag
 * verdicts — percent flags arrive bucketed server-side, the client never
 * computes cohorts (FES §10). Clients cache the snapshot (Hive configBox) and
 * refetch on app-open + every 6h.
 *
 * Authentication + per-user bucketing identity ride the bearer JWT, whose
 * guard is owned by the AUTH feature (AUTH-002) and attaches when that task
 * lands. Until then the endpoint evaluates with the anonymous identity —
 * verdict shape identical, no user data involved.
 */
@Controller('v1/config')
export class FlagsController {
  constructor(private readonly flags: FeatureFlagService) {}

  @Get()
  async getConfig(): Promise<ConfigResponse> {
    return {
      flags: await this.flags.evaluateAll(''),
      evaluatedAt: new Date().toISOString(),
    };
  }
}
