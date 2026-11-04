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

TaxInput _soleTraderInput({
  int startYear = 2026,
  List<TaxEntry> entries = const [],
  bool vat = false,
}) => TaxInput(
  profile: GbTaxProfile(
    entityKind: TaxEntityKind.soleTrader,
    salesTaxRegistered: vat,
  ),
  year: _gb.taxYear(startYear),
  entries: entries,
);

TaxInput _companyInput({
  int startYear = 2026,
  List<TaxEntry> entries = const [],
  bool vat = false,
}) => TaxInput(
  profile: GbTaxProfile(
    entityKind: TaxEntityKind.company,
    salesTaxRegistered: vat,
  ),
  year: _gb.taxYear(startYear),
  entries: entries,
);

TaxReportLine _referenced(TaxReport report, String reference) =>
    report.lines.firstWhere((line) => line.reportReference == reference);

int _line(TaxReport report, String label) =>
    report.lines.firstWhere((line) => line.label == label).amountMinor;

void main() {
  group('sole trader SA103F', () {
    test('maps expenses to their boxes and adds back depreciation', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [
            _pounds('gb.se.turnover', 50000),
            _pounds('gb.se.cost_of_goods', 10000),
            _pounds('gb.se.wages', 5000),
            _pounds('gb.se.depreciation', 2000),
            _pounds('gb.se.capital_allowances', 3000),
          ],
        ),
      );
      expect(_referenced(report, 'SA103F box 15').amountMinor, 5000000);
      expect(_referenced(report, 'SA103F box 17').amountMinor, 1000000);
      expect(_referenced(report, 'SA103F box 19').amountMinor, 500000);
      expect(_referenced(report, 'SA103F box 29').amountMinor, 200000);
      expect(_referenced(report, 'SA103F box 31').amountMinor, 1500000);
      expect(_referenced(report, 'SA103F box 47').amountMinor, 3500000);
      expect(_referenced(report, 'SA103F box 49').amountMinor, 300000);
      expect(_referenced(report, 'SA103F box 64').amountMinor, 3200000);
      expect(
        report.assumptions,
        contains(contains('Annual Investment Allowance')),
      );
    });

    test('uses the trading allowance instead of smaller expenses', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [
            _pounds('gb.se.turnover', 5000),
            _pounds('gb.se.cost_of_goods', 400),
          ],
        ),
      );
      expect(_line(report, 'Trading income allowance'), 100000);
      expect(_line(report, 'Net profit'), 400000);
      expect(_line(report, 'Net business profit for tax purposes'), 400000);
      expect(
        report.lines.any((line) => line.reportReference == 'SA103F box 31'),
        isFalse,
      );
    });

    test('prefers actual expenses when they are larger', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [
            _pounds('gb.se.turnover', 30000),
            _pounds('gb.se.cost_of_goods', 2000),
          ],
        ),
      );
      expect(
        report.lines.any((line) => line.reportReference == 'SA103F box 16.1'),
        isFalse,
      );
      expect(_referenced(report, 'SA103F box 47').amountMinor, 2800000);
    });

    test('reports a loss without a tax liability', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [
            _pounds('gb.se.turnover', 1000),
            _pounds('gb.se.cost_of_goods', 5000),
          ],
        ),
      );
      expect(_referenced(report, 'SA103F box 48').amountMinor, 400000);
      expect(_referenced(report, 'SA103F box 65').amountMinor, 400000);
      expect(report.liabilities, isEmpty);
    });

    test('turnover strips VAT and applies business use', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [
            _entry('gb.se.turnover', 1200000, salesTaxMinor: 200000),
            _entry('gb.se.car_van_travel', 100000, businessUsePercent: 50),
            _pounds('gb.se.cost_of_goods', 2000),
          ],
        ),
      );
      expect(_referenced(report, 'SA103F box 15').amountMinor, 1000000);
      expect(_referenced(report, 'SA103F box 20').amountMinor, 50000);
      expect(_referenced(report, 'SA103F box 47').amountMinor, 750000);
    });
  });

  group('sole trader VAT', () {
    test('output VAT less input VAT is a separate liability', () {
      final report = _gb.report(
        _soleTraderInput(
          vat: true,
          entries: [
            _entry('gb.se.turnover', 1200000, salesTaxMinor: 200000),
            _entry('gb.se.cost_of_goods', 240000, salesTaxMinor: 40000),
          ],
        ),
      );
      final vat = report.liabilities.single;
      expect(vat.label, 'VAT');
      expect(vat.amountMinor, 160000);
      expect(_line(report, 'VAT charged on sales (output VAT)'), 200000);
      expect(_line(report, 'VAT paid on purchases (input VAT)'), 40000);
      expect(report.balanceDueMinor, 160000);
    });

    test('explicit VAT categories record the VAT itself', () {
      final report = _gb.report(
        _companyInput(
          vat: true,
          entries: [
            _pounds('gb.vat.output', 1500),
            _pounds('gb.vat.input', 500),
          ],
        ),
      );
      expect(report.liabilities.single.amountMinor, 100000);
    });

    test('no VAT summary when not registered', () {
      final report = _gb.report(
        _soleTraderInput(
          entries: [_entry('gb.se.turnover', 1200000, salesTaxMinor: 200000)],
        ),
      );
      expect(report.liabilities, isEmpty);
      expect(report.lines.any((line) => line.label.contains('VAT')), isFalse);
    });
  });

  group('company CT600', () {
    test('marginal relief between £50,000 and £250,000', () {
      final report = _gb.report(
        _companyInput(entries: [_pounds('gb.co.turnover', 100000)]),
      );
      expect(_referenced(report, 'CT600 box 155').amountMinor, 10000000);
      expect(_referenced(report, 'CT600 box 235').amountMinor, 10000000);
      expect(_referenced(report, 'CT600 box 315').amountMinor, 10000000);
      expect(_referenced(report, 'CT600 box 430').amountMinor, 2500000);
      expect(_referenced(report, 'CT600 box 435').amountMinor, 225000);
      expect(_referenced(report, 'CT600 box 440').amountMinor, 2275000);
      expect(report.liabilities.single.amountMinor, 2275000);
    });

    test('small profits rate', () {
      final report = _gb.report(
        _companyInput(entries: [_pounds('gb.co.turnover', 40000)]),
      );
      expect(report.liabilities.single.amountMinor, 760000);
      expect(
        report.lines.any((line) => line.reportReference == 'CT600 box 435'),
        isFalse,
      );
    });

    test('main rate', () {
      final report = _gb.report(
        _companyInput(entries: [_pounds('gb.co.turnover', 300000)]),
      );
      expect(report.liabilities.single.amountMinor, 7500000);
    });

    test('expenses and capital allowances reduce trading profit', () {
      final report = _gb.report(
        _companyInput(
          entries: [
            _pounds('gb.co.turnover', 100000),
            _pounds('gb.co.wages', 20000),
            _pounds('gb.co.other_expenses', 10000),
            _pounds('gb.co.capital_allowances', 5000),
          ],
        ),
      );
      // £100,000 - £30,000 - £5,000 = £65,000.
      expect(_referenced(report, 'CT600 box 155').amountMinor, 6500000);
      // 25% of £65,000 less (250,000 - 65,000) x 3/200.
      expect(report.liabilities.single.amountMinor, 1625000 - 277500);
    });

    test('depreciation is added back', () {
      final report = _gb.report(
        _companyInput(
          entries: [
            _pounds('gb.co.turnover', 100000),
            _pounds('gb.co.depreciation', 5000),
          ],
        ),
      );
      expect(_referenced(report, 'CT600 box 155').amountMinor, 10000000);
      expect(_line(report, 'Depreciation (disallowable, added back)'), 500000);
    });

    test('other income and interest are added after trading profit', () {
      final report = _gb.report(
        _companyInput(
          entries: [
            _pounds('gb.co.turnover', 40000),
            _pounds('gb.co.other_income', 5000),
            _pounds('gb.co.interest_received', 1000),
          ],
        ),
      );
      expect(_referenced(report, 'CT600 box 235').amountMinor, 4600000);
    });

    test('VAT is a separate liability from Corporation Tax', () {
      final report = _gb.report(
        _companyInput(
          vat: true,
          entries: [
            _entry('gb.co.turnover', 1200000, salesTaxMinor: 200000),
            _entry('gb.co.other_expenses', 480000, salesTaxMinor: 80000),
          ],
        ),
      );
      expect(report.totalLiabilityMinor, 114000 + 120000);
      expect(report.liabilities, hasLength(2));
      expect(_line(report, 'VAT due'), 120000);
    });

    test('assumptions state the associated companies position', () {
      final report = _gb.report(
        _companyInput(entries: [_pounds('gb.co.turnover', 100000)]),
      );
      expect(
        report.assumptions,
        contains(
          'No associated companies: the £50,000 and £250,000 limits are not '
          'reduced.',
        ),
      );
    });

    test('wrong-kind categories are counted', () {
      final report = _gb.report(
        _companyInput(
          entries: [
            _pounds('gb.se.turnover', 1000),
            _pounds('gb.co.turnover', 1000),
          ],
        ),
      );
      expect(report.uncategorizedCount, 1);
    });
  });

  group('catalog', () {
    test('SA103F boxes are recorded', () {
      expect(_gb.category('gb.se.turnover')!.reportReference, 'SA103F box 15');
      expect(
        _gb.category('gb.se.capital_allowances')!.reportReference,
        'SA103F box 49',
      );
      expect(
        _gb.category('gb.se.depreciation')!.reportReference,
        'SA103F box 29',
      );
    });

    test('CT600 boxes are recorded', () {
      expect(_gb.category('gb.co.turnover')!.reportReference, 'CT600 box 145');
      expect(
        _gb.category('gb.co.other_income')!.reportReference,
        'CT600 box 205',
      );
    });

    test('each kind only sees its own catalog', () {
      final soleTrader = _gb.categoriesFor(TaxEntityKind.soleTrader);
      expect(soleTrader.first.code, 'gb.se.turnover');
      expect(
        soleTrader.any((category) => category.code.startsWith('gb.ind.')),
        isFalse,
      );
      expect(
        soleTrader.any((category) => category.code.startsWith('gb.vat.')),
        isTrue,
      );
      final company = _gb.categoriesFor(TaxEntityKind.company);
      expect(company.first.code, 'gb.co.turnover');
      expect(
        company.any((category) => category.code.startsWith('gb.vat.')),
        isTrue,
      );
    });

    test('codes are unique and prefixed', () {
      final codes = _gb
          .categoriesFor(TaxEntityKind.individual)
          .map((category) => category.code);
      expect(codes.toSet(), hasLength(codes.length));
      expect(codes.every((code) => code.startsWith('gb.')), isTrue);
    });
  });

  group('opportunities', () {
    test('VAT registration threshold is flagged when close', () {
      final input = _soleTraderInput(
        entries: [_pounds('gb.se.turnover', 80000)],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.vat_registration_threshold');
      expect(opportunity.estimatedSavingMinor, isNull);
      expect(opportunity.explanation, contains('£90,000'));
    });

    test('no VAT opportunity when registered', () {
      final input = _soleTraderInput(
        vat: true,
        entries: [_pounds('gb.se.turnover', 80000)],
      );
      expect(
        _gb
            .opportunities(input, _gb.report(input))
            .where((item) => item.id == 'gb.vat_registration_threshold'),
        isEmpty,
      );
    });

    test('director salary versus dividends', () {
      final company = _companyInput(
        entries: [_pounds('gb.co.turnover', 100000)],
      );
      final input = TaxInput(
        profile: const GbTaxProfile(entityKind: TaxEntityKind.individual),
        year: _gb.taxYear(2026),
        entries: const [],
        linked: [company],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.director_salary_vs_dividend');
      expect(opportunity.estimatedSavingMinor, greaterThan(0));
      expect(opportunity.explanation, contains('£12,570'));
      expect(opportunity.explanation, contains('Employment Allowance'));
    });

    test('a company that already pays wages still gets the comparison', () {
      final company = _companyInput(
        entries: [
          _pounds('gb.co.turnover', 100000),
          _pounds('gb.co.wages', 20000),
        ],
      );
      final input = TaxInput(
        profile: const GbTaxProfile(entityKind: TaxEntityKind.individual),
        year: _gb.taxYear(2026),
        entries: const [],
        linked: [company],
      );
      final opportunity = _gb
          .opportunities(input, _gb.report(input))
          .firstWhere((item) => item.id == 'gb.director_salary_vs_dividend');
      expect(opportunity.explanation, contains('illustrative'));
    });
  });
}
