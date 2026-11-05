import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'package:openbudget_ui/src/theme/ob_pen.dart';

/// A clean fill with the OpenBudget pen outline on top.
///
/// This is the hand-drawn replacement for a `BoxDecoration` with a colour, a
/// rounded corner, and a border. The fill stays a real, level shape so text
/// and artwork sit on a quiet field; only the outline is drawn by hand. Use a
/// stable [seed] per surface so its outline never changes between frames.
///
/// Leave [outline] null for a borderless field, or [color] null for an
/// outline around content that paints its own background.
class ObRoughDecoration extends Decoration {
  const ObRoughDecoration({
    this.color,
    this.outline,
    this.radius = 12,
    this.strokeWidth = ObPen.strokeWidth,
    this.seed = 1,
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
  );

  final Color? color;
  final Color? outline;
  final double radius;
  final double strokeWidth;
  final int seed;

  RRect _shape(Rect rect) =>
      RRect.fromRectAndRadius(rect, Radius.circular(radius));

  /// Where the fill and clip meet the pen: at the centre of the line, so a
  /// fill or a full-bleed child never pokes out past the outline.
  double get _inset =>
      outline == null ? 0 : ObPen.inset(strokeWidth: strokeWidth);

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.all(_inset);

  @override
  bool hitTest(Size size, Offset position, {TextDirection? textDirection}) =>
      _shape(Offset.zero & size).contains(position);

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) =>
      Path()..addRRect(_shape(rect.deflate(_inset)));

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
      other.seed == seed;

  @override
  int get hashCode => Object.hash(color, outline, radius, strokeWidth, seed);
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
    canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    if (decoration.color case final fill?) {
      final rect = (Offset.zero & size).deflate(decoration._inset);
      if (!rect.isEmpty) {
        canvas.drawRRect(decoration._shape(rect), Paint()..color = fill);
      }
    }
    if (decoration.outline case final ink?) {
      ObPen.outline(
        canvas,
        size,
        color: ink,
        radius: decoration.radius,
        strokeWidth: decoration.strokeWidth,
        seed: decoration.seed,
      );
    }
    canvas.restore();
  }
}
