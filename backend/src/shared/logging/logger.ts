import pino, { type Logger } from 'pino';
import { getRequestId } from './request-context';

/**
 * Structured logger with mandatory redaction (BIS §1.6). Sensitive fields are
 * stripped by pino's redact engine before serialisation, so credentials, cookies,
 * tokens, and cipher material can never reach a log sink even if a caller passes a
 * whole object. The redaction test asserts none of these appear in output.
 *
 * NYCU Portal passwords are never stored or logged (IRR A1 / B-1) — but the raw
 * cookie captured during login IS sensitive in-flight, hence redacted here too.
 */
export const REDACTED_PATHS: readonly string[] = [
  'password',
  'passwd',
  'portalPassword',
  'cookie',
  'cookies',
  'portalCookie',
  'sessionCookie',
  'authorization',
  'token',
  'accessToken',
  'refreshToken',
  'idToken',
  'fcmToken',
  'plaintext',
  'dataKey',
  'ciphertext',
  'secret',
  'apiKey',
  '*.password',
  '*.cookie',
  '*.token',
  '*.refreshToken',
  'req.headers.authorization',
  'req.headers.cookie',
  'res.headers["set-cookie"]',
];

export const REDACTION_CENSOR = '[REDACTED]';

export const logger: Logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  // Emit ISO timestamps and a stable "level" string for log-based alerting.
  formatters: {
    level: (label) => ({ level: label }),
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: { paths: [...REDACTED_PATHS], censor: REDACTION_CENSOR },
  // Attach the correlation id to every line without callers passing it.
  mixin: () => {
    const requestId = getRequestId();
    return requestId ? { requestId } : {};
  },
});

/** Child logger scoped to a subsystem (e.g. `childLogger('sync-worker')`). */
export function childLogger(component: string): Logger {
  return logger.child({ component });
}
