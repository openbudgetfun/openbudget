import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'us_tax_rules_test.dart'
    show entryDollars, entryMinor, individualInput, lineNamed, soleTraderInput;

const rules = UsTaxRules();

void main() {
  group('usIncomeTaxFromTable boundaries (2025 single)', () {
    // Boundary checks from the skill's test vectors: the whole-dollar
    // taxable income selects a Tax Table row; the tax is the formula on
    // the row midpoint, rounded to whole dollars.
    final cases = <(int, int)>[
      (4, 0), // row 0-5, midpoint 2.50, tax 0.25 -> 0
      (5, 1), // row 5-15, midpoint 10
      (14, 1),
      (24, 2), // row 15-25, midpoint 20
      (25, 4), // row 25-50, midpoint 37.50, tax 3.75 -> 4
      (2999, 299), // row 2,975-3,000, midpoint 2,987.50
      (3000, 303), // row 3,000-3,050, midpoint 3,025
      (3049, 303),
      (3050, 308), // midpoint 3,075
      (10000, 1003), // midpoint 10,025
      (99999, 16909), // row 99,950-100,000, midpoint 99,975
    ];
    for (final (dollars, expectedTaxDollars) in cases) {
      test(r'taxable income $' + dollars.toString(), () {
        expect(
          usIncomeTaxFromTable(
            dollars * 100,
            UsFilingStatus.single,
            2025,
          ),
          expectedTaxDollars * 100,
        );
      });
    }

    test(r'$100,000 and above use the worksheet formula, not the Table', () {
      // Taxable 99,999.50 rounds to 100,000 (half up) and then uses the
      // worksheet: the formula on the whole amount is $16,914.00.
      expect(
        usIncomeTaxFromTable(9999950, UsFilingStatus.single, 2025),
        1691400,
      );
      expect(
        usIncomeTaxFromTable(10000000, UsFilingStatus.single, 2025),
        1691400,
      );
    });

    test('an unsupported year throws', () {
      expect(
        () => usIncomeTaxFromTable(1000000, UsFilingStatus.single, 2027),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
    });
  });

  group('skill test vectors: formula versus Tax Table', () {
    test(r'A: 2025 single, wages $85,000, taxable $69,250', () {
      final report = rules.report(
        individualWages(2025, UsFilingStatus.single, 8500000),
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 6925000);
      // Formula on 69,250 would give $10,149.00; the Table row midpoint
      // 69,275 gives $10,154.50 -> $10,155.
      expect(lineNamed(report, 'Federal income tax').amountMinor, 1015500);
    });

    test(r'B: 2025 MFJ, wages $150,000, two children under 17', () {
      final report = rules.report(
        individualWages(
          2025,
          UsFilingStatus.marriedFilingJointly,
          15000000,
          const [
            UsDependent(underSeventeen: true, hasValidSsn: true),
            UsDependent(underSeventeen: true, hasValidSsn: true),
          ],
        ),
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 11850000);
      // Above $100,000 the formula is the filed method: $15,898.00.
      expect(lineNamed(report, 'Federal income tax').amountMinor, 1589800);
      expect(
        lineNamed(
          report,
          'Child tax credit and credit for other dependents',
        ).amountMinor,
        440000,
      );
      expect(lineNamed(report, 'Total tax').amountMinor, 1149800);
    });

    test(r'C: 2026 single, wages $60,000 plus $20,000 qualified dividends', () {
      final report = rules.report(
        individualInput(
          entries: [
            entryMinor(2026, 'us.ind.wages', 6000000),
            entryMinor(2026, 'us.ind.qualified_dividends', 2000000),
          ],
        ),
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 6390000);
      // Ordinary part $43,900: row midpoint 43,925 -> $5,023. Preferential
      // part $20,000: $5,550 at 0% and $14,450 at 15% = $2,168 (2,167.50
      // rounded). Tax on all $63,900 by Table would be $8,776, so the
      // worksheet keeps $7,191.
      expect(lineNamed(report, 'Federal income tax').amountMinor, 719100);
    });

    test(
      'D: 2025 single age 66 with overtime premium and car loan interest',
      () {
        final report = rules.report(
          individualInput(
            year: 2025,
            entries: [
              entryDollars(2025, 'us.ind.wages', 90000),
              entryDollars(2025, 'us.ind.qualified_overtime_premium', 6000),
              entryDollars(2025, 'us.ind.vehicle_loan_interest', 3000),
            ],
            profile: const UsTaxProfile(
              entityKind: TaxEntityKind.individual,
              taxpayer65OrOlder: true,
            ),
          ),
        );
        // Schedule 1-A: overtime 6,000 + vehicle interest 3,000 + senior
        // (6,000 - 6% x 15,000 = 5,100) = 14,100. The IRS adds $2,000 to the
        // standard deduction at 65+, which this pack does not compute, so
        // taxable is 90,000 - 14,100 - 15,750 = 60,150.
        expect(
          lineNamed(report, 'Schedule 1-A additional deductions').amountMinor,
          1410000,
        );
        expect(lineNamed(report, 'Taxable income').amountMinor, 6015000);
        // Table row midpoint 60,175 -> $8,152.50 -> $8,153.
        expect(lineNamed(report, 'Federal income tax').amountMinor, 815300);
      },
    );

    test(r'E: 2025 sole proprietor with a $100,000 Schedule C profit', () {
      final report = rules.report(
        individualInput(
          year: 2025,
          linked: [
            soleTraderInput(
              year: 2025,
              entries: [
                entryDollars(2025, 'us.sch_c.gross_receipts', 100000),
              ],
            ),
          ],
        ),
      );
      // Net earnings $92,350; SE tax $14,129.55; half $7,064.77; AGI
      // $92,935.22; QBI limited to 20% x taxable income = $15,437.04;
      // taxable $61,748.19.
      expect(lineNamed(report, 'Self-employment tax').amountMinor, 1412955);
      expect(
        lineNamed(report, 'Qualified business income deduction').amountMinor,
        1543704,
      );
      expect(lineNamed(report, 'Taxable income').amountMinor, 6174819);
      // Table row 61,700-61,750, midpoint 61,725: $8,493.50 -> $8,494
      // (the formula on 61,748 gives $8,498.56).
      expect(lineNamed(report, 'Federal income tax').amountMinor, 849400);
      // Total tax = $8,494.00 + $14,129.55 = $22,623.55.
      expect(lineNamed(report, 'Total tax').amountMinor, 2262355);
    });
  });
}

TaxInput individualWages(
  int year,
  UsFilingStatus status,
  int wagesMinor, [
  List<UsDependent> dependents = const [],
]) => individualInput(
  status: status,
  year: year,
  entries: [entryMinor(year, 'us.ind.wages', wagesMinor)],
  profile: UsTaxProfile(
    entityKind: TaxEntityKind.individual,
    filingStatus: status,
    dependents: dependents,
  ),
);
