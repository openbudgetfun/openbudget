import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:skribble/skribble.dart';

/// A hand-drawn icon for a text field's `prefixIcon` or `suffixIcon` slot.
///
/// A text field lays its icons out in a box at least 48pt square, so the
/// icon is a comfortable target and lines up with the text. A bare
/// [SkribbleIcon] stretches to fill that box but draws its glyph at the
/// box's top-left corner, which lands it on the field's rough outline. This
/// keeps the glyph at its own [size] and centres it in the box, the way a
/// Material `Icon` does.
class ObFieldIcon extends HookWidget {
  const ObFieldIcon({
    required this.data,
    this.size,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final WiredSvgIconData data;

  /// The glyph size; defaults to the field's icon size.
  final double? size;

  /// The ink; defaults to the field's prefix or suffix icon colour.
  final Color? color;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Center(
    widthFactor: 1,
    heightFactor: 1,
    child: SkribbleIcon(
      data: data,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    ),
  );
}
