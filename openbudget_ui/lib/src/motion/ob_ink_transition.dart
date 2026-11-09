import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';

/// Brings every route in behind a stroke of ink.
///
/// On Android, the web and desktop, the new page is rolled on from the
/// leading edge like a brayer of ink: its edge is a wavering brush stroke
/// with the teal overprint a step behind. On iOS and macOS the page keeps
/// the native slide, and with it the swipe back, but its leading edge is
/// inked as it travels.
///
/// When the platform asks for reduced motion the page simply fades in.
class ObInkPageTransitionsBuilder extends PageTransitionsBuilder {
  const ObInkPageTransitionsBuilder();

  static const _cupertino = CupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 460);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: animation, child: child);
    }
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return _cupertino.buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        ObInkEdge(animation: animation, child: child),
      );
    }
    return ObInkWipe(animation: animation, child: child);
  }
}

/// Reveals [child] behind a wavering ink edge that sweeps across it as
/// [animation] runs from 0 to 1.
class ObInkWipe extends HookWidget {
  const ObInkWipe({required this.animation, required this.child, super.key});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final curved = useMemoized(
      () => CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic.flipped,
      ),
      [animation],
    );
    useEffect(() => curved.dispose, [curved]);
    final direction = Directionality.of(context);
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, page) {
        final progress = curved.value;
        if (progress >= 1) {
          return page!;
        }
        return CustomPaint(
          foregroundPainter: _InkWipeEdgePainter(
            progress: progress,
            ink: palette.ink,
            overprint: palette.overprint,
            direction: direction,
          ),
          child: ClipPath(
            clipper: _InkWipeClipper(progress: progress, direction: direction),
            child: page,
          ),
        );
      },
    );
  }
}

/// Inks the leading edge of a page while [animation] carries it in.
class ObInkEdge extends HookWidget {
  const ObInkEdge({required this.animation, required this.child, super.key});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final direction = Directionality.of(context);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, page) {
        final progress = animation.value;
        if (progress <= 0 || progress >= 1) {
          return page!;
        }
        // The stroke is strongest mid-flight and fades as the page lands.
        final strength = math.sin(progress * math.pi);
        return CustomPaint(
          foregroundPainter: _InkEdgePainter(
            ink: palette.ink.withValues(alpha: 0.9 * strength),
            overprint: palette.overprint.withValues(alpha: strength),
            direction: direction,
          ),
          child: page,
        );
      },
    );
  }
}

/// The x position of the wavering edge at height [y], for a sweep at
/// [progress] across a box of [size].
double _edgeX(Size size, double y, double progress) {
  final overshoot = size.width * 0.18;
  final base = -overshoot + (size.width + overshoot * 2) * progress;
  final wave =
      math.sin(y / 46 + progress * 3) * 10 + math.sin(y / 17 + 1.3) * 4;
  // The brush leans: the top of the stroke leads the bottom.
  final lean = (0.5 - y / math.max(size.height, 1)) * overshoot;
  return base + wave + lean;
}

List<Offset> _edgePoints(Size size, double progress, {double shift = 0}) => [
  for (var y = 0.0; y <= size.height + 12; y += 12)
    Offset(_edgeX(size, y, progress) + shift, y),
];

Path _edgePath(Size size, double progress, {double shift = 0}) =>
    Path()..addPolygon(_edgePoints(size, progress, shift: shift), false);

Path _mirror(Path path, Size size, TextDirection direction) =>
    direction == TextDirection.ltr
    ? path
    : path.transform(
        (Matrix4.identity()
              ..translateByDouble(size.width, 0, 0, 1)
              ..scaleByDouble(-1, 1, 1, 1))
            .storage,
      );

class _InkWipeClipper extends CustomClipper<Path> {
  const _InkWipeClipper({required this.progress, required this.direction});

  final double progress;
  final TextDirection direction;

  @override
  Path getClip(Size size) {
    final region = Path()
      ..addPolygon([
        const Offset(-1, 0),
        ..._edgePoints(size, progress),
        Offset(-1, size.height + 12),
      ], true);
    return _mirror(region, size, direction);
  }

  @override
  bool shouldReclip(_InkWipeClipper oldClipper) =>
      progress != oldClipper.progress || direction != oldClipper.direction;
}

class _InkWipeEdgePainter extends CustomPainter {
  const _InkWipeEdgePainter({
    required this.progress,
    required this.ink,
    required this.overprint,
    required this.direction,
  });

  final double progress;
  final Color ink;
  final Color overprint;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }
    // The teal overprint trails the ink, off-register.
    canvas
      ..drawPath(
        _mirror(_edgePath(size, progress, shift: -9), size, direction),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = overprint,
      )
      ..drawPath(
        _mirror(_edgePath(size, progress), size, direction),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = ink,
      );
  }

  @override
  bool shouldRepaint(_InkWipeEdgePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      ink != oldDelegate.ink ||
      overprint != oldDelegate.overprint ||
      direction != oldDelegate.direction;
}

class _InkEdgePainter extends CustomPainter {
  const _InkEdgePainter({
    required this.ink,
    required this.overprint,
    required this.direction,
  });

  final Color ink;
  final Color overprint;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    Path edge(double x) {
      final path = Path()..moveTo(x, 0);
      for (var y = 12.0; y <= size.height + 12; y += 12) {
        path.lineTo(x + math.sin(y / 23) * 1.6 + math.sin(y / 61) * 2.4, y);
      }
      return _mirror(path, size, direction);
    }

    canvas
      ..drawPath(
        edge(-3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = overprint,
      )
      ..drawPath(
        edge(0),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = ink,
      );
  }

  @override
  bool shouldRepaint(_InkEdgePainter oldDelegate) =>
      ink != oldDelegate.ink ||
      overprint != oldDelegate.overprint ||
      direction != oldDelegate.direction;
}
