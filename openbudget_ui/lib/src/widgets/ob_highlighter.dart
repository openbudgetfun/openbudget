import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// A highlighter stroke behind [child], like a marker swiped over a figure.
///
/// OpenBudget reserves it for money that is ready to assign: the one number
/// a person should act on. The stroke is decoration; [child] still carries
/// the meaning in words and figures.
class ObHighlighter extends HookWidget {
  const ObHighlighter({
    required this.child,
    this.color,
    this.seed = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    super.key,
  });

  final Widget child;

  /// The stroke colour; defaults to [ObPalette.highlighter].
  final Color? color;

  /// Fixed so the stroke's tilt and ragged ends never change on rebuild.
  final int seed;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _HighlighterPainter(
      color: color ?? Theme.of(context).ob.highlighter,
      seed: seed,
    ),
    child: Padding(padding: padding, child: child),
  );
}

class _HighlighterPainter extends CustomPainter {
  const _HighlighterPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final random = math.Random(seed);
    double jitter(double amount) => (random.nextDouble() - 0.5) * amount;

    // The band covers the lower two thirds of the line, tilted a touch, with
    // ragged ends where the marker landed and lifted.
    final top = size.height * 0.24;
    final bottom = size.height * 0.94;
    final rise = size.height * 0.06;
    final path = Path()
      ..moveTo(jitter(4), top + rise + jitter(2))
      ..quadraticBezierTo(
        size.width / 2,
        top + jitter(3),
        size.width + jitter(4),
        top - rise + jitter(2),
      )
      ..lineTo(size.width + 2 + jitter(3), bottom - rise + jitter(2))
      ..quadraticBezierTo(
        size.width / 2,
        bottom + jitter(3),
        jitter(4) - 2,
        bottom + rise + jitter(2),
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_HighlighterPainter oldDelegate) =>
      color != oldDelegate.color || seed != oldDelegate.seed;
}
