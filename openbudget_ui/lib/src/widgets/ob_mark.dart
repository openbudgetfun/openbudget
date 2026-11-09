import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:path_parsing/path_parsing.dart';

/// The colourways the OpenBudget mark is drawn in.
enum ObMarkVariant {
  /// Spot inks on light grounds.
  paper,

  /// The same spot inks inside a chalk sticker halo, for dark grounds.
  night,

  /// One colour with the details knocked out, for single-colour use.
  ink,
}

/// The OpenBudget mark: a pink cash envelope, flap open, with a gold coin
/// dropping in. The pocket is printed a second time in teal, a few points
/// off-register, the way cheap two-colour print lands.
///
/// The drawing is the one in `brand/mark.svg`; the path data here is copied
/// from it verbatim, and a test keeps the two in step.
///
/// [variant] defaults to [ObMarkVariant.paper] in the light theme and
/// [ObMarkVariant.night] in the dark one. With [tile], the mark sits on its
/// app-icon tile, laid out the way the platform icons are.
///
/// The mark is announced as [semanticLabel]; leave it null where a visible
/// product name already says the same thing.
class ObMark extends HookWidget {
  const ObMark({
    this.size = 48,
    this.variant,
    this.tile = false,
    this.color,
    this.semanticLabel,
    super.key,
  }) : assert(size > 0, 'size must be positive');

  /// The side of the square the mark is drawn in.
  final double size;

  final ObMarkVariant? variant;

  /// Whether to draw the app-icon tile behind the mark.
  final bool tile;

  /// The colour of [ObMarkVariant.ink]; defaults to the theme's ink, or to
  /// [ObSwatch.ink] on a tile. Ignored by the other variants.
  final Color? color;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    final resolved =
        variant ??
        (palette.isNight ? ObMarkVariant.night : ObMarkVariant.paper);
    final mono = color ?? (tile ? ObSwatch.ink : palette.ink);
    final tileColour = tile
        ? (resolved == ObMarkVariant.night
              ? ObSwatch.night
              : ObSwatch.newsprint)
        : null;

    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ObMarkPainter(
          variant: resolved,
          mono: mono,
          tile: tileColour,
          tileEdge: palette.line,
        ),
      ),
    );
    final label = semanticLabel;
    if (label == null) {
      return ExcludeSemantics(child: mark);
    }
    return Semantics(label: label, image: true, child: mark);
  }
}

/// Every distinct path of the mark, in the order the SVG first draws them.
@visibleForTesting
const List<String> obMarkPathData = [
  _ObMarkPaths.pocket,
  _ObMarkPaths.flap,
  _ObMarkPaths.coin,
  _ObMarkPaths.rim,
  _ObMarkPaths.folds,
];

/// The mark's geometry on its 128-unit artboard, from `brand/mark.svg`.
abstract final class _ObMarkPaths {
  /// The envelope's front pocket. It is also printed in teal, offset by
  /// [_ObMarkPaths.offRegister].
  static const pocket =
      'M12.5 60.5C36 59 86 60.5 111.5 59.2Q115.6 59.1 115.4 63.3C114.8 77 115.6 95 115 109.2Q114.8 114.3 109.7 114.2C84 114.9 40 113.6 14.4 114.6Q9.4 114.7 9.5 109.6C9.9 95 8.9 77 9.3 64.4Q9.4 60.6 12.5 60.5Z';

  /// The open flap, showing the lining.
  static const flap =
      'M10.2 60.4C26 47 45 27 61.2 8.6Q62.6 7.4 64 8.6C80 26 97 46 114.4 59.4Z';

  /// The coin, halfway in.
  static const coin =
      'M62.6 21.4C77 21.6 87.4 32.8 87 47C86.6 60.6 75.6 71.8 61.6 71.6C47.6 71.4 36.8 60.4 37.1 46.4C37.4 32.4 48.4 21.2 62.6 21.4Z';

  /// The coin's struck rim.
  static const rim =
      'M62.3 30.2C71.6 30.4 78.4 37.6 78.2 46.8C78 55.8 70.8 63 61.8 62.8C52.8 62.6 45.8 55.4 46 46.4C46.2 37.4 53.2 30 62.3 30.2Z';

  /// The folds on the pocket.
  static const folds =
      'M11.8 112.6C28 103 45 92.5 62.3 82.8C79 92 96 102.6 113 112.4';

  static const offRegister = Offset(4.5, 5);
}

