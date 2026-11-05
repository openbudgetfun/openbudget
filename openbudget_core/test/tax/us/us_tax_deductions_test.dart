import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'us_tax_rules_test.dart'
    show entryDollars, individualInput, soleTraderInput;

const rules = UsTaxRules();

TaxReportLine lineNamed(TaxReport report, String label) =>
    report.lines.firstWhere((line) => line.label == label);

bool hasLineNamed(TaxReport report, String label) =>
    report.lines.any((line) => line.label == label);

TaxInput saltInput({
  required int wagesDollars,
  required int saltDollars,
  int year = 2025,
  UsFilingStatus status = UsFilingStatus.single,
  int itemizedDollars = 100000,
  int feieDollars = 0,
}) => individualInput(
  status: status,
  year: year,
  entries: [
    entryDollars(year, 'us.ind.wages', wagesDollars),
    entryDollars(year, 'us.ind.state_local_taxes', saltDollars),
    entryDollars(year, 'us.ind.itemized_deductions', itemizedDollars),
  ],
  profile: UsTaxProfile(
    entityKind: TaxEntityKind.individual,
    filingStatus: status,
    foreignEarnedIncomeExclusionMinor: feieDollars * 100,
  ),
);

void main() {
  group('SALT cap and phase-down', () {
    test(r'2025 MFJ: $60,000 of tax at $520,000 MAGI caps at $34,000', () {
      final report = rules.report(
        saltInput(
          status: UsFilingStatus.marriedFilingJointly,
          wagesDollars: 520000,
          saltDollars: 60000,
        ),
      );
      // Cap 40,000 - 30% x 20,000 = 34,000.
      expect(
        lineNamed(
          report,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        3400000,
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 44600000);
    });

    test(r'2025 MFJ: the $10,000 floor at $600,000 MAGI', () {
      final report = rules.report(
        saltInput(
          status: UsFilingStatus.marriedFilingJointly,
          wagesDollars: 600000,
          saltDollars: 60000,
        ),
      );
      expect(
        lineNamed(
          report,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        1000000,
      );
    });

    test(r'2026 single: $60,400 - 30% x $45,000 = $26,900 at $550,000', () {
      final report = rules.report(
        saltInput(year: 2026, wagesDollars: 550000, saltDollars: 60000),
      );
      expect(
        lineNamed(
          report,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        2690000,
      );
    });

    test(r'2026 single: floor reached just above $606,333 of MAGI', () {
      // 40,400 - 30% x 101,000 = 10,100 (above the floor).
      final aboveFloor = rules.report(
        saltInput(year: 2026, wagesDollars: 606000, saltDollars: 60000),
      );
      expect(
        lineNamed(
          aboveFloor,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        1010000,
      );
      // 40,400 - 30% x 102,000 = 9,800, floored at 10,000.
      final atFloor = rules.report(
        saltInput(year: 2026, wagesDollars: 607000, saltDollars: 60000),
      );
      expect(
        lineNamed(
          atFloor,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        1000000,
      );
    });

    test('2025 MFS halves the cap, threshold, and floor', () {
      final report = rules.report(
        saltInput(
          status: UsFilingStatus.marriedFilingSeparately,
          wagesDollars: 260000,
          saltDollars: 60000,
        ),
      );
      // Cap 20,000 - 30% x 10,000 = 17,000.
      expect(
        lineNamed(
          report,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        1700000,
      );
      final atFloor = rules.report(
        saltInput(
          status: UsFilingStatus.marriedFilingSeparately,
          wagesDollars: 300000,
          saltDollars: 60000,
        ),
      );
      // 20,000 - 30% x 50,000 = 5,000, the MFS floor.
      expect(
        lineNamed(
          atFloor,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        500000,
      );
    });

    test('no phase-down at or below the threshold', () {
      final report = rules.report(
        saltInput(wagesDollars: 500000, saltDollars: 60000),
      );
      expect(
        lineNamed(
          report,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        4000000,
      );
    });

    test('the foreign earned income exclusion raises the MAGI test', () {
      // MAGI 490,000 alone does not trigger the phase-down; with a $20,000
      // exclusion MAGI is 510,000 and 30% x 10,000 = 3,000 is removed.
      final without = rules.report(
        saltInput(wagesDollars: 490000, saltDollars: 60000),
      );
      expect(
        lineNamed(
          without,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        4000000,
      );
      final withFeie = rules.report(
        saltInput(
          wagesDollars: 490000,
          saltDollars: 60000,
          feieDollars: 20000,
        ),
      );
      expect(
        lineNamed(
          withFeie,
          'State and local taxes allowed after the SALT cap',
        ).amountMinor,
        3700000,
      );
    });
  });

  group('Schedule 1-A deductions', () {
    test(r'tips: $25,000 at $170,000 MAGI phases to $23,000', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 170000),
            entryDollars(2025, 'us.ind.qualified_tips', 25000),
          ],
        ),
      );
      // Cap 25,000 - 100 x 20 = 23,000.
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        2300000,
      );
    });

    test('tips below the reduced cap are deducted in full', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 170000),
            entryDollars(2025, 'us.ind.qualified_tips', 5000),
          ],
        ),
      );
      // The reduced cap is 23,000, so all 5,000 of tips are deducted.
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        500000,
      );
    });

    test(r'car loan interest: $8,000 at $120,000 MAGI deducts $6,000', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 120000),
            entryDollars(2025, 'us.ind.vehicle_loan_interest', 8000),
          ],
        ),
      );
      // Cap 10,000 - 200 x 20 = 6,000; the deduction is the lesser of the
      // interest and the reduced cap.
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        600000,
      );
    });

    test(r'car loan interest is gone at $150,000 MAGI', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 150000),
            entryDollars(2025, 'us.ind.vehicle_loan_interest', 8000),
          ],
        ),
      );
      // 10,000 - 200 x 50 = 0.
      expect(
        hasLineNamed(report, 'Schedule 1-A additional deductions'),
        isFalse,
      );
    });

    test('overtime premium is limited by the reduced MFJ cap', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 320000),
            entryDollars(2025, 'us.ind.qualified_overtime_premium', 12500),
          ],
        ),
      );
      // Cap 25,000 - 100 x 20 = 23,000; the premium is 12,500, so the
      // deduction is 12,500.
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        1250000,
      );
    });

    test(r'senior: $6,000 - 6% x $15,000 = $5,100 at $90,000 MAGI', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [entryDollars(2025, 'us.ind.wages', 90000)],
          profile: const UsTaxProfile(
            entityKind: TaxEntityKind.individual,
            taxpayer65OrOlder: true,
          ),
        ),
      );
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        510000,
      );
    });

    test(r'senior reaches zero at $175,000 MAGI', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [entryDollars(2025, 'us.ind.wages', 175000)],
          profile: const UsTaxProfile(
            entityKind: TaxEntityKind.individual,
            taxpayer65OrOlder: true,
          ),
        ),
      );
      expect(
        hasLineNamed(report, 'Schedule 1-A additional deductions'),
        isFalse,
      );
    });

    test('a joint couple can claim the senior deduction for both', () {
      final report = rules.report(
        individualInput(
          status: UsFilingStatus.marriedFilingJointly,
          year: 2025,
          entries: [entryDollars(2025, 'us.ind.wages', 160000)],
          profile: const UsTaxProfile(
            entityKind: TaxEntityKind.individual,
            filingStatus: UsFilingStatus.marriedFilingJointly,
            taxpayer65OrOlder: true,
            spouse65OrOlder: true,
          ),
        ),
      );
      // 2 x 6,000 - 6% x ($160,000 - $150,000) = 11,400, the 6% applied
      // once to the combined amount (the documented interpretation).
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        1140000,
      );
    });

    test(
      'married filing separately cannot claim tips, overtime, or senior',
      () {
        final report = rules.report(
          individualInput(
            status: UsFilingStatus.marriedFilingSeparately,
            year: 2025,
            entries: [
              entryDollars(2025, 'us.ind.wages', 60000),
              entryDollars(2025, 'us.ind.qualified_tips', 5000),
              entryDollars(2025, 'us.ind.qualified_overtime_premium', 5000),
            ],
            profile: const UsTaxProfile(
              entityKind: TaxEntityKind.individual,
              filingStatus: UsFilingStatus.marriedFilingSeparately,
              taxpayer65OrOlder: true,
            ),
          ),
        );
        // Vehicle loan interest is still allowed, tips and overtime are not,
        // and the senior deduction requires a joint return.
        expect(
          hasLineNamed(report, 'Schedule 1-A additional deductions'),
          isFalse,
        );
        expect(report.assumptions, contains(contains('cannot claim the tips')));
      },
    );

    test('a missing SSN is flagged for Schedule 1-A claims', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          entries: [
            entryDollars(2025, 'us.ind.wages', 60000),
            entryDollars(2025, 'us.ind.qualified_tips', 5000),
          ],
          profile: const UsTaxProfile(
            entityKind: TaxEntityKind.individual,
            taxpayerHasSsn: false,
          ),
        ),
      );
      expect(
        lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
        500000,
      );
      expect(
        report.assumptions,
        contains(contains('without an SSN on file')),
      );
    });
  });

  group('home office method choice', () {
    test(r'the regular Form 8829 method is not capped at $1,500', () {
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryDollars(2026, 'us.sch_c.gross_receipts', 100000),
            entryDollars(2026, 'us.sch_c.advertising', 2000),
            entryDollars(2026, 'us.sch_c.home_office', 2000),
          ],
          profile: const UsTaxProfile(
            entityKind: TaxEntityKind.soleTrader,
            homeOfficeMethod: UsHomeOfficeMethod.regular,
          ),
        ),
      );
      // Tentative profit 98,000 less the full 2,000 of home office costs.
      expect(lineNamed(report, 'Net profit or (loss)').amountMinor, 9600000);
      expect(
        lineWithCode(report, 'us.sch_c.home_office').amountMinor,
        200000,
      );
      expect(report.assumptions, contains(contains('Form 8829')));
    });

    test(r'the simplified method stays capped at $1,500', () {
      // The default profile method is the simplified one.
      final report = rules.report(
        soleTraderInput(
          entries: [
            entryDollars(2026, 'us.sch_c.gross_receipts', 100000),
            entryDollars(2026, 'us.sch_c.advertising', 2000),
            entryDollars(2026, 'us.sch_c.home_office', 2000),
          ],
        ),
      );
      expect(
        lineWithCode(report, 'us.sch_c.home_office').amountMinor,
        150000,
      );
      expect(lineNamed(report, 'Net profit or (loss)').amountMinor, 9650000);
    });
  });
}

TaxReportLine lineWithCode(TaxReport report, String code) =>
    report.lines.firstWhere((line) => line.code == code);
