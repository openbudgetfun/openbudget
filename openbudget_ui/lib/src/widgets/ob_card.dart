import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// A paper card with a hand-drawn outline.
///
/// [tone] lays its wash under the content; text on it stays ink. [onTap]
/// makes the whole card one target.
class ObCard extends HookWidget {
  const ObCard({
    required this.child,
    this.padding,
    this.tone,
    this.onTap,
    this.margin,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ObTone? tone;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;
    return Card(
      color: switch (tone) {
        final tone? => palette.wash(tone),
        null => null,
      },
      margin: margin,
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
