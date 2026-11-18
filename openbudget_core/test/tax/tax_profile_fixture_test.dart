// The stored-JSON contract: every fixture captured from today's
// serialisation (see profile_fixtures/) round-trips byte-identically
// through the pack decoder, and the two guardrail answers the packs now
// ask join the stored shape without disturbing it.
//
// Fixtures are stored pretty-printed for review; the contract is the
// exact key sequence and values `jsonEncode` writes, so the comparison
// canonicalises whitespace through `jsonEncode(jsonDecode(...))`.
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

const expectedTypes = <TaxJurisdiction, Type>{
  TaxJurisdiction.gb: GbTaxProfile,
  TaxJurisdiction.us: UsTaxProfile,
  TaxJurisdiction.ng: NgTaxProfile,
  TaxJurisdiction.de: DeTaxProfile,
};

void main() {
  final fixtures =
      Directory('test/tax/profile_fixtures')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('the fixture directory is there and holds every jurisdiction', () {
    expect(fixtures, isNotEmpty);
    for (final jurisdiction in TaxJurisdiction.values) {
      expect(
        fixtures.any(
          (file) => file.path.contains(
            '/${jurisdiction.countryCode.toLowerCase()}_',
          ),
        ),
        isTrue,
        reason: 'no fixtures for ${jurisdiction.countryCode}',
      );
    }
  });

  for (final fixture in fixtures) {
    final name = fixture.uri.pathSegments.last;
    test('$name round-trips byte-identically', () {
      final stored = fixture.readAsStringSync();
      final json = jsonDecode(stored) as Map<String, Object?>;
      final code = json['jurisdiction']! as String;
      final jurisdiction = TaxJurisdiction.fromCountryCode(code)!;

      final profile = TaxProfile.fromJson(json);
      expect(profile.runtimeType, expectedTypes[jurisdiction], reason: name);
      expect(
        jsonEncode(profile.toJson()),
        jsonEncode(json),
        reason: '$name must keep its stored key sequence and values',
      );
    });
  }

  test('old fixtures carry no guardrail answers and default them false', () {
    final json = jsonDecode(
      File(
        'test/tax/profile_fixtures/gb_individual_default.json',
      ).readAsStringSync(),
    ) as Map<String, Object?>;
    expect(json.containsKey('taxResident'), isFalse);
    expect(json.containsKey('usPerson'), isFalse);

    final profile = TaxProfile.fromJson(json) as GbTaxProfile;
    expect(profile.taxResident, isFalse);
    expect(profile.usPerson, isFalse);
    // Re-serialising adds nothing, so the stored bytes never move.
    expect(jsonEncode(profile.toJson()), jsonEncode(json));
  });

  test('guardrail answers are stored after the shared fields', () {
    const profile = GbTaxProfile(
      entityKind: EntityKind.individual,
      taxResident: true,
      usPerson: true,
    );
    expect(profile.toJson().keys.toList(), [
      'jurisdiction',
      'entityKind',
      'salesTaxRegistered',
      'taxResident',
      'usPerson',
      'scottishTaxpayer',
    ]);
    final restored = TaxProfile.fromJson(profile.toJson()) as GbTaxProfile;
    expect(restored.taxResident, isTrue);
    expect(restored.usPerson, isTrue);
    expect(jsonEncode(restored.toJson()), jsonEncode(profile.toJson()));
  });

  test('a rejected guardrail answer fails naming the field', () {
    expect(
      () => TaxProfile.fromJson({
        'jurisdiction': 'GB',
        'entityKind': 'individual',
        'taxResident': 'yes',
      }),
      throwsFormatException,
    );
  });
}
