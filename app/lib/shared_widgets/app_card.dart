import 'package:flutter/material.dart';

import '../app/theme/tokens.g.dart';

/// Card variants (Design Spec §5.2).
enum AppCardVariant { default_, interactive, sunken }

/// `[C-Card]` (Design Spec §5.2) — base surface: `bg/surface` fill,
/// `radius/lg`, `shadow/card` in light / 1px `border/subtle` in dark (flat,
/// Linear-style), padding `space/4`, internal gap `space/3`. Component-library
/// baseline (INFRA-009); the tablet `space/5` padding step arrives with the
/// responsive layout classes (FA §8).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.default_,
    this.overline,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;

  /// Header slot: overline rendered `type/caption-2` uppercase
  /// `text/tertiary` (DS §5.2).
  final String? overline;

  /// Optional trailing header action ("View All →", `type/subhead` accent).
  final Widget? trailing;

  /// Interactive cards accept a tap (hover raise arrives with desktop polish).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<NycuColors>()!;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final fill = variant == AppCardVariant.sunken ? c.bgSurfaceSunken : c.bgSurface;

    final content = Padding(
      padding: const EdgeInsets.all(Space.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (overline != null) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    overline!.toUpperCase(),
                    style: TextStyle(
                      fontSize: TypeScale.caption2.size,
                      height: TypeScale.caption2.height,
                      fontWeight: TypeScale.caption2.weight,
                      letterSpacing: TypeScale.caption2.tracking,
                      color: c.textTertiary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: Space.x3),
          ],
          child,
        ],
      ),
    );

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(Corners.lg),
        // Dark mode prefers borders over shadows (DS §1.5); light default
        // cards carry shadow/card = Y2 B8 gray/900 @6% (textPrimary in light
        // IS gray/900 — the documented shadow base).
        border: dark || variant == AppCardVariant.sunken
            ? Border.all(color: c.borderSubtle)
            : null,
        boxShadow: !dark && variant != AppCardVariant.sunken
            ? <BoxShadow>[
                BoxShadow(
                  color: c.textPrimary.withOpacity(0.06),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: content,
    );

    if (variant != AppCardVariant.interactive || onTap == null) {
      return surface;
    }
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Corners.lg),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.statePressed;
          }
          if (states.contains(WidgetState.hovered)) {
            return c.stateHover;
          }
          return null;
        }),
        child: surface,
      ),
    );
  }
}
