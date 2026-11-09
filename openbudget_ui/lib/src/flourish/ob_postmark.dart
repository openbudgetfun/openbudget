import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/motion/ob_motion.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';
import 'package:openbudget_ui/src/theme/openbudget_theme.dart';

/// The arc a stamped flourish lands on: it drops from above, slightly too
/// big, and settles with a small bounce, tilted the way a hand stamps.
Widget _stampIn({
  required Animation<double> progress,
  required double tilt,
  required Widget child,
}) => AnimatedBuilder(
  animation: progress,
  child: child,
  builder: (context, stamp) {
    final t = progress.value;
    final landed = Curves.easeOutBack.transform(t);
    final scale = 1.55 - 0.55 * landed;
    final opacity = (t / 0.35).clamp(0.0, 1.0);
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: tilt * (0.4 + 0.6 * landed),
        child: Transform.scale(scale: scale, child: stamp),
      ),
    );
  },
);

/// A rubber-stamped postmark: two inked rings around a short word and a
/// date, with cancellation waves trailing off to one side.
///
/// OpenBudget stamps a postmark on things that are done: a fully funded
/// envelope, a month that balances, a reconciled account. It lands with a
/// small stamp-in when it first shows (still, with reduced motion) and is
/// announced as [label] and [detail].
class ObPostmark extends HookWidget {
  const ObPostmark({
    required this.label,
    this.detail,
    this.tone = ObTone.brand,
    this.size = 72,
    this.waves = true,
    this.tilt = -0.17,
    this.seed = 3,
    this.animate = true,
    super.key,
  });

  /// The stamped word, such as "Funded". Keep it short.
  final String label;

  /// A second line, usually a date or a currency code.
  final String? detail;

  /// The ink: the tone's hue, which reads at AA on paper.
  final ObTone tone;

  /// The diameter of the rings.
  final double size;

  /// Whether to trail cancellation waves after the rings.
  final bool waves;

  /// The stamp's tilt, in radians.
  final double tilt;

  final int seed;

