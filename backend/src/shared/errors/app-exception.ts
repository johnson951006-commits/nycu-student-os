import { ERROR_CODES, type ErrorCode } from './error-codes';

/**
 * The one exception type the backend throws for expected failures (BIS §1.9).
 * Carries a registered [ErrorCode]; the HTTP status and bilingual messages are
 * derived from the registry so callers never hand-write them.
 *
 * `detail` is developer-facing (logged, never returned to clients); `meta` holds
 * template values (e.g. `{ t, category }`) for message interpolation at the edge.
 */
export class AppException extends Error {
  constructor(
    readonly code: ErrorCode,
    readonly detail?: string,
    readonly meta?: Record<string, unknown>,
  ) {
    super(detail ?? code);
    this.name = new.target.name;
    Object.setPrototypeOf(this, new.target.prototype);
  }

  get status(): number {
    return ERROR_CODES[this.code].status;
  }
}

/**
 * Worker-side classification (BIS §1.9): a transient failure is redelivered
 * (Pub/Sub nack) so the message retries; a permanent failure is acknowledged and
 * routed to the DLQ. Handlers throw the matching subclass; the runtime decides
 * ack/nack from the class, not from ad-hoc booleans.
 */
export class TransientError extends AppException {}

export class PermanentError extends AppException {}
