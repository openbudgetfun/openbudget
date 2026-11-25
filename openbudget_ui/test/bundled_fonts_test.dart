import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Every app build ships, and Flutter web downloads before its first frame,
/// each face this package registers. These checks keep that set to the faces
/// the theme letters with, each present and trimmed.
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final families = RegExp(
    r'^    - family: (\S+)$',
    multiLine: true,
  ).allMatches(pubspec).map((match) => match.group(1)!).toList();
  final assets = RegExp(
    r'^        - asset: (\S+)$',
    multiLine: true,
  ).allMatches(pubspec).map((match) => match.group(1)!).toList();

  test('given the theme typefaces when the pubspec is read then exactly '
      'those families are registered', () {
    expect(
      families.toSet(),
      {obDisplayTypeface, obTextTypeface, obStampTypeface},
    );
    for (final family in [obDisplayTypeface, obTextTypeface, obStampTypeface]) {
      expect(
        [obDisplayFontFamily, obTextFontFamily, obStampFontFamily],
        contains('packages/openbudget_ui/$family'),
      );
    }
  });

  test('given the registered faces when checked then each file exists and '
      'the set stays under its size budget', () {
    expect(assets, isNotEmpty);
    var total = 0;
    for (final asset in assets) {
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: '$asset is missing');
      total += file.lengthSync();
    }
    // 14 trimmed faces are about 2.9 MB. The upstream package's 129 were
    // 60 MB; raise this only with a face the theme really letters with.
    expect(total, lessThan(4 * 1024 * 1024));
  });

  test('given the pubspec when read then the full upstream font package is '
      'not a dependency', () {
    expect(pubspec, isNot(contains('skribble_font_recursive:')));
  });
}
