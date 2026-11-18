// One test per pack and kind of books that answers every question the pack
// asks through the form, saves, and checks the stored profile JSON byte for
// byte. The questions are not listed here: the driver reads them from the
// pack, so a question added to a pack fails these tests until they answer it.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/tax/tax_profile_form_values.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../tax_test_data.dart';
import 'tax_profile_test_harness.dart';

/// A month and day of the month answer.
typedef MonthDay = ({int month, int day});

/// Answers [question] through the form: a bool as a switch, a choice by the
/// label of its option (null for the "none" choice), text as typed, and a
/// month and day by the two dropdowns.
Future<void> answerQuestion(
  WidgetTester tester,
  TaxProfileQuestion question,
  Object? answer,
) async {
  switch (question) {
    case TaxBoolQuestion():
      await setTaxSwitch(tester, question.key, value: answer! as bool);
    case final TaxChoiceQuestion choice:
      final labelKey = answer == null
          ? choice.noneLabelKey!
          : choice.options
                .singleWhere((option) => option.value == answer)
                .labelKey;
      await pickTaxOption(tester, question.key, taxText(labelKey));
    case TaxCountQuestion() || TaxMoneyQuestion():
      await enterTaxText(tester, question.key, answer! as String);
    case TaxMonthDayQuestion():
      final (:month, :day) = answer! as MonthDay;
      await revealTaxField(tester, taxField(question.key));
      final dropdowns = find.descendant(
        of: taxField(question.key),
        matching: find.byType(DropdownButtonFormField<int>),
      );
      await tester.tap(dropdowns.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(_monthName(month)).last);
      await tester.pumpAndSettle();
      await tester.tap(dropdowns.last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('$day').last);
      await tester.pumpAndSettle();
  }
}

String _monthName(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];

