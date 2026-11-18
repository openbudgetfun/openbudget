import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

const _gb = GbTaxRules();

TaxEntry _entry(
  String code,
  int amountMinor, {
  int businessUsePercent = 100,
  int salesTaxMinor = 0,
}) => TaxEntry(
  date: DateTime.utc(2026, 5),
  amountMinor: amountMinor,
  categoryCode: code,
  businessUsePercent: businessUsePercent,
  salesTaxMinor: salesTaxMinor,
);

TaxEntry _pounds(String code, int pounds) => _entry(code, pounds * 100);

TaxInput _individualInput({
  int startYear = 2026,
  List<TaxEntry> entries = const [],
  bool scottish = false,
  GbStudentLoanPlan? loan,
  bool postgraduateLoan = false,
  List<TaxInput> linked = const [],
}) => TaxInput(
  profile: GbTaxProfile(
    entityKind: EntityKind.individual,
    scottishTaxpayer: scottish,
    studentLoanPlan: loan,
    postgraduateLoan: postgraduateLoan,
  ),
  year: _gb.taxYear(startYear),
  entries: entries,
  linked: linked,
);

TaxReport _report({
  int startYear = 2026,
  List<TaxEntry> entries = const [],
  bool scottish = false,
  GbStudentLoanPlan? loan,
  bool postgraduateLoan = false,
  List<TaxInput> linked = const [],
}) => _gb.report(
  _individualInput(
    startYear: startYear,
    entries: entries,
    scottish: scottish,
    loan: loan,
    postgraduateLoan: postgraduateLoan,
    linked: linked,
  ),
);

TaxInput _soleTraderInput({int startYear = 2026, int turnover = 0}) => TaxInput(
  profile: const GbTaxProfile(entityKind: EntityKind.soleTrader),
  year: _gb.taxYear(startYear),
  entries: [_pounds('gb.se.turnover', turnover)],
);

int _line(TaxReport report, String label) =>
    report.lines.firstWhere((line) => line.label == label).amountMinor;

