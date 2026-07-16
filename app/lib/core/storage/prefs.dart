import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys (FA §9.2): trivial primitives only.
abstract final class PrefsKeys {
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String onboardingSeen = 'onboarding_seen';
  static const String lastTabIndex = 'last_tab_index';
}

/// The theme/locale snapshot read **synchronously** at bootstrap so the very first
/// frame uses the persisted mode/locale — no flash-of-wrong-theme (FA §4).
/// Defaults: follow the system theme, and no explicit locale (follow the device
/// until the user chooses one — IRR §1.9).
class ThemeLocaleSnapshot {
  const ThemeLocaleSnapshot({required this.themeMode, required this.locale});

  final ThemeMode themeMode;
  final Locale? locale;

  static ThemeLocaleSnapshot read(SharedPreferences prefs) {
    final themeMode = switch (prefs.getString(PrefsKeys.themeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final code = prefs.getString(PrefsKeys.locale);
    final locale =
        (code != null && code.isNotEmpty) ? _parseLocale(code) : null;
    return ThemeLocaleSnapshot(themeMode: themeMode, locale: locale);
  }

  static Locale _parseLocale(String code) {
    final parts = code.split('-');
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
