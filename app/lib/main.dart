import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'bootstrap/bootstrap.dart';
import 'bootstrap/providers.dart';

/// Entry point (FA §4): run the local-first bootstrap, then hand the opened stores
/// and the theme/locale snapshot to the composition root by seeding providers.
Future<void> main() async {
  final result = await bootstrap();

  runApp(
    ProviderScope(
      overrides: <Override>[
        secureStorageProvider.overrideWithValue(result.secureStorage),
        appDatabaseProvider.overrideWithValue(result.database),
        sharedPreferencesProvider.overrideWithValue(result.prefs),
        themeModeProvider.overrideWithValue(result.themeMode),
        localeProvider.overrideWithValue(result.locale),
      ],
      child: const NycuApp(),
    ),
  );
}
