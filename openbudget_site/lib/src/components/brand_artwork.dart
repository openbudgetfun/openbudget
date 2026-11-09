import 'dart:io';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// The repository's brand sources, relative to this package.
const brandDirectory = '../brand';

/// A file from `brand/`, inlined into the page as decorative SVG.
///
/// The site reads the brand sources when it is built, so the page always
/// draws the mark exactly as `brand/` does. The paper colourway's hex
/// colours stay in place; `web/styles.css` repaints them for night.
final class BrandArtwork extends StatelessComponent {
  const BrandArtwork(this.file, {this.classes, super.key});

  /// The file name inside `brand/`, such as `lockup.svg`.
  final String file;

  /// Classes for the `<svg>` element.
  final String? classes;

  @override
  Component build(BuildContext context) =>
      RawText(inlineBrandSvg(file, classes: classes));
}

/// The SVG in `brand/[file]`, trimmed for inlining: no XML title or
/// comments, no whitespace between tags, and hidden from assistive
/// technology because the surrounding link or heading names it.
String inlineBrandSvg(String file, {String? classes}) {
  final source = File('$brandDirectory/$file').readAsStringSync();
  final classAttribute = classes == null ? '' : ' class="$classes"';
  return source
      .replaceAll(RegExp('<title>[^<]*</title>'), '')
      .replaceAll(RegExp('<!--.*?-->', dotAll: true), '')
      .replaceAll(RegExp(r'>\s+<'), '><')
      .replaceFirst(
        '<svg ',
        '<svg aria-hidden="true" focusable="false"$classAttribute ',
      )
      .trim();
}