final Path _pocket = _parse(_ObMarkPaths.pocket);
final Path _flap = _parse(_ObMarkPaths.flap);
final Path _coin = _parse(_ObMarkPaths.coin);
final Path _rim = _parse(_ObMarkPaths.rim);
final Path _folds = _parse(_ObMarkPaths.folds);
final Path _shadow = _pocket.shift(_ObMarkPaths.offRegister);

Path _parse(String data) {
  final proxy = _PathProxy();
  writeSvgPathDataToPath(data, proxy);
  return proxy.path;
}

final class _PathProxy extends PathProxy {
  final Path path = Path();

  @override
  void close() => path.close();

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);
}

/// The artboard the paths are drawn on.
const double _artboard = 128;

/// The mark's share of an app-icon tile, as in the platform icons.
const double _tileScale = .64;

class _ObMarkPainter extends CustomPainter {
  const _ObMarkPainter({
    required this.variant,
    required this.mono,
    required this.tile,
    required this.tileEdge,
  });

  final ObMarkVariant variant;
  final Color mono;
  final Color? tile;
  final Color tileEdge;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (side <= 0) {
      return;
    }
    var markSide = side;
    if (tile case final tileColour?) {
      // iOS-style continuous corners, like the icon on a home screen.
      final shape = RSuperellipse.fromRectAndRadius(
        Offset.zero & Size.square(side),
        Radius.circular(side * .2237),
      );
      canvas
        ..drawRSuperellipse(shape, Paint()..color = tileColour)
        ..drawRSuperellipse(
          shape,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = tileEdge,
        );
      markSide = side * _tileScale;
    }

    canvas
      ..save()
      ..translate((side - markSide) / 2, (side - markSide) / 2)
      ..scale(markSide / _artboard);
    switch (variant) {
      case ObMarkVariant.paper:
        _paintColour(canvas);
      case ObMarkVariant.night:
        _paintHalo(canvas);
        _paintColour(canvas);
      case ObMarkVariant.ink:
        _paintMono(canvas);
    }
    canvas.restore();
  }

  /// A chalk sticker edge under the whole mark, so its ink outline reads on
  /// a dark ground.
  void _paintHalo(Canvas canvas) {
    final fill = Paint()..color = ObSwatch.chalk;
    final edge = _stroke(ObSwatch.chalk, 12);
    for (final shape in [_shadow, _flap, _coin, _pocket]) {
      canvas
        ..drawPath(shape, fill)
        ..drawPath(shape, edge);
    }
  }

  void _paintColour(Canvas canvas) {
    canvas
      ..drawPath(_shadow, Paint()..color = ObSwatch.teal)
      ..drawPath(_flap, Paint()..color = ObSwatch.pinkWash)
      ..drawPath(_flap, _stroke(ObSwatch.ink, 5))
      ..drawPath(_coin, Paint()..color = ObSwatch.sunflower)
      ..drawPath(_coin, _stroke(ObSwatch.ink, 5))
      ..drawPath(_rim, _stroke(ObSwatch.ink, 3.2))
      ..drawPath(_pocket, Paint()..color = ObSwatch.pink)
      ..drawPath(_pocket, _stroke(ObSwatch.ink, 5))
      ..drawPath(_folds, _stroke(ObSwatch.ink, 4.5));
  }

  /// One colour. The flap is an outline and the coin solid, with its rim
  /// and a gap around the pocket cut out; the pocket is solid with its
  /// folds cut out.
  void _paintMono(Canvas canvas) {
    final clear = Paint()..blendMode = BlendMode.clear;
    const bounds = Rect.fromLTWH(0, 0, _artboard, _artboard);
    canvas
      ..saveLayer(bounds, Paint())
      ..drawPath(_flap, _stroke(mono, 5))
      ..drawPath(_coin, Paint()..color = mono)
      ..drawPath(_rim, _stroke(mono, 3.2)..blendMode = BlendMode.clear)
      ..drawPath(_pocket, _stroke(mono, 9)..blendMode = BlendMode.clear)
      ..drawPath(_pocket, clear)
      ..restore()
      ..saveLayer(bounds, Paint())
      ..drawPath(_pocket, Paint()..color = mono)
      ..drawPath(_folds, _stroke(mono, 4.5)..blendMode = BlendMode.clear)
      ..restore();
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  @override
  bool shouldRepaint(_ObMarkPainter oldDelegate) =>
      variant != oldDelegate.variant ||
      mono != oldDelegate.mono ||
      tile != oldDelegate.tile ||
      tileEdge != oldDelegate.tileEdge;
}
