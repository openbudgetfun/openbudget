/// Hand-drawn SVG path data.
///
/// A [Sketch] draws boxes, rings and lines whose edges bow a little, like a
/// pen line, so the site's doodles match the app's skribble world. The
/// wobble comes from a seeded generator, so every build draws the same
/// shapes.
library;

import 'dart:math' as math;

/// A pen that draws slightly irregular SVG path data.
final class Sketch {
  /// A pen whose wobble starts from [seed].
  Sketch(int seed) : _state = seed;

  int _state;

  /// A deterministic offset in `[-amount, amount]`.
  double _jitter(double amount) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return (_state / 0x7fffffff * 2 - 1) * amount;
  }

  /// A rounded rectangle whose edges bow by up to [wobble].
  String box(
    double x,
    double y,
    double width,
    double height, {
    double radius = 4,
    double wobble = 1.1,
  }) {
    final right = x + width;
    final bottom = y + height;
    final r = radius;
    String edge(double x1, double y1, double x2, double y2) {
      final c1x = x1 + (x2 - x1) / 3 + _jitter(wobble);
      final c1y = y1 + (y2 - y1) / 3 + _jitter(wobble);
      final c2x = x1 + (x2 - x1) * 2 / 3 + _jitter(wobble);
      final c2y = y1 + (y2 - y1) * 2 / 3 + _jitter(wobble);
      return 'C${_n(c1x)} ${_n(c1y)} ${_n(c2x)} ${_n(c2y)} ${_n(x2)} ${_n(y2)}';
    }

    return [
      'M${_n(x + r)} ${_n(y)}',
      edge(x + r, y, right - r, y),
      'Q${_n(right)} ${_n(y)} ${_n(right)} ${_n(y + r)}',
      edge(right, y + r, right, bottom - r),
      'Q${_n(right)} ${_n(bottom)} ${_n(right - r)} ${_n(bottom)}',
      edge(right - r, bottom, x + r, bottom),
      'Q${_n(x)} ${_n(bottom)} ${_n(x)} ${_n(bottom - r)}',
      edge(x, bottom - r, x, y + r),
      'Q${_n(x)} ${_n(y)} ${_n(x + r)} ${_n(y)}Z',
    ].join();
  }

  /// A circle drawn in eight strokes, each a little off true.
  String ring(double cx, double cy, double r, {double wobble = .8}) {
    const segments = 8;
    final points = [
      for (var i = 0; i < segments; i++)
        (
          cx + math.cos(i / segments * 2 * math.pi) * (r + _jitter(wobble)),
          cy + math.sin(i / segments * 2 * math.pi) * (r + _jitter(wobble)),
        ),
    ];
    return '${smooth([...points, points.first])}Z';
  }

  /// A line through [points], each nudged by up to [wobble].
  String line(List<(double, double)> points, {double wobble = .6}) {
    final nudged = [
      for (final (x, y) in points) (x + _jitter(wobble), y + _jitter(wobble)),
    ];
    return 'M${nudged.map((p) => '${_n(p.$1)} ${_n(p.$2)}').join('L')}';
  }

  /// A curve through [points], drawn with quadratic midpoints.
  String smooth(List<(double, double)> points) {
    final buffer = StringBuffer(
      'M${_n(points.first.$1)} ${_n(points.first.$2)}',
    );
    for (var i = 1; i < points.length - 1; i++) {
      final (x, y) = points[i];
      final (nx, ny) = points[i + 1];
      buffer.write(
        'Q${_n(x)} ${_n(y)} ${_n((x + nx) / 2)} ${_n((y + ny) / 2)}',
      );
    }
    final (lx, ly) = points.last;
    buffer.write('L${_n(lx)} ${_n(ly)}');
    return buffer.toString();
  }

  /// A wavy line from ([x1], [y]) to ([x2], [y]), like a postmark cancel.
  String wave(double x1, double x2, double y, {double amplitude = 2.4}) {
    final buffer = StringBuffer('M${_n(x1)} ${_n(y)}');
    const step = 9.0;
    var x = x1;
    var up = true;
    while (x < x2) {
      final next = math.min(x + step, x2);
      final crest = y + (up ? -amplitude : amplitude) + _jitter(.4);
      buffer.write('Q${_n((x + next) / 2)} ${_n(crest)} ${_n(next)} ${_n(y)}');
      x = next;
      up = !up;
    }
    return buffer.toString();
  }
}

/// [value] to one decimal place, without a trailing `.0`.
String _n(double value) {
  final text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