/// Fills every question [countryCode] asks of [kind] with [answers], saves,
/// and expects the stored JSON to be exactly [expected]'s.
void packTest(
  String name, {
  required String countryCode,
  required EntityKind kind,
  required Map<String, Object?> answers,
  required TaxProfile expected,
}) {
  testWidgets(name, (tester) async {
    tester.view
      ..physicalSize = const Size(800, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final pack = TaxRules.forJurisdiction(
      TaxJurisdiction.fromCountryCode(countryCode)!,
    );
    final questions = [
      for (final question in pack.profileQuestions(kind))
        if (question.key != taxEntityKindKey) question,
    ];
    expect(
      answers.keys.toSet(),
      questions.map((question) => question.key).toSet(),
      reason: 'the test must answer exactly the questions the pack asks',
    );

    final fake = FakeTaxRepository();
    await tester.pumpWidget(
      buildTaxProfileApp(fake, countryCode: countryCode, kind: kind),
    );
    await tester.pumpAndSettle();

    for (final question in questions) {
      await answerQuestion(tester, question, answers[question.key]);
    }
    await saveTaxProfile(tester);

    expect(fake.savedProfiles, hasLength(1));
    expect(
      fake.savedProfiles.single.profileJson,
      jsonEncode(expected.toJson()),
    );
  });
}

void main() {
  group('GB', () {
    packTest(
      'an individual edits every question and saves',
      countryCode: 'GB',
      kind: EntityKind.individual,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'scottishTaxpayer': true,
        'studentLoanPlan': 'plan5',
        'postgraduateLoan': true,
      },
      expected: const GbTaxProfile(
        entityKind: EntityKind.individual,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        scottishTaxpayer: true,
        studentLoanPlan: GbStudentLoanPlan.plan5,
        postgraduateLoan: true,
      ),
    );

    packTest(
      'a company edits every question and saves',
      countryCode: 'GB',
      kind: EntityKind.company,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'scottishTaxpayer': true,
        'studentLoanPlan': 'plan4',
        'postgraduateLoan': true,
        'accountingPeriodEnd': (month: 5, day: 30),
        'associatedCompanies': '3',
      },
      expected: const GbTaxProfile(
        entityKind: EntityKind.company,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        scottishTaxpayer: true,
        studentLoanPlan: GbStudentLoanPlan.plan4,
        postgraduateLoan: true,
        accountingPeriodEndMonth: 5,
        accountingPeriodEndDay: 30,
        associatedCompanies: 3,
      ),
    );
  });

  group('US', () {
    packTest(
      'an individual edits every question and saves',
      countryCode: 'US',
      kind: EntityKind.individual,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'filingStatus': 'marriedFilingJointly',
        'taxpayerHasSsn': false,
        'spouseHasSsn': false,
        'taxpayer65OrOlder': true,
        'spouse65OrOlder': true,
        'dependentsUnder17': '2',
        'dependents17OrOlder': '1',
        'dependentsHaveSsn': true,
        'foreignEarnedIncomeExclusionMinor': '5,000.50',
      },
      expected: const UsTaxProfile(
        entityKind: EntityKind.individual,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        filingStatus: UsFilingStatus.marriedFilingJointly,
        taxpayerHasSsn: false,
        spouseHasSsn: false,
        taxpayer65OrOlder: true,
        spouse65OrOlder: true,
        foreignEarnedIncomeExclusionMinor: 500050,
        dependents: [
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: false, hasValidSsn: true),
        ],
      ),
    );

    packTest(
      'a sole trader edits every question and saves',
      countryCode: 'US',
      kind: EntityKind.soleTrader,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'filingStatus': 'headOfHousehold',
        'specifiedServiceTrade': true,
        'homeOfficeMethod': 'regular',
      },
      expected: const UsTaxProfile(
        entityKind: EntityKind.soleTrader,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        filingStatus: UsFilingStatus.headOfHousehold,
        specifiedServiceTrade: true,
        homeOfficeMethod: UsHomeOfficeMethod.regular,
      ),
    );

    packTest(
      'a company edits every question and saves',
      countryCode: 'US',
      kind: EntityKind.company,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'filingStatus': 'marriedFilingSeparately',
      },
      expected: const UsTaxProfile(
        entityKind: EntityKind.company,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        filingStatus: UsFilingStatus.marriedFilingSeparately,
      ),
    );
  });

  group('NG', () {
    packTest(
      'an individual edits every question and saves',
      countryCode: 'NG',
      kind: EntityKind.individual,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'annualRentMinor': '1,200,000.50',
        'smallCompanyCeiling': 'ntaaIntended',
        'mneGroupMember': true,
      },
      expected: const NgTaxProfile(
        entityKind: EntityKind.individual,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        annualRentMinor: 120000050,
        smallCompanyCeiling: NgSmallCompanyCeiling.ntaaIntended,
        mneGroupMember: true,
      ),
    );

    packTest(
      'a company edits every question and saves',
      countryCode: 'NG',
      kind: EntityKind.company,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'annualRentMinor': '250000',
        'smallCompanyCeiling': 'ntaGazette',
        'mneGroupMember': true,
      },
      expected: const NgTaxProfile(
        entityKind: EntityKind.company,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        annualRentMinor: 25000000,
        mneGroupMember: true,
      ),
    );
  });

  group('DE', () {
    packTest(
      'an individual edits every question and saves',
      countryCode: 'DE',
      kind: EntityKind.individual,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'jointAssessment': true,
        'spouseEmployed': true,
        'churchTax': true,
        'churchTaxState': 'bayern',
        'children': '2',
        'statutoryPensionMinor': '4800.25',
        'commuteKmOneWay': '25',
        'commuteDays': '220',
        'smallBusinessExemption': false,
      },
      expected: const DeTaxProfile(
        entityKind: EntityKind.individual,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        jointAssessment: true,
        spouseEmployed: true,
        churchTax: true,
        churchTaxState: DeBundesland.bayern,
        children: 2,
        statutoryPensionMinor: 480025,
        commuteKmOneWay: 25,
        commuteDays: 220,
        smallBusinessExemption: false,
      ),
    );

    packTest(
      'a sole trader edits every question and saves',
      countryCode: 'DE',
      kind: EntityKind.soleTrader,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'jointAssessment': true,
        'churchTax': true,
        'churchTaxState': 'nordrheinWestfalen',
        'einkunftsArt': 'freiberuflich',
        'previousYearTurnoverMinor': '17500',
        'smallBusinessExemption': false,
      },
      expected: const DeTaxProfile(
        entityKind: EntityKind.soleTrader,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        jointAssessment: true,
        churchTax: true,
        churchTaxState: DeBundesland.nordrheinWestfalen,
        einkunftsArt: DeEinkunftsArt.freiberuflich,
        previousYearTurnoverMinor: 1750000,
        smallBusinessExemption: false,
      ),
    );

    packTest(
      'a company edits every question and saves',
      countryCode: 'DE',
      kind: EntityKind.company,
      answers: {
        'salesTaxRegistered': true,
        'taxResident': true,
        'usPerson': true,
        'jointAssessment': true,
        'churchTax': true,
        'churchTaxState': 'hessen',
        'previousYearTurnoverMinor': '90000.50',
        'smallBusinessExemption': false,
      },
      expected: const DeTaxProfile(
        entityKind: EntityKind.company,
        salesTaxRegistered: true,
        taxResident: true,
        usPerson: true,
        jointAssessment: true,
        churchTax: true,
        churchTaxState: DeBundesland.hessen,
        previousYearTurnoverMinor: 9000050,
        smallBusinessExemption: false,
      ),
    );
  });

  testWidgets('church tax with no state picks "not specified"', (tester) async {
    // Tall enough for the whole menu, which builds only the rows on screen.
    tester.view
      ..physicalSize = const Size(800, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = FakeTaxRepository(
      profile: taxProfileRecord(
        profile: const DeTaxProfile(
          entityKind: EntityKind.individual,
          churchTax: true,
          churchTaxState: DeBundesland.hessen,
        ),
      ),
    );
    await tester.pumpWidget(buildTaxProfileApp(fake, countryCode: 'DE'));
    await tester.pumpAndSettle();

    await pickTaxOption(
      tester,
      'churchTaxState',
      taxText('taxQDeChurchStateNone'),
    );
    await saveTaxProfile(tester);

    expect(lastSavedTaxProfile(fake), isNot(contains('churchTaxState')));
  });
}
