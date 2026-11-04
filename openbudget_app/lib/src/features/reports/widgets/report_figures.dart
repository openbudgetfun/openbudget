import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A supporting label with its money figure underneath.
///
/// Reports repeat this pair in headers and summaries; [alignEnd] keeps a
/// right-hand column flush with its edge.
class ReportFigure extends HookWidget {
  const ReportFigure({
    required this.label,
    required this.amount,
    this.tone = ObTone.neutral,
    this.alignEnd = false,
    super.key,
  });

  final String label;
  final String amount;
  final ObTone tone;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
        ObAmount(amount, tone: tone, style: theme.textTheme.titleSmall),
      ],
    );
  }
}
