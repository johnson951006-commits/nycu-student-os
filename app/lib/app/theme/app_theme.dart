import 'package:flutter/material.dart';

/// PLACEHOLDER theme so the scaffold renders a correct first frame. The real,
/// token-generated theme (Design Spec §1 → tokens.g.dart → NycuColors, per the
/// FES §6 pipeline) replaces this in INFRA-009; only the brightness/theme-mode
/// wiring in `app.dart` is permanent. This file is the sanctioned home for raw
/// colour values (the only place exempt from the token-literal lint).
abstract final class AppTheme {
  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          // NYCU blue (Design Spec §1) as a placeholder seed until INFRA-009.
          seedColor: const Color(0xFF2472E8),
          brightness: brightness,
        ),
      );
}
