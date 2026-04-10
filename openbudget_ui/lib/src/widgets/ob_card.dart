import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A themed card widget with consistent styling.
class ObCard extends HookWidget {
  const ObCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Card(
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
}
