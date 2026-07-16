import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nycu_student_os/core/flags/config_store.dart';
import 'package:nycu_student_os/core/flags/registry.dart';
import 'package:nycu_student_os/core/storage/hive_boxes.dart';

/// Client flag framework (INFRA-010, FES §10): snapshot → registry-default
/// fallback order, and registry discipline. The server↔client↔OpenAPI key
/// cross-check runs in the backend suite + corpus-lint.
void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('flags_test');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>(HiveBoxes.config);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  test('registry seeds exactly the five INFRA-010 flags', () {
    expect(flagRegistry.map((f) => f.key).toList(), <String>[
      'grades_sync',
      'sec_pinning_enforced',
      'sec_min_supported_version',
      'notif_digest_batching',
      'analytics',
    ]);
  });

  test('every flag carries a fail-safe of its verdict type', () {
    for (final def in flagRegistry) {
      if (def.type == FlagType.remoteConfig) {
        expect(def.failSafe, isA<String>(), reason: def.key);
      } else {
        expect(def.failSafe, isA<bool>(), reason: def.key);
      }
    }
  });

  test('verdict falls back to the compiled default with no snapshot', () {
    final store = ConfigStore();
    expect(store.snapshot, isNull);
    expect(store.verdict('sec_pinning_enforced'), true);
    expect(store.verdict('grades_sync'), false);
    expect(store.verdict('sec_min_supported_version'), '0.0.0');
  });

  test('a saved snapshot wins over the default and survives re-read', () async {
    final store = ConfigStore();
    await store.saveSnapshot(<String, Object?>{
      'grades_sync': true,
      'sec_min_supported_version': '1.2.0',
    });

    expect(store.verdict('grades_sync'), true);
    expect(store.verdict('sec_min_supported_version'), '1.2.0');
    // Keys absent from the snapshot still resolve to registry defaults.
    expect(store.verdict('sec_pinning_enforced'), true);
    expect(store.fetchedAt, isNotNull);
  });

  test('unknown keys (server ahead of client) resolve to null, never throw', () {
    final store = ConfigStore();
    expect(store.verdict('some_future_flag'), isNull);
  });
}
