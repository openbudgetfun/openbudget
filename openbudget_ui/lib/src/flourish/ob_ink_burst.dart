import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/motion/ob_motion.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// A small burst of spot ink around [child] when money lands.
///
/// The burst plays each time [trigger] changes after the first build, never
/// on mount, so it marks a moment the person caused: an envelope filled, a
/// transfer done, a month balanced. Dots, dashes and rings of every spot
/// ink fly out from the centre and fade. With reduced motion nothing plays;
/// whatever announced the moment in words still does.
class ObInkBurst extends HookWidget {
  const ObInkBurst({
    required this.child,
    required this.trigger,
    this.pieces = 16,
    this.reach = 34,
    this.seed = 7,
    super.key,
  }) : assert(pieces > 0, 'a burst needs at least one piece');

  final Widget child;

  /// Plays the burst whenever it changes. Pass the value that changing
  /// marks the moment, such as a funded count.
  final Object? trigger;

  final int pieces;

  /// How far past the child's edge the ink flies.
  final double reach;

  final int seed;

  /// How long one burst lasts.
  static const Duration duration = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final allowed = obMotionAllowed(context);
    final controller = useAnimationController(
      duration: duration,
      initialValue: 1,
    );
    final mounted = useRef(false);
    useEffect(() {
      if (!mounted.value) {
        mounted.value = true;
        return null;
      }
      if (allowed) {
        controller.forward(from: 0);
      }
      return null;
    }, [trigger]);
    return CustomPaint(
      foregroundPainter: ObInkBurstPainter(
        progress: controller,
        inks: [...palette.spots, palette.ink],
        pieces: pieces,
        reach: reach,
        seed: seed,
      ),
      child: child,
    );
  }
}

/// Paints one frame of an [ObInkBurst].
class ObInkBurstPainter extends CustomPainter {
  ObInkBurstPainter({
    required this.progress,
    required this.inks,
    this.pieces = 16,
    this.reach = 34,
    this.seed = 7,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<Color> inks;
  final int pieces;
  final double reach;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1 || inks.isEmpty) {
      return;
    }
    final random = math.Random(seed);
    final center = size.center(Offset.zero);
    final start = size.shortestSide * 0.35;
    final flight = Curves.easeOutCubic.transform(t);
    final fade = 1 - Curves.easeInQuad.transform(t);
    for (var i = 0; i < pieces; i++) {
      final angle =
          i / pieces * math.pi * 2 + (random.nextDouble() - 0.5) * 0.5;
      final distance =
          start +
          (size.shortestSide * 0.2 + reach) *
              (0.55 + random.nextDouble() * 0.45) *
              flight;
      final direction = Offset.fromDirection(angle);
      final at = center + direction * distance;
      final paint = Paint()
        ..color = inks[i % inks.length].withValues(alpha: fade)
        ..strokeCap = StrokeCap.round;
      switch (i % 3) {
        case 0:
          canvas.drawCircle(at, 3.6 * (1 - t * 0.4), paint);
        case 1:
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2;
          canvas.drawLine(at - direction * 5, at + direction * 5, paint);
        default:
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;
          canvas.drawCircle(at, 4.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ObInkBurstPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      pieces != oldDelegate.pieces ||
      reach != oldDelegate.reach ||
      seed != oldDelegate.seed ||
      !_same(inks, oldDelegate.inks);

  static bool _same(List<Color> a, List<Color> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
