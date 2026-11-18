import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'package:openbudget_ui/src/theme/ob_pen.dart';

/// A rounded rectangle drawn with the OpenBudget pen outline.
///
/// Material controls take their edge from an [OutlinedBorder], so painting
/// the pen here gives every themed button, card, chip, dialog, and sheet the
/// same hand-drawn edge without restyling each call site. The control's own
/// Material paints the fill; this border only inks the outline. The seed is
/// fixed, so a control of a given size draws the same wobble on every frame
/// and never shimmers while it is pressed or focused.
class ObRoughBorder extends OutlinedBorder {
  const ObRoughBorder({super.side, this.radius = 6, this.seed = 3});

  /// Defaults to the control radius; cards, chips, and sheets pass theirs.
  final double radius;
  final int seed;

  /// The fill meets the pen at its centre line, so no fill shows outside
  /// the outline.
  RRect _shape(Rect rect) => RRect.fromRectAndRadius(
    rect.deflate(_penInset(side)),
    Radius.circular(radius),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0 || rect.isEmpty) {
      return;
    }
    canvas
      ..save()
      ..translate(rect.left, rect.top);
    ObPen.outline(
      canvas,
      rect.size,
      color: side.color,
      radius: radius,
      strokeWidth: side.width,
      seed: seed,
    );
    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) =>
      ObRoughBorder(side: side.scale(t), radius: radius * t, seed: seed);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is ObRoughBorder) {
      return ObRoughBorder(
        side: BorderSide.lerp(a.side, side, t),
        radius: lerpDouble(a.radius, radius, t)!,
        seed: seed,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is ObRoughBorder) {
      return ObRoughBorder(
        side: BorderSide.lerp(side, b.side, t),
        radius: lerpDouble(radius, b.radius, t)!,
        seed: b.seed,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  ObRoughBorder copyWith({BorderSide? side}) =>
      ObRoughBorder(side: side ?? this.side, radius: radius, seed: seed);

  @override
  bool operator ==(Object other) =>
      other is ObRoughBorder &&
      other.side == side &&
      other.radius == radius &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(side, radius, seed);
}

/// The pen outline around a text field.
///
/// A rough line cannot leave a clean gap for a floating label, so this border
/// reports itself as not an outline: Material then floats the label inside
/// the field, as it does for a filled field, and the pen draws the whole box.
class ObRoughInputBorder extends InputBorder {
  const ObRoughInputBorder({super.borderSide, this.radius = 6, this.seed = 11});

  final double radius;
  final int seed;

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.strokeInset);

  @override
  ObRoughInputBorder copyWith({BorderSide? borderSide}) => ObRoughInputBorder(
    borderSide: borderSide ?? this.borderSide,
    radius: radius,
    seed: seed,
  );

  /// The field's fill meets the pen at its centre line.
  RRect _shape(Rect rect) => RRect.fromRectAndRadius(
    rect.deflate(_penInset(borderSide)),
    Radius.circular(radius),
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect).deflate(borderSide.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_shape(rect));

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0,
    double gapPercentage = 0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none || rect.isEmpty) {
      return;
    }
    canvas
      ..save()
      ..translate(rect.left, rect.top);
    ObPen.outline(
      canvas,
      rect.size,
      color: borderSide.color,
      radius: radius,
      strokeWidth: borderSide.width,
      seed: seed,
    );
    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) => ObRoughInputBorder(
    borderSide: borderSide.scale(t),
    radius: radius * t,
    seed: seed,
  );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is ObRoughInputBorder) {
      return ObRoughInputBorder(
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
        radius: lerpDouble(a.radius, radius, t)!,
        seed: seed,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is ObRoughInputBorder) {
      return ObRoughInputBorder(
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
        radius: lerpDouble(radius, b.radius, t)!,
        seed: b.seed,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) =>
      other is ObRoughInputBorder &&
      other.borderSide == borderSide &&
      other.radius == radius &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(borderSide, radius, seed);
}

/// Where a pen outline of [side] lands inside its box, or nothing when the
/// side is not drawn.
double _penInset(BorderSide side) =>
    side.style == BorderStyle.none || side.width == 0
    ? 0
    : ObPen.inset(strokeWidth: side.width);

/// A raised sticker: a hand-drawn outline over a flat fill, with a hard
/// print shadow laid down off-register below and to the right.
///
/// OpenBudget's primary buttons, heroes and dialogs are stickers. [lift] is
/// how far the sticker stands off the page: at 1 the fill sits up and to the
/// left of its shadow; at 0 it has been pressed down onto the shadow, which
/// disappears under it. A button theme resolves its pressed state to a
/// border with `lift: 0`, so Material's shape animation presses it in.
class ObStickerBorder extends OutlinedBorder {
  const ObStickerBorder({
    super.side,
    this.radius = 14,
    this.seed = 3,
    this.shadowColor = const Color(0x00000000),
    this.shadowOffset = const Offset(3, 3),
    this.lift = 1,
  }) : assert(lift >= 0 && lift <= 1, 'lift must be between 0 and 1');

  final double radius;
  final int seed;

  /// The print shadow's ink. Transparent draws no shadow.
  final Color shadowColor;

  /// How far the shadow is printed from the fill.
  final Offset shadowOffset;

  /// 1 when raised, 0 when pressed flat onto the shadow.
  final double lift;

  /// The sticker's footprint: the rect less room for the shadow.
  Rect _base(Rect rect) => Rect.fromLTRB(
    rect.left,
    rect.top,
    rect.right - shadowOffset.dx.abs(),
    rect.bottom - shadowOffset.dy.abs(),
  );

  Offset get _press => shadowOffset * (1 - lift);

  RRect _fill(Rect rect) => RRect.fromRectAndRadius(
    _base(rect).shift(_press).deflate(_penInset(side)),
    Radius.circular(radius),
  );

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.fromLTRB(
    side.strokeInset,
    side.strokeInset,
    side.strokeInset + shadowOffset.dx.abs(),
    side.strokeInset + shadowOffset.dy.abs(),
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_fill(rect).deflate(side.strokeInset));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(_fill(rect));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) {
      return;
    }
    final fill = _fill(rect);
    if (shadowColor.a > 0 && lift > 0) {
      final shadow = RRect.fromRectAndRadius(
        _base(rect).shift(shadowOffset).deflate(_penInset(side)),
        Radius.circular(radius),
      );
      // The fill is painted before the border, so the shadow is drawn only
      // where the fill is not.
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addRRect(shadow),
          Path()..addRRect(fill),
        ),
        Paint()..color = shadowColor,
      );
    }
    if (side.style == BorderStyle.none || side.width == 0) {
      return;
    }
    final base = _base(rect).shift(_press);
    canvas
      ..save()
      ..translate(base.left, base.top);
    ObPen.outline(
      canvas,
      base.size,
      color: side.color,
      radius: radius,
      strokeWidth: side.width,
      seed: seed,
    );
    canvas.restore();
  }

  @override
  ShapeBorder scale(double t) => ObStickerBorder(
    side: side.scale(t),
    radius: radius * t,
    seed: seed,
    shadowColor: shadowColor,
    shadowOffset: shadowOffset * t,
    lift: lift,
  );

  ObStickerBorder _lerp(ObStickerBorder a, ObStickerBorder b, double t) =>
      ObStickerBorder(
        side: BorderSide.lerp(a.side, b.side, t),
        radius: lerpDouble(a.radius, b.radius, t)!,
        seed: b.seed,
        shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
        shadowOffset: Offset.lerp(a.shadowOffset, b.shadowOffset, t)!,
        lift: lerpDouble(a.lift, b.lift, t)!.clamp(0.0, 1.0),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) =>
      a is ObStickerBorder ? _lerp(a, this, t) : super.lerpFrom(a, t);

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) =>
      b is ObStickerBorder ? _lerp(this, b, t) : super.lerpTo(b, t);

  @override
  ObStickerBorder copyWith({
    BorderSide? side,
    Color? shadowColor,
    double? lift,
  }) => ObStickerBorder(
    side: side ?? this.side,
    radius: radius,
    seed: seed,
    shadowColor: shadowColor ?? this.shadowColor,
    shadowOffset: shadowOffset,
    lift: lift ?? this.lift,
  );

  @override
  bool operator ==(Object other) =>
      other is ObStickerBorder &&
      other.side == side &&
      other.radius == radius &&
      other.seed == seed &&
      other.shadowColor == shadowColor &&
      other.shadowOffset == shadowOffset &&
      other.lift == lift;

  @override
  int get hashCode =>
      Object.hash(side, radius, seed, shadowColor, shadowOffset, lift);
}

