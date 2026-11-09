import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/flourish/ob_scribble_underline.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// The heading above a group of rows, with an optional trailing action.
///
/// The title is lettered in the display face with a pen scribble swept
/// under it in the action ink. Announced as a header so screen-reader users
/// can jump between sections.
class ObSectionHeader extends HookWidget {
  const ObSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
    this.underline = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  /// Whether to sweep the scribble under the title.
  final bool underline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final heading = Semantics(
      header: true,
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(color: palette.ink),
      ),
    );
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (underline)
                  ObScribbleUnderline(
                    thickness: 3.4,
                    // The same title always gets the same stroke.
                    seed: title.codeUnits.fold(
                      7,
                      (sum, unit) => (sum * 31 + unit) & 0xFFFFF,
                    ),
                    child: heading,
                  )
                else
                  heading,
                if (subtitle case final text?) ...[
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
