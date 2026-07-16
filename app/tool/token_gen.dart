// Design-token generator + validation gate (FES §6, INFRA-009).
//
// Reads `contracts/tokens/tokens.json` (Design Spec §1, the single source of
// visual truth) and emits `lib/app/theme/tokens.g.dart`. Pure Dart — run from
// the `app/` directory:
//
//   dart run tool/token_gen.dart            # regenerate tokens.g.dart
//   dart run tool/token_gen.dart --verify   # CI gate: validate, don't write
//
// `--verify` enforces the FES §6 blocking checks:
//   schema     every semantic color has both modes; values well-formed
//   reference  every `{path}` reference resolves (no deleted-token refs)
//   contrast   every documented text/background pair meets its Design Spec
//              §1.2 threshold in BOTH modes (WCAG 2.1 relative luminance)
//   motion     user-blocking durations ≤ 300ms (IRR §9.3 cap)
//   text size  every type-scale size ≥ a11y.minTextSize
//   coverage   committed tokens.g.dart is byte-identical to the emission
//              (a hand-edited generated file fails)
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const String tokensPath = '../contracts/tokens/tokens.json';
const String outputPath = 'lib/app/theme/tokens.g.dart';

/// Documented text/background contrast pairs (Design Spec §1.2 Text table):
/// [foreground, background, minimum ratio]. `textDisabled` has no target ("—").
/// `textTertiary` carries the DS "large text only" annotation → WCAG large-text
/// AA threshold 3.0.
const List<(String, String, double)> contrastPairs = [
  ('textPrimary', 'bgSurface', 12.0),
  ('textPrimary', 'bgCanvas', 12.0),
  ('textSecondary', 'bgSurface', 4.6),
  ('textSecondary', 'bgCanvas', 4.6),
  ('textTertiary', 'bgSurface', 3.0),
  ('textTertiary', 'bgCanvas', 3.0),
  ('textAccent', 'bgSurface', 4.5),
  ('textAccent', 'bgCanvas', 4.5),
  ('textDanger', 'bgSurface', 4.5),
  ('textDanger', 'bgCanvas', 4.5),
  ('textSuccess', 'bgSurface', 4.5),
  ('textSuccess', 'bgCanvas', 4.5),
  ('textWarning', 'bgSurface', 4.5),
  ('textWarning', 'bgCanvas', 4.5),
  ('textOnAccent', 'bgAccent', 4.5),
];

/// Motion tokens that gate user-visible interaction (IRR §9.3: ≤300ms).
/// `gentle`/`celebrate` are decorative (ring fill, completion) — exempt.
const List<String> userBlockingMotion = ['instant', 'quick', 'standard'];

void main(List<String> args) {
  final verify = args.contains('--verify');
  final errors = <String>[];

  final Map<String, dynamic> tokens;
  try {
    tokens =
        jsonDecode(File(tokensPath).readAsStringSync()) as Map<String, dynamic>;
  } on Object catch (e) {
    stderr.writeln('token_gen: cannot read/parse $tokensPath: $e');
    exit(2);
  }

  final resolver = _Resolver(tokens, errors);
  final semantic = _readSemantic(tokens, resolver, errors);
  final course = _readCourse(tokens, resolver, errors);
  final space = _readDimensions(tokens, 'space', errors);
  final radius = _readDimensions(tokens, 'radius', errors);
  final motion = _readDimensions(tokens, 'motion', errors);
  final typeScale = _readTypeScale(tokens, errors);
  final a11y = _readDimensions(tokens, 'a11y', errors);

  if (errors.isEmpty) {
    _checkContrast(semantic, errors);
    _checkMotion(motion, errors);
    _checkTextSizes(typeScale, a11y, errors);
  }

  if (errors.isNotEmpty) {
    stderr.writeln('token_gen: FAIL (${errors.length} violation(s))');
    for (final e in errors) {
      stderr.writeln('  ✗ $e');
    }
    exit(1);
  }

  final version = tokens['version'] as String? ?? '0.0.0';
  final emitted = _emit(version, semantic, course, space, radius, motion,
      typeScale, a11y);

  if (verify) {
    final existing = File(outputPath);
    if (!existing.existsSync() || existing.readAsStringSync() != emitted) {
      stderr.writeln(
          'token_gen: FAIL — $outputPath is stale or hand-edited; run '
          '`dart run tool/token_gen.dart` and commit the result.');
      exit(1);
    }
    stdout.writeln('token_gen: PASS (schema, references, contrast, motion, '
        'text-size, regeneration)');
    return;
  }

  File(outputPath).writeAsStringSync(emitted);
  stdout.writeln('token_gen: wrote $outputPath (tokens v$version)');
}

// ───────────────────────────── reading & schema ─────────────────────────────

