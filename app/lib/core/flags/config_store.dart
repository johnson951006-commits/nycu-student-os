import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../storage/hive_boxes.dart';
import 'registry.dart';

/// Snapshot key inside the config box.
const String _snapshotKey = 'flags_snapshot';
const String _fetchedAtKey = 'flags_fetched_at';

/// Hive-backed store for the `GET /v1/config` snapshot (FES §10 / FA §9.2):
/// the network layer (future task) writes the evaluated verdicts here on
/// app-open + 6h refresh; readers resolve fetch → snapshot → compiled
/// registry default. Contents are evaluated verdicts only — safe to lose.
class ConfigStore {
  Box<dynamic> get _box => Hive.box<dynamic>(HiveBoxes.config);

  /// Persists a fresh `/v1/config` verdict map (called by the fetcher).
  Future<void> saveSnapshot(Map<String, Object?> flags) async {
    await _box.put(_snapshotKey, Map<String, Object?>.from(flags));
    await _box.put(_fetchedAtKey, DateTime.now().toIso8601String());
  }

  /// The cached verdicts, or null when no snapshot has ever been written.
  Map<String, Object?>? get snapshot {
    final raw = _box.get(_snapshotKey);
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  DateTime? get fetchedAt {
    final raw = _box.get(_fetchedAtKey);
    return raw is String ? DateTime.tryParse(raw) : null;
  }

  /// Resolves one flag verdict: snapshot → registry default. Unknown keys
  /// (server ahead of client) return null — callers treat as absent.
  Object? verdict(String key) {
    final snap = snapshot;
    if (snap != null && snap.containsKey(key)) {
      return snap[key];
    }
    return flagDefinition(key)?.defaultValue;
  }
}

final Provider<ConfigStore> configStoreProvider =
    Provider<ConfigStore>((ref) => ConfigStore());

/// Watchable verdict per flag key (FES §10: widgets watch it like any
/// provider). Re-evaluated when [configRevisionProvider] bumps after a
/// snapshot write, so flag flips rebuild live.
final StateProvider<int> configRevisionProvider = StateProvider<int>((_) => 0);

final ProviderFamily<Object?, String> flagProvider =
    Provider.family<Object?, String>((ref, key) {
  ref.watch(configRevisionProvider);
  return ref.watch(configStoreProvider).verdict(key);
});

/// Boolean convenience with the registry fail-safe as the final fallback.
final ProviderFamily<bool, String> boolFlagProvider =
    Provider.family<bool, String>((ref, key) {
  final value = ref.watch(flagProvider(key));
  if (value is bool) {
    return value;
  }
  final def = flagDefinition(key);
  return def?.failSafe is bool ? def!.failSafe as bool : false;
});
