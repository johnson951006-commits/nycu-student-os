import 'package:flutter/material.dart';

import 'tokens.g.dart';

/// Token-built Material 3 theme (FA §6): Design Spec §1 values flow from
/// `contracts/tokens/tokens.json` → [NycuColors]/[TypeScale] (generated) → the
/// [ThemeData] here. Material 3 is the theming engine only — every value below
/// references a token; nothing is hand-copied (FES §6).
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, NycuColors.light);

  static ThemeData dark() => _build(Brightness.dark, NycuColors.dark);

  static ThemeData _build(Brightness brightness, NycuColors c) {
    // ColorScheme mapping per FA §6; secondary carries the Secondary-button
    // pair (fill bg/accent-tint, content text/accent — Design Spec §5.1).
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.bgAccent,
      onPrimary: c.textOnAccent,
      secondary: c.bgAccentTint,
      onSecondary: c.textAccent,
      error: c.textDanger,
      onError: c.textOnAccent,
      surface: c.bgSurface,
      onSurface: c.textPrimary,
      surfaceContainerLowest: c.bgCanvas,
      outline: c.borderDefault,
      outlineVariant: c.borderSubtle,
    );

    TextStyle style(TypeSpec spec, Color color, {bool tabular = false}) {
      return TextStyle(
        fontSize: spec.size,
        height: spec.height,
        fontWeight: spec.weight,
        letterSpacing: spec.tracking,
        color: color,
        fontFeatures: tabular
            ? const <FontFeature>[FontFeature.tabularFigures()]
            : null,
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.bgCanvas,
      dividerColor: c.dividerHairline,
      // FA §6: fallback chain Inter → Noto Sans TC (IRR A5); CJK line-height
      // adjustments are applied per-locale at the text-style call sites.
      fontFamily: 'Inter',
      fontFamilyFallback: const <String>['Noto Sans TC'],
      // FA §6 documented TextTheme mapping (unlisted slots keep M3 defaults;
      // components consume [TypeScale] directly for the full scale).
      textTheme: TextTheme(
        displaySmall: style(TypeScale.display, c.textPrimary, tabular: true),
        headlineMedium: style(TypeScale.title1, c.textPrimary),
        titleMedium: style(TypeScale.headline, c.textPrimary),
        bodyLarge: style(TypeScale.body, c.textPrimary),
        bodySmall: style(TypeScale.footnote, c.textSecondary),
        labelSmall: style(TypeScale.caption2, c.textTertiary),
      ),
      // FA §6: the Design Spec elevates with shadow/border, never M3 tint.
      cardTheme: CardTheme(
        color: c.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.lg),
          side: brightness == Brightness.dark
              ? BorderSide(color: c.borderSubtle)
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.bgSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.xxl)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: c.bgSurfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Corners.xl),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[c],
    );
  }
}
