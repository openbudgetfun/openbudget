import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The guidance-only disclaimer pinned under a tax screen.
class TaxDisclaimerBar extends HookWidget {
  const TaxDisclaimerBar({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.sm,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
          ),
        ),
      ),
    );
  }
}
