import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';

/// A paper envelope that fills with pencil as money goes in.
///
/// [fraction] is how much of the envelope's target is in place: 0 is empty,
/// 1 is full. A full envelope gets a wax seal at the point of its flap.
/// An overspent envelope fills completely in the overspent tone and its flap
/// is drawn open, so the state reads without colour.
///
/// [semanticLabel] says the same thing in words, such as "80% funded".
class ObEnvelopeGauge extends HookWidget {
  const ObEnvelopeGauge({
    required this.fraction,
    required this.semanticLabel,
    this.tone = ObTone.funded,
    this.overspent = false,
    this.width = 44,
    this.seed = 1,
    super.key,
  }) : assert(width > 0, 'width must be positive');

  final double fraction;
  final String semanticLabel;

  /// The tone of the funded share. Ignored when [overspent].
  final ObTone tone;

  final bool overspent;

  /// The envelope is drawn at a 10:7 letter proportion, with headroom above
  /// it for an open flap.
  final double width;

  final int seed;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final target = overspent
        ? 1.0
        : (fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 420);
    final fillTone = overspent ? ObTone.overspent : tone;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: width,
        height: width * (_bodyAspect + _flapRoom),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: target),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => CustomPaint(
            painter: _EnvelopePainter(
              fraction: value,
              ink: palette.ink,
              wash: palette.wash(fillTone),
              hue: palette.hue(fillTone),
              sealed: !overspent && target >= 1,
              open: overspent,
              seed: seed,
            ),
          ),
        ),
      ),
    );
  }
}

const double _bodyAspect = 0.7;
const double _flapRoom = 0.16;

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter({
    required this.fraction,
    required this.ink,
    required this.wash,
    required this.hue,
    required this.sealed,
    required this.open,
    required this.seed,
  });

  final double fraction;
  final Color ink;
  final Color wash;
  final Color hue;
  final bool sealed;
  final bool open;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.8;
    final inset = ObPen.inset(strokeWidth: strokeWidth);
    final headroom = size.width * _flapRoom;
    final bodySize = Size(size.width, size.height - headroom);
    final body = (Offset(0, headroom) & bodySize).deflate(inset);
    final radius = bodySize.shortestSide * 0.12;

    if (fraction > 0) {
      final top = body.bottom - body.height * fraction;
      final filled = Rect.fromLTRB(body.left, top, body.right, body.bottom);
      canvas
        ..save()
        ..clipRRect(RRect.fromRectAndRadius(body, Radius.circular(radius)))
        ..drawRect(filled, Paint()..color = wash);
      ObPen.hatchedRect(
        canvas,
        filled,
        color: hue,
        gap: bodySize.shortestSide / 6,
        seed: seed,
      );
      canvas.restore();
    }

    canvas
      ..save()
      ..translate(0, headroom);
    ObPen.outline(
      canvas,
      bodySize,
      color: ink,
      radius: radius,
      strokeWidth: strokeWidth,
      seed: seed,
    );
    canvas.restore();

    // A closed flap folds down to just past the middle; a torn-open flap
    // stands up into the headroom above the envelope.
    final tip = open
        ? Offset(body.center.dx, inset)
        : Offset(body.center.dx, body.top + body.height * 0.52);
    ObPen.stroke(
      canvas,
      [body.topLeft, tip, body.topRight],
      color: ink,
      strokeWidth: 1.6,
      seed: seed + 1,
    );

    if (sealed) {
      final sealRadius = bodySize.shortestSide * 0.13;
      canvas
        ..drawCircle(tip, sealRadius, Paint()..color = hue)
        ..drawCircle(
          tip,
          sealRadius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = ink,
        );
    }
  }

  @override
  bool shouldRepaint(_EnvelopePainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      ink != oldDelegate.ink ||
      wash != oldDelegate.wash ||
      hue != oldDelegate.hue ||
      sealed != oldDelegate.sealed ||
      open != oldDelegate.open ||
      seed != oldDelegate.seed;
}
