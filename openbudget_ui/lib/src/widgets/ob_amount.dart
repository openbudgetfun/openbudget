import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/openbudget_theme.dart';
import 'package:openbudget_ui/src/widgets/ob_highlighter.dart';

/// A money figure in the numeral face, with tabular digits.
///
/// [text] is already formatted for its currency by the caller; this widget
/// only sets it. [tone] colours the figure, and [highlighted] draws the
/// ready-to-assign highlighter behind it. Colour is never the only signal,
/// so a toned amount sits next to words that say what it means.
class ObAmount extends HookWidget {
  const ObAmount(
    this.text, {
    this.tone = ObTone.neutral,
    this.style,
    this.highlighted = false,
    this.semanticsLabel,
    this.textAlign,
    super.key,
  });

  final String text;
  final ObTone tone;

  /// The base style; defaults to the theme's `titleMedium`.
  final TextStyle? style;

  final bool highlighted;

  /// A spoken form of [text], such as "minus twelve dollars".
  final String? semanticsLabel;

  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final figure = Text(
      text,
      semanticsLabel: semanticsLabel,
      textAlign: textAlign,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: ObTextStyles.amount(style ?? theme.textTheme.titleMedium)
          .copyWith(color: highlighted ? palette.ink : palette.hue(tone)),
    );
    if (!highlighted) {
      return figure;
    }
    return ObHighlighter(child: figure);
  }
}
