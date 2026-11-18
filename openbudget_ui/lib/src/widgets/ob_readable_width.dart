import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Keeps a scrolling page in a readable column on wide windows.
///
/// The builder receives [padding] widened on both sides so the content is
/// never more than [maxWidth] across. The scroll view itself still spans the
/// window, so the wheel, the scrollbar and pull-to-refresh work anywhere on
/// it, not only over the column. Phones get [padding] unchanged.
class ObReadableWidth extends HookWidget {
  const ObReadableWidth({
    required this.builder,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 760,
    super.key,
  });

  /// Builds the scroll view with the padding to give it.
  final Widget Function(BuildContext context, EdgeInsets padding) builder;

  /// The padding on a narrow window.
  final EdgeInsets padding;

  /// The widest the content gets, padding included.
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final gutter = constraints.hasBoundedWidth
          ? math.max(0, (constraints.maxWidth - maxWidth) / 2).toDouble()
          : 0.0;
      return builder(
        context,
        padding + EdgeInsets.symmetric(horizontal: gutter),
      );
    },
  );
}
