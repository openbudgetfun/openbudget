// The filing calendar contract (docs/tax-jurisdictions.md, task C5): every
// pack derives sourced, neutrally worded, sorted deadlines, and every
// deadline the four tax skills name is produced for a representative
// profile and year.
import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

TaxProfile _profile(
  TaxJurisdiction jurisdiction,
  EntityKind kind, [
  Map<String, Object?> extra = const {},
]) => TaxProfile.fromJson({
  'jurisdiction': jurisdiction.countryCode,
  'entityKind': kind.name,
  ...extra,
});

/// The deadlines one skill names, with the profile and year that produce
/// them.
typedef _SkillDeadline = ({
  List<String> ids,
  TaxJurisdiction jurisdiction,
  int startYear,
  EntityKind kind,
  Map<String, Object?> profile,
  String skill,
});

_SkillDeadline _named(
  String skill,
  TaxJurisdiction jurisdiction,
  EntityKind kind,
  List<String> ids, {
  int startYear = 2026,
  Map<String, Object?> profile = const {},
}) => (
  ids: ids,
  jurisdiction: jurisdiction,
  startYear: startYear,
  kind: kind,
  profile: profile,
  skill: skill,
);

/// Every deadline id the skills name. Each entry lists the ids one
/// representative profile produces; the test splits them.
final List<_SkillDeadline> _skillDeadlines = [
  _named(
    'uk-personal-tax',
    TaxJurisdiction.gb,
    EntityKind.individual,
    [
      'gb.sa.notify',
      'gb.sa.paper-return',
      'gb.sa.coding-out',
      'gb.sa.online-return',
      'gb.sa.balancing-payment',
      'gb.sa.class2-voluntary',
      'gb.sa.payment-on-account-1',
      'gb.sa.payment-on-account-2',
      'gb.sa.amend',
    ],
    startYear: 2025,
  ),
  _named('uk-personal-tax', TaxJurisdiction.gb, EntityKind.soleTrader, [
    'gb.mtd.quarterly-update',
    'gb.mtd.final-declaration',
  ]),
  _named('uk-company-tax', TaxJurisdiction.gb, EntityKind.company, [
    'gb.ct.payment',
    'gb.ct.return',
    'gb.ct.s455',
    'gb.co.accounts',
  ]),
  _named('uk-vat-payroll', TaxJurisdiction.gb, EntityKind.company, [
    'gb.paye.p60',
    'gb.paye.p11d',
    'gb.paye.class-1a',
    'gb.paye.eps',
    'gb.paye.pension-contributions',
  ]),
  _named(
    'uk-vat-payroll',
    TaxJurisdiction.gb,
    EntityKind.soleTrader,
    ['gb.vat.return'],
    profile: {'salesTaxRegistered': true},
  ),
  _named('us-federal-tax', TaxJurisdiction.us, EntityKind.individual, [
    'us.1040.return',
    'us.1040.extended-return',
    'us.1040-es.estimated-payment',
    'us.fbar.report',
    'us.fbar.extended-report',
  ]),
  _named(
    'us-federal-tax',
    TaxJurisdiction.us,
    EntityKind.individual,
    ['us.1040.abroad-return', 'us.1040.abroad-letter-extension'],
    profile: {'foreignEarnedIncomeExclusionMinor': 13290000},
  ),
  _named('us-federal-tax', TaxJurisdiction.us, EntityKind.soleTrader, [
    'us.941.quarterly-return',
    'us.940.futa-deposit',
    'us.940.annual-return',
    'us.w2.wage-statements',
    'us.1099-nec.nonemployee-compensation',
    'us.1099-misc.payee-copy',
    'us.1099-misc.irs-paper',
    'us.1099-misc.irs-electronic',
  ]),
  _named('us-federal-tax', TaxJurisdiction.us, EntityKind.company, [
    'us.1120.return',
    'us.1120.extended-return',
    'us.1120.estimated-payment',
  ]),
  _named('nigeria-tax', TaxJurisdiction.ng, EntityKind.individual, [
    'ng.pit.annual-return',
  ]),
  _named('nigeria-tax', TaxJurisdiction.ng, EntityKind.soleTrader, [
    'ng.paye.employer-return',
    'ng.paye.monthly-remittance',
    'ng.wht.monthly-remittance',
  ]),
  _named('nigeria-tax', TaxJurisdiction.ng, EntityKind.company, [
    'ng.cit.annual-return',
  ]),
  _named(
    'nigeria-tax',
    TaxJurisdiction.ng,
    EntityKind.soleTrader,
    ['ng.vat.monthly-return'],
    profile: {'salesTaxRegistered': true},
  ),
  _named('germany-tax', TaxJurisdiction.de, EntityKind.individual, [
    'de.erklaerung.abgabe',
    'de.erklaerung.abgabe-beraten',
  ]),
  _named('germany-tax', TaxJurisdiction.de, EntityKind.soleTrader, [
    'de.est.vorauszahlung',
    'de.gewst.vorauszahlung',
  ]),
  _named(
    'germany-tax',
    TaxJurisdiction.de,
    EntityKind.soleTrader,
    ['de.ust.voranmeldung'],
    profile: {'salesTaxRegistered': true, 'smallBusinessExemption': false},
  ),
  _named('germany-tax', TaxJurisdiction.de, EntityKind.company, [
    'de.lohnsteuer.anmeldung',
  ]),
];

