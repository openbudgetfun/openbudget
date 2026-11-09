import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:path_parsing/path_parsing.dart';

/// The colourways the OpenBudget mark is drawn in.
enum ObMarkVariant {
  /// Ink and indigo on envelope paper: the mark on light grounds.
  paper,

  /// Paper ink and night indigo: the mark on dark grounds.
  night,

  /// One colour with the paper knocked out, for single-colour use.
  ink,
}

/// The OpenBudget mark: three cash envelopes standing together, each filled
/// to its own level. The middle one is full, so it is sealed.
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
    final colours = switch (resolved) {
      ObMarkVariant.paper => _MarkColours.onPaper,
      ObMarkVariant.night => _MarkColours.onNight,
      ObMarkVariant.ink => null,
    };
    final mono = color ?? (tile ? ObSwatch.ink : palette.ink);
    final tileColour = tile
        ? (resolved == ObMarkVariant.night ? ObSwatch.night : ObSwatch.paper)
        : null;

    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ObMarkPainter(
          colours: colours,
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

/// Every path of the mark, in the order the SVG draws them.
@visibleForTesting
const List<String> obMarkPathData = [
  _ObMarkPaths.leftBody,
  _ObMarkPaths.leftFunded,
  _ObMarkPaths.leftHatch,
  _ObMarkPaths.leftFlap,
  _ObMarkPaths.rightBody,
  _ObMarkPaths.rightFunded,
  _ObMarkPaths.rightHatch,
  _ObMarkPaths.rightFlap,
  _ObMarkPaths.middleBody,
  _ObMarkPaths.middleHatch,
  _ObMarkPaths.middleFold,
  _ObMarkPaths.seal,
];

/// The mark's geometry on its 128-unit artboard, from `brand/mark.svg`.
abstract final class _ObMarkPaths {
  /// The left envelope, half funded.
  static const leftBody =
      'M11.5 48.9C17.8 47.4 29 47 34.9 45.9Q39.6 45.3 40.3 50.1C41.5 66.1 45 86.9 46.2 100.2Q46.7 104.9 42 105.4C35.7 106.7 24.8 107.1 18.6 108.3Q13.9 108.8 13.5 104C12 88.5 8.7 68.4 7.2 54.2Q6.7 49.4 11.5 48.9Z';
  static const leftFlap =
      'M8.4 51.3C14.1 54.9 20 59.6 24.9 61.7C29.1 58.2 33.7 52.4 38.3 47.4';
  static const leftFunded =
      'M8.5 79.9C20 76.2 30.8 77.9 45 74.3L49 106.5L12.3 111Z';
  static const leftHatch =
      'M9.5 80.3L11 76.9M10.6 88.9L16.4 76.3M11.6 97.6L21.8 75.6M12.7 106.2L27.1 75M16 110.1L32.5 74.3M21.3 109.4L37.8 73.6M26.7 108.8L43.2 73M32 108.1L44.8 80.5M37.4 107.5L45.9 89.1M42.8 106.8L46.9 97.8';

  /// The right envelope, two thirds funded.
  static const rightBody =
      'M93.1 36.2C99.5 36.1 110.6 38.3 116.5 38.5Q121.2 39 120.8 43.8C118.1 63.2 116.4 87.7 114.3 103.9Q113.7 108.6 109 108C102.6 107.8 91.9 105.8 85.6 105.7Q80.9 105.1 81.6 100.3C84 81.5 85.6 57.7 87.7 40.4Q88.3 35.6 93.1 36.2Z';
  static const rightFlap =
      'M89.5 37.8C94.2 42.6 98.9 48.5 103.2 51.6C108.1 49.2 113.9 44.6 119.5 40.8';
  static const rightFunded =
      'M83.6 60.9C95.7 60 105.9 64.1 120.5 63.7L115.6 110.7L78.8 106.9Z';
  static const rightHatch =
      'M84.6 61.5L86.8 58.6M83.7 70.2L92.2 59.2M82.7 78.8L97.5 59.8M81.8 87.5L102.9 60.3M80.9 96.2L108.3 60.9M80 104.8L113.7 61.5M84.2 106.9L119 62M89.6 107.5L118.9 69.7M94.9 108L118 78.3M100.3 108.6L117.1 87M105.7 109.2L116.2 95.7M111.1 109.7L115.3 104.3';

  /// The middle envelope: full, so its flap is folded and sealed.
  static const middleBody =
      'M51.6 19.9C59.4 19.2 72 20.4 79.2 20.1Q83.9 20.1 83.9 24.9C83 50.1 83.6 80.2 82.9 101.4Q82.8 106.1 78.1 105.9C70.3 106.4 58.1 105.3 50.5 105.8Q45.8 105.6 46.1 100.8C46.7 76.4 46.1 47.1 46.6 24.6Q46.8 19.7 51.6 19.9Z';
  static const middleFold =
      'M48.2 21.8C54.1 27 60 33.1 65.1 36.1C70.3 32.9 76.3 27.1 82.4 22';
  static const middleHatch =
      'M45.8 20.7L47.8 17.6M45.7 29.4L53.2 17.7M45.6 38.1L58.6 17.7M45.5 46.8L64 17.8M45.4 55.6L69.4 17.8M45.3 64.3L74.8 17.9M45.2 73L80.2 18M45.2 81.7L84.8 19.2M45.1 90.4L84.7 27.9M45 99.1L84.6 36.6M45.3 107.1L84.5 45.3M50.7 107.2L84.4 54M56.1 107.2L84.4 62.7M61.5 107.3L84.3 71.4M66.9 107.3L84.2 80.2M72.3 107.4L84.1 88.9M77.7 107.4L84 97.6M83.1 107.5L83.9 106.3';

  /// The wax seal at the point of the middle flap.
  static const seal =
      'M72 36.1C72.1 36.7 71.9 37.3 71.7 37.8C71.5 38.4 71.2 38.9 70.8 39.4C70.5 39.9 70.1 40.3 69.7 40.7C69.3 41.1 68.9 41.4 68.4 41.7C67.9 42 67.3 42.2 66.8 42.3C66.3 42.5 65.7 42.5 65.1 42.5C64.6 42.5 64 42.5 63.4 42.4C62.9 42.3 62.3 42.2 61.7 42C61.2 41.7 60.6 41.4 60.2 41C59.8 40.6 59.5 40 59.2 39.5C59 38.9 58.9 38.3 58.9 37.8C58.8 37.2 58.8 36.6 58.8 36.1C58.9 35.5 58.9 35 59 34.4C59 33.9 59.2 33.3 59.4 32.8C59.6 32.3 60 31.8 60.4 31.3C60.8 30.9 61.3 30.6 61.8 30.3C62.3 30 62.8 29.8 63.4 29.6C63.9 29.4 64.6 29.3 65.1 29.3C65.7 29.3 66.3 29.4 66.9 29.6C67.4 29.8 67.9 30.2 68.3 30.5C68.8 30.9 69.2 31.3 69.5 31.7C69.9 32.1 70.3 32.4 70.7 32.9C71 33.3 71.4 33.8 71.6 34.3C71.9 34.9 72 35.5 72 36.1Z';
}

@immutable
final class _MarkColours {
  const _MarkColours({
    required this.paper,
    required this.ink,
    required this.funded,
  });

  /// The paper colourway.
  static const onPaper = _MarkColours(
    paper: ObSwatch.paper,
    ink: ObSwatch.ink,
    funded: ObSwatch.indigo,
  );

  /// The night colourway.
  static const onNight = _MarkColours(
    paper: ObSwatch.night,
    ink: ObSwatch.nightInk,
    funded: ObSwatch.nightIndigo,
  );

  /// The envelopes' paper, the fold on the full envelope, and the hatching.
  final Color paper;
  final Color ink;
  final Color funded;

  /// The wax seal is the same yellow on every ground.
  Color get seal => ObSwatch.highlighter;

  @override
  bool operator ==(Object other) =>
      other is _MarkColours &&
      other.paper == paper &&
      other.ink == ink &&
      other.funded == funded;

  @override
  int get hashCode => Object.hash(paper, ink, funded);
}

/// One envelope's parsed paths.
final class _Envelope {
  _Envelope({
    required String body,
    required String flap,
    required String hatch,
    String? funded,
  }) : body = _parse(body),
       flap = _parse(flap),
       hatch = _parse(hatch),
       funded = funded == null ? null : _parse(funded);

  final Path body;
  final Path flap;
  final Path hatch;

  /// The funded share; null when the envelope is full.
  final Path? funded;
}

final _left = _Envelope(
  body: _ObMarkPaths.leftBody,
  flap: _ObMarkPaths.leftFlap,
  hatch: _ObMarkPaths.leftHatch,
  funded: _ObMarkPaths.leftFunded,
);

final _right = _Envelope(
  body: _ObMarkPaths.rightBody,
  flap: _ObMarkPaths.rightFlap,
  hatch: _ObMarkPaths.rightHatch,
  funded: _ObMarkPaths.rightFunded,
);

final _middle = _Envelope(
  body: _ObMarkPaths.middleBody,
  flap: _ObMarkPaths.middleFold,
  hatch: _ObMarkPaths.middleHatch,
);

final Path _seal = _parse(_ObMarkPaths.seal);

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
    required this.colours,
    required this.mono,
    required this.tile,
    required this.tileEdge,
  });

  /// The colourway, or null for the one-colour mark in [mono].
  final _MarkColours? colours;
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
    if (colours case final colours?) {
      _paintColour(canvas, colours);
    } else {
      _paintMono(canvas);
    }
    canvas.restore();
  }

  void _paintColour(Canvas canvas, _MarkColours colours) {
    final hatch = _stroke(colours.paper.withValues(alpha: .28), 1.3);
    for (final envelope in [_left, _right, _middle]) {
      final full = envelope.funded == null;
      canvas
        ..drawPath(envelope.body, Paint()..color = colours.paper)
        ..save()
        ..clipPath(envelope.body)
        ..drawPath(
          envelope.funded ?? envelope.body,
          Paint()..color = colours.funded,
        );
      if (envelope.funded case final funded?) {
        canvas.clipPath(funded);
      }
      canvas
        ..drawPath(envelope.hatch, hatch)
        ..restore()
        ..drawPath(envelope.body, _stroke(colours.ink, 3.6))
        ..drawPath(
          envelope.flap,
          _stroke(full ? colours.paper : colours.ink, 3.2),
        );
    }
    canvas
      ..drawPath(_seal, Paint()..color = colours.seal)
      ..drawPath(_seal, _stroke(colours.ink, 2.6));
  }

  /// One colour. The middle envelope stands in front of the other two, with
  /// a paper gap around it; its fold and seal are cut out of it.
  void _paintMono(Canvas canvas) {
    final fill = Paint()..color = mono;
    final clear = Paint()..blendMode = BlendMode.clear;
    const bounds = Rect.fromLTWH(0, 0, _artboard, _artboard);

    canvas.saveLayer(bounds, Paint());
    for (final envelope in [_left, _right]) {
      canvas
        ..save()
        ..clipPath(envelope.body)
        ..drawPath(envelope.funded ?? envelope.body, fill)
        ..restore()
        ..drawPath(envelope.body, _stroke(mono, 3.6))
        ..drawPath(envelope.flap, _stroke(mono, 3.2));
    }
    canvas
      ..drawPath(_middle.body, clear)
      ..drawPath(_middle.body, _stroke(mono, 7.2)..blendMode = BlendMode.clear)
      ..restore()
      ..saveLayer(bounds, Paint())
      ..drawPath(_middle.body, fill)
      ..drawPath(_middle.body, _stroke(mono, 3.6))
      ..drawPath(_middle.flap, _stroke(mono, 3.2)..blendMode = BlendMode.clear)
      ..drawPath(_seal, clear)
      ..drawPath(_seal, _stroke(mono, 2.6))
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
      colours != oldDelegate.colours ||
      mono != oldDelegate.mono ||
      tile != oldDelegate.tile ||
      tileEdge != oldDelegate.tileEdge;
}
