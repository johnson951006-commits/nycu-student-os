/**
 * Portal session (the encrypted NYCU cookie jar) — mirrors the
 * `portal_sessions` table (DB §7) column-for-column, nullability included.
 *
 * The jar is stored KMS-envelope-encrypted (`enc_cookie_jar` + `dek_wrapped`,
 * BIS §2.2/§7); NO password is ever modelled, stored, or transported anywhere
 * in this system (PRD v1.1 / IRR A1 — there is deliberately no credential field
 * on this entity). Behaviour-agnostic: probing, expiry and re-auth transitions
 * belong to the auth/sync services, not this model.
 */

/**
 * `portal_sessions.status` CHECK
 * (status IN ('ACTIVE','STALE','EXPIRED','REAUTH_REQUIRED')).
 */
export const PORTAL_SESSION_STATUSES = [
  'ACTIVE',
  'STALE',
  'EXPIRED',
  'REAUTH_REQUIRED',
] as const;
export type PortalSessionStatus = (typeof PORTAL_SESSION_STATUSES)[number];

export interface PortalSession {
  /** `user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE` */
  readonly userId: string;
  /** `enc_cookie_jar BYTEA NOT NULL` — ciphertext; server-side only. */
  readonly encCookieJar: Uint8Array;
  /** `dek_wrapped BYTEA NOT NULL` — KMS-wrapped data key; server-side only. */
  readonly dekWrapped: Uint8Array;
  /** `status TEXT NOT NULL DEFAULT 'ACTIVE'` */
  readonly status: PortalSessionStatus;
  /** `last_validated_at TIMESTAMPTZ` (nullable — null until first probe) */
  readonly lastValidatedAt: Date | null;
  /** `fail_count SMALLINT NOT NULL DEFAULT 0 CHECK (fail_count >= 0)` */
  readonly failCount: number;
  /** `created_at TIMESTAMPTZ NOT NULL` */
  readonly createdAt: Date;
  /** `updated_at TIMESTAMPTZ NOT NULL` */
  readonly updatedAt: Date;
}
