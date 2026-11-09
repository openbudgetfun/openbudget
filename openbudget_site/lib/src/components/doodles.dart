/// The site's pen-and-pencil drawings, as inline SVG.
///
/// Every drawing is decorative: the text beside it says the same thing.
/// Strokes use `currentColor`; the `d-*` classes take their fills from the
/// theme in `web/styles.css`.
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/src/components/sketch.dart';

/// One of the drawings that sit beside "what makes it different".
enum Doodle {
  envelopes,
  currencies,
  books,
  postmarks,
  agents,
  openSource,
}

/// A doodle drawn inline.
final class DoodleArt extends StatelessComponent {
  const DoodleArt(this.doodle, {super.key});

  /// Which drawing to show.
  final Doodle doodle;

  @override
  Component build(BuildContext context) => RawText(doodleSvg(doodle));
}

/// The SVG markup for [doodle].
String doodleSvg(Doodle doodle) {
  final body = switch (doodle) {
    Doodle.envelopes => _envelopes(),
    Doodle.currencies => _currencies(),
    Doodle.books => _books(),
    Doodle.postmarks => _postmarks(),
    Doodle.agents => _agents(),
    Doodle.openSource => _openSource(),
  };
  return '<svg class="doodle" viewBox="0 0 160 120" aria-hidden="true" '
      'focusable="false"><g fill="none" stroke="currentColor" '
      'stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
      '$body</g></svg>';
}

String _path(String d, {String? classes, String extra = ''}) =>
    '<path d="$d"${classes == null ? '' : ' class="$classes"'}$extra/>';

String _text(double x, double y, String text, {double size = 15}) =>
    '<text class="d-text" x="$x" y="$y" font-size="$size" '
    'text-anchor="middle" dominant-baseline="central">$text</text>';

/// Money moving from one envelope to another.
String _envelopes() {
  final pen = Sketch(11);
  return [
    _path(pen.box(26, 44, 40, 62, radius: 5), classes: 'd-paper'),
    _path(
      pen.box(28.5, 80, 35, 23.5, radius: 3),
      classes: 'd-indigo',
      extra: ' stroke="none"',
    ),
    _path(pen.box(26, 44, 40, 62, radius: 5)),
    _path(pen.line([(30, 48), (46, 62), (62, 48)])),
    _path(pen.box(92, 30, 42, 76, radius: 5), classes: 'd-paper'),
    _path(
      pen.box(94.5, 50, 37, 53.5, radius: 3),
      classes: 'd-indigo',
      extra: ' stroke="none"',
    ),
    _path(pen.box(92, 30, 42, 76, radius: 5)),
    _path(pen.line([(96, 34), (113, 49), (130, 34)])),
    _path(pen.smooth([(44, 36), (52, 14), (80, 8), (104, 14), (110, 24)])),
    _path(pen.line([(101, 21), (110, 25), (113, 15)])),
    _path(pen.ring(78, 10, 6.5), classes: 'd-seal'),
  ].join();
}

/// Coins in four currencies adding up to one net worth.
String _currencies() {
  final pen = Sketch(23);
  const coins = [
    (28.0, 42.0, '£'),
    (60.0, 42.0, r'$'),
    (28.0, 76.0, '€'),
    (60.0, 76.0, '₦'),
  ];
  return [
    for (final (x, y, symbol) in coins) ...[
      _path(pen.ring(x, y, 13), classes: 'd-wash'),
      _text(x, y + 1, symbol),
    ],
    _path(pen.line([(82, 60), (102, 60)])),
    _path(pen.line([(96, 54), (103, 60), (96, 66)])),
    _path(pen.box(112, 22, 32, 84, radius: 5), classes: 'd-paper'),
    _path(
      pen.box(114.5, 34, 27, 69.5, radius: 3),
      classes: 'd-indigo',
      extra: ' stroke="none"',
    ),
    _path(pen.box(112, 22, 32, 84, radius: 5)),
    _path(pen.ring(128, 30, 5.5), classes: 'd-seal'),
  ].join();
}

