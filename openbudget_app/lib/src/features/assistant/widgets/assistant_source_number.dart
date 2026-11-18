import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A source's number in the sources sheet, drawn like the citation marks in a
/// reply: the number on a spot-ink wash with a thin rule.
///
/// [highlighted] marks the source the sheet was opened from.
class AssistantSourceNumber extends HookWidget {
  const AssistantSourceNumber({
    required this.number,
    required this.semanticLabel,
    this.highlighted = false,
    super.key,
  });

  final int number;

  /// What a screen reader says, such as "Source 2".
  final String semanticLabel;

  /// Whether this is the source a sources sheet was opened from.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: Container(
          constraints: const BoxConstraints(minWidth: 16),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          // A flat wash and a thin rule rather than the rough pen: at this
          // size the pen's wobble would swamp the number.
          decoration: BoxDecoration(
            color: highlighted ? palette.highlighter : palette.brandWash,
            border: Border.all(color: palette.quietPen),
            borderRadius: BorderRadius.circular(RadiusTokens.sm - 2),
          ),
          child: Text(
            NumberFormat.decimalPattern().format(number),
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: highlighted ? palette.onHighlighter : palette.ink,
              fontWeight: FontWeight.w700,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
