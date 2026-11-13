// The question contract: every field today's tax profile screen edits has
// a question that the pack asks for the kinds of books the screen shows it
// for, so the generic form (C4) can replace the per-country branches
// without losing a field. The lists below mirror
// `openbudget_app/lib/src/features/tax/screens/tax_profile_screen.dart` as
// of C3; when the screen is replaced, this test pins the form instead.
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// A field the screen edits: the pack that asks it, the question key that
/// stores the answer, and the kinds of books the screen shows it for.
typedef ScreenField = ({
  TaxJurisdiction jurisdiction,
  String key,
  Set<EntityKind> kinds,
});

/// Every question key the screen writes into the profile JSON, plus the
/// three dependents answers that compose the stored `dependents` list.
final screenFields = <ScreenField>[
  // Common, shown for every country and kind.
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'entityKind',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'entityKind',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.ng,
    key: 'entityKind',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'entityKind',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'salesTaxRegistered',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'salesTaxRegistered',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.ng,
    key: 'salesTaxRegistered',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'salesTaxRegistered',
    kinds: EntityKind.values.toSet(),
  ),

  // GB.
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'scottishTaxpayer',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'studentLoanPlan',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'postgraduateLoan',
    kinds: EntityKind.values.toSet(),
  ),
  // The screen's accountingPeriodEndMonth and accountingPeriodEndDay
  // dropdowns are the two halves of the accountingPeriodEnd question.
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'accountingPeriodEnd',
    kinds: {EntityKind.company},
  ),
  (
    jurisdiction: TaxJurisdiction.gb,
    key: 'associatedCompanies',
    kinds: {EntityKind.company},
  ),

  // US.
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'filingStatus',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'taxpayerHasSsn',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'spouseHasSsn',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'taxpayer65OrOlder',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'spouse65OrOlder',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'dependentsUnder17',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'dependents17OrOlder',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'dependentsHaveSsn',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'foreignEarnedIncomeExclusionMinor',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'specifiedServiceTrade',
    kinds: {EntityKind.soleTrader},
  ),
  (
    jurisdiction: TaxJurisdiction.us,
    key: 'homeOfficeMethod',
    kinds: {EntityKind.soleTrader},
  ),

  // NG.
  (
    jurisdiction: TaxJurisdiction.ng,
    key: 'annualRentMinor',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.ng,
    key: 'smallCompanyCeiling',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.ng,
    key: 'mneGroupMember',
    kinds: EntityKind.values.toSet(),
  ),

  // DE.
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'jointAssessment',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'spouseEmployed',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'churchTax',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'churchTaxState',
    kinds: EntityKind.values.toSet(),
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'einkunftsArt',
    kinds: {EntityKind.soleTrader},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'children',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'statutoryPensionMinor',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'commuteKmOneWay',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'commuteDays',
    kinds: {EntityKind.individual},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'previousYearTurnoverMinor',
    kinds: {EntityKind.soleTrader, EntityKind.company},
  ),
  (
    jurisdiction: TaxJurisdiction.de,
    key: 'smallBusinessExemption',
    kinds: EntityKind.values.toSet(),
  ),
];

/// All the ARB keys a question names: its label, help, choice options and
/// the month/day halves.
Set<String> arbKeysOf(TaxProfileQuestion question) => {
  question.labelKey,
  ?question.helpKey,
  if (question is TaxChoiceQuestion) ...[
    for (final option in question.options) option.labelKey,
    ?question.noneLabelKey,
  ],
  if (question is TaxMonthDayQuestion) ...[
    question.monthLabelKey,
    question.dayLabelKey,
  ],
};

