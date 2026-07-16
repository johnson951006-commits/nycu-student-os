import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nycu_student_os/app/theme/app_theme.dart';
import 'package:nycu_student_os/shared_widgets/shared_widgets.dart';

/// INFRA-009 Required Test: component goldens across theme × locale.
/// Baselines live in `test/goldens/goldens/ci/` — regenerate deliberately with
/// `flutter test --update-goldens test/goldens` (designer-reviewable diff,
/// FES §6). Alchemist's CI renderer keeps images platform-independent.
void main() {
  for (final (themeName, theme) in <(String, ThemeData)>[
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    for (final (localeName, locale) in <(String, Locale)>[
      ('zh_TW', Locale('zh', 'TW')),
      ('en', Locale('en')),
    ]) {
      goldenTest(
        'component baseline ($themeName, $localeName)',
        fileName: 'components_${themeName}_$localeName',
        builder: () => GoldenTestGroup(
          columns: 1,
          children: <Widget>[
            GoldenTestScenario(
              name: 'AppButton variants x sizes',
              child: _Harness(
                theme: theme,
                locale: locale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final variant in AppButtonVariant.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            for (final size in AppButtonSize.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: AppButton(
                                  label: 'Button',
                                  variant: variant,
                                  size: size,
                                  onPressed: () {},
                                ),
                              ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AppButton(
                          label: 'Loading',
                          loading: true,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        const AppButton(label: 'Disabled', onPressed: null),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GoldenTestScenario(
              name: 'AppCard variants + localized error copy',
              child: _Harness(
                theme: theme,
                locale: locale,
                child: SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Builder(
                        builder: (context) => AppCard(
                          overline: 'Due soon',
                          trailing: Text(
                            'View All',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).errorCookieExpired,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const AppCard(
                        variant: AppCardVariant.sunken,
                        child: Text('Sunken well'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

/// Wraps golden content with the real app theme + locale so goldens exercise
/// the token-built [ThemeData] and gen_l10n delegates end-to-end.
class _Harness extends StatelessWidget {
  const _Harness({
    required this.theme,
    required this.locale,
    required this.child,
  });

  final ThemeData theme;
  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: Center(
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}
