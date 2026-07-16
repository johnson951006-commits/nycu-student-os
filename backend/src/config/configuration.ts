import { registerAs } from '@nestjs/config';
import { validateEnv, type AppConfig } from './config.schema';

/**
 * Namespaced, typed configuration for injection via `ConfigType<typeof configuration>`
 * / `@Inject(configuration.KEY)`. Values are validated (the `validate` hook in the
 * config module runs the same schema at boot, fail-fast — BIS §1.4).
 */
export const configuration = registerAs(
  'app',
  (): AppConfig => validateEnv(process.env),
);
