import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';
import 'package:openbudget_ui/src/theme/ob_rough_border.dart';

/// A paper card with a hand-drawn outline.
///
/// [tone] lays its wash under the content; text on it stays ink. [onTap]
/// makes the whole card one target.
///
/// A [raised] card is a sticker: a firm ink outline over a hard print
/// shadow, for the one card a screen is about. [shadow] picks the shadow's
/// ink; it defaults to [ObPalette.printShadow].
class ObCard extends HookWidget {
  const ObCard({
    required this.child,
    this.padding,
    this.tone,
    this.onTap,
    this.margin,
    this.raised = false,
    this.shadow,
    this.seed = 3,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ObTone? tone;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool raised;
  final Color? shadow;

  /// Fixed so the outline's wobble never changes on rebuild.
  final int seed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;
    final ShapeBorder? shape = raised
        ? ObStickerBorder(
            side: BorderSide(color: palette.ink, width: ObPen.strokeWidth),
            radius: RadiusTokens.lg,
            seed: seed,
            shadowColor: shadow ?? palette.printShadow,
            shadowOffset: const Offset(5, 5),
          )
        : null;
    return Card(
      color: switch (tone) {
        final tone? => palette.wash(tone),
        null => null,
      },
      shape: shape,
      margin: margin,
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(customBorder: shape, onTap: onTap, child: content),
    );
  }
}
