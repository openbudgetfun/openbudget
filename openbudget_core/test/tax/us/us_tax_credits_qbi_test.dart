import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'us_tax_rules_test.dart'
    show entryDollars, entryMinor, individualInput, soleTraderInput;

const rules = UsTaxRules();

TaxReportLine lineNamed(TaxReport report, String label) =>
    report.lines.firstWhere((line) => line.label == label);

bool hasLineNamed(TaxReport report, String label) =>
    report.lines.any((line) => line.label == label);

void main() {
  group('child tax credit', () {
    test(r'two children under 17 earn $4,400 before the phase-out', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 15000000)],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            dependents: [
              UsDependent(underSeventeen: true, hasValidSsn: true),
              UsDependent(underSeventeen: true, hasValidSsn: true),
            ],
          ),
        ),
      );
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        440000,
      );
      expect(lineNamed(report, 'Total tax').amountMinor, 1149800);
    });

    test(r'phase-out at $50 per $1,000 over $400,000 joint', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 44000000)],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            dependents: [
              UsDependent(underSeventeen: true, hasValidSsn: true),
              UsDependent(underSeventeen: true, hasValidSsn: true),
            ],
          ),
        ),
      );
      // $40,000 over the threshold is 40 units of $1,000: $2,000 removed.
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        240000,
      );
    });

    test(r'a dependent 17 or older earns the $500 other-dependent credit', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 15000000)],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            dependents: [
              UsDependent(underSeventeen: true, hasValidSsn: true),
              UsDependent(underSeventeen: false, hasValidSsn: true),
            ],
          ),
        ),
      );
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        270000,
      );
    });

    test('a dependent without a valid SSN earns no credit and is flagged', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 15000000)],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            dependents: [
              UsDependent(underSeventeen: true, hasValidSsn: true),
              UsDependent(underSeventeen: true, hasValidSsn: false),
            ],
          ),
        ),
      );
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        220000,
      );
      expect(
        report.assumptions,
        contains(contains('without an SSN valid for employment')),
      );
    });

    test('the credit never exceeds the tax', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryMinor(2025, 'us.ind.wages', 3000000)],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            dependents: [
              UsDependent(underSeventeen: true, hasValidSsn: true),
              UsDependent(underSeventeen: true, hasValidSsn: true),
            ],
          ),
        ),
      );
      // Taxable income is zero, so there is nothing to credit.
      expect(
        hasLineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ),
        isFalse,
      );
      expect(lineNamed(report, 'Total tax').amountMinor, 0);
    });
  });

  group('qualifying surviving spouse', () {
    test('uses the joint standard deduction and joint thresholds', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.qualifyingSurvivingSpouse,
          year: 2025,
          entries: [
            entryMinor(2025, 'us.ind.wages', 15000000),
            entryMinor(2025, 'us.ind.taxable_interest', 1000000),
            entryMinor(2025, 'us.ind.tax_exempt_interest', 1000000),
          ],
          profile: const UsTaxProfile(
            entityKind: EntityKind.individual,
            filingStatus: UsFilingStatus.qualifyingSurvivingSpouse,
            dependents: [UsDependent(underSeventeen: true, hasValidSsn: true)],
          ),
        ),
      );
      // Standard deduction $31,500, the joint figure.
      expect(lineNamed(report, 'Standard deduction').amountMinor, 3150000);
      // The NIIT threshold is the joint $250,000, so MAGI $162,000 is far
      // below it, and the credit uses the joint $400,000 phase-out.
      expect(
        report.lines.any((line) => line.label == 'Net investment income tax'),
        isFalse,
      );
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        220000,
      );
    });

    test('round-trips through JSON', () {
      const profile = UsTaxProfile(
        entityKind: EntityKind.individual,
        filingStatus: UsFilingStatus.qualifyingSurvivingSpouse,
        homeOfficeMethod: UsHomeOfficeMethod.regular,
        specifiedServiceTrade: true,
        foreignEarnedIncomeExclusionMinor: 500000,
        taxpayer65OrOlder: true,
        spouse65OrOlder: true,
        taxpayerHasSsn: false,
        spouseHasSsn: false,
        dependents: [UsDependent(underSeventeen: true, hasValidSsn: false)],
      );
      final parsed = TaxProfile.fromJson(profile.toJson()) as UsTaxProfile;
      expect(parsed.filingStatus, UsFilingStatus.qualifyingSurvivingSpouse);
      expect(parsed.homeOfficeMethod, UsHomeOfficeMethod.regular);
      expect(parsed.specifiedServiceTrade, isTrue);
      expect(parsed.foreignEarnedIncomeExclusionMinor, 500000);
      expect(parsed.taxpayer65OrOlder, isTrue);
      expect(parsed.spouse65OrOlder, isTrue);
      expect(parsed.taxpayerHasSsn, isFalse);
      expect(parsed.spouseHasSsn, isFalse);
      expect(parsed.dependents.single.underSeventeen, isTrue);
      expect(parsed.dependents.single.hasValidSsn, isFalse);
    });

    test('old JSON without the new fields still parses', () {
      final parsed = TaxProfile.fromJson(const {
        'jurisdiction': 'US',
        'entityKind': 'individual',
        'salesTaxRegistered': false,
        'filingStatus': 'marriedFilingJointly',
      }) as UsTaxProfile;
      expect(parsed.filingStatus, UsFilingStatus.marriedFilingJointly);
      expect(parsed.homeOfficeMethod, UsHomeOfficeMethod.simplified);
      expect(parsed.specifiedServiceTrade, isFalse);
      expect(parsed.foreignEarnedIncomeExclusionMinor, 0);
      expect(parsed.taxpayer65OrOlder, isFalse);
      expect(parsed.taxpayerHasSsn, isTrue);
      expect(parsed.dependents, isEmpty);
    });
  });

  group('negative adjusted gross income', () {
    test('AGI may be negative and taxable income still floors at zero', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 400000),
            entryMinor(2026, 'us.ind.hsa_contribution', 500000),
          ],
        ),
      );
      expect(lineNamed(report, 'Adjusted gross income').amountMinor, -100000);
      expect(lineNamed(report, 'Taxable income').amountMinor, 0);
      expect(lineNamed(report, 'Total tax').amountMinor, 0);
    });
  });

  group('qualified business income above the threshold', () {
    int qbiDeductionOf(TaxReport report) =>
        hasLineNamed(report, 'Qualified business income deduction')
        ? lineNamed(report, 'Qualified business income deduction').amountMinor
        : 0;

    test('a business with no W-2 wages phases to zero across the range', () {
      // Taxable income before QBI of $219,113 sits in the 2026 single
      // phase-in range ($201,750 to $276,750); the deduction is reduced
      // but not zero.
      final inRange = rules.report(
        individualInput(
          linked: [businessProfit(2026, 250000)],
        ),
      );
      const fullLimit = 4382266; // 20% x taxable income before QBI.
      expect(qbiDeductionOf(inRange), greaterThan(0));
      expect(qbiDeductionOf(inRange), lessThan(fullLimit));

      // At or past the end of the range the deduction is zero.
      final atEnd = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 28418907)],
          linked: [businessProfit(2026, 10000)],
        ),
      );
      expect(qbiDeductionOf(atEnd), 0);
      expect(
        hasLineNamed(atEnd, 'Qualified business income deduction'),
        isFalse,
      );
    });

    test('Schedule C wages lift the limitation above the threshold', () {
      // Same $300,000 gross receipts; $20,000 of W-2 wages makes the wage
      // limitation large enough that almost nothing is removed, while a
      // no-wage business is cut by the phase-in.
      final noWages = rules.report(
        individualInput(linked: [businessProfit(2026, 300000)]),
      );
      final withWages = rules.report(
        individualInput(
          linked: [
            soleTraderInput(
              entries: [
                entryDollars(2026, 'us.sch_c.gross_receipts', 300000),
                entryDollars(2026, 'us.sch_c.wages', 20000),
              ],
            ),
          ],
        ),
      );
      final noWagesDeduction = qbiDeductionOf(noWages);
      final withWagesDeduction = qbiDeductionOf(withWages);
      expect(noWagesDeduction, greaterThan(0));
      expect(withWagesDeduction, greaterThan(noWagesDeduction));
    });

    test('UBIA enters the alternative limitation', () {
      // With only $2,000 of wages the 50% limit is $1,000; 25% of wages
      // plus 2.5% of $400,000 UBIA is $10,500, so the UBIA alternative
      // lifts the deduction.
      final wagesOnly = rules.report(
        individualInput(
          linked: [
            soleTraderInput(
              entries: [
                entryDollars(2026, 'us.sch_c.gross_receipts', 300000),
                entryDollars(2026, 'us.sch_c.wages', 2000),
              ],
            ),
          ],
        ),
      );
      final withUbia = rules.report(
        individualInput(
          linked: [
            soleTraderInput(
              entries: [
                entryDollars(2026, 'us.sch_c.gross_receipts', 300000),
                entryDollars(2026, 'us.sch_c.wages', 2000),
                entryDollars(
                  2026,
                  'us.sch_c.ubia_of_qualified_property',
                  4000000,
                ),
              ],
            ),
          ],
        ),
      );
      expect(qbiDeductionOf(wagesOnly), greaterThan(0));
      expect(qbiDeductionOf(withUbia), greaterThan(qbiDeductionOf(wagesOnly)));
    });

    test('a specified service trade or business phases out entirely', () {
      final notSstb = rules.report(
        individualInput(
          linked: [businessProfit(2026, 300000)],
        ),
      );
      final sstb = rules.report(
        individualInput(
          linked: [
            soleTraderInput(
              entries: [entryDollars(2026, 'us.sch_c.gross_receipts', 300000)],
              profile: const UsTaxProfile(
                entityKind: EntityKind.soleTrader,
                specifiedServiceTrade: true,
              ),
            ),
          ],
        ),
      );
      final sstbBeyondRange = rules.report(
        individualInput(
          linked: [
            soleTraderInput(
              entries: [entryDollars(2026, 'us.sch_c.gross_receipts', 500000)],
              profile: const UsTaxProfile(
                entityKind: EntityKind.soleTrader,
                specifiedServiceTrade: true,
              ),
            ),
          ],
        ),
      );
      // In the range the SSTB deduction is smaller than the non-SSTB one;
      // beyond the range it is zero.
      expect(qbiDeductionOf(sstb), greaterThan(0));
      expect(qbiDeductionOf(sstb), lessThan(qbiDeductionOf(notSstb)));
      expect(qbiDeductionOf(sstbBeyondRange), 0);
    });

    test('the 2026 minimum deduction is kept below the threshold', () {
      final report = rules.report(
        individualInput(
          entries: [entryMinor(2026, 'us.ind.wages', 2000000)],
          linked: [businessProfit(2026, 1500)],
        ),
      );
      expect(qbiDeductionOf(report), 40000);
    });
  });
}

TaxInput businessProfit(int year, int dollars) => soleTraderInput(
  year: year,
  entries: [entryDollars(year, 'us.sch_c.gross_receipts', dollars)],
);
