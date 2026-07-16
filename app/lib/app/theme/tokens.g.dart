// GENERATED FILE — do not edit by hand (FES §6).
//
// Source: contracts/tokens/tokens.json (v1.0.0)
// Regenerate: dart run tool/token_gen.dart   (verify: --verify)
// Every visual value in the app comes from here or the theme
// built on it — literals elsewhere fail the token-literal lint.
import 'package:flutter/material.dart';

/// Semantic color tokens (Design Spec §1.2) plus the course
/// identity palette (§1.1), as a [ThemeExtension] so every
/// widget reads colors from the active theme.
class NycuColors extends ThemeExtension<NycuColors> {
  const NycuColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.bgSurfaceSunken,
    required this.bgSidebar,
    required this.bgOverlay,
    required this.bgAccent,
    required this.bgAccentTint,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textAccent,
    required this.textOnAccent,
    required this.textDanger,
    required this.textSuccess,
    required this.textWarning,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderFocus,
    required this.dividerHairline,
    required this.eventAssignment,
    required this.eventExam,
    required this.eventPersonal,
    required this.eventTodo,
    required this.stateHover,
    required this.statePressed,
    required this.stateSelected,
    required this.stateDragTarget,
    required this.courseColors,
    required this.courseContainers,
    required this.courseOnContainers,
  });

  final Color bgCanvas;
  final Color bgSurface;
  final Color bgSurfaceRaised;
  final Color bgSurfaceSunken;
  final Color bgSidebar;
  final Color bgOverlay;
  final Color bgAccent;
  final Color bgAccentTint;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textAccent;
  final Color textOnAccent;
  final Color textDanger;
  final Color textSuccess;
  final Color textWarning;
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderFocus;
  final Color dividerHairline;
  final Color eventAssignment;
  final Color eventExam;
  final Color eventPersonal;
  final Color eventTodo;
  final Color stateHover;
  final Color statePressed;
  final Color stateSelected;
  final Color stateDragTarget;
  final List<Color> courseColors;
  final List<Color> courseContainers;
  final List<Color> courseOnContainers;

  static const NycuColors light = NycuColors(
    bgCanvas: Color(0xFFF7F8FA),
    bgSurface: Color(0xFFFFFFFF),
    bgSurfaceRaised: Color(0xFFFFFFFF),
    bgSurfaceSunken: Color(0xFFF0F2F5),
    bgSidebar: Color(0xEBFBFCFD),
    bgOverlay: Color(0x66101828),
    bgAccent: Color(0xFF2472E8),
    bgAccentTint: Color(0xFFEEF5FF),
    textPrimary: Color(0xFF101828),
    textSecondary: Color(0xFF475467),
    textTertiary: Color(0xFF667085),
    textDisabled: Color(0xFF98A2B3),
    textAccent: Color(0xFF1A5FD0),
    textOnAccent: Color(0xFFFFFFFF),
    textDanger: Color(0xFFD92D20),
    textSuccess: Color(0xFF027A48),
    textWarning: Color(0xFFB54708),
    borderSubtle: Color(0xFFE4E7EC),
    borderDefault: Color(0xFFD0D5DD),
    borderStrong: Color(0xFF98A2B3),
    borderFocus: Color(0xFF2472E8),
    dividerHairline: Color(0xB3E4E7EC),
    eventAssignment: Color(0xFFF79009),
    eventExam: Color(0xFFF04438),
    eventPersonal: Color(0xFFD9A507),
    eventTodo: Color(0xFF7A5AF8),
    stateHover: Color(0x0A101828),
    statePressed: Color(0x14101828),
    stateSelected: Color(0x1A2472E8),
    stateDragTarget: Color(0x0F2472E8),
    courseColors: <Color>[
      Color(0xFF2472E8),
      Color(0xFF0FB5AE),
      Color(0xFF7A5AF8),
      Color(0xFFF79009),
      Color(0xFFEE46BC),
      Color(0xFF6172F3),
      Color(0xFF039855),
      Color(0xFFF04438),
      Color(0xFFD9A507),
      Color(0xFF667085),
    ],
    courseContainers: <Color>[
      Color(0xFFD9E9FF),
      Color(0xFFCCF3F0),
      Color(0xFFEBE4FF),
      Color(0xFFFEEAD3),
      Color(0xFFFCE7F6),
      Color(0xFFE0EAFF),
      Color(0xFFD3F3DF),
      Color(0xFFFEE4E2),
      Color(0xFFFEF3C7),
      Color(0xFFF0F2F5),
    ],
    courseOnContainers: <Color>[
      Color(0xFF154DA8),
      Color(0xFF107569),
      Color(0xFF5925DC),
      Color(0xFFB54708),
      Color(0xFFC11574),
      Color(0xFF3538CD),
      Color(0xFF027A48),
      Color(0xFFB42318),
      Color(0xFFA97F05),
      Color(0xFF344054),
    ],
  );

  static const NycuColors dark = NycuColors(
    bgCanvas: Color(0xFF0B0F17),
    bgSurface: Color(0xFF101828),
    bgSurfaceRaised: Color(0xFF1D2939),
    bgSurfaceSunken: Color(0xFF0E1421),
    bgSidebar: Color(0xE0101828),
    bgOverlay: Color(0x99000000),
    bgAccent: Color(0xFF4A90F4),
    bgAccentTint: Color(0x244A90F4),
    textPrimary: Color(0xFFF5F7FA),
    textSecondary: Color(0xFF98A2B3),
    textTertiary: Color(0xFF667085),
    textDisabled: Color(0xFF475467),
    textAccent: Color(0xFF7EB3FA),
    textOnAccent: Color(0xFF0B0F17),
    textDanger: Color(0xFFF97066),
    textSuccess: Color(0xFF32D583),
    textWarning: Color(0xFFFDB022),
    borderSubtle: Color(0xFF232B3B),
    borderDefault: Color(0xFF2E3850),
    borderStrong: Color(0xFF475467),
    borderFocus: Color(0xFF4A90F4),
    dividerHairline: Color(0x14FFFFFF),
    eventAssignment: Color(0xFFFDB022),
    eventExam: Color(0xFFF97066),
    eventPersonal: Color(0xFFF5C518),
    eventTodo: Color(0xFF9B8AFB),
    stateHover: Color(0x0FFFFFFF),
    statePressed: Color(0x1AFFFFFF),
    stateSelected: Color(0x294A90F4),
    stateDragTarget: Color(0x0F2472E8),
    courseColors: <Color>[
      Color(0xFF4A90F4),
      Color(0xFF2ED3B7),
      Color(0xFF9B8AFB),
      Color(0xFFFDB022),
      Color(0xFFF670C7),
      Color(0xFF8098F9),
      Color(0xFF32D583),
      Color(0xFFF97066),
      Color(0xFFF7D144),
      Color(0xFF98A2B3),
    ],
    courseContainers: <Color>[
      Color(0xFFD9E9FF),
      Color(0xFFCCF3F0),
      Color(0xFFEBE4FF),
      Color(0xFFFEEAD3),
      Color(0xFFFCE7F6),
      Color(0xFFE0EAFF),
      Color(0xFFD3F3DF),
      Color(0xFFFEE4E2),
      Color(0xFFFEF3C7),
      Color(0xFFF0F2F5),
    ],
    courseOnContainers: <Color>[
      Color(0xFF154DA8),
      Color(0xFF107569),
      Color(0xFF5925DC),
      Color(0xFFB54708),
      Color(0xFFC11574),
      Color(0xFF3538CD),
      Color(0xFF027A48),
      Color(0xFFB42318),
      Color(0xFFA97F05),
      Color(0xFF344054),
    ],
  );

  @override
  NycuColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSurfaceRaised,
    Color? bgSurfaceSunken,
    Color? bgSidebar,
    Color? bgOverlay,
    Color? bgAccent,
    Color? bgAccentTint,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textAccent,
    Color? textOnAccent,
    Color? textDanger,
    Color? textSuccess,
    Color? textWarning,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderFocus,
    Color? dividerHairline,
    Color? eventAssignment,
    Color? eventExam,
    Color? eventPersonal,
    Color? eventTodo,
    Color? stateHover,
    Color? statePressed,
    Color? stateSelected,
    Color? stateDragTarget,
    List<Color>? courseColors,
    List<Color>? courseContainers,
    List<Color>? courseOnContainers,
  }) {
    return NycuColors(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurfaceRaised: bgSurfaceRaised ?? this.bgSurfaceRaised,
      bgSurfaceSunken: bgSurfaceSunken ?? this.bgSurfaceSunken,
      bgSidebar: bgSidebar ?? this.bgSidebar,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      bgAccent: bgAccent ?? this.bgAccent,
      bgAccentTint: bgAccentTint ?? this.bgAccentTint,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textAccent: textAccent ?? this.textAccent,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      textDanger: textDanger ?? this.textDanger,
      textSuccess: textSuccess ?? this.textSuccess,
      textWarning: textWarning ?? this.textWarning,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      dividerHairline: dividerHairline ?? this.dividerHairline,
      eventAssignment: eventAssignment ?? this.eventAssignment,
      eventExam: eventExam ?? this.eventExam,
      eventPersonal: eventPersonal ?? this.eventPersonal,
      eventTodo: eventTodo ?? this.eventTodo,
      stateHover: stateHover ?? this.stateHover,
      statePressed: statePressed ?? this.statePressed,
      stateSelected: stateSelected ?? this.stateSelected,
      stateDragTarget: stateDragTarget ?? this.stateDragTarget,
      courseColors: courseColors ?? this.courseColors,
      courseContainers: courseContainers ?? this.courseContainers,
      courseOnContainers: courseOnContainers ?? this.courseOnContainers,
    );
  }

  @override
  NycuColors lerp(NycuColors? other, double t) {
    if (other == null) {
      return this;
    }
    return NycuColors(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSurfaceRaised: Color.lerp(bgSurfaceRaised, other.bgSurfaceRaised, t)!,
      bgSurfaceSunken: Color.lerp(bgSurfaceSunken, other.bgSurfaceSunken, t)!,
      bgSidebar: Color.lerp(bgSidebar, other.bgSidebar, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      bgAccent: Color.lerp(bgAccent, other.bgAccent, t)!,
      bgAccentTint: Color.lerp(bgAccentTint, other.bgAccentTint, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textAccent: Color.lerp(textAccent, other.textAccent, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      textDanger: Color.lerp(textDanger, other.textDanger, t)!,
      textSuccess: Color.lerp(textSuccess, other.textSuccess, t)!,
      textWarning: Color.lerp(textWarning, other.textWarning, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      dividerHairline: Color.lerp(dividerHairline, other.dividerHairline, t)!,
      eventAssignment: Color.lerp(eventAssignment, other.eventAssignment, t)!,
      eventExam: Color.lerp(eventExam, other.eventExam, t)!,
      eventPersonal: Color.lerp(eventPersonal, other.eventPersonal, t)!,
      eventTodo: Color.lerp(eventTodo, other.eventTodo, t)!,
      stateHover: Color.lerp(stateHover, other.stateHover, t)!,
      statePressed: Color.lerp(statePressed, other.statePressed, t)!,
      stateSelected: Color.lerp(stateSelected, other.stateSelected, t)!,
      stateDragTarget: Color.lerp(stateDragTarget, other.stateDragTarget, t)!,
      courseColors: _lerpColors(courseColors, other.courseColors, t),
      courseContainers: _lerpColors(courseContainers, other.courseContainers, t),
      courseOnContainers: _lerpColors(courseOnContainers, other.courseOnContainers, t),
    );
  }
}

List<Color> _lerpColors(List<Color> a, List<Color> b, double t) {
  return List<Color>.generate(
      a.length, (int i) => Color.lerp(a[i], b[i], t)!);
}

/// 4pt spacing scale (Design Spec §1.4).
abstract final class Space {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;
}

/// Corner radii (Design Spec §1.5).
abstract final class Corners {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

/// Motion durations (Design Spec §1.6). `reduced` is the
/// Reduce-Motion fallback (all springs collapse to 150ms fades).
abstract final class Motion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration gentle = Duration(milliseconds: 450);
  static const Duration celebrate = Duration(milliseconds: 600);
  static const Duration reduced = Duration(milliseconds: 150);
}

/// One type-scale step (Design Spec §1.3).
class TypeSpec {
  const TypeSpec(this.size, this.lineHeight, this.weight, this.tracking);

  final double size;
  final double lineHeight;
  final FontWeight weight;
  final double tracking;

  /// Line height as the [TextStyle.height] multiplier.
  double get height => lineHeight / size;
}

/// Type scale (Design Spec §1.3), 4pt-aligned.
abstract final class TypeScale {
  static const TypeSpec display = TypeSpec(34, 41, FontWeight.w700, 0.4);
  static const TypeSpec title1 = TypeSpec(28, 34, FontWeight.w700, 0.38);
  static const TypeSpec title2 = TypeSpec(22, 28, FontWeight.w700, -0.26);
  static const TypeSpec title3 = TypeSpec(20, 25, FontWeight.w600, -0.45);
  static const TypeSpec headline = TypeSpec(17, 22, FontWeight.w600, -0.43);
  static const TypeSpec body = TypeSpec(17, 22, FontWeight.w400, -0.43);
  static const TypeSpec callout = TypeSpec(16, 21, FontWeight.w400, -0.31);
  static const TypeSpec subhead = TypeSpec(15, 20, FontWeight.w400, -0.23);
  static const TypeSpec footnote = TypeSpec(13, 18, FontWeight.w400, -0.08);
  static const TypeSpec caption1 = TypeSpec(12, 16, FontWeight.w500, 0);
  static const TypeSpec caption2 = TypeSpec(11, 13, FontWeight.w600, 0.06);
  static const TypeSpec mono = TypeSpec(15, 20, FontWeight.w400, 0);
}

/// Accessibility constants (Design Spec §1.3/§5.1).
abstract final class A11y {
  static const double minTapTarget = 44;
  static const double minTextSize = 11;
}
