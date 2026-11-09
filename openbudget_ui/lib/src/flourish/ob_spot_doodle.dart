import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/flourish/ob_postmark.dart';
import 'package:openbudget_ui/src/motion/ob_motion.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:skribble/skribble.dart';

/// A doodle inked over a blot of spot colour, printed slightly
/// off-register.
///
/// Empty states lead with one, so an empty screen reads as an invitation
/// rather than a gap. The blot settles in and the doodle draws itself on
/// when it first shows; with reduced motion both are simply there. It is
/// decoration, silent to screen readers.
class ObSpotDoodle extends HookWidget {
  const ObSpotDoodle({
    required this.kind,
    this.spot,
    this.size = 112,
    this.seed = 3,
    this.animate = true,
    super.key,
  });

  final WiredDoodleKind kind;

  /// The blot's spot ink; defaults to the action pink.
  final Color? spot;

  final double size;
  final int seed;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final controller = useObFlourish(
      duration: const Duration(milliseconds: 900),
      play: animate,
    );
    final settle = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
      [controller],
    );
    final draw = useMemoized(
      () => CurvedAnimation(
        parent: controller,
        curve: const Interval(0.25, 1, curve: Curves.easeInOut),
      ),
      [controller],
    );
    useEffect(
      () => () {
        settle.dispose();
        draw.dispose();
      },
      [settle, draw],
    );
    final allowed = obMotionAllowed(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: settle,
              child: CustomPaint(
                size: Size.square(size),
                painter: _BlotPainter(
                  fill: spot ?? palette.action,
                  ink: palette.ink,
                  seed: seed,
                ),
              ),
            ),
            WiredDrawTransition(
              progress: allowed ? draw : const AlwaysStoppedAnimation(1),
              child: WiredDoodle(
                kind: kind,
                size: size * 0.6,
                seed: seed,
                strokeWidth: 2.6,
                color: palette.onAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlotPainter extends CustomPainter {
  const _BlotPainter({
    required this.fill,
    required this.ink,
    required this.seed,
  });

  final Color fill;
  final Color ink;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final blot = ObSealPainter.rim(size * 0.92, seed: seed);
    canvas
      ..save()
      ..translate(size.width * 0.04, size.height * 0.04)
      ..drawPath(blot, Paint()..color = fill)
      // The ink plate lands a few points off the colour.
      ..translate(-size.width * 0.035, -size.height * 0.03)
      ..drawPath(
        blot,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ink.withValues(alpha: 0.75),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_BlotPainter oldDelegate) =>
      fill != oldDelegate.fill ||
      ink != oldDelegate.ink ||
      seed != oldDelegate.seed;
}