  /// Whether to stamp in when it first shows.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.ob.hue(tone);
    final controller = useObFlourish(
      duration: const Duration(milliseconds: 420),
      play: animate,
    );
    final width = waves ? size * 1.9 : size;
    final style = ObTextStyles.stamp(theme.textTheme.labelSmall).copyWith(
      color: ink,
      fontSize: size * 0.17,
    );
    return Semantics(
      label: [label, ?detail].join(', '),
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: size,
        child: _stampIn(
          progress: controller,
          tilt: tilt,
          child: CustomPaint(
            painter: _PostmarkPainter(
              ink: ink,
              diameter: size,
              waves: waves,
              seed: seed,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: style,
                      ),
                      if (detail case final line?) ...[
                        SizedBox(height: size * 0.05),
                        Text(
                          line.toUpperCase(),
                          maxLines: 1,
                          softWrap: false,
                          style: style.copyWith(fontSize: size * 0.13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostmarkPainter extends CustomPainter {
  const _PostmarkPainter({
    required this.ink,
    required this.diameter,
    required this.waves,
    required this.seed,
  });

  final Color ink;
  final double diameter;
  final bool waves;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Size.square(diameter);
    ObPen.circle(canvas, ring, color: ink, strokeWidth: 2.4, seed: seed);
    final inner = diameter * 0.14;
    canvas
      ..save()
      ..translate(inner, inner);
    ObPen.circle(
      canvas,
      Size.square(diameter - inner * 2),
      color: ink,
      strokeWidth: 1.4,
      seed: seed + 1,
    );
    canvas.restore();
    if (!waves) {
      return;
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = ink;
    final start = diameter * 0.92;
    final end = size.width;
    for (var line = 0; line < 3; line++) {
      final y = diameter * (0.32 + line * 0.18);
      final path = Path()..moveTo(start, y);
      for (var x = start; x <= end; x += 2) {
        path.lineTo(
          x,
          y +
              math.sin((x - start) / (diameter * 0.09) + line) *
                  diameter *
                  0.04,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_PostmarkPainter oldDelegate) =>
      ink != oldDelegate.ink ||
      diameter != oldDelegate.diameter ||
      waves != oldDelegate.waves ||
      seed != oldDelegate.seed;
}

/// A wax seal pressed onto something finished: a sunflower coin of wax
/// with an embossed tick.
///
/// A full envelope is sealed with one. It stamps in when it first shows
/// (still, with reduced motion), and is announced as
/// [semanticLabel] when one is given.
class ObSeal extends HookWidget {
  const ObSeal({
    this.size = 28,
    this.semanticLabel,
    this.animate = true,
    this.seed = 5,
    super.key,
  });

  final double size;
  final String? semanticLabel;
  final bool animate;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final controller = useObFlourish(
      duration: const Duration(milliseconds: 380),
      play: animate,
    );
    final seal = SizedBox.square(
      dimension: size,
      child: _stampIn(
        progress: controller,
        tilt: -0.12,
        child: CustomPaint(
          painter: ObSealPainter(
            wax: palette.highlighter,
            ink: palette.onHighlighter,
            seed: seed,
          ),
        ),
      ),
    );
    if (semanticLabel case final label?) {
      return Semantics(label: label, image: true, child: seal);
    }
    return ExcludeSemantics(child: seal);
  }
}

/// Paints a wax seal filling its box: a blobby disc of [wax] with an ink
/// edge, a pressed inner ring, and a tick.
class ObSealPainter extends CustomPainter {
  const ObSealPainter({required this.wax, required this.ink, this.seed = 5});

  final Color wax;
  final Color ink;
  final int seed;

  /// The seal's blobby rim, the way wax spreads under a stamp.
  static Path rim(Size size, {int seed = 5}) {
    final random = math.Random(seed);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 * 0.92;
    const lobes = 9;
    final points = [
      for (var i = 0; i < lobes; i++)
        Offset.fromDirection(
          i / lobes * math.pi * 2,
          radius * (0.9 + random.nextDouble() * 0.1),
        ),
    ];
    final path = Path();
    for (var i = 0; i < lobes; i++) {
      final current = center + points[i];
      final next = center + points[(i + 1) % lobes];
      final mid = Offset.lerp(current, next, 0.5)!;
      if (i == 0) {
        path.moveTo(mid.dx, mid.dy);
      }
      final following = Offset.lerp(
        next,
        center + points[(i + 2) % lobes],
        0.5,
      )!;
      path.quadraticBezierTo(next.dx, next.dy, following.dx, following.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    final outline = rim(size, seed: seed);
    final stroke = math.max(1.2, size.shortestSide * 0.07);
    canvas
      ..drawPath(outline, Paint()..color = wax)
      ..drawPath(
        outline,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeJoin = StrokeJoin.round
          ..color = ink,
      )
      ..drawCircle(
        size.center(Offset.zero),
        size.shortestSide * 0.29,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke * 0.6
          ..color = ink.withValues(alpha: 0.55),
      );
    final s = size.shortestSide;
    final o = size.center(Offset.zero) - Offset(s / 2, s / 2);
    canvas.drawPath(
      Path()
        ..moveTo(o.dx + s * 0.36, o.dy + s * 0.52)
        ..lineTo(o.dx + s * 0.46, o.dy + s * 0.62)
        ..lineTo(o.dx + s * 0.65, o.dy + s * 0.4),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = ink,
    );
  }

  @override
  bool shouldRepaint(ObSealPainter oldDelegate) =>
      wax != oldDelegate.wax ||
      ink != oldDelegate.ink ||
      seed != oldDelegate.seed;
}

/// A currency shown as a tiny postage stamp: the code lettered on a spot-ink
/// stamp with perforated edges.
///
/// Money in OpenBudget travels between currencies the way post travels
/// between countries, so every currency badge is a stamp. Each code always
/// gets the same spot ink.
class ObCurrencyStamp extends HookWidget {
  const ObCurrencyStamp(this.code, {this.semanticLabel, super.key});

  /// The ISO 4217 code, such as "GBP".
  final String code;

  /// A spoken form, such as "Pounds sterling"; defaults to [code].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final index = code.codeUnits.fold<int>(0, (sum, unit) => sum * 31 + unit);
    final fill = palette.spot(index.abs());
    return Semantics(
      label: semanticLabel ?? code,
      excludeSemantics: true,
      child: CustomPaint(
        painter: _PerforatedPainter(fill: fill, ink: palette.onAction),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
          child: Text(
            code.toUpperCase(),
            maxLines: 1,
            style: ObTextStyles.stamp(
              theme.textTheme.labelSmall,
            ).copyWith(color: palette.onAction, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _PerforatedPainter extends CustomPainter {
  const _PerforatedPainter({required this.fill, required this.ink});

  final Color fill;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    const hole = 1.6;
    const pitch = 5.0;
    final body = Path()..addRect(Offset.zero & size);
    final holes = Path();
    void row(double y) {
      for (var x = pitch / 2; x < size.width; x += pitch) {
        holes.addOval(Rect.fromCircle(center: Offset(x, y), radius: hole));
      }
    }

    void column(double x) {
      for (var y = pitch / 2; y < size.height; y += pitch) {
        holes.addOval(Rect.fromCircle(center: Offset(x, y), radius: hole));
      }
    }

    row(0);
    row(size.height);
    column(0);
    column(size.width);
    canvas
      ..drawPath(
        Path.combine(PathOperation.difference, body, holes),
        Paint()..color = fill,
      )
      ..drawRect(
        (Offset.zero & size).deflate(3.2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = ink.withValues(alpha: 0.7),
      );
  }

  @override
  bool shouldRepaint(_PerforatedPainter oldDelegate) =>
      fill != oldDelegate.fill || ink != oldDelegate.ink;
}
