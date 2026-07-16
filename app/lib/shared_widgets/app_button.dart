import 'package:flutter/material.dart';

import '../app/theme/tokens.g.dart';

/// Button variants (Design Spec §5.1). Variants are enums, never booleans
/// (FA §13 "no boolean soup").
enum AppButtonVariant { primary, secondary, tertiary, destructive }

/// Button sizes (Design Spec §5.1): Large 50pt · Medium 44pt · Small 32pt pill.
enum AppButtonSize { large, medium, small }

/// `[C-Button]` (Design Spec §5.1) — token-only styling, both themes,
/// semantics-labeled, golden-tested. Component-library baseline (INFRA-009);
/// press-scale/focus-ring motion recipes attach with the animation bindings
/// (FA §14) when features consume it.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    super.key,
  });

  final String label;

  /// Disabled when null (40% opacity, DS §5.1).
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Loading state: label swaps to a 20pt spinner, width locked (DS §5.1).
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<NycuColors>()!;

    final (double height, double padH, double radius) = switch (size) {
      AppButtonSize.large => (50, Space.x5, Corners.md),
      AppButtonSize.medium => (44, Space.x4, Corners.sm),
      AppButtonSize.small => (32, Space.x3, Corners.full),
    };

    // Destructive = "Secondary-style with red tokens" (DS §5.1): the fill
    // mirrors the documented accent-tint pattern (accent @14%, DS §1.2
    // bg/accent-tint dark) applied to the danger token; solid red stays
    // reserved for confirm dialogs.
    final (Color? fill, Color fg) = switch (variant) {
      AppButtonVariant.primary => (c.bgAccent, c.textOnAccent),
      AppButtonVariant.secondary => (c.bgAccentTint, c.textAccent),
      AppButtonVariant.tertiary => (null, c.textAccent),
      AppButtonVariant.destructive =>
        (c.textDanger.withOpacity(0.14), c.textDanger),
    };

    final enabled = onPressed != null && !loading;

    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: TypeScale.headline.size,
        height: TypeScale.headline.height,
        fontWeight: TypeScale.headline.weight,
        letterSpacing: TypeScale.headline.tracking,
        color: fg,
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        // Disabled = 40% opacity, no shadow (DS §5.1).
        opacity: enabled || loading ? 1.0 : 0.4,
        child: ConstrainedBox(
          // Min touch target 44×44 always — Small keeps an invisible
          // hit-area (DS §5.1 / A11y.minTapTarget).
          constraints: BoxConstraints(
            minWidth: A11y.minTapTarget,
            minHeight: A11y.minTapTarget,
          ),
          child: Center(
            child: Material(
              color: fill,
              type: fill == null ? MaterialType.transparency : MaterialType.canvas,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: enabled ? onPressed : null,
                borderRadius: BorderRadius.circular(radius),
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return c.statePressed;
                  }
                  if (states.contains(WidgetState.hovered) ||
                      states.contains(WidgetState.focused)) {
                    return c.stateHover;
                  }
                  return null;
                }),
                child: Container(
                  height: height,
                  padding: EdgeInsets.symmetric(horizontal: padH),
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Width-locked loading: the label keeps its layout
                      // (invisible) while the 20pt spinner overlays (DS §5.1).
                      Opacity(
                        opacity: loading ? 0.0 : 1.0,
                        child: labelText,
                      ),
                      if (loading)
                        SizedBox(
                          width: Space.x5,
                          height: Space.x5,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(fg),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