/// Deadlines a skill mentions that no pack emits, and why. Each reason is
/// one of: the date depends on a fact the profile does not hold, the item
/// is an option or an event rather than a filing or payment, or the entity
/// form is not modelled.
const Map<String, String> _notEmitted = {
  'gb.confirmation-statement':
      'uk-company-tax: the review date comes from the incorporation date, '
      'which the profile does not hold',
  'gb.psc-change': 'uk-company-tax: 14 days after an event, not a date',
  'gb.ct.loan-relief-claim':
      'uk-company-tax: measured from the accounting period of the loan',
  'gb.paye.full-payment-submission':
      'uk-vat-payroll: on or before each payday, which the books do not hold',
  'gb.id-verification':
      'uk-company-tax: the skill says the transition end is not a deadline',
  'us.1120s.return':
      'us-federal-tax: the pack models a C corporation; an S election is not '
      'in the profile',
  'us.farm-estimate':
      'us-federal-tax: applies to farmers and fishers; the profile does not '
      'hold the occupation',
  'us.8832.election':
      'us-federal-tax: an election window measured from the filing',
  'ng.government-vat-remittance':
      'nigeria-tax: applies to government payers only',
  'ng.e-invoicing-adoption':
      'nigeria-tax: a compliance milestone, not a filing or payment',
  'ng.accounting-date-change-notice':
      'nigeria-tax: measured back from the filing date of a changed year',
  'de.ust.abschlusszahlung':
      'germany-tax: one month after the day the return is filed',
  'de.kleinunternehmer-verzicht':
      'germany-tax: an option to waive the exemption, not a filing',
  'de.est.vorauszahlung-anpassung':
      'germany-tax: a window to ask for a change, not a filing or payment',
  'de.ust.19a-meldung':
      'germany-tax: applies only after enrolment under § 19a UStG',
};

