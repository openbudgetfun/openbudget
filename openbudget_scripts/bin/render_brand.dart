#! /usr/bin/env dart

/// Renders OpenBudget's platform icons and splash images from the SVG
/// sources in `brand/`.
///
/// Run from the repository root:
///
/// ```sh
/// dart run openbudget_scripts:render_brand
/// ```
///
/// The script lays the mark out for each platform (a full-bleed paper tile
/// for iOS, web and Windows; a squircle with a shadow for macOS; the adaptive
/// safe zone for Android; transparent marks for the splash screens),
/// rasterises those layouts with `resvg` into `openbudget_app/build/brand/`,
/// then runs `flutter_launcher_icons` and `flutter_native_splash`, which read
/// their source images from there. The small mark becomes the web app's SVG
/// favicon.
///
/// `openbudget_app/web/index.html` is maintained by hand: the splash
/// generator rewrites it on every run, so the script restores it afterwards.
/// It does the same for the Xcode project, which the icon generator touches
/// without need.
/// The generators also reformat the JSON they touch, so the script runs
/// `dprint fmt` over it, then compresses every generated PNG losslessly with
/// `oxipng`.
///
/// `resvg`, `oxipng` and `dprint` must be on the `PATH`; the devenv shell
/// provides all three.
library;

import 'dart:io';

/// The repository's brand sources.
const _brandDirectory = 'brand';

/// Where the launcher icon and splash configs read their source images.
const _outputDirectory = 'openbudget_app/build/brand';

/// `ObSwatch.newsprint`, the sunny cream tile behind the mark.
const _paper = '#FFF4DE';

/// The JSON files the generators rewrite in their own style.
const _generatedJson = [
  'openbudget_app/web/manifest.json',
  'openbudget_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
  'openbudget_app/ios/Runner/Assets.xcassets/LaunchBackground.imageset/Contents.json',
  'openbudget_app/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json',
  'openbudget_app/macos/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
];

/// The directories that hold only generated icons and splash images.
const _generatedRasterDirectories = [
  'openbudget_app/android/app/src/main/res',
  'openbudget_app/ios/Runner/Assets.xcassets/AppIcon.appiconset',
  'openbudget_app/ios/Runner/Assets.xcassets/LaunchBackground.imageset',
  'openbudget_app/ios/Runner/Assets.xcassets/LaunchImage.imageset',
  'openbudget_app/macos/Runner/Assets.xcassets/AppIcon.appiconset',
  'openbudget_app/web/icons',
  'openbudget_app/web/splash/img',
];

Future<void> main(List<String> arguments) async {
  if (!File('$_brandDirectory/mark.svg').existsSync()) {
    _fail(
      'Run from the repository root: $_brandDirectory/mark.svg is missing.',
    );
  }
  await _requireTool('resvg', ['--version']);
  await _requireTool('oxipng', ['--version']);
  await _requireTool('dprint', ['--version']);

  final mark = _readMark('mark.svg');
  final night = _readMark('mark-night.svg');
  final mono = _readMark('mark-mono.svg');

  Directory(_outputDirectory).createSync(recursive: true);
  final layouts = <String, _Layout>{
    // iOS, web, Windows and Android's legacy icon: a full-bleed paper tile.
    // The mark spans 64% of the tile, so it also clears the 80% safe circle
    // of a maskable web icon.
    'app_icon.png': _Layout(
      size: 1024,
      mark: mark,
      scale: .64,
      background: _paper,
    ),
    // iOS 18 dark icon: the system draws the dark ground.
    'app_icon_ios_dark.png': _Layout(size: 1024, mark: night, scale: .64),
    // iOS 18 tinted icon: light on transparent; iOS supplies the tint.
    'app_icon_ios_tinted.png': _Layout(
      size: 1024,
      mark: mono,
      scale: .64,
      monoColour: '#FFFFFF',
    ),
    // macOS: Apple's 824pt squircle on a 1024pt canvas, with its shadow.
    'app_icon_macos.png': _Layout(
      size: 1024,
      mark: mark,
      scale: .64,
      background: _paper,
      macOS: true,
    ),
    // Android adaptive layers: the mark inside the 66dp safe zone of 108dp.
    'android_foreground.png': _Layout(size: 1024, mark: mark, scale: .52),
    'android_monochrome.png': _Layout(
      size: 1024,
      mark: mono,
      scale: .52,
      monoColour: '#000000',
    ),
    // Splash screens. flutter_native_splash treats `image` as 4x.
    'splash.png': _Layout(size: 640, mark: mark, scale: .94),
    'splash_night.png': _Layout(size: 640, mark: night, scale: .94),
    // Android 12 shows the splash icon inside a 768px circle of 1152px.
    'splash_android12.png': _Layout(size: 1152, mark: mark, scale: .5),
    'splash_android12_night.png': _Layout(size: 1152, mark: night, scale: .5),
  };

  for (final MapEntry(key: name, value: layout) in layouts.entries) {
    await _rasterise(layout, '$_outputDirectory/$name');
    stdout.writeln('rendered $_outputDirectory/$name');
  }

  File('$_brandDirectory/mark-small.svg')
      .copySync('openbudget_app/web/favicon.svg');
  stdout.writeln('copied the small mark to openbudget_app/web/favicon.svg');

  // flutter_launcher_icons also rewrites an unrelated asset-symbol setting in
  // the Xcode project; the icon set's name is already `AppIcon`, so keep the
  // project as it was.
  final xcodeProject = File(
    'openbudget_app/ios/Runner.xcodeproj/project.pbxproj',
  );
  final xcodeProjectSource = xcodeProject.readAsStringSync();
  await _run('dart', [
    'run',
    'flutter_launcher_icons',
  ], workingDirectory: 'openbudget_app');
  xcodeProject.writeAsStringSync(xcodeProjectSource);

  final indexHtml = File('openbudget_app/web/index.html');
  final handwrittenIndex = indexHtml.readAsStringSync();
  await _run('dart', [
    'run',
    'flutter_native_splash:create',
  ], workingDirectory: 'openbudget_app');
  indexHtml.writeAsStringSync(handwrittenIndex);

  await _run('dprint', ['fmt', ..._generatedJson]);

  final rasters = [
    for (final directory in _generatedRasterDirectories)
      for (final entity in Directory(directory).listSync(recursive: true))
        if (entity is File && entity.path.endsWith('.png')) entity.path,
  ];
  await _run('oxipng', [
    '--quiet',
    '--opt',
    '4',
    '--strip',
    'safe',
    ...rasters,
  ]);
  stdout.writeln('compressed ${rasters.length} generated PNGs');
}

