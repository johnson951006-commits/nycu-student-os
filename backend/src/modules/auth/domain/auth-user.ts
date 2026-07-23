/**
 * Identity domain model — mirrors the `users` table (DB §7) column-for-column,
 * nullability included. Behaviour-agnostic: no persistence, no validation, no
 * framework imports. Request validation lives in the DTO/zod layer (AUTH-002);
 * the DB CHECK constraints are the authority for the closed value domains below.
 */

/** `users.locale` CHECK (locale IN ('zh-TW','en')). */
export const USER_LOCALES = ['zh-TW', 'en'] as const;
export type UserLocale = (typeof USER_LOCALES)[number];

/** `users.role_preference` CHECK (role_preference IN ('student','ta')). */
export const ROLE_PREFERENCES = ['student', 'ta'] as const;
export type RolePreference = (typeof ROLE_PREFERENCES)[number];

export interface AuthUser {
  /** `id UUID PRIMARY KEY` */
  readonly id: string;
  /** `student_id TEXT NOT NULL` */
  readonly studentId: string;
  /** `display_name TEXT` (nullable) */
  readonly displayName: string | null;
  /** `email TEXT` (nullable) */
  readonly email: string | null;
  /** `locale TEXT NOT NULL DEFAULT 'zh-TW'` */
  readonly locale: UserLocale;
  /** `role_preference TEXT` (nullable) */
  readonly rolePreference: RolePreference | null;
  /** `created_at TIMESTAMPTZ NOT NULL` */
  readonly createdAt: Date;
  /** `updated_at TIMESTAMPTZ NOT NULL` */
  readonly updatedAt: Date;
  /** `deleted_at TIMESTAMPTZ` (nullable — Tier-A soft delete, 30d purge) */
  readonly deletedAt: Date | null;
}
