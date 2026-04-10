import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A themed filled button for primary actions.
class ObFilledButton extends HookWidget {
  const ObFilledButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
}

/// A themed outlined button for secondary actions.
class ObOutlinedButton extends HookWidget {
  const ObOutlinedButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => OutlinedButton(onPressed: onPressed, child: child);
}

/// A themed text button for tertiary actions.
class ObTextButton extends HookWidget {
  const ObTextButton({required this.onPressed, required this.child, super.key});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => TextButton(onPressed: onPressed, child: child);
}