/// How one raster lays the mark out.
final class _Layout {
  const _Layout({
    required this.size,
    required this.mark,
    required this.scale,
    this.background,
    this.monoColour,
    this.macOS = false,
  });

  /// The square canvas, in pixels.
  final int size;

  /// The mark's SVG source.
  final String mark;

  /// The mark's 128-unit artboard as a share of the canvas (or, for macOS,
  /// of the squircle).
  final double scale;

  /// The tile colour; transparent when null.
  final String? background;

  /// The colour that `currentColor` resolves to in the monochrome mark.
  final String? monoColour;

  /// Whether to draw the macOS squircle and shadow under the mark.
  final bool macOS;

  /// The full SVG document for this layout.
  String get document {
    final buffer = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" viewBox="0 0 $size $size">',
    );
    // macOS Big Sur grid: an 824px squircle (radius 185px) centred on a
    // 1024px canvas, with a soft drop shadow beneath it.
    final tile = macOS ? size * 824 / 1024 : size.toDouble();
    final inset = (size - tile) / 2;
    if (macOS) {
      buffer
        ..write(
          '<defs><filter id="shadow" x="-10%" y="-10%" width="120%" height="130%">',
        )
        ..write(
          '<feDropShadow dx="0" dy="${size * 10 / 1024}" stdDeviation="${size * 10 / 1024}" flood-color="#000" flood-opacity=".28"/>',
        )
        ..write('</filter></defs>')
        ..write(
          '<rect x="$inset" y="$inset" width="$tile" height="$tile" rx="${tile * 185 / 824}" fill="$background" filter="url(#shadow)"/>',
        );
    } else if (background != null) {
      buffer.write('<rect width="$size" height="$size" fill="$background"/>');
    }
    final markSize = tile * scale;
    final offset = (size - markSize) / 2;
    var nested = mark.replaceFirst(
      '<svg ',
      '<svg x="$offset" y="$offset" width="$markSize" height="$markSize" ',
    );
    if (monoColour case final colour?) {
      nested = nested.replaceAll('currentColor', colour);
    }
    buffer
      ..write(nested)
      ..write('</svg>');
    return buffer.toString();
  }
}

String _readMark(String name) {
  final source = File('$_brandDirectory/$name').readAsStringSync();
  // Drop the XML title: the nested mark is artwork, not a document.
  return source.replaceFirst(RegExp(r'\s*<title>[^<]*</title>'), '');
}

Future<void> _rasterise(_Layout layout, String output) async {
  final temporary = await Directory.systemTemp.createTemp('openbudget_brand');
  try {
    final input = File('${temporary.path}/layout.svg')
      ..writeAsStringSync(layout.document);
    await _run('resvg', [
      '--width',
      '${layout.size}',
      '--height',
      '${layout.size}',
      input.path,
      output,
    ], quiet: true);
  } finally {
    temporary.deleteSync(recursive: true);
  }
}

Future<void> _requireTool(String executable, List<String> arguments) async {
  try {
    final result = await Process.run(executable, arguments);
    if (result.exitCode == 0) {
      return;
    }
  } on ProcessException {
    // Reported below.
  }
  _fail('`$executable` is not on the PATH. Run this inside `devenv shell`.');
}

Future<void> _run(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  bool quiet = false,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    mode: quiet ? ProcessStartMode.normal : ProcessStartMode.inheritStdio,
  );
  final stderrText = quiet
      ? process.stderr.transform(const SystemEncoding().decoder).join()
      : Future.value('');
  if (quiet) {
    await process.stdout.drain<void>();
  }
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    _fail(
      '`$executable ${arguments.join(' ')}` failed with exit code $exitCode.\n${await stderrText}',
    );
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