/// Household books beside company books.
String _books() {
  final pen = Sketch(37);
  String book(double x, double y, String label, String fill) => [
    _path(pen.box(x, y, 50, 70), classes: fill),
    _path(pen.line([(x + 9, y + 2), (x + 9, y + 68)])),
    for (final row in [16.0, 26.0, 36.0])
      _path(
        pen.line([(x + 16, y + row), (x + 42, y + row)]),
        extra: ' stroke-width="1.6"',
      ),
    _text(x + 29, y + 54, label, size: 12),
  ].join();
  return [
    book(20, 28, 'Home', 'd-paper'),
    book(90, 22, 'Ltd', 'd-wash'),
    _text(80, 64, '&', size: 22),
  ].join();
}

/// Postmarks from the four countries the tax guidance covers.
String _postmarks() {
  final pen = Sketch(41);
  const marks = [
    (40.0, 38.0, 'UK'),
    (104.0, 34.0, 'US'),
    (56.0, 86.0, 'NG'),
    (120.0, 84.0, 'DE'),
  ];
  return [
    for (final (x, y, code) in marks) ...[
      _path(pen.ring(x, y, 20), classes: 'd-paper'),
      _path(pen.ring(x, y, 15.5), extra: ' stroke-width="1.4"'),
      _text(x, y + 1, code, size: 13),
    ],
    for (final y in [52.0, 60.0, 68.0])
      _path(pen.wave(70, 154, y), extra: ' stroke-width="1.8"'),
  ].join();
}

/// A question to the assistant, and a token for an outside agent.
String _agents() {
  final pen = Sketch(53);
  return [
    _path(pen.box(16, 18, 86, 52, radius: 10), classes: 'd-paper'),
    _path(pen.line([(36, 69), (30, 86), (52, 69)]), classes: 'd-paper'),
    for (final x in [44.0, 59.0, 74.0])
      _path(pen.ring(x, 44, 3.4, wobble: .3), classes: 'd-ink'),
    _path(
      pen.smooth([(98, 76), (108, 92), (118, 72), (126, 66)]),
      extra: ' stroke-dasharray="3 6"',
    ),
    _path(pen.ring(132, 58, 11), classes: 'd-seal'),
    _path(pen.line([(132, 69), (132, 108)])),
    _path(pen.line([(132, 98), (141, 98)])),
    _path(pen.line([(132, 89), (139, 89)])),
    _text(132, 25, 'MCP', size: 12),
  ].join();
}

/// An open envelope with code spilling out.
String _openSource() {
  final pen = Sketch(67);
  return [
    _path(pen.line([(28, 60), (80, 24), (132, 60)]), classes: 'd-wash'),
    _path(pen.box(28, 58, 104, 50, radius: 5), classes: 'd-paper'),
    _path(pen.line([(30, 104), (80, 76), (130, 104)])),
    _text(80, 46, '&lt;/&gt;', size: 20),
  ].join();
}

/// A pencil underline for a heading, drawn on when it scrolls into view.
const scribbleUnderline =
    '<svg class="underline" viewBox="0 0 300 14" preserveAspectRatio="none" '
    'aria-hidden="true" focusable="false"><path d="M3 9C48 4 96 3 150 6S250 '
    '11 297 5" fill="none" stroke="currentColor" stroke-width="3.2" '
    'stroke-linecap="round" pathLength="1"/></svg>';

/// The hand-drawn arrow that points from the hero's note to the desk.
const heroArrow =
    '<svg class="hand-arrow" viewBox="0 0 90 70" aria-hidden="true" '
    'focusable="false"><g fill="none" stroke="currentColor" stroke-width="2.6" '
    'stroke-linecap="round" stroke-linejoin="round"><path d="M8 10C30 6 58 '
    '14 66 34S64 58 58 62" pathLength="1"/><path d="M50 52L58 63L68 54" '
    'pathLength="1"/></g></svg>';
