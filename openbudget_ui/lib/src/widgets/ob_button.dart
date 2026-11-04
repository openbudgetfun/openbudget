import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:skribble/skribble.dart' show WiredLoadingIndicator;

/// The one deliberate next step on a page: ink fill, paper label.
///
/// While [isLoading], the button is disabled and shows a hand-drawn loader
/// in place of its label; [loadingLabel] is announced instead.
class ObFilledButton extends HookWidget {
  const ObFilledButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.loadingLabel,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: isLoading ? null : onPressed,
    child: isLoading
        ? Semantics(
            label: loadingLabel,
            child: WiredLoadingIndicator(
              size: 20,
              color: Theme.of(context).ob.mutedInk,
            ),
          )
        : child,
  );
}

/// A secondary action: a quiet pen outline on paper.
class ObOutlinedButton extends HookWidget {
  const ObOutlinedButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed, child: child);
}

/// A tertiary action: ink lettering with no outline.
class ObTextButton extends HookWidget {
  const ObTextButton({required this.onPressed, required this.child, super.key});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: onPressed, child: child);
}
