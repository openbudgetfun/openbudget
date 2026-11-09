import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/flourish/ob_ink_burst.dart';
import 'package:openbudget_ui/src/flourish/ob_postmark.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_pen.dart';

/// A paper envelope that fills with ink as money goes in.
///
/// [fraction] is how much of the envelope's target is in place: 0 is empty,
/// 1 is full. The funded share is a wash with pencil hatching and a firm
/// water line. A full envelope is closed with a wax seal, and a small burst
/// of spot ink marks the moment it fills. An overspent envelope fills
/// completely in the overspent tone and its flap is torn open, so the state
/// reads without colour.
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
        : const Duration(milliseconds: 520);
    final fillTone = overspent ? ObTone.overspent : tone;
    final sealed = !overspent && target >= 1;

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: ObInkBurst(
        trigger: sealed,
        pieces: 10,
        reach: width * 0.35,
        seed: seed,
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
                paper: palette.surface,
                ink: palette.ink,
                wash: palette.wash(fillTone),
                hue: palette.hue(fillTone),
                wax: palette.highlighter,
                onWax: palette.onHighlighter,
                sealed: sealed && value >= 0.999,
                open: overspent,
                seed: seed,
              ),
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
    required this.paper,
    required this.ink,
    required this.wash,
    required this.hue,
    required this.wax,
    required this.onWax,
    required this.sealed,
    required this.open,
    required this.seed,
  });

  final double fraction;
  final Color paper;
  final Color ink;
  final Color wash;
  final Color hue;
  final Color wax;
  final Color onWax;
  final bool sealed;
  final bool open;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2;
    final inset = ObPen.inset(strokeWidth: strokeWidth);
    final headroom = size.width * _flapRoom;
    final bodySize = Size(size.width, size.height - headroom);
    final body = (Offset(0, headroom) & bodySize).deflate(inset);
    final radius = bodySize.shortestSide * 0.12;
    final clip = RRect.fromRectAndRadius(body, Radius.circular(radius));

    canvas.drawRRect(clip, Paint()..color = paper);
    if (fraction > 0) {
      final top = body.bottom - body.height * fraction;
      final filled = Rect.fromLTRB(body.left, top, body.right, body.bottom);
      canvas
        ..save()
        ..clipRRect(clip)
        ..drawRect(filled, Paint()..color = wash);
      ObPen.hatchedRect(
        canvas,
        filled,
        color: hue,
        gap: bodySize.shortestSide / 6,
        seed: seed,
      );
      if (fraction < 1) {
        // The water line: where the money comes up to.
        canvas.drawLine(
          Offset(body.left, top),
          Offset(body.right, top),
          Paint()
            ..strokeWidth = 2.2
            ..color = hue,
        );
      }
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

    if (open) {
      // A torn flap stands up into the headroom, its far edge ragged.
      final tip = Offset(body.center.dx, inset);
      final tear = (body.topRight - tip) / 4;
      final notch = Offset(tear.dy, -tear.dx) * 0.35;
      ObPen.stroke(
        canvas,
        [
          body.topLeft,
          tip,
          tip + tear + notch,
          tip + tear * 2 - notch,
          tip + tear * 3 + notch,
          body.topRight,
        ],
        color: ink,
        strokeWidth: 1.8,
        seed: seed + 1,
      );
      return;
    }

    // A closed flap folds down to just past the middle.
    final tip = Offset(body.center.dx, body.top + body.height * 0.52);
    ObPen.stroke(
      canvas,
      [body.topLeft, tip, body.topRight],
      color: ink,
      strokeWidth: 1.8,
      seed: seed + 1,
    );

    if (sealed) {
      final side = bodySize.shortestSide * 0.42;
      canvas
        ..save()
        ..translate(tip.dx - side / 2, tip.dy - side / 2);
      ObSealPainter(wax: wax, ink: onWax, seed: seed).paint(
        canvas,
        Size.square(side),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EnvelopePainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      paper != oldDelegate.paper ||
      ink != oldDelegate.ink ||
      wash != oldDelegate.wash ||
      hue != oldDelegate.hue ||
      wax != oldDelegate.wax ||
      onWax != oldDelegate.onWax ||
      sealed != oldDelegate.sealed ||
      open != oldDelegate.open ||
      seed != oldDelegate.seed;
}
