import 'package:flutter/material.dart';

/// A themed card widget with consistent styling.
class ObCard extends StatelessWidget {
  const ObCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Card(
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
}