/// A highlighter swipe: the irregular marker blob behind a selected
/// navigation destination.
///
/// It has no outline. Its outer path is the blob itself, so a Material
/// indicator filled with the highlighter colour takes the swipe's shape.
class ObMarkerBorder extends OutlinedBorder {
  const ObMarkerBorder({super.side, this.seed = 1});

  final int seed;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      obMarkerPath(rect, seed: seed);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  ObMarkerBorder copyWith({BorderSide? side}) =>
      ObMarkerBorder(side: side ?? this.side, seed: seed);

  @override
  bool operator ==(Object other) =>
      other is ObMarkerBorder && other.side == side && other.seed == seed;

  @override
  int get hashCode => Object.hash(side, seed);
}

/// The outline of a highlighter swipe across [rect]: a band with soft,
/// ragged ends, tilted a touch, the way a chisel marker lands and lifts.
Path obMarkerPath(Rect rect, {int seed = 1}) {
  if (rect.isEmpty) {
    return Path();
  }
  var state = seed * 9301 + 49297;
  double jitter(double amount) {
    state = (state * 9301 + 49297) % 233280;
    return (state / 233280 - 0.5) * amount;
  }

  final w = rect.width;
  final h = rect.height;
  final tilt = h * 0.08;
  final left = rect.left;
  final top = rect.top;
  return Path()
    ..moveTo(left + w * 0.06 + jitter(3), top + h * 0.12 + tilt + jitter(2))
    ..cubicTo(
      left + w * 0.35,
      top + h * 0.02 + jitter(3),
      left + w * 0.7,
      top + h * 0.06 + jitter(3),
      left + w * 0.96 + jitter(3),
      top + h * 0.04 - tilt + jitter(2),
    )
    ..quadraticBezierTo(
      left + w + jitter(4),
      top + h * 0.5,
      left + w * 0.95 + jitter(3),
      top + h * 0.9 - tilt + jitter(2),
    )
    ..cubicTo(
      left + w * 0.66,
      top + h + jitter(3),
      left + w * 0.32,
      top + h * 0.96 + jitter(3),
      left + w * 0.04 + jitter(3),
      top + h * 0.94 + tilt + jitter(2),
    )
    ..quadraticBezierTo(
      left + jitter(4),
      top + h * 0.52,
      left + w * 0.06 + jitter(3),
      top + h * 0.12 + tilt,
    )
    ..close();
}
