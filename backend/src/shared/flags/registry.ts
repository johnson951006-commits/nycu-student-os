/**
 * Feature-flag registry (BIS §12.4 / FES §10) — the compiled source of truth
 * for every flag the backend evaluates. Runtime values live in
 * `system_settings` under the reserved `flag:` key prefix; this registry owns
 * type, default, fail-safe direction, ownership, and expiry. A flag consumed
 * anywhere without a registry entry fails CI (flag-registry cross-check:
 * client ↔ server ↔ OpenAPI).
 *
 * Lint note: in THIS file, single-quoted snake_case strings are reserved for
 * flag keys — the corpus-lint cross-check extracts them mechanically.
 */
export enum FlagType {
  boolFlag,
  percentRollout,
  remoteConfig,
}

export interface FlagDefinition {
  readonly key: string;
  readonly type: FlagType;
  /** Compiled default when no `system_settings` row exists. */
  readonly defaultValue: boolean | number | string;
  /**
   * Value returned when the settings read FAILS (BIS §12.4): kill switches
   * fail to the SAFE state — closed for senders, open for core reads.
   */
  readonly safeDefault: boolean | number | string;
  /** Deterministic-bucketing salt (percent flags only); change to reshuffle. */
  readonly salt?: string;
  /** BIS §12.4 designated kill switch (ops can halt the behavior fleet-wide). */
  readonly killSwitch: boolean;
  /** FES §10: permanent switches are exempt from expiry; all others expire. */
  readonly permanent: boolean;
  readonly owner: string;
  readonly createdAt: string;
  readonly expiresAt: string | null;
  readonly description: string;
}

export const FLAG_PREFIX = 'flag:';

export const FLAG_REGISTRY: readonly FlagDefinition[] = [
  {
    key: 'grades_sync',
    type: FlagType.boolFlag,
    defaultValue: false,
    safeDefault: false,
    killSwitch: true,
    permanent: true,
    owner: 'Sync Guild',
    createdAt: '2026-07-16',
    expiresAt: null,
    description:
      'Grade sync + Grade Published notifications (flag-gated pending the PRD grades amendment; DB Design §11 separate authz path).',
  },
  {
    key: 'sec_pinning_enforced',
    type: FlagType.boolFlag,
    defaultValue: true,
    safeDefault: true,
    killSwitch: false,
    permanent: true,
    owner: 'Security Guild',
    createdAt: '2026-07-16',
    expiresAt: null,
    description:
      'Client certificate-pinning enforcement (fail-closed: a degraded read never relaxes pinning).',
  },
  {
    key: 'sec_min_supported_version',
    type: FlagType.remoteConfig,
    defaultValue: '0.0.0',
    safeDefault: '0.0.0',
    killSwitch: false,
    permanent: true,
    owner: 'Mobile Platform',
    createdAt: '2026-07-16',
    expiresAt: null,
    description:
      'Minimum supported app version for the 426 upgrade ladder (BIS §12.2); 0.0.0 = no enforcement. Fail-open: never block clients on a read failure.',
  },
  {
    key: 'notif_digest_batching',
    type: FlagType.percentRollout,
    defaultValue: 0,
    safeDefault: 0,
    salt: 'V1',
    killSwitch: true,
    permanent: true,
    owner: 'Notifications Guild',
    createdAt: '2026-07-16',
    expiresAt: null,
    description:
      'Digest batching rollout percentage (BIS §4.3); 0 = off. Kill switch: senders fail closed.',
  },
  {
    key: 'analytics',
    type: FlagType.boolFlag,
    defaultValue: false,
    safeDefault: false,
    killSwitch: false,
    permanent: false,
    owner: 'App Platform',
    createdAt: '2026-07-16',
    expiresAt: '2027-01-16',
    description:
      'Analytics event emission — off until the consent copy (open item P-2) is ratified; expires so the P-2 closure is forced.',
  },
];

const byKey = new Map(FLAG_REGISTRY.map((f) => [f.key, f]));

export function flagDefinition(key: string): FlagDefinition | undefined {
  return byKey.get(key);
}
