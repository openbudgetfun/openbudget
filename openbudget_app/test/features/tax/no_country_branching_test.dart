// The tax screens ask the packs' questions and never branch on a country's
// profile class. Adding a country adds a pack, not an `is` check here.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A type check, cast or pattern on a country profile class such as
/// `GbTaxProfile`: a two-letter country prefix before `TaxProfile`.
final _countryProfileCheck = RegExp(
  r'(?:\b(?:is|as)!?\s+|\bcase\s+(?:final\s+|const\s+)?)[A-Z][a-z]TaxProfile\b',
);

void main() {
  test('no code in the app branches on a country profile class', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (_countryProfileCheck.hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('the check recognises the forms it is meant to catch', () {
    for (final line in [
      'final gb = profile is GbTaxProfile ? profile : null;',
      'if (profile is! UsTaxProfile) return;',
      'final us = profile as UsTaxProfile;',
      'case final NgTaxProfile ng:',
      'case DeTaxProfile():',
    ]) {
      expect(_countryProfileCheck.hasMatch(line), isTrue, reason: line);
    }
    for (final line in [
      'final TaxProfile profile;',
      'const GbTaxProfile(entityKind: EntityKind.individual)',
      'profile is TaxProfile',
    ]) {
      expect(_countryProfileCheck.hasMatch(line), isFalse, reason: line);
    }
  });
}
