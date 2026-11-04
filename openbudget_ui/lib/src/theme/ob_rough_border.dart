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
