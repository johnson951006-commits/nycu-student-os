import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:nycu_student_os/core/db/app_database.dart';
import 'package:nycu_student_os/core/storage/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Store-open smoke (INFRA-008 Required Test): the local stores open and are
/// usable. The drift database is opened in-memory here; the on-device SQLCipher
/// file connection is exercised by the integration suite (FES §13). Hive and
/// secure storage require platform channels and are covered on-device.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppDatabase opens and is queryable (in-memory)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final row = await db.customSelect('SELECT 1 AS v').getSingle();
    expect(row.read<int>('v'), 1);
    await db.close();
  });

  test('theme/locale snapshot defaults to system + no locale', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final snapshot = ThemeLocaleSnapshot.read(prefs);
    expect(snapshot.themeMode, ThemeMode.system);
    expect(snapshot.locale, isNull);
  });

  test('theme/locale snapshot reads persisted values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'theme_mode': 'dark',
      'locale': 'zh-TW',
    });
    final prefs = await SharedPreferences.getInstance();
    final snapshot = ThemeLocaleSnapshot.read(prefs);
    expect(snapshot.themeMode, ThemeMode.dark);
    expect(snapshot.locale, const Locale('zh', 'TW'));
  });
}