void main() {
  group('the filing calendar contract', () {
    for (final jurisdiction in TaxJurisdiction.values) {
      group(jurisdiction.countryCode, () {
        final pack = TaxRules.forJurisdiction(jurisdiction);

        for (final startYear in pack.supportedStartYears) {
          for (final kind in EntityKind.values) {
            test('$startYear ${kind.name} deadlines are well formed', () {
              final profile = _profile(jurisdiction, kind, {
                'salesTaxRegistered': true,
                'smallBusinessExemption': false,
                'foreignEarnedIncomeExclusionMinor': 1,
              });
              final deadlines = pack.deadlines(
                pack.taxYear(startYear),
                profile,
              );

              expect(deadlines, isNotEmpty);
              final prefix = '${jurisdiction.countryCode.toLowerCase()}.';
              final instances = <String>{};
              for (var index = 0; index < deadlines.length; index++) {
                final deadline = deadlines[index];
                final reason = '${deadline.id} ${deadline.periodLabel}';
                expect(deadline.id, startsWith(prefix), reason: reason);
                expect(deadline.title.trim(), isNotEmpty, reason: reason);
                expect(deadline.citation.trim(), isNotEmpty, reason: reason);
                expect(deadline.source.scheme, 'https', reason: reason);
                expect(deadline.source.host, isNotEmpty, reason: reason);
                expect(
                  instances.add(
                    '${deadline.id}|${deadline.periodStart}|'
                    '${deadline.dueDate}',
                  ),
                  isTrue,
                  reason: '$reason is unique',
                );
                for (final date in [
                  deadline.dueDate,
                  deadline.periodStart,
                  deadline.periodEnd,
                ]) {
                  expect(
                    date,
                    DateTime.utc(date.year, date.month, date.day),
                    reason: '$reason uses date-only UTC values',
                  );
                }
                expect(
                  deadline.periodStart.isBefore(deadline.periodEnd),
                  isTrue,
                  reason: reason,
                );
                expect(deadline.periodLabel, isNotEmpty, reason: reason);
                if (deadline.rolledFrom case final nominal?) {
                  expect(
                    deadline.dueDate.isAfter(nominal),
                    isTrue,
                    reason: '$reason is moved forward, never back',
                  );
                }
                if (index > 0) {
                  expect(
                    deadlines[index - 1].dueDate.isAfter(deadline.dueDate),
                    isFalse,
                    reason: '$reason follows the previous date',
                  );
                }
              }
            });

            test('$startYear ${kind.name} deadlines pass the wording lint', () {
              final profile = _profile(jurisdiction, kind, {
                'salesTaxRegistered': true,
                'smallBusinessExemption': false,
                'foreignEarnedIncomeExclusionMinor': 1,
              });
              for (final deadline in pack.deadlines(
                pack.taxYear(startYear),
                profile,
              )) {
                expect(
                  findWordingIssues(
                    title: deadline.title,
                    explanation: '${deadline.note ?? ''} ${deadline.citation}',
                  ),
                  isEmpty,
                  reason: '${deadline.id}: ${deadline.title}',
                );
              }
            });
          }
        }

        test('refuses a year it has no rules for', () {
          final unsupported = TaxYear(
            jurisdiction: jurisdiction,
            startYear: 1999,
            start: DateTime.utc(1999),
            end: DateTime.utc(2000),
            label: '1999',
          );
          expect(
            () => pack.deadlines(
              unsupported,
              _profile(jurisdiction, EntityKind.individual),
            ),
            throwsA(isA<UnsupportedTaxYearException>()),
          );
        });

        test("refuses another country's profile", () {
          final other = TaxJurisdiction.values.firstWhere(
            (candidate) => candidate != jurisdiction,
          );
          expect(
            () => pack.deadlines(
              pack.taxYear(pack.supportedStartYears.first),
              _profile(other, EntityKind.individual),
            ),
            throwsArgumentError,
          );
        });

        test("refuses another country's year", () {
          final other = TaxJurisdiction.values.firstWhere(
            (candidate) => candidate != jurisdiction,
          );
          final otherPack = TaxRules.forJurisdiction(other);
          expect(
            () => pack.deadlines(
              otherPack.taxYear(otherPack.supportedStartYears.first),
              _profile(jurisdiction, EntityKind.individual),
            ),
            throwsArgumentError,
          );
        });

        test('declares the filing calendar as built', () {
          expect(
            pack.manifest.coverageOf(TaxSection.filingCalendar),
            isNot(TaxSectionCoverage.notBuilt),
          );
        });
      });
    }
  });

  group('every deadline the skills name', () {
    for (final entry in _skillDeadlines) {
      final ids = entry.ids;
      final label =
          '${entry.skill} ${entry.jurisdiction.countryCode} '
          '${entry.startYear} ${entry.kind.name}';
      test('$label produces ${ids.length} named rules', () {
        final pack = TaxRules.forJurisdiction(entry.jurisdiction);
        final produced = {
          for (final deadline in pack.deadlines(
            pack.taxYear(entry.startYear),
            _profile(entry.jurisdiction, entry.kind, entry.profile),
          ))
            deadline.id,
        };
        for (final id in ids) {
          expect(produced, contains(id), reason: '$id from ${entry.skill}');
        }
      });
    }

    test('names every rule once, with a skill behind it', () {
      final ids = [
        for (final entry in _skillDeadlines) ...entry.ids,
      ];
      expect(ids.toSet(), hasLength(ids.length), reason: 'no id is repeated');
      expect(ids.length, greaterThan(40));
    });

    test('leaves out only what each skill gives no date for', () {
      final emitted = <String>{};
      for (final jurisdiction in TaxJurisdiction.values) {
        final pack = TaxRules.forJurisdiction(jurisdiction);
        for (final startYear in pack.supportedStartYears) {
          for (final kind in EntityKind.values) {
            for (final deadline in pack.deadlines(
              pack.taxYear(startYear),
              _profile(jurisdiction, kind, {
                'salesTaxRegistered': true,
                'smallBusinessExemption': false,
                'foreignEarnedIncomeExclusionMinor': 1,
              }),
            )) {
              emitted.add(deadline.id);
            }
          }
        }
      }
      for (final entry in _notEmitted.entries) {
        expect(emitted, isNot(contains(entry.key)), reason: entry.value);
        expect(entry.value, isNotEmpty);
      }
    });
  });

  group('days left', () {
    test('counts whole days to the due date and goes negative after it', () {
      final deadline = TaxRules.forJurisdiction(TaxJurisdiction.gb)
          .deadlines(
            TaxRules.forJurisdiction(TaxJurisdiction.gb).taxYear(2025),
            _profile(TaxJurisdiction.gb, EntityKind.individual),
          )
          .firstWhere((deadline) => deadline.id == 'gb.sa.online-return');
      expect(deadline.dueDate, DateTime.utc(2027, 1, 31));
      expect(deadline.daysLeft(DateTime.utc(2027, 1, 31)), 0);
      expect(deadline.daysLeft(DateTime.utc(2027, 1, 1, 23, 59)), 30);
      expect(deadline.daysLeft(DateTime.utc(2027, 2, 2)), -2);
    });
  });
}
