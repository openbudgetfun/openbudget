// The answers contract the generic profile form relies on: every pack's
// profile reads its questions back as answers, and applying those answers
// returns a profile that stores the same bytes. The US dependents answers
// and GB's defaulted accounting period are the two places the answers
// differ from the stored JSON.
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  final fixtures = Directory('test/tax/profile_fixtures')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList();

  for (final fixture in fixtures) {
    final name = fixture.uri.pathSegments.last;
    test('$name survives its own answers unchanged', () {
      final stored = jsonDecode(fixture.readAsStringSync());
      final profile = TaxProfile.fromJson(stored as Map<String, Object?>);

      final applied = profile.withAnswers(profile.toAnswers());

      expect(jsonEncode(applied.toJson()), jsonEncode(profile.toJson()));
    });
  }

  group('GbTaxProfile', () {
    test('answers show the default accounting period', () {
      const profile = GbTaxProfile(entityKind: EntityKind.company);

      expect(profile.toAnswers(), containsPair('accountingPeriodEndMonth', 3));
      expect(profile.toAnswers(), containsPair('accountingPeriodEndDay', 31));
      expect(profile.toJson(), isNot(contains('accountingPeriodEndMonth')));
    });

    test('a default period is stored as nothing again', () {
      const profile = GbTaxProfile(
        entityKind: EntityKind.company,
        accountingPeriodEndMonth: 12,
      );

      final reset = profile.withAnswers({
        'accountingPeriodEndMonth': 3,
        'accountingPeriodEndDay': 31,
      });

      expect(reset.toJson(), isNot(contains('accountingPeriodEndMonth')));
    });

    test('a "none" choice clears the student loan plan', () {
      const profile = GbTaxProfile(
        entityKind: EntityKind.individual,
        studentLoanPlan: GbStudentLoanPlan.plan2,
      );

      final cleared = profile.withAnswers({'studentLoanPlan': null});

      expect((cleared as GbTaxProfile).studentLoanPlan, isNull);
    });
  });

  group('UsTaxProfile', () {
    test('answers count the dependents and fold the SSN answer', () {
      const profile = UsTaxProfile(
        entityKind: EntityKind.individual,
        dependents: [
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: false, hasValidSsn: true),
        ],
      );

      final answers = profile.toAnswers();

      expect(answers, containsPair('dependentsUnder17', 2));
      expect(answers, containsPair('dependents17OrOlder', 1));
      expect(answers, containsPair('dependentsHaveSsn', true));
      expect(answers, isNot(contains('dependents')));
    });

    test('no dependents never claims they have SSNs', () {
      const profile = UsTaxProfile(entityKind: EntityKind.individual);

      expect(profile.toAnswers(), containsPair('dependentsHaveSsn', false));
    });

    test('the dependents answers compose the stored list', () {
      const profile = UsTaxProfile(entityKind: EntityKind.individual);

      final updated = profile.withAnswers({
        'dependentsUnder17': 1,
        'dependents17OrOlder': 2,
        'dependentsHaveSsn': true,
      });

      expect(updated.toJson()['dependents'], [
        {'underSeventeen': true, 'hasValidSsn': true},
        {'underSeventeen': false, 'hasValidSsn': true},
        {'underSeventeen': false, 'hasValidSsn': true},
      ]);
    });

    test('unchanged dependents answers keep mixed SSN answers', () {
      const profile = UsTaxProfile(
        entityKind: EntityKind.individual,
        dependents: [
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: true, hasValidSsn: false),
        ],
      );

      final saved = profile.withAnswers({'filingStatus': 'headOfHousehold'});

      expect(saved.toJson()['dependents'], profile.toJson()['dependents']);
    });

    test('an answered count that is not a whole number is refused', () {
      const profile = UsTaxProfile(entityKind: EntityKind.individual);

      expect(
        () => profile.withAnswers({'dependentsUnder17': -1}),
        throwsFormatException,
      );
    });
  });

  test('answers keep the fields a question does not name', () {
    const profile = DeTaxProfile(
      entityKind: EntityKind.individual,
      children: 2,
      taxResident: true,
    );

    final updated = profile.withAnswers({'churchTax': true});

    expect((updated as DeTaxProfile).churchTax, isTrue);
    expect(updated.children, 2);
    expect(updated.taxResident, isTrue);
  });
}