void main() {
  group('tax year', () {
    test('runs from 6 April to 5 April exclusive', () {
      final year = _gb.taxYear(2026);
      expect(year.start, DateTime.utc(2026, 4, 6));
      expect(year.end, DateTime.utc(2027, 4, 6));
      expect(year.label, '2026/27');
      expect(year.contains(DateTime.utc(2026, 4, 6)), isTrue);
      expect(year.contains(DateTime.utc(2027, 4, 5, 23, 59)), isTrue);
      expect(year.contains(DateTime.utc(2027, 4, 6)), isFalse);
    });

    test('taxYearFor switches on 6 April', () {
      expect(_gb.taxYearFor(DateTime.utc(2026, 4, 5)).startYear, 2025);
      expect(_gb.taxYearFor(DateTime.utc(2026, 4, 6)).startYear, 2026);
      expect(_gb.taxYearFor(DateTime.utc(2025, 4, 6)).startYear, 2025);
      expect(_gb.taxYearFor(DateTime(2026, 4, 5, 23, 59)).startYear, 2025);
    });

    test('unsupported years throw UnsupportedTaxYearException', () {
      expect(
        () => _gb.taxYear(2027),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
      expect(
        () => _gb.taxYearFor(DateTime.utc(2025, 4, 5)),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
      final future = TaxYear(
        jurisdiction: TaxJurisdiction.gb,
        startYear: 2027,
        start: DateTime.utc(2027, 4, 6),
        end: DateTime.utc(2028, 4, 6),
        label: '2027/28',
      );
      expect(
        () => _gb.report(
          TaxInput(
            profile: const GbTaxProfile(entityKind: EntityKind.individual),
            year: future,
            entries: const [],
          ),
        ),
        throwsA(isA<UnsupportedTaxYearException>()),
      );
    });

    test('only 2025 and 2026 are supported', () {
      expect(_gb.supportedStartYears, {2025, 2026});
    });
  });

  group('personal allowance', () {
    test('zero income has no liabilities', () {
      final report = _report();
      expect(report.liabilities, isEmpty);
      expect(report.totalLiabilityMinor, 0);
      expect(report.balanceDueMinor, 0);
      expect(_line(report, 'Total income'), 0);
    });

    test('income below the allowance is untaxed', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 12570)]);
      expect(report.totalLiabilityMinor, 0);
      expect(_line(report, 'Taxable income'), 0);
    });

    test('tapers by £1 for each £2 above £100,000', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 110000)]);
      expect(_line(report, 'Personal allowance'), 757000);
      expect(_line(report, 'Taxable income'), 10243000);
      expect(report.totalLiabilityMinor, 3343200);
    });

    test('is nil at £125,140', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 125140)]);
      expect(_line(report, 'Personal allowance'), 0);
      expect(report.totalLiabilityMinor, 4251600);
    });
  });

  group('income tax bands', () {
    test('2026/27 basic rate', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 30000)]);
      expect(report.totalLiabilityMinor, 348600);
      expect(
        report.liabilities.single.label,
        'Income Tax on non-savings income',
      );
    });

    test('exactly on the basic rate ceiling', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 50270)]);
      expect(report.totalLiabilityMinor, 754000);
    });

    test('one pound over the basic rate ceiling', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 50271)]);
      expect(report.totalLiabilityMinor, 754040);
    });

    test('2025/26 uses the same main bands', () {
      final report = _report(
        startYear: 2025,
        entries: [_pounds('gb.ind.employment', 30000)],
      );
      expect(report.totalLiabilityMinor, 348600);
    });

    test('Scottish rates apply to non-savings income', () {
      final report = _report(
        entries: [_pounds('gb.ind.employment', 50000)],
        scottish: true,
      );
      expect(report.totalLiabilityMinor, 898205);
      expect(
        report.liabilities.single.label,
        'Income Tax on non-savings income (Scottish rates)',
      );
      expect(report.liabilities.single.bands.map((band) => band.label), [
        'Starter rate',
        'Basic rate',
        'Intermediate rate',
        'Higher rate',
      ]);
    });

    test('Scottish bands changed in 2026/27', () {
      final report = _report(
        entries: [_pounds('gb.ind.employment', 30000)],
        scottish: true,
      );
      // £30,000 - £12,570 = £17,430 taxable: £3,967 at 19%, £12,989 at 20%,
      // and £474 at 21%.
      expect(report.totalLiabilityMinor, 75373 + 259780 + 9954);
    });
  });

  group('savings income', () {
    // https://www.gov.uk/apply-tax-free-interest-on-savings/how-much-is-tax-free
    test('personal savings allowance covers the first £1,000', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.savings', 1300),
        ],
      );
      expect(report.totalLiabilityMinor, 354600);
      final savings = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on savings income',
      );
      expect(savings.amountMinor, 6000);
    });

    test('starting rate for savings covers £200 of interest', () {
      // The official example: £16,000 wages and £200 interest pay no tax on
      // the interest.
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 16000),
          _pounds('gb.ind.savings', 200),
        ],
      );
      expect(report.totalLiabilityMinor, 68600);
      final savings = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on savings income',
      );
      expect(savings.amountMinor, 0);
    });

    test('higher rate taxpayers get a £500 allowance', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 60000),
          _pounds('gb.ind.savings', 1000),
        ],
      );
      // £47,430 taxable + £1,000 savings: £500 PSA, £500 at 40%.
      final savings = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on savings income',
      );
      expect(savings.amountMinor, 20000);
    });

    test('additional rate taxpayers get no savings allowance', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 200000),
          _pounds('gb.ind.savings', 1000),
        ],
      );
      final savings = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on savings income',
      );
      expect(savings.amountMinor, 45000);
    });
  });

  group('dividends', () {
    // https://www.gov.uk/tax-on-dividends (2026/27 example).
    test('2026/27 example: £29,570 wages and £3,000 dividends', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 29570),
          _pounds('gb.ind.dividends', 3000),
        ],
      );
      expect(report.totalLiabilityMinor, 366875);
      final dividends = report.liabilities.firstWhere(
        (liability) => liability.label == 'Income Tax on dividend income',
      );
      expect(dividends.amountMinor, 26875);
    });

    test('2025/26 rates are two points lower', () {
      final report = _report(
        startYear: 2025,
        entries: [
          _pounds('gb.ind.employment', 29570),
          _pounds('gb.ind.dividends', 3000),
        ],
      );
      expect(report.totalLiabilityMinor, 361875);
    });

    test('dividends only use the allowance and the basic rate', () {
      final report = _report(entries: [_pounds('gb.ind.dividends', 20000)]);
      // £7,430 taxable, £500 allowance, £6,930 at 10.75% = £744.97.
      expect(report.totalLiabilityMinor, 74497);
    });

    test('a dividend of exactly the allowance is untaxed', () {
      final report = _report(entries: [_pounds('gb.ind.dividends', 13070)]);
      expect(report.totalLiabilityMinor, 0);
    });
  });

  group('capital gains tax', () {
    TaxReport gainsReport({required int proceeds, required int cost}) =>
        _report(
          entries: [
            _pounds('gb.ind.employment', 32570),
            _entry('gb.ind.capital_gains_proceeds', proceeds * 100),
            _entry('gb.ind.capital_gains_cost', cost * 100),
          ],
        );

    // https://www.gov.uk/capital-gains-tax/rates (2026/27 examples).
    test('example 1: gains within the basic rate band', () {
      final report = gainsReport(proceeds: 20000, cost: 7400);
      final cgt = report.liabilities.firstWhere(
        (liability) => liability.label == 'Capital Gains Tax',
      );
      expect(cgt.amountMinor, 172800);
      expect(_line(report, 'Taxable gains'), 960000);
    });

    test('example 2: gains above the basic rate band', () {
      final report = gainsReport(proceeds: 60000, cost: 7400);
      final cgt = report.liabilities.firstWhere(
        (liability) => liability.label == 'Capital Gains Tax',
      );
      expect(cgt.amountMinor, 1084200);
    });

    test('the annual exempt amount is £3,000', () {
      final report = gainsReport(proceeds: 4000, cost: 1000);
      expect(report.totalLiabilityMinor, 400000);
      expect(
        report.liabilities.any(
          (liability) => liability.label == 'Capital Gains Tax',
        ),
        isFalse,
      );
    });
  });

  group('national insurance', () {
    test('Class 4 runs at 6% and 2%', () {
      final report = _report(linked: [_soleTraderInput(turnover: 60000)]);
      final class4 = report.liabilities.firstWhere(
        (liability) => liability.label == 'Class 4 National Insurance',
      );
      expect(class4.amountMinor, 243660);
      // The £1,000 trading allowance reduces the £60,000 turnover to £59,000;
      // £11,032 income tax plus £2,436.60 Class 4.
      expect(report.totalLiabilityMinor, 1346860);
      expect(_line(report, 'Class 2 National Insurance (treated as paid)'), 0);
    });

    test('Class 2 is not charged below the small profits threshold', () {
      final report = _report(linked: [_soleTraderInput(turnover: 5000)]);
      expect(_line(report, 'Class 2 National Insurance (not payable)'), 0);
    });
  });

  group('student loans', () {
    test('plan 1 takes 9% above £26,900 in 2026/27', () {
      // https://www.gov.uk/repaying-your-student-loan/what-you-pay example.
      final report = _report(
        entries: [_pounds('gb.ind.employment', 42000)],
        loan: GbStudentLoanPlan.plan1,
      );
      final loan = report.liabilities.firstWhere(
        (liability) => liability.label.startsWith('Student loan'),
      );
      expect(loan.amountMinor, 135900);
      expect(report.totalLiabilityMinor, 724500);
    });

    test('plan 2 rounds down to whole pounds (SA110 box 3)', () {
      // TC11: 9% x (£45,000 - £29,385) = £1,405.35, reported as £1,405.
      final report = _report(
        entries: [_pounds('gb.ind.employment', 45000)],
        loan: GbStudentLoanPlan.plan2,
      );
      final loan = report.liabilities.firstWhere(
        (liability) => liability.label.startsWith('Student loan'),
      );
      expect(loan.amountMinor, 140500);
    });

    test('plan 5 has no repayments in 2025/26', () {
      final report = _report(
        startYear: 2025,
        entries: [_pounds('gb.ind.employment', 42000)],
        loan: GbStudentLoanPlan.plan5,
      );
      expect(
        report.liabilities.any(
          (liability) => liability.label.startsWith('Student loan'),
        ),
        isFalse,
      );
    });

    test('plan 5 takes 9% above £25,000 in 2026/27', () {
      final report = _report(
        entries: [_pounds('gb.ind.employment', 30000)],
        loan: GbStudentLoanPlan.plan5,
      );
      final loan = report.liabilities.firstWhere(
        (liability) => liability.label.startsWith('Student loan'),
      );
      expect(loan.amountMinor, 45000);
    });

    test('postgraduate loans take 6%', () {
      final report = _report(
        entries: [_pounds('gb.ind.employment', 31000)],
        loan: GbStudentLoanPlan.postgraduate,
      );
      final loan = report.liabilities.firstWhere(
        (liability) => liability.label.startsWith('Student loan'),
      );
      expect(loan.amountMinor, 60000);
    });

    test('an undergraduate plan and a postgraduate loan run together', () {
      final report = _report(
        entries: [_pounds('gb.ind.employment', 45000)],
        loan: GbStudentLoanPlan.plan2,
        postgraduateLoan: true,
      );
      final loans = report.liabilities.where(
        (liability) => liability.label.startsWith('Student loan'),
      );
      // Plan 2 £1,405.35 -> £1,405, postgraduate 6% x £24,000 = £1,440.
      expect(loans.map((loan) => loan.amountMinor), [140500, 144000]);
      expect(loans, hasLength(2));
    });

    test('the base counts savings and dividends only above £2,000', () {
      // £2,000 of savings is inside the unearned threshold, so the base is
      // the £30,000 salary: 9% x £615 = £55.35 -> £55.
      final withinThreshold = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.savings', 2000),
        ],
        loan: GbStudentLoanPlan.plan2,
      );
      expect(
        withinThreshold.liabilities
            .firstWhere((liability) => liability.label.startsWith('Student'))
            .amountMinor,
        5500,
      );
      // £2,500 of savings adds £500 to the base: 9% x £1,115 = £100.35 -> £100.
      final aboveThreshold = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.savings', 2500),
        ],
        loan: GbStudentLoanPlan.plan2,
      );
      expect(
        aboveThreshold.liabilities
            .firstWhere((liability) => liability.label.startsWith('Student'))
            .amountMinor,
        10000,
      );
    });

    test('gross pension contributions reduce the repayment base', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 40000),
          _pounds('gb.ind.pension_contributions', 5000),
        ],
        loan: GbStudentLoanPlan.plan2,
      );
      // Base £35,000: 9% x £5,615 = £505.35 -> £505.
      final loan = report.liabilities.firstWhere(
        (liability) => liability.label.startsWith('Student loan'),
      );
      expect(loan.amountMinor, 50500);
    });
  });

  group('profile JSON', () {
    test('an old profile with the postgraduate plan still parses', () {
      final restored = TaxProfile.fromJson({
        'jurisdiction': 'GB',
        'entityKind': 'individual',
        'salesTaxRegistered': false,
        'scottishTaxpayer': false,
        'studentLoanPlan': 'postgraduate',
      });
      expect(restored, isA<GbTaxProfile>());
      final gb = restored as GbTaxProfile;
      expect(gb.studentLoanPlan, isNull);
      expect(gb.postgraduateLoan, isTrue);
    });

    test('accounting period and associates round-trip for a company', () {
      const profile = GbTaxProfile(
        entityKind: EntityKind.company,
        accountingPeriodEndMonth: 12,
        associatedCompanies: 2,
      );
      final restored = TaxProfile.fromJson(profile.toJson());
      expect(restored, isA<GbTaxProfile>());
      final gb = restored as GbTaxProfile;
      expect(gb.accountingPeriodEndMonth, 12);
      expect(gb.accountingPeriodEndDay, 31);
      expect(gb.associatedCompanies, 2);
      expect(gb.toJson(), profile.toJson());
    });

    test('defaults keep the stored JSON shape', () {
      const profile = GbTaxProfile(
        entityKind: EntityKind.individual,
        scottishTaxpayer: true,
        studentLoanPlan: GbStudentLoanPlan.plan2,
      );
      expect(profile.toJson(), {
        'jurisdiction': 'GB',
        'entityKind': 'individual',
        'salesTaxRegistered': false,
        'scottishTaxpayer': true,
        'studentLoanPlan': 'plan2',
      });
    });
  });

  group('payments on account', () {
    test('the statutory schedule appears when the base reaches £1,000', () {
      // TC1: sole-trade profit £60,000 in 2025/26 gives £11,432.00 Income
      // Tax plus £2,456.60 Class 4; each instalment is half of £13,888.60.
      final report = _report(
        startYear: 2025,
        linked: [
          TaxInput(
            profile: const GbTaxProfile(entityKind: EntityKind.soleTrader),
            year: _gb.taxYear(2025),
            entries: [
              _pounds('gb.se.turnover', 61000),
              _pounds('gb.se.cost_of_goods', 1000),
            ],
          ),
        ],
      );
      expect(report.totalLiabilityMinor, 1143200 + 245660);
      expect(
        _line(
          report,
          'First payment on account towards next year, due 31 '
          'January 2027',
        ),
        694430,
      );
      expect(
        _line(
          report,
          'Second payment on account towards next year, due 31 '
          'July 2027',
        ),
        694430,
      );
    });

    test('no payments on account below the £1,000 minimum', () {
      // Income Tax £3,486.00 less £2,800 tax at source leaves £686, under
      // the £1,000 minimum.
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.tax_paid', 2800),
        ],
      );
      expect(
        report.lines.where(
          (line) => line.label.contains('payment on account'),
        ),
        isEmpty,
      );
      expect(
        report.assumptions.join(' '),
        contains('No payments on account are due'),
      );
    });

    test('no payments on account when more than 80% was collected', () {
      // £3,486.00 Income Tax with £2,789.00 collected: the base £697 is
      // under 20% of the year's tax, so nothing is due.
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.tax_paid', 2789),
        ],
      );
      expect(
        report.lines.where(
          (line) => line.label.contains('payment on account'),
        ),
        isEmpty,
      );
    });

    test('payments on account exclude capital gains and student loans', () {
      // The year's Income Tax is £3,668.75; the £2,448.00 CGT, the £106
      // plan 2 loan and the £50 collected at source do not join the base,
      // so each instalment is half of £3,618.75.
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 29570),
          _pounds('gb.ind.dividends', 3000),
          _entry('gb.ind.capital_gains_proceeds', 2400000),
          _entry('gb.ind.capital_gains_cost', 740000),
          _pounds('gb.ind.tax_paid', 50),
        ],
        loan: GbStudentLoanPlan.plan2,
      );
      expect(
        _line(
          report,
          'First payment on account towards next year, due 31 January 2028',
        ),
        180937,
      );
    });

    test('the deadline opportunity states the instalments', () {
      final input = _individualInput(
        entries: [_pounds('gb.ind.employment', 30000)],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.self_assessment_deadline');
      expect(opportunity.explanation, contains('£1,743'));
      expect(opportunity.explanation, contains('31 July 2028'));
      expect(opportunity.explanation, contains('High Income Child Benefit'));
    });
  });

  group('tax paid', () {
    test('reduces the balance due', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.tax_paid', 1000),
        ],
      );
      expect(report.alreadyPaidMinor, 100000);
      expect(report.balanceDueMinor, 248600);
      expect(_line(report, 'Balance due'), 248600);
    });

    test('a refund is labelled as such', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.tax_paid', 5000),
        ],
      );
      expect(report.balanceDueMinor, -151400);
      expect(_line(report, 'Refund due'), 151400);
    });
  });

  group('categories and assumptions', () {
    test('unknown categories are counted', () {
      final report = _report(
        entries: [
          _pounds('gb.unknown.thing', 1000),
          _pounds('gb.se.turnover', 1000),
          _pounds('gb.ind.employment', 1000),
        ],
      );
      expect(report.uncategorizedCount, 2);
      expect(_line(report, 'Employment income'), 100000);
    });

    test('relief entries reduce adjusted net income but are not deducted', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.pension_contributions', 5000),
        ],
      );
      // The contribution is not deducted from taxable income...
      expect(report.totalLiabilityMinor, 348600);
      expect(_line(report, 'Pension contributions'), 500000);
      expect(
        report.assumptions,
        contains(
          'Pension contributions and Gift Aid donations are shown as recorded '
          'and reduce adjusted net income for the allowance taper; their band '
          'extension and scheme-specific relief are not modelled.',
        ),
      );
    });

    test('a gross pension contribution restores the tapered allowance', () {
      // £110,000 employment less £10,000 gross pension: adjusted net income
      // of £100,000 keeps the full allowance.
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 110000),
          _pounds('gb.ind.pension_contributions', 10000),
        ],
      );
      expect(_line(report, 'Personal allowance'), 1257000);
      // £97,430 taxable: £37,700 at 20% and £59,730 at 40%.
      expect(report.totalLiabilityMinor, 754000 + 2389200);
    });

    test('a gross Gift Aid donation reduces adjusted net income', () {
      final report = _report(
        entries: [
          _pounds('gb.ind.employment', 105000),
          _pounds('gb.ind.gift_aid', 10000),
        ],
      );
      expect(_line(report, 'Personal allowance'), 1257000);
      // £92,430 taxable: £37,700 at 20% and £54,730 at 40%.
      expect(report.totalLiabilityMinor, 754000 + 2189200);
    });

    test('assumptions and sources are stated', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 30000)]);
      expect(report.assumptions, isNotEmpty);
      expect(report.sources, isNotEmpty);
      expect(report.rulesVerifiedOn, DateTime.utc(2026, 11, 4));
      expect(
        report.sources,
        contains(Uri.parse('https://www.gov.uk/income-tax-rates')),
      );
    });

    test('the pack is reachable through TaxRules', () {
      expect(TaxRules.forJurisdiction(TaxJurisdiction.gb), isA<GbTaxRules>());
    });
  });

  group('opportunities', () {
    test('restoring the personal allowance in the taper zone', () {
      final input = _individualInput(
        entries: [_pounds('gb.ind.employment', 110000)],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.pension_taper');
      expect(opportunity.estimatedSavingMinor, 400000);
      expect(
        opportunity.source,
        Uri.parse('https://www.gov.uk/income-tax-rates'),
      );
      expect(opportunity.deadline, DateTime.utc(2027, 4, 5));
    });

    test('the pension annual allowance is stated', () {
      final input = _individualInput(
        entries: [_pounds('gb.ind.employment', 30000)],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.pension_annual_allowance');
      expect(opportunity.estimatedSavingMinor, isNull);
      expect(opportunity.deadline, DateTime.utc(2027, 4, 5));
    });

    test('sheltering savings in an ISA', () {
      final input = _individualInput(
        entries: [
          _pounds('gb.ind.employment', 30000),
          _pounds('gb.ind.savings', 2000),
        ],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.isa_allowance');
      expect(opportunity.estimatedSavingMinor, 20000);
    });

    test('unused capital gains annual exempt amount', () {
      final input = _individualInput(
        entries: [
          _pounds('gb.ind.employment', 32570),
          _entry('gb.ind.capital_gains_proceeds', 100000),
          _entry('gb.ind.capital_gains_cost', 0),
        ],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere(
            (item) => item.id == 'gb.capital_gains_annual_exempt_amount',
          );
      expect(opportunity.estimatedSavingMinor, 36000);
    });

    test('payments on account deadline is 31 January', () {
      final input = _individualInput(
        entries: [_pounds('gb.ind.employment', 30000)],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.self_assessment_deadline');
      expect(opportunity.deadline, DateTime.utc(2027, 1, 31));
      expect(opportunity.explanation, contains('31 January'));
    });

    test('trading allowance is compared with actual expenses', () {
      final trade = TaxInput(
        profile: const GbTaxProfile(entityKind: EntityKind.soleTrader),
        year: _gb.taxYear(2026),
        entries: [
          _pounds('gb.se.turnover', 30000),
          _pounds('gb.se.cost_of_goods', 400),
        ],
      );
      final input = _individualInput(linked: [trade]);
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.trading_allowance');
      // £600 more deducted than the actual expenses, at 20%.
      expect(opportunity.estimatedSavingMinor, 12000);
    });
  });

  group('caveats', () {
    test('a report that uses the student-loan rules lists the student-loan '
        'caveats and no German ones', () {
      final report = _report(
        loan: GbStudentLoanPlan.plan2,
        entries: [_pounds('gb.ind.employment', 60000)],
      );

      expect(
        report.caveats.map((caveat) => caveat.id),
        contains('gb.student-loan-unearned-threshold'),
      );
      for (final caveat in report.caveats) {
        expect(
          caveat.id,
          startsWith('gb.'),
          reason: '${caveat.id} is not a GB caveat',
        );
      }
      // The report carried only caveats its sections and keys touched:
      // every caveat is one of its rule set's.
      final ruleSet = _gb.ruleSet(report.year.startYear);
      expect(
        report.caveats.toSet().difference(ruleSet.caveats.toSet()),
        isEmpty,
      );
    });

    test('a report with no student loan carries no student-loan caveat', () {
      final report = _report(entries: [_pounds('gb.ind.employment', 30000)]);

      expect(
        report.caveats.map((caveat) => caveat.id),
        isNot(contains('gb.student-loan-unearned-threshold')),
      );
    });
  });
}
