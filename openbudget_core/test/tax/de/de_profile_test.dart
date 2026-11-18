// The DeTaxProfile JSON contract: new inputs round-trip, and old JSON keeps
// the behaviour it was saved under — the bare church flag means the 9 %
// assumption, and a sole trader without an Einkunftsart is gewerblich.
import 'dart:convert';

import 'package:openbudget_core/src/tax/de/de_profile.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:test/test.dart';

DeTaxProfile parse(Map<String, Object?> json) =>
    TaxProfile.fromJson(json) as DeTaxProfile;

void main() {
  test('round-trips every input', () {
    const profile = DeTaxProfile(
      entityKind: EntityKind.individual,
      jointAssessment: true,
      churchTax: true,
      churchTaxState: DeBundesland.bayern,
      children: 2,
      spouseEmployed: true,
      statutoryPensionMinor: 123456,
      previousYearTurnoverMinor: 2400000,
      commuteKmOneWay: 25,
      commuteDays: 210,
    );
    final restored = parse(
      jsonDecode(jsonEncode(profile.toJson())) as Map<String, Object?>,
    );
    expect(restored.jointAssessment, isTrue);
    expect(restored.churchTax, isTrue);
    expect(restored.churchTaxState, DeBundesland.bayern);
    expect(restored.churchTaxRateBasisPoints, 800);
    expect(restored.children, 2);
    expect(restored.spouseEmployed, isTrue);
    expect(restored.statutoryPensionMinor, 123456);
    expect(restored.previousYearTurnoverMinor, 2400000);
    expect(restored.commuteKmOneWay, 25);
    expect(restored.commuteDays, 210);
  });

  test('parses old JSON with only the church flag as 9 %', () {
    final profile = parse({
      'jurisdiction': 'DE',
      'entityKind': 'individual',
      'jointAssessment': true,
      'churchTax': true,
      'smallBusinessExemption': true,
    });
    expect(profile.churchTaxState, isNull);
    expect(profile.churchTaxRateBasisPoints, 900);
    expect(profile.children, 0);
    expect(profile.spouseEmployed, isFalse);
    expect(profile.einkunftsArt, DeEinkunftsArt.gewerblich);
  });

  test('parses old JSON without the church flag as no church tax', () {
    final profile = parse({
      'jurisdiction': 'DE',
      'entityKind': 'individual',
    });
    expect(profile.churchTaxRateBasisPoints, 0);
  });

  test('the Bundesland sets the church rate: BY and BW 8 %, others 9 %', () {
    const profile = DeTaxProfile(entityKind: EntityKind.individual);
    for (final state in DeBundesland.values) {
      expect(
        DeTaxProfile(
          entityKind: EntityKind.individual,
          churchTaxState: state,
        ).churchTaxRateBasisPoints,
        state == DeBundesland.bayern || state == DeBundesland.badenWuerttemberg
            ? 800
            : 900,
        reason: state.label,
      );
    }
    // The state wins over the bare flag.
    expect(
      const DeTaxProfile(
        entityKind: EntityKind.individual,
        churchTax: true,
        churchTaxState: DeBundesland.bayern,
      ).churchTaxRateBasisPoints,
      800,
    );
    expect(profile.churchTaxRateBasisPoints, 0);
  });

  test('a sole trader defaults to gewerblich, as the old pack did', () {
    const profile = DeTaxProfile(entityKind: EntityKind.soleTrader);
    expect(profile.einkunftsArt, DeEinkunftsArt.gewerblich);
    final freiberuflich = parse({
      'jurisdiction': 'DE',
      'entityKind': 'soleTrader',
      'einkunftsArt': 'freiberuflich',
    });
    expect(freiberuflich.einkunftsArt, DeEinkunftsArt.freiberuflich);
  });
}
