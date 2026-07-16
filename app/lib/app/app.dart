import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bootstrap/providers.dart';
import 'theme/app_theme.dart';

/// Composition-root widget. Reads the bootstrap-seeded theme/locale providers so
/// the first frame already uses the persisted mode/locale (no flash — FA §4).
/// Routing and the token-generated theme are wired by later tasks; the scaffold
/// renders a placeholder ("app boots to a placeholder").
class NycuApp extends ConsumerWidget {
  const NycuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'NYCU Student OS',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      supportedLocales: const <Locale>[
        Locale('zh', 'TW'),
        Locale('en'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _BootstrapPlaceholder(),
    );
  }
}

class _BootstrapPlaceholder extends StatelessWidget {
  const _BootstrapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('NYCU Student OS', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Starting…', style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