void main() {
  group('profileQuestions', () {
    for (final jurisdiction in TaxJurisdiction.values) {
      final pack = TaxRules.forJurisdiction(jurisdiction);

      test('${jurisdiction.countryCode} asks questions of every kind', () {
        for (final kind in EntityKind.values) {
          expect(
            pack.profileQuestions(kind),
            isNotEmpty,
            reason: '${kind.name} has no questions',
          );
        }
      });

      test('${jurisdiction.countryCode} asks the two guardrail questions '
          'of every kind', () {
        for (final kind in EntityKind.values) {
          final keys = [
            for (final question in pack.profileQuestions(kind)) question.key,
          ];
          expect(
            keys,
            containsAll(['taxResident', 'usPerson']),
            reason: '${kind.name} is never asked the guardrails',
          );
        }
      });

      test('${jurisdiction.countryCode} starts with the shared questions', () {
        for (final kind in EntityKind.values) {
          final questions = pack.profileQuestions(kind);
          for (var i = 0; i < commonTaxProfileQuestions.length; i++) {
            expect(
              identical(questions[i], commonTaxProfileQuestions[i]),
              isTrue,
              reason: 'question $i is not the shared definition',
            );
          }
        }
      });

      test('${jurisdiction.countryCode} declares its questions once', () {
        for (final kind in EntityKind.values) {
          final keys = [
            for (final question in pack.profileQuestions(kind)) question.key,
          ];
          expect(
            keys,
            equals(keys.toSet()),
            reason: '${kind.name} has a duplicate key',
          );
        }
      });

      test('${jurisdiction.countryCode} names only AppLocalizations keys', () {
        for (final kind in EntityKind.values) {
          for (final question in pack.profileQuestions(kind)) {
            for (final key in arbKeysOf(question)) {
              expect(
                key,
                startsWith('taxQ'),
                reason: '${question.key} names the non-taxQ key $key',
              );
            }
          }
        }
      });

      test(
        '${jurisdiction.countryCode} conditions reference asked questions',
        () {
          for (final kind in EntityKind.values) {
            final questions = pack.profileQuestions(kind);
            final keys = [for (final question in questions) question.key];
            for (final question in questions) {
              final condition = question.visibleWhen;
              if (condition == null) continue;
              expect(
                keys,
                contains(condition.key),
                reason: '${question.key} depends on an unasked question',
              );
            }
          }
        },
      );

      test('${jurisdiction.countryCode} offers each choice a value and '
          'no duplicates', () {
        for (final kind in EntityKind.values) {
          for (final question in pack.profileQuestions(kind)) {
            if (question is! TaxChoiceQuestion) continue;
            expect(question.options, isNotEmpty, reason: question.key);
            final values = [
              for (final option in question.options) option.value,
            ];
            final uniqueValues = <String>{for (final value in values) value};
            expect(
              uniqueValues,
              hasLength(values.length),
              reason: '${question.key} repeats an option value',
            );
          }
        }
      });

      test('${jurisdiction.countryCode} choice options cover the stored '
          'enum names', () {
        final expectedOptionValues = switch (jurisdiction) {
          TaxJurisdiction.gb => <String, Set<String>>{
            'entityKind': {for (final kind in EntityKind.values) kind.name},
            'studentLoanPlan': {'plan1', 'plan2', 'plan4', 'plan5'},
          },
          TaxJurisdiction.us => <String, Set<String>>{
            'entityKind': {for (final kind in EntityKind.values) kind.name},
            'filingStatus': {
              for (final status in UsFilingStatus.values) status.name,
            },
            'homeOfficeMethod': {
              for (final method in UsHomeOfficeMethod.values) method.name,
            },
          },
          TaxJurisdiction.ng => <String, Set<String>>{
            'entityKind': {for (final kind in EntityKind.values) kind.name},
            'smallCompanyCeiling': {
              for (final ceiling in NgSmallCompanyCeiling.values) ceiling.name,
            },
          },
          TaxJurisdiction.de => <String, Set<String>>{
            'entityKind': {for (final kind in EntityKind.values) kind.name},
            'churchTaxState': {
              for (final state in DeBundesland.values) state.name,
            },
            'einkunftsArt': {for (final art in DeEinkunftsArt.values) art.name},
          },
        };
        final found = <String, Set<String>>{};
        for (final kind in EntityKind.values) {
          for (final question in pack.profileQuestions(kind)) {
            if (question is! TaxChoiceQuestion) continue;
            found[question.key] = {
              ...?found[question.key],
              for (final option in question.options) option.value,
            };
          }
        }
        for (final entry in expectedOptionValues.entries) {
          expect(
            found[entry.key],
            entry.value,
            reason: '${entry.key} does not offer every stored value',
          );
        }
      });
    }

    test('the screen edits nothing the packs do not ask', () {
      for (final field in screenFields) {
        final pack = TaxRules.forJurisdiction(field.jurisdiction);
        for (final kind in field.kinds) {
          final keys = [
            for (final question in pack.profileQuestions(kind)) question.key,
          ];
          expect(
            keys,
            contains(field.key),
            reason:
                '${field.jurisdiction.countryCode} ${kind.name} edits '
                '${field.key} on the tax profile screen but no question '
                'stores it',
          );
        }
      }
    });

    test('optional questions offer a none choice', () {
      final gb = TaxRules.forJurisdiction(TaxJurisdiction.gb)
          .profileQuestions(EntityKind.individual);
      final plan = gb.whereType<TaxChoiceQuestion>().firstWhere(
        (question) => question.key == 'studentLoanPlan',
      );
      expect(plan.noneLabelKey, isNotNull);

      final de = TaxRules.forJurisdiction(TaxJurisdiction.de)
          .profileQuestions(EntityKind.individual);
      final state = de.whereType<TaxChoiceQuestion>().firstWhere(
        (question) => question.key == 'churchTaxState',
      );
      expect(state.noneLabelKey, isNotNull);
    });

    test('conditional questions carry their screen conditions', () {
      List<TaxProfileQuestion> questionsOf(
        TaxJurisdiction jurisdiction,
        EntityKind kind,
      ) => [
        for (final question in TaxRules.forJurisdiction(
          jurisdiction,
        ).profileQuestions(kind))
          question,
      ];

      final spouseSsn = questionsOf(
        TaxJurisdiction.us,
        EntityKind.individual,
      ).firstWhere((question) => question.key == 'spouseHasSsn');
      expect(spouseSsn.visibleWhen, isNotNull);
      expect(
        spouseSsn.visibleWhen!.matches(UsFilingStatus.marriedFilingJointly),
        isTrue,
      );
      expect(
        spouseSsn.visibleWhen!.matches(UsFilingStatus.single),
        isFalse,
      );

      final spouseEmployed = questionsOf(
        TaxJurisdiction.de,
        EntityKind.individual,
      ).firstWhere((question) => question.key == 'spouseEmployed');
      expect(spouseEmployed.visibleWhen!.matches(true), isTrue);
      expect(spouseEmployed.visibleWhen!.matches(false), isFalse);

      final churchState = questionsOf(
        TaxJurisdiction.de,
        EntityKind.company,
      ).firstWhere((question) => question.key == 'churchTaxState');
      expect(churchState.visibleWhen!.matches(true), isTrue);
    });

    test('the month-day question names its two stored fields', () {
      final gb = TaxRules.forJurisdiction(TaxJurisdiction.gb)
          .profileQuestions(EntityKind.company);
      final yearEnd = gb.whereType<TaxMonthDayQuestion>().firstWhere(
        (question) => question.key == 'accountingPeriodEnd',
      );
      // Stored under <key>Month and <key>Day, the fields the screen edits.
      final stored = const GbTaxProfile(
        entityKind: EntityKind.company,
        accountingPeriodEndMonth: 7,
        accountingPeriodEndDay: 15,
      ).toJson();
      expect(stored['accountingPeriodEndMonth'], 7);
      expect(stored['accountingPeriodEndDay'], 15);
      expect(yearEnd.monthLabelKey, startsWith('taxQ'));
      expect(yearEnd.dayLabelKey, startsWith('taxQ'));
    });
  });
}
