import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'package:openbudget_ui/src/theme/ob_pen.dart';

/// A clean fill with the OpenBudget pen outline on top, and optionally a
/// print shadow laid down off-register beneath it.
///
/// This is the hand-drawn replacement for a `BoxDecoration` with a colour, a
/// rounded corner, a border and a shadow. The fill stays a real, level shape
/// so text and artwork sit on a quiet field; only the outline is drawn by
/// hand, and the shadow is a hard, flat second ink rather than a blur. Use a
/// stable [seed] per surface so its outline never changes between frames.
///
/// Leave [outline] null for a borderless field, [color] null for an outline
/// around content that paints its own background, and [shadow] null for a
/// field that lies flat on the page.
class ObRoughDecoration extends Decoration {
  const ObRoughDecoration({
    this.color,
    this.outline,
    this.radius = 12,
    this.strokeWidth = ObPen.strokeWidth,
    this.seed = 1,
    this.shadow,
    this.shadowOffset = const Offset(4, 4),
  });

  /// Interpolates colours and geometry so an `AnimatedContainer` can move
  /// between two hand-drawn states. The outline keeps the target's seed.
  factory ObRoughDecoration.lerp(
    ObRoughDecoration a,
    ObRoughDecoration b,
    double t,
  ) => ObRoughDecoration(
    color: Color.lerp(a.color, b.color, t),
    outline: Color.lerp(a.outline, b.outline, t),
    radius: lerpDouble(a.radius, b.radius, t)!,
    strokeWidth: lerpDouble(a.strokeWidth, b.strokeWidth, t)!,
    seed: t < 0.5 ? a.seed : b.seed,
    shadow: Color.lerp(a.shadow, b.shadow, t),
    shadowOffset: Offset.lerp(a.shadowOffset, b.shadowOffset, t)!,
  );

  final Color? color;
  final Color? outline;
  final double radius;
  final double strokeWidth;
  final int seed;

  /// The print shadow's ink, or null for none.
  final Color? shadow;

  /// How far the shadow is printed from the fill. The decoration keeps room
  /// for it inside its own box, so nothing is clipped by a parent.
  final Offset shadowOffset;

  Offset get _room => shadow == null
      ? Offset.zero
      : Offset(shadowOffset.dx.abs(), shadowOffset.dy.abs());

  /// The fill's footprint: the box less room for the shadow.
  Rect _base(Rect rect) => Rect.fromLTRB(
    rect.left,
    rect.top,
    rect.right - _room.dx,
    rect.bottom - _room.dy,
  );

  RRect _shape(Rect rect) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  /// Where the fill and clip meet the pen: at the centre of the line, so a
  /// fill or a full-bleed child never pokes out past the outline.
  double get _inset =>
      outline == null ? 0 : ObPen.inset(strokeWidth: strokeWidth);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.fromLTRB(
    _inset,
    _inset,
    _inset + _room.dx,
    _inset + _room.dy,
  );

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) =>
      _shape(Offset.zero & size).contains(position);

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      Path()..addRRect(_shape(_base(rect).deflate(_inset)));

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _ObRoughDecorationPainter(this, onChanged);

  @override
  ObRoughDecoration? lerpFrom(Decoration? a, double t) =>
      a is ObRoughDecoration ? ObRoughDecoration.lerp(a, this, t) : null;

  @override
  ObRoughDecoration? lerpTo(Decoration? b, double t) =>
      b is ObRoughDecoration ? ObRoughDecoration.lerp(this, b, t) : null;

  @override
  bool operator ==(Object other) =>
      other is ObRoughDecoration &&
      other.color == color &&
      other.outline == outline &&
      other.radius == radius &&
      other.strokeWidth == strokeWidth &&
      other.seed == seed &&
      other.shadow == shadow &&
      other.shadowOffset == shadowOffset;

  @override
  int get hashCode => Object.hash(
    color,
    outline,
    radius,
    strokeWidth,
    seed,
    shadow,
    shadowOffset,
  );
}

class _ObRoughDecorationPainter extends BoxPainter {
  _ObRoughDecorationPainter(this._decoration, super.onChanged);

  final ObRoughDecoration _decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null || size.isEmpty) {
      return;
    }
    final decoration = _decoration;
    final base = decoration._base(Offset.zero & size);
    if (base.isEmpty) {
      return;
    }
    canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    final fillRect = base.deflate(decoration._inset);
    if (decoration.shadow case final shadow? when !fillRect.isEmpty) {
      canvas.drawRRect(
        decoration._shape(fillRect.shift(decoration.shadowOffset)),
        Paint()..color = shadow,
      );
    }
    if (decoration.color case final fill? when !fillRect.isEmpty) {
      canvas.drawRRect(decoration._shape(fillRect), Paint()..color = fill);
    }
    if (decoration.outline case final ink?) {
      ObPen.outline(
        canvas,
        base.size,
        color: ink,
        radius: decoration.radius,
        strokeWidth: decoration.strokeWidth,
        seed: decoration.seed,
      );
    }
    canvas.restore();
  }
}
