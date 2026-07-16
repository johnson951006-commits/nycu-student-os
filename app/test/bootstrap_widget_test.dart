import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nycu_student_os/app/app.dart';
import 'package:nycu_student_os/bootstrap/providers.dart';

/// Bootstrap widget test (INFRA-008 Required Test): the app renders its placeholder
/// and the FIRST frame already reflects the seeded theme mode + locale (no
/// flash-of-wrong-theme — FA §4). The placeholder does not read the store
/// providers, so they are intentionally left un-overridden.
void main() {
  testWidgets('frame 1 uses the seeded theme mode and locale', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          themeModeProvider.overrideWithValue(ThemeMode.dark),
          localeProvider.overrideWithValue(const Locale('zh', 'TW')),
        ],
        child: const NycuApp(),
      ),
    );

    final MaterialApp app =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.locale, const Locale('zh', 'TW'));
    expect(find.text('NYCU Student OS'), findsOneWidget);
  });

  testWidgets('defaults render when the snapshot is system/no-locale',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          themeModeProvider.overrideWithValue(ThemeMode.system),
          localeProvider.overrideWithValue(null),
        ],
        child: const NycuApp(),
      ),
    );

    final MaterialApp app =
        tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.system);
    expect(app.locale, isNull);
  });
}
