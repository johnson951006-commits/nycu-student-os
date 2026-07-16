/**
 * The four run shapes of the single backend image (BIS §1.1/§1.2).
 * The active profile is selected at boot by the APP_PROFILE env var.
 */
export const APP_PROFILES = ['api', 'sync-worker', 'notif-worker', 'jobs'] as const;

export type AppProfile = (typeof APP_PROFILES)[number];

export function isAppProfile(value: unknown): value is AppProfile {
  return (
    typeof value === 'string' && (APP_PROFILES as readonly string[]).includes(value)
  );
}
