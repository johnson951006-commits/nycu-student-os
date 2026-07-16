import { z } from 'zod';
import { APP_PROFILES } from './app-profile';

/**
 * Typed configuration schema (BIS §1.4/§1.5).
 *
 * Core variables are required so the process fails fast on misconfiguration.
 * Infrastructure/secret variables are typed here but OPTIONAL at scaffold time;
 * the tasks that introduce their consumers tighten requiredness (per-profile) as
 * they land — DATABASE_URL by INFRA-005, REDIS_URL/JWT/KMS by INFRA-006,
 * FCM/PubSub by INFRA-010. This keeps unconsumed infrastructure from being
 * required merely to boot the scaffold.
 */
export const configSchema = z.object({
  // --- core (required / defaulted) ---
  APP_PROFILE: z.enum(APP_PROFILES),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().max(65535).default(8080),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),

  // --- data tier (INFRA-005 / BIS §6.1) ---
  DATABASE_URL: z.string().url().optional(),
  DATABASE_DIRECT_URL: z.string().url().optional(),
  REDIS_URL: z.string().optional(),

  // --- auth / crypto (INFRA-006) ---
  JWT_PRIVATE_KEY_PEM: z.string().optional(),
  JWT_PUBLIC_JWKS: z.string().optional(),
  KMS_KEY_PORTAL_COOKIES: z.string().optional(),
  LOG_HASH_KEY: z.string().optional(),

  // --- messaging (INFRA-010) ---
  FIREBASE_SERVICE_ACCOUNT: z.string().optional(),
  PUBSUB_TOPIC_SYNC: z.string().optional(),
  PUBSUB_TOPIC_EVENTS: z.string().optional(),
  PUBSUB_TOPIC_NOTIF: z.string().optional(),

  // --- portal client (sync-worker) ---
  PORTAL_BASE_URLS: z.string().optional(),
  PORTAL_MAX_CONCURRENCY: z.coerce.number().int().positive().optional(),
  PORTAL_MAX_RPS: z.coerce.number().int().positive().optional(),

  // --- observability / internal ---
  OTEL_EXPORTER_OTLP_ENDPOINT: z.string().url().optional(),
  INTERNAL_AUDIENCE: z.string().optional(),
});

export type AppConfig = z.infer<typeof configSchema>;

/**
 * Fail-fast validation (BIS §1.4): throws a descriptive error on invalid config so
 * bootstrap aborts before the process can serve traffic. Used both as the
 * `@nestjs/config` validator and directly by main.ts.
 */
export function validateEnv(
  env: NodeJS.ProcessEnv | Record<string, unknown>,
): AppConfig {
  const parsed = configSchema.safeParse(env);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((issue) => `  - ${issue.path.join('.') || '(root)'}: ${issue.message}`)
      .join('\n');
    throw new Error(`Invalid configuration (BIS §1.4 fail-fast):\n${issues}`);
  }
  return parsed.data;
}
