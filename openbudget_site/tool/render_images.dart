/// Draws the site's images from the SVG sources in `brand/`.
///
/// Run from this package's directory:
///
/// ```sh
/// dart run tool/render_images.dart
/// ```
///
/// It copies the small mark to `web/favicon.svg`, composes the social card
/// (`web/og.png`, 1200 by 630) and the home-screen icon
/// (`web/apple-touch-icon.png`, 180 by 180) as SVG, rasterises them with
/// `resvg` using the app's own Skribble fonts, and compresses them with
/// `oxipng`. Both tools come with the repository's devenv shell.
library;

import 'dart:io';
import 'dart:isolate';

const _brand = '../brand';
const _paper = '#FCF8EF';
const _ink = '#262C44';
const _muted = '#5C627A';
const _indigo = '#3E4CC9';
const _highlighter = '#FFEC8A';

Future<void> main() async {
  if (!File('$_brand/mark.svg').existsSync()) {
    _fail('Run from openbudget_site/: $_brand/mark.svg is missing.');
  }
  final fonts = await _skribbleFonts();

  File('$_brand/mark-small.svg').copySync('web/favicon.svg');
  stdout.writeln('copied $_brand/mark-small.svg to web/favicon.svg');

  await _render(
    _socialCard(),
    'web/og.png',
    width: 1200,
    height: 630,
    fonts: fonts,
  );
  await _render(
    _touchIcon(),
    'web/apple-touch-icon.png',
    width: 180,
    height: 180,
    fonts: fonts,
  );
  await _run('oxipng', [
    '--quiet',
    '--opt',
    '4',
    '--strip',
    'safe',
    'web/og.png',
    'web/apple-touch-icon.png',
  ]);
  stdout.writeln('compressed web/og.png and web/apple-touch-icon.png');
}

/// The social card: the promise in the display face beside the mark.
String _socialCard() {
  const left = 72;
  // Advance widths of "Put every " and "dollar" in SkribbleGentle
  // ExtraBold at 92px, so the highlighter sits under the one word.
  const wordStart = left + 473.8;
  const wordWidth = 271.4;
  return '''
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="$_paper"/>
  ${_nest('lockup.svg', x: left, y: 58, width: 52 * 552 / 118, height: 52)}
  <rect x="${wordStart - 6}" y="230" width="${wordWidth + 12}" height="44" rx="6" fill="$_highlighter" transform="rotate(-1.2 ${wordStart + wordWidth / 2} 252)"/>
  <g font-family="SkribbleGentle" font-weight="800" font-size="92" fill="$_ink">
    <text x="$left" y="268">Put every dollar</text>
    <text x="$left" y="364">in an envelope.</text>
  </g>
  <path d="M74 392C210 384 380 398 520 389S700 386 770 392" fill="none" stroke="$_indigo" stroke-width="5" stroke-linecap="round"/>
  <text x="$left" y="462" font-family="SkribbleLinearGentle" font-size="32" fill="$_muted">Envelope budgeting across currencies.</text>
  <text x="$left" y="560" font-family="SkribbleMonoGentle" font-weight="600" font-size="28" fill="$_indigo">openbudget.app</text>
  <text x="330" y="560" font-family="SkribbleLinearGentle" font-size="28" fill="$_muted">Free to start · Open source</text>
  ${_nest('mark.svg', x: 846, y: 150, width: 320, height: 320)}
</svg>
''';
}

/// The home-screen icon: the mark on a paper tile, as the app icon is.
String _touchIcon() =>
    '''
<svg xmlns="http://www.w3.org/2000/svg" width="180" height="180" viewBox="0 0 180 180">
  <rect width="180" height="180" fill="$_paper"/>
  ${_nest('mark.svg', x: 32.4, y: 32.4, width: 115.2, height: 115.2)}
</svg>
''';

/// [file] from `brand/` placed as a nested SVG.
String _nest(
  String file, {
  required num x,
  required num y,
  required num width,
  required num height,
}) {
  final source = File('$_brand/$file').readAsStringSync().replaceFirst(
    RegExp('<title>[^<]*</title>'),
    '',
  );
  return source.replaceFirst(
    '<svg ',
    '<svg x="$x" y="$y" width="$width" height="$height" ',
  );
}

/// The directory holding the Skribble font files the app ships with.
Future<String> _skribbleFonts() async {
  final library = await Isolate.resolvePackageUri(
    Uri.parse('package:skribble_font_recursive/'),
  );
  if (library == null) {
    _fail('Cannot find skribble_font_recursive. Run `dart pub get` first.');
  }
  return library.resolve('../assets/fonts/').toFilePath();
}

Future<void> _render(
  String svg,
  String output, {
  required int width,
  required int height,
  required String fonts,
}) async {
  final temporary = await Directory.systemTemp.createTemp('openbudget_site');
  try {
    final input = File('${temporary.path}/image.svg')..writeAsStringSync(svg);
    await _run('resvg', [
      '--width',
      '$width',
      '--height',
      '$height',
      '--skip-system-fonts',
      '--use-fonts-dir',
      fonts,
      input.path,
      output,
    ]);
    stdout.writeln('rendered $output');
  } finally {
    temporary.deleteSync(recursive: true);
  }
}

Future<void> _run(String executable, List<String> arguments) async {
  final ProcessResult result;
  try {
    result = await Process.run(executable, arguments);
  } on ProcessException {
    _fail('`$executable` is not on the PATH. Run this inside `devenv shell`.');
  }
  if (result.exitCode != 0) {
    _fail('`$executable` failed:\n${result.stderr}');
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