class _Resolver {
  _Resolver(this.root, this.errors);
  final Map<String, dynamic> root;
  final List<String> errors;

  /// Resolves `#RRGGBB[AA]` or a `{dot.path}` reference to a hex string.
  String? hex(dynamic value, String context) {
    if (value is! String) {
      errors.add('$context: expected string, got $value');
      return null;
    }
    var v = value;
    if (v.startsWith('{') && v.endsWith('}')) {
      dynamic node = root;
      for (final part in v.substring(1, v.length - 1).split('.')) {
        if (node is Map<String, dynamic> && node.containsKey(part)) {
          node = node[part];
        } else {
          errors.add('$context: unresolved reference $v');
          return null;
        }
      }
      if (node is Map<String, dynamic> && node[r'$value'] is String) {
        v = node[r'$value'] as String;
      } else {
        errors.add('$context: reference $v does not point at a color leaf');
        return null;
      }
    }
    if (!RegExp(r'^#[0-9A-F]{6}([0-9A-F]{2})?$').hasMatch(v)) {
      errors.add('$context: malformed hex "$v"');
      return null;
    }
    return v;
  }
}

class _ModalColor {
  const _ModalColor(this.light, this.dark);
  final String light;
  final String dark;
}

Map<String, _ModalColor> _readSemantic(
    Map<String, dynamic> tokens, _Resolver r, List<String> errors) {
  final out = <String, _ModalColor>{};
  final semantic =
      (tokens['color'] as Map<String, dynamic>?)?['semantic'] as Map<String, dynamic>?;
  if (semantic == null) {
    errors.add('schema: color.semantic missing');
    return out;
  }
  semantic.forEach((name, dynamic def) {
    final value = (def as Map<String, dynamic>)[r'$value'];
    if (value is! Map<String, dynamic> ||
        value['light'] == null ||
        value['dark'] == null) {
      errors.add('schema: $name must define both light and dark modes');
      return;
    }
    final light = r.hex(value['light'], '$name.light');
    final dark = r.hex(value['dark'], '$name.dark');
    if (light != null && dark != null) {
      out[name] = _ModalColor(light, dark);
    }
  });
  return out;
}

class _CoursePalette {
  const _CoursePalette(this.light, this.dark, this.containers, this.onContainers);
  final List<String> light;
  final List<String> dark;
  final List<String> containers;
  final List<String> onContainers;
}

_CoursePalette _readCourse(
    Map<String, dynamic> tokens, _Resolver r, List<String> errors) {
  final course =
      (tokens['color'] as Map<String, dynamic>?)?['course'] as Map<String, dynamic>?;
  List<String> readList(dynamic raw, String context) {
    if (raw is! List || raw.length != 10) {
      errors.add('schema: $context must be a 10-entry list (course palette)');
      return const [];
    }
    final out = <String>[];
    for (var i = 0; i < raw.length; i++) {
      final h = r.hex(raw[i], '$context[$i]');
      if (h != null) out.add(h);
    }
    return out;
  }

  if (course == null) {
    errors.add('schema: color.course missing');
    return const _CoursePalette([], [], [], []);
  }
  final colors = (course['colors'] as Map<String, dynamic>)[r'$value']
      as Map<String, dynamic>;
  return _CoursePalette(
    readList(colors['light'], 'course.colors.light'),
    readList(colors['dark'], 'course.colors.dark'),
    readList((course['containers'] as Map<String, dynamic>)[r'$value'],
        'course.containers'),
    readList((course['onContainers'] as Map<String, dynamic>)[r'$value'],
        'course.onContainers'),
  );
}

Map<String, num> _readDimensions(
    Map<String, dynamic> tokens, String group, List<String> errors) {
  final out = <String, num>{};
  final map = tokens[group] as Map<String, dynamic>?;
  if (map == null) {
    errors.add('schema: $group missing');
    return out;
  }
  map.forEach((name, dynamic def) {
    final value = (def as Map<String, dynamic>)[r'$value'];
    if (value is num) {
      out[name] = value;
    } else {
      errors.add('schema: $group.$name must be numeric');
    }
  });
  return out;
}

Map<String, Map<String, num>> _readTypeScale(
    Map<String, dynamic> tokens, List<String> errors) {
  final out = <String, Map<String, num>>{};
  final map = tokens['typeScale'] as Map<String, dynamic>?;
  if (map == null) {
    errors.add('schema: typeScale missing');
    return out;
  }
  map.forEach((name, dynamic def) {
    final value = (def as Map<String, dynamic>)[r'$value'];
    if (value is Map<String, dynamic> &&
        value['size'] is num &&
        value['lineHeight'] is num &&
        value['weight'] is num &&
        value['tracking'] is num) {
      out[name] = value.cast<String, num>();
    } else {
      errors.add(
          'schema: typeScale.$name needs size/lineHeight/weight/tracking');
    }
  });
  return out;
}

