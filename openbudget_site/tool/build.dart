/// Builds the site into `build/jaspr`, ready to deploy.
///
/// Run from this package's directory, with `jaspr_cli` activated:
///
/// ```sh
/// dart run tool/build.dart
/// ```
///
/// It runs `jaspr build` with the sitemap domain from `siteConfig`, then
/// removes what build_runner writes beside the pages: `packages/` (the
/// assets of every dependency), `.dart_tool/` (a package config holding the
/// build machine's absolute paths) and `.build.manifest`. None of them
/// belong on a public host. It fails unless the home page, the not-found
/// page and the sitemap were all written.
library;

import 'dart:io';

import 'package:openbudget_site/site_config.dart';

const _output = 'build/jaspr';
const _leftovers = ['packages', '.dart_tool', '.build.manifest'];
const _requiredFiles = ['index.html', '404.html', 'sitemap.xml'];

Future<void> main() async {
  final Process jaspr;
  try {
    jaspr = await Process.start('jaspr', [
      'build',
      '--sitemap-domain=${siteConfig.siteUrl.origin}',
      // The not-found page is a fallback, not a page to index.
      '--sitemap-exclude=^/404',
    ]);
  } on ProcessException {
    _fail(
      '`jaspr` is not on the PATH. '
      'Run `dart pub global activate jaspr_cli 0.23.5` first.',
    );
  }
  // With no terminal on stdin, `jaspr build` warns about the missing
  // jaspr_builder dependency instead of offering to add it (see
  // pubspec.yaml for why the site has none).
  await jaspr.stdin.close();
  await Future.wait([
    stdout.addStream(jaspr.stdout),
    stderr.addStream(jaspr.stderr),
  ]);
  final exitCode = await jaspr.exitCode;
  if (exitCode != 0) {
    _fail('`jaspr build` failed with exit code $exitCode.');
  }

  for (final name in _leftovers) {
    final path = '$_output/$name';
    final entity = FileSystemEntity.isDirectorySync(path)
        ? Directory(path)
        : File(path);
    if (entity.existsSync()) entity.deleteSync(recursive: true);
  }

  final missing = [
    for (final name in _requiredFiles)
      if (!File('$_output/$name').existsSync()) name,
  ];
  if (missing.isNotEmpty) {
    _fail('`jaspr build` did not write ${missing.join(', ')}.');
  }

  final files =
      Directory(_output).listSync(recursive: true).whereType<File>().toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  var total = 0;
  stdout.writeln('\nReady to deploy from $_output:');
  for (final file in files) {
    final size = file.lengthSync();
    total += size;
    final name = file.path.substring(_output.length + 1);
    stdout.writeln('${_kilobytes(size).padLeft(9)}  $name');
  }
  stdout.writeln('${_kilobytes(total).padLeft(9)}  total');
}

String _kilobytes(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
