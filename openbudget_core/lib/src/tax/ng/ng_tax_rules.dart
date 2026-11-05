import 'dart:math' as math;

import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

part 'ng_business_report.dart';
part 'ng_company_report.dart';
part 'ng_individual_report.dart';
part 'ng_opportunities.dart';
part 'ng_reports.dart';
part 'ng_tax_categories.dart';
part 'ng_tax_rates.dart';

/// Nigeria's tax rules under the Nigeria Tax Act 2025.
///
/// The pack supports the 2026 calendar year of assessment. Amounts are in
/// kobo, the minor unit of the naira: N1 is 100 kobo.
///
/// It computes personal income tax on the Fourth Schedule bands after the
/// eligible deductions in section 30, business profits for sole traders and
/// companies with one year of capital allowance at the First Schedule Table I
/// rates, companies income tax at 0% for small companies and 30% otherwise,
/// the 4% development levy, and VAT at 7.5% for registered persons.
///
/// It does not model the minimum effective tax rate for large groups
/// (section 57), state and local government levies, or the minimum-wage
/// exemption in section 58.
///
/// Every amount is in kobo, and every computed slice is rounded down to a
/// whole kobo: band tax through [applyTaxBands], rent relief, capital
/// allowances, companies income tax, the development levy and VAT. Rounding
/// down keeps a claim within the receipt and matches the contract's band
/// helper.
///
/// [report] throws [ArgumentError] when the input is not Nigerian and
/// [UnsupportedTaxYearException] when the year's rates are missing.
final class NgTaxRules implements TaxRulePack {
  /// Creates the Nigeria rule pack.
  const NgTaxRules();

  static const Set<int> _supportedStartYears = {2026};

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.ng;

  @override
  Set<int> get supportedStartYears => _supportedStartYears;

  @override
  TaxYear taxYearFor(DateTime date) => taxYear(date.year);

  @override
  TaxYear taxYear(int startYear) => TaxYear(
    jurisdiction: TaxJurisdiction.ng,
    startYear: startYear,
    start: DateTime.utc(startYear),
    end: DateTime.utc(startYear + 1),
    label: '$startYear',
  );

  @override
  List<TaxCategory> categoriesFor(TaxEntityKind kind) => switch (kind) {
    TaxEntityKind.individual => _NgTaxCategories.individual,
    TaxEntityKind.soleTrader => _NgTaxCategories.soleTrader,
    TaxEntityKind.company => _NgTaxCategories.company,
  };

  @override
  TaxCategory? category(String code) => _NgTaxCategories.byCode[code];

  @override
  TaxReport report(TaxInput input) {
    final table = _tableFor(input);
    return switch (input.profile.entityKind) {
      TaxEntityKind.individual => _individualReport(input, table),
      TaxEntityKind.soleTrader => _soleTraderReport(input, table),
      TaxEntityKind.company => _companyReport(input, table),
    };
  }

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) {
    final table = _tableFor(input);
    return switch (input.profile.entityKind) {
      TaxEntityKind.individual => _individualOpportunities(
        input,
        report,
        table,
      ),
      TaxEntityKind.soleTrader => _soleTraderOpportunities(input, table),
      TaxEntityKind.company => _companyOpportunities(input, table),
    };
  }
}

/// Validates [input] and returns the rate table for its year.
_NgTaxTable _tableFor(TaxInput input) {
  if (input.year.jurisdiction != TaxJurisdiction.ng) {
    throw ArgumentError.value(
      input.year.jurisdiction,
      'input.year',
      'The Nigeria rule pack needs a Nigerian tax year.',
    );
  }
  if (input.profile.jurisdiction != TaxJurisdiction.ng) {
    throw ArgumentError.value(
      input.profile.jurisdiction,
      'input.profile',
      'The Nigeria rule pack needs a Nigerian tax profile.',
    );
  }
  final table = _ngTables[input.year.startYear];
  if (table == null) {
    throw UnsupportedTaxYearException(TaxJurisdiction.ng, input.year.startYear);
  }
  return table;
}
