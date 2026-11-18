import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/color_tokens.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_rough_decoration.dart';

/// A short status label on its tone's wash, such as "Overspent".
///
/// A pill of wash with a pencil edge. The label is ink on the wash so it
/// always reads; a small dot, or the optional [icon], takes the tone's hue.
/// The word carries the meaning, never the colour.
class ObToneChip extends HookWidget {
  const ObToneChip({
    required this.label,
    this.tone = ObTone.neutral,
    this.icon,
    this.seed = 21,
    super.key,
  });

  final String label;
  final ObTone tone;
  final Widget? icon;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Container(
      // Tight enough that a dotted chip is no wider than a bare one used to
      // be, so it fits beside an amount in a 390pt-wide row.
      padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
      decoration: ObRoughDecoration(
        color: palette.wash(tone),
        outline: palette.quietPen,
        radius: RadiusTokens.pill,
        strokeWidth: 1.4,
        seed: seed,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon case final glyph?)
            IconTheme.merge(
              data: IconThemeData(color: palette.hue(tone), size: 16),
              child: glyph,
            )
          else
            ExcludeSemantics(
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: palette.hue(tone),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}
