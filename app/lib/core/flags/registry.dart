/// Client feature-flag registry (FES §10) — the compiled mirror of the server
/// registry (`backend/src/shared/flags/registry.ts`). Every flag the client
/// consumes MUST exist here with a default and a fail-safe direction; CI
/// cross-checks the two lists and the OpenAPI config schema mechanically.
///
/// The client renders server-evaluated verdicts only — it NEVER computes
/// cohorts (BIS §12.4); these defaults are the last resort after
/// fresh-fetch → Hive snapshot both miss.
///
/// Lint note: single-quoted snake_case strings in this file are reserved for
/// flag keys (the cross-check extracts them mechanically).
library;

enum FlagType { boolFlag, percentRollout, remoteConfig }

class FlagDefinition {
  const FlagDefinition({
    required this.key,
    required this.type,
    required this.defaultValue,
    required this.failSafe,
    required this.description,
  });

  final String key;
  final FlagType type;

  /// Verdict used when neither a fresh fetch nor a Hive snapshot exists.
  final Object defaultValue;

  /// Direction on degraded reads (mirror of the server's safe default):
  /// killed features hide affordances gracefully — never dead buttons.
  final Object failSafe;
  final String description;
}

const List<FlagDefinition> flagRegistry = <FlagDefinition>[
  FlagDefinition(
    key: 'grades_sync',
    type: FlagType.boolFlag,
    defaultValue: false,
    failSafe: false,
    description: 'Grades UI + grade notifications (kill switch; off = absent).',
  ),
  FlagDefinition(
    key: 'sec_pinning_enforced',
    type: FlagType.boolFlag,
    defaultValue: true,
    failSafe: true,
    description: 'Certificate-pinning enforcement (fail-closed).',
  ),
  FlagDefinition(
    key: 'sec_min_supported_version',
    type: FlagType.remoteConfig,
    defaultValue: '0.0.0',
    failSafe: '0.0.0',
    description: 'Minimum supported app version (426 ladder; fail-open).',
  ),
  FlagDefinition(
    key: 'notif_digest_batching',
    type: FlagType.percentRollout,
    defaultValue: false,
    failSafe: false,
    description:
        'Digest batching — arrives as an evaluated boolean verdict per user.',
  ),
  FlagDefinition(
    key: 'analytics',
    type: FlagType.boolFlag,
    defaultValue: false,
    failSafe: false,
    description: 'Analytics emission (off pending consent copy, P-2).',
  ),
];

final Map<String, FlagDefinition> _byKey = <String, FlagDefinition>{
  for (final f in flagRegistry) f.key: f,
};

FlagDefinition? flagDefinition(String key) => _byKey[key];
