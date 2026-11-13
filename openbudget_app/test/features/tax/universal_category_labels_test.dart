import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Every universal tax category needs an English label in `app_en.arb`
/// and a generated getter, because the app shows them for entities in
/// countries without a rule pack (`docs/tax-jurisdictions.md`, U6).
void main() {
  final arb = jsonDecode(
    File('lib/l10n/app_en.arb').readAsStringSync(),
  ) as Map<String, Object?>;
  final generated = File(
    'lib/l10n/generated/app_localizations_en.dart',
  ).readAsStringSync();

  test('every universal category code has an ARB label', () {
    expect(universalCategories, isNotEmpty);
    for (final category in universalCategories) {
      final key = category.labelKey!;
      expect(
        arb[key],
        isA<String>(),
        reason: '${category.code} must label itself as "$key" in app_en.arb',
      );
    }
  });

  test('every universal category label is generated into localizations', () {
    for (final category in universalCategories) {
      final key = category.labelKey!;
      expect(
        generated,
        contains(key),
        reason: 'run flutter gen-l10n so "$key" reaches AppLocalizations',
      );
    }
  });
}
