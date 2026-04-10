import 'package:flutter/material.dart';

/// A themed filled button for primary actions.
class ObFilledButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FilledButton(
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
}

/// A themed outlined button for secondary actions.
class ObOutlinedButton extends StatelessWidget {
  const ObOutlinedButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}

/// A themed text button for tertiary actions.
class ObTextButton extends StatelessWidget {
  const ObTextButton({required this.onPressed, required this.child, super.key});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: onPressed, child: child);
  }
}
