import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/db/app_database.dart';
import '../core/storage/secure_storage.dart';

/// Providers seeded at bootstrap via `ProviderScope(overrides:)` (FA §4). Each
/// throws until overridden, so reading one before bootstrap is a loud programming
/// error rather than a silent wrong default. Mutable variants (e.g. a settings-
/// backed theme controller) are introduced by their owning tasks.

final Provider<SecureStorage> secureStorageProvider = Provider<SecureStorage>(
  (ref) => throw UnimplementedError('secureStorageProvider is seeded at bootstrap'),
);

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider is seeded at bootstrap'),
);

final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider is seeded at bootstrap'),
);

final Provider<ThemeMode> themeModeProvider = Provider<ThemeMode>(
  (ref) => throw UnimplementedError('themeModeProvider is seeded at bootstrap'),
);

final Provider<Locale?> localeProvider = Provider<Locale?>(
  (ref) => throw UnimplementedError('localeProvider is seeded at bootstrap'),
);
