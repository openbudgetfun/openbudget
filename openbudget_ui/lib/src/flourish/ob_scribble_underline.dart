import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/motion/ob_motion.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// A hand-drawn underline swept under [child], like a pen flourish under a
/// heading.
///
/// The stroke is drawn on once, left to right, when the widget first shows;
/// with reduced motion it is simply there. It is decoration: [child] still
/// says everything, and the stroke is excluded from semantics.
class ObScribbleUnderline extends HookWidget {
  const ObScribbleUnderline({
    required this.child,
    this.color,
    this.thickness = 4,
    this.width,
    this.seed = 1,
    this.animate = true,
    super.key,
  });

  final Widget child;

  /// The stroke colour; defaults to the action spot ink.
  final Color? color;

  final double thickness;

  /// The stroke's length; defaults to the child's full width.
  final double? width;

  /// Fixed so the stroke's wobble never changes on rebuild.
  final int seed;

  /// Whether to draw the stroke on when it first shows.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final controller = useObFlourish(
      duration: const Duration(milliseconds: 520),
      play: animate,
    );
    final progress = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      [controller],
    );
    useEffect(() => progress.dispose, [progress]);
    return CustomPaint(
      foregroundPainter: ObScribblePainter(
        progress: progress,
        color: color ?? Theme.of(context).ob.action,
        thickness: thickness,
        length: width,
        seed: seed,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: thickness + 4),
        child: child,
      ),
    );
  }
}

/// Paints a scribbled underline along the bottom of its box.
///
/// The stroke dips and rises a little along its length and ends in a small
/// return flick, the way a quick pen underline lands. [progress] draws it on.
class ObScribblePainter extends CustomPainter {
  ObScribblePainter({
    required this.progress,
    required this.color,
    required this.thickness,
    this.length,
    this.seed = 1,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final double thickness;
  final double? length;
  final int seed;

  /// The stroke as a path across [size], before any draw-on trim.
  static Path stroke(
    Size size, {
    double thickness = 4,
    double? length,
    int seed = 1,
  }) {
    final random = math.Random(seed);
    double jitter(double amount) => (random.nextDouble() - 0.5) * amount;
    final span = math.min(length ?? size.width, size.width);
    final y = size.height - thickness / 2 - 1;
    return Path()
      ..moveTo(jitter(2), y + jitter(2))
      ..cubicTo(
        span * 0.3,
        y - 3 + jitter(2),
        span * 0.62,
        y + 2 + jitter(2),
        span + jitter(2),
        y - 2 + jitter(1),
      )
      // The flick: the pen doubles back a little before it lifts.
      ..quadraticBezierTo(
        span * 0.9,
        y + 1.5,
        span * 0.78 + jitter(3),
        y + 2.5 + jitter(1),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value.clamp(0.0, 1.0);
    if (t <= 0 || size.isEmpty) {
      return;
    }
    final path = stroke(size, thickness: thickness, length: length, seed: seed);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    if (t >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    final drawn = Path();
    final metrics = path.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * t;
    for (final metric in metrics) {
      if (remaining <= 0) {
        break;
      }
      drawn.addPath(
        metric.extractPath(0, math.min(remaining, metric.length)),
        Offset.zero,
      );
      remaining -= metric.length;
    }
    canvas.drawPath(drawn, paint);
  }

  @override
  bool shouldRepaint(ObScribblePainter oldDelegate) =>
      color != oldDelegate.color ||
      thickness != oldDelegate.thickness ||
      length != oldDelegate.length ||
      seed != oldDelegate.seed ||
      progress != oldDelegate.progress;
}
