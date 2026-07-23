/**
 * App session (the JWT/refresh pair's server-side record) — mirrors the
 * `app_sessions` table (DB §7) column-for-column, nullability included.
 * Behaviour-agnostic: rotation, revocation and reuse-detection are the auth
 * service's concern (later AUTH tasks), not this model's.
 */
export interface AppSession {
  /** `id UUID PRIMARY KEY` */
  readonly id: string;
  /** `user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE` */
  readonly userId: string;
  /**
   * `refresh_hash TEXT NOT NULL` — the HASH of the refresh token, never the
   * token itself (BIS §7 A02). Server-side only; never mirrored client-side.
   */
  readonly refreshHash: string;
  /** `rotated_from UUID` (nullable) — predecessor in the rotation chain. */
  readonly rotatedFrom: string | null;
  /** `device_label TEXT` (nullable) */
  readonly deviceLabel: string | null;
  /** `expires_at TIMESTAMPTZ NOT NULL` */
  readonly expiresAt: Date;
  /** `revoked_at TIMESTAMPTZ` (nullable) */
  readonly revokedAt: Date | null;
  /** `created_at TIMESTAMPTZ NOT NULL` */
  readonly createdAt: Date;
}
