import 'package:flutter/material.dart' show Locale, ThemeMode, WidgetsFlutterBinding;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/db/app_database.dart';
import '../core/db/connection.dart';
import '../core/storage/hive_boxes.dart';
import '../core/storage/prefs.dart';
import '../core/storage/secure_storage.dart';

/// The opened stores + the frame-1 snapshot, handed to the composition root to
/// seed providers.
class BootstrapResult {
  const BootstrapResult({
    required this.secureStorage,
    required this.database,
    required this.prefs,
    required this.themeMode,
    required this.locale,
  });

  final SecureStorage secureStorage;
  final AppDatabase database;
  final SharedPreferences prefs;
  final ThemeMode themeMode;
  final Locale? locale;
}

/// Local-first bootstrap (FA §4): open every store **in order**, read the
/// persisted theme/locale snapshot synchronously so the first frame is correct
/// (no flash-of-wrong-theme), then return the opened stores for provider seeding.
Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Secure storage → the SQLCipher key (created on first launch, FES §13).
  final secureStorage = SecureStorage();
  final databaseKey = await secureStorage.readOrCreateDatabaseKey();

  // 2. drift(SQLCipher) → the local-first domain database.
  final database = AppDatabase(openEncryptedConnection(databaseKey));

  // 3. Hive → structured non-relational caches.
  await Hive.initFlutter();
  await openHiveBoxes();

  // 4. SharedPreferences → primitives + the theme/locale snapshot.
  final prefs = await SharedPreferences.getInstance();
  final snapshot = ThemeLocaleSnapshot.read(prefs);

  return BootstrapResult(
    secureStorage: secureStorage,
    database: database,
    prefs: prefs,
    themeMode: snapshot.themeMode,
    locale: snapshot.locale,
  );
}
