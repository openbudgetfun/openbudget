import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/motion/ob_motion.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// A highlighter stroke swiped behind [child], like a marker over a figure.
///
/// OpenBudget reserves it for money that is ready to assign: the one number
/// a person should act on. The marker swipes on left to right when it first
/// shows (it is simply there with reduced motion). Text on it takes
/// [ObPalette.onHighlighter]. The stroke is decoration; [child] still
/// carries the meaning in words and figures.
class ObHighlighter extends HookWidget {
  const ObHighlighter({
    required this.child,
    this.color,
    this.seed = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.animate = true,
    super.key,
  });

  final Widget child;

  /// The stroke colour; defaults to [ObPalette.highlighter].
  final Color? color;

  /// Fixed so the stroke's tilt and ragged ends never change on rebuild.
  final int seed;

  final EdgeInsetsGeometry padding;

  /// Whether to swipe the marker on when it first shows.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final controller = useObFlourish(
      duration: const Duration(milliseconds: 380),
      play: animate,
    );
    final swipe = useMemoized(
      () => CurvedAnimation(parent: controller, curve: Curves.easeOutQuart),
      [controller],
    );
    useEffect(() => swipe.dispose, [swipe]);
    return CustomPaint(
      painter: ObHighlighterPainter(
        progress: swipe,
        color: color ?? Theme.of(context).ob.highlighter,
        seed: seed,
        direction: Directionality.of(context),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Paints a ragged highlighter band across its box, revealed from the
/// leading edge as [progress] runs to 1.
class ObHighlighterPainter extends CustomPainter {
  ObHighlighterPainter({
    required this.progress,
    required this.color,
    this.seed = 1,
    this.direction = TextDirection.ltr,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color color;
  final int seed;
  final TextDirection direction;

  /// The band across [size]: covering the lower two thirds of a line,
  /// tilted a touch, with ragged ends where the marker landed and lifted.
  static Path band(Size size, {int seed = 1}) {
    final random = math.Random(seed);
    double jitter(double amount) => (random.nextDouble() - 0.5) * amount;
    final top = size.height * 0.2;
    final bottom = size.height * 0.96;
    final rise = size.height * 0.05;
    return Path()
      ..moveTo(jitter(4) - 2, top + rise + jitter(2))
      ..quadraticBezierTo(
        size.width / 2,
        top + jitter(3),
        size.width + 2 + jitter(3),
        top - rise + jitter(2),
      )
      // The square-nib end: a short ragged wedge.
      ..lineTo(size.width + 4 + jitter(2), (top + bottom) / 2 + jitter(3))
      ..lineTo(size.width + 1 + jitter(3), bottom - rise + jitter(2))
      ..quadraticBezierTo(
        size.width / 2,
        bottom + jitter(3),
        jitter(4) - 3,
        bottom + rise + jitter(2),
      )
      ..lineTo(jitter(3) - 5, (top + bottom) / 2 + jitter(3))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value.clamp(0.0, 1.0);
    if (size.isEmpty || t <= 0) {
      return;
    }
    final reveal = (size.width + 12) * t;
    final clip = direction == TextDirection.ltr
        ? Rect.fromLTRB(-8, -8, reveal - 6, size.height + 8)
        : Rect.fromLTRB(
            size.width + 6 - reveal,
            -8,
            size.width + 8,
            size.height + 8,
          );
    canvas
      ..save()
      ..clipRect(clip)
      ..drawPath(band(size, seed: seed), Paint()..color = color)
      ..restore();
  }

  @override
  bool shouldRepaint(ObHighlighterPainter oldDelegate) =>
      color != oldDelegate.color ||
      seed != oldDelegate.seed ||
      direction != oldDelegate.direction ||
      progress != oldDelegate.progress;
}
