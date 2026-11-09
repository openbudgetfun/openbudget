import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/openbudget_theme.dart';
import 'package:openbudget_ui/src/widgets/ob_highlighter.dart';

/// A money figure in the linear face, with tabular digits.
///
/// [text] is already formatted for its currency by the caller; this widget
/// only sets it. [tone] colours the figure, and [highlighted] swipes the
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
      style:
          ObTextStyles.amount(
            style ?? theme.textTheme.titleMedium,
          ).copyWith(
            color: highlighted ? palette.onHighlighter : palette.hue(tone),
          ),
    );
    if (!highlighted) {
      return figure;
    }
    return ObHighlighter(child: figure);
  }
}

/// The one big figure a screen is about, lettered in the display face.
///
/// The minor units after the decimal mark (the last `.` or `,` followed by
/// exactly two digits) are set smaller and raised, the way a price is
/// lettered on a shop sign, so the whole amount reads first. Figures
/// without two minor digits, such as yen, are set whole. [text] is already
/// formatted; the figure is announced as [semanticsLabel] or [text].
class ObHeroAmount extends HookWidget {
  const ObHeroAmount(
    this.text, {
    this.tone = ObTone.neutral,
    this.style,
    this.semanticsLabel,
    super.key,
  });

  final String text;
  final ObTone tone;

  /// The base style; defaults to the theme's `displayMedium`.
  final TextStyle? style;

  final String? semanticsLabel;

  /// Splits [text] into the whole figure and its minor units, such as
  /// `£1,204` and `.50`. The second part is empty when there are none.
  static (String, String) split(String text) {
    final match = RegExp(r'[.,]\d{2}(?!\d)\D*$').firstMatch(text);
    if (match == null) {
      return (text, '');
    }
    return (text.substring(0, match.start), text.substring(match.start));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final base = ObTextStyles.heroAmount(
      style ?? theme.textTheme.displayMedium,
    ).copyWith(color: palette.hue(tone));
    final (whole, minor) = split(text);
    final fontSize = base.fontSize ?? 46;
    return Semantics(
      label: semanticsLabel ?? text,
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(
            style: base,
            children: [
              TextSpan(text: whole),
              if (minor.isNotEmpty)
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Padding(
                    padding: EdgeInsets.only(top: fontSize * 0.08, left: 2),
                    child: Text(
                      minor,
                      style: base.copyWith(fontSize: fontSize * 0.5),
                    ),
                  ),
                ),
            ],
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}