// ─────────────────────────────── validations ────────────────────────────────

double _luminance(String hex) {
  double lin(int c) {
    final s = c / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = int.parse(hex.substring(1, 3), radix: 16);
  final g = int.parse(hex.substring(3, 5), radix: 16);
  final b = int.parse(hex.substring(5, 7), radix: 16);
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
}

double _contrast(String fg, String bg) {
  final l1 = _luminance(fg);
  final l2 = _luminance(bg);
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}

void _checkContrast(Map<String, _ModalColor> semantic, List<String> errors) {
  for (final (fg, bg, min) in contrastPairs) {
    final f = semantic[fg];
    final b = semantic[bg];
    if (f == null || b == null) {
      errors.add('contrast: pair $fg/$bg references an unknown token');
      continue;
    }
    for (final (mode, fh, bh) in [
      ('light', f.light, b.light),
      ('dark', f.dark, b.dark)
    ]) {
      final ratio = _contrast(fh, bh);
      if (ratio < min) {
        errors.add(
            'contrast: $fg on $bg ($mode) = ${ratio.toStringAsFixed(2)}:1 '
            '< required $min:1 (DS §1.2)');
      }
    }
  }
}

void _checkMotion(Map<String, num> motion, List<String> errors) {
  for (final name in userBlockingMotion) {
    final ms = motion[name];
    if (ms == null) {
      errors.add('motion: token $name missing');
    } else if (ms > 300) {
      errors.add('motion: $name = ${ms}ms exceeds the 300ms user-blocking cap '
          '(IRR §9.3)');
    }
  }
}

void _checkTextSizes(Map<String, Map<String, num>> typeScale,
    Map<String, num> a11y, List<String> errors) {
  final min = a11y['minTextSize'];
  if (min == null) {
    errors.add('a11y: minTextSize missing');
    return;
  }
  typeScale.forEach((name, spec) {
    if ((spec['size'] as num) < min) {
      errors.add('a11y: typeScale.$name size ${spec['size']} < minTextSize '
          '$min (DS §1.3)');
    }
  });
}

// ───────────────────────────────── emission ─────────────────────────────────

String _dartColor(String hex) {
  final rgb = hex.substring(1, 7);
  final alpha = hex.length == 9 ? hex.substring(7, 9) : 'FF';
  return 'Color(0x$alpha$rgb)';
}

String _num(num v) =>
    v == v.truncate() ? v.truncate().toString() : v.toString();

String _emit(
  String version,
  Map<String, _ModalColor> semantic,
  _CoursePalette course,
  Map<String, num> space,
  Map<String, num> radius,
  Map<String, num> motion,
  Map<String, Map<String, num>> typeScale,
  Map<String, num> a11y,
) {
  final names = semantic.keys.toList();
  final b = StringBuffer();

  b.writeln('// GENERATED FILE — do not edit by hand (FES §6).');
  b.writeln('//');
  b.writeln('// Source: contracts/tokens/tokens.json (v$version)');
  b.writeln(
      '// Regenerate: dart run tool/token_gen.dart   (verify: --verify)');
  b.writeln('// Every visual value in the app comes from here or the theme');
  b.writeln('// built on it — literals elsewhere fail the token-literal lint.');
  b.writeln("import 'package:flutter/material.dart';");
  b.writeln();
  b.writeln('/// Semantic color tokens (Design Spec §1.2) plus the course');
  b.writeln('/// identity palette (§1.1), as a [ThemeExtension] so every');
  b.writeln('/// widget reads colors from the active theme.');
  b.writeln('class NycuColors extends ThemeExtension<NycuColors> {');
  b.writeln('  const NycuColors({');
  for (final n in names) {
    b.writeln('    required this.$n,');
  }
  b.writeln('    required this.courseColors,');
  b.writeln('    required this.courseContainers,');
  b.writeln('    required this.courseOnContainers,');
  b.writeln('  });');
  b.writeln();
  for (final n in names) {
    b.writeln('  final Color $n;');
  }
  b.writeln('  final List<Color> courseColors;');
  b.writeln('  final List<Color> courseContainers;');
  b.writeln('  final List<Color> courseOnContainers;');
  b.writeln();
  for (final (label, mode) in [('light', true), ('dark', false)]) {
    b.writeln('  static const NycuColors $label = NycuColors(');
    for (final n in names) {
      final c = semantic[n]!;
      b.writeln('    $n: ${_dartColor(mode ? c.light : c.dark)},');
    }
    b.writeln('    courseColors: <Color>[');
    for (final h in mode ? course.light : course.dark) {
      b.writeln('      ${_dartColor(h)},');
    }
    b.writeln('    ],');
    b.writeln('    courseContainers: <Color>[');
    for (final h in course.containers) {
      b.writeln('      ${_dartColor(h)},');
    }
    b.writeln('    ],');
    b.writeln('    courseOnContainers: <Color>[');
    for (final h in course.onContainers) {
      b.writeln('      ${_dartColor(h)},');
    }
    b.writeln('    ],');
    b.writeln('  );');
    b.writeln();
  }
  b.writeln('  @override');
  b.writeln('  NycuColors copyWith({');
  for (final n in names) {
    b.writeln('    Color? $n,');
  }
  b.writeln('    List<Color>? courseColors,');
  b.writeln('    List<Color>? courseContainers,');
  b.writeln('    List<Color>? courseOnContainers,');
  b.writeln('  }) {');
  b.writeln('    return NycuColors(');
  for (final n in names) {
    b.writeln('      $n: $n ?? this.$n,');
  }
  b.writeln('      courseColors: courseColors ?? this.courseColors,');
  b.writeln(
      '      courseContainers: courseContainers ?? this.courseContainers,');
  b.writeln(
      '      courseOnContainers: courseOnContainers ?? this.courseOnContainers,');
  b.writeln('    );');
  b.writeln('  }');
  b.writeln();
  b.writeln('  @override');
  b.writeln('  NycuColors lerp(NycuColors? other, double t) {');
  b.writeln('    if (other == null) {');
  b.writeln('      return this;');
  b.writeln('    }');
  b.writeln('    return NycuColors(');
  for (final n in names) {
    b.writeln('      $n: Color.lerp($n, other.$n, t)!,');
  }
  b.writeln(
      '      courseColors: _lerpColors(courseColors, other.courseColors, t),');
  b.writeln(
      '      courseContainers: _lerpColors(courseContainers, other.courseContainers, t),');
  b.writeln(
      '      courseOnContainers: _lerpColors(courseOnContainers, other.courseOnContainers, t),');
  b.writeln('    );');
  b.writeln('  }');
  b.writeln('}');
  b.writeln();
  b.writeln('List<Color> _lerpColors(List<Color> a, List<Color> b, double t) {');
  b.writeln('  return List<Color>.generate(');
  b.writeln('      a.length, (int i) => Color.lerp(a[i], b[i], t)!);');
  b.writeln('}');
  b.writeln();
  b.writeln('/// 4pt spacing scale (Design Spec §1.4).');
  b.writeln('abstract final class Space {');
  space.forEach((n, v) {
    b.writeln('  static const double $n = ${_num(v)};');
  });
  b.writeln('}');
  b.writeln();
  b.writeln('/// Corner radii (Design Spec §1.5).');
  b.writeln('abstract final class Corners {');
  radius.forEach((n, v) {
    b.writeln('  static const double $n = ${_num(v)};');
  });
  b.writeln('}');
  b.writeln();
  b.writeln('/// Motion durations (Design Spec §1.6). `reduced` is the');
  b.writeln('/// Reduce-Motion fallback (all springs collapse to 150ms fades).');
  b.writeln('abstract final class Motion {');
  motion.forEach((n, v) {
    b.writeln('  static const Duration $n = Duration(milliseconds: ${_num(v)});');
  });
  b.writeln('}');
  b.writeln();
  b.writeln('/// One type-scale step (Design Spec §1.3).');
  b.writeln('class TypeSpec {');
  b.writeln('  const TypeSpec(this.size, this.lineHeight, this.weight, this.tracking);');
  b.writeln();
  b.writeln('  final double size;');
  b.writeln('  final double lineHeight;');
  b.writeln('  final FontWeight weight;');
  b.writeln('  final double tracking;');
  b.writeln();
  b.writeln('  /// Line height as the [TextStyle.height] multiplier.');
  b.writeln('  double get height => lineHeight / size;');
  b.writeln('}');
  b.writeln();
  b.writeln('/// Type scale (Design Spec §1.3), 4pt-aligned.');
  b.writeln('abstract final class TypeScale {');
  typeScale.forEach((n, s) {
    b.writeln(
        '  static const TypeSpec $n = TypeSpec(${_num(s['size']!)}, ${_num(s['lineHeight']!)}, FontWeight.w${_num(s['weight']!)}, ${_num(s['tracking']!)});');
  });
  b.writeln('}');
  b.writeln();
  b.writeln('/// Accessibility constants (Design Spec §1.3/§5.1).');
  b.writeln('abstract final class A11y {');
  a11y.forEach((n, v) {
    b.writeln('  static const double $n = ${_num(v)};');
  });
  b.writeln('}');
  return b.toString();
}
