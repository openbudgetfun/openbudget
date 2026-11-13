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

/// What the Nigeria pack covers, and how mature it is.
///
/// The personal return leaves out the minimum-wage exemption and state and
/// local levies, the business reports do not model prior-year capital
/// allowances, and the company return does not compute the minimum effective
/// tax rate for large groups. Capital gains, digital assets and the filing
/// calendar are not built.
const TaxPackManifest ngTaxManifest = TaxPackManifest(
  maturity: TaxPackMaturity.preview,
  sections: {
    TaxSection.personalReturn: TaxSectionCoverage.partial,
    TaxSection.selfEmployment: TaxSectionCoverage.partial,
    TaxSection.companyReturn: TaxSectionCoverage.partial,
    TaxSection.indirectTax: TaxSectionCoverage.partial,
    TaxSection.capitalGains: TaxSectionCoverage.notBuilt,
    TaxSection.digitalAssets: TaxSectionCoverage.notBuilt,
    TaxSection.filingCalendar: TaxSectionCoverage.notBuilt,
    TaxSection.payroll: TaxSectionCoverage.notBuilt,
  },
);

/// Nigeria's tax rules, under the regime the year of assessment selects.
///
/// The pack supports the 2025 and 2026 calendar years of assessment. Amounts
/// are in kobo, the minor unit of the naira: N1 is 100 kobo.
///
/// Income earned in calendar 2025 stays under the repealed Personal Income
/// Tax Act, Companies Income Tax Act and Value Added Tax Act (secondary
/// sources; the Act texts were not read): the PITA progressive bands after
/// the consolidated relief allowance, the 1% minimum tax, CITA tiers of 0%,
/// 20% and 30% by turnover with the 3% tertiary education tax, and VAT at
/// 7.5% with the old N25,000,000 registration threshold.
///
/// Income from 1 January 2026 follows the Nigeria Tax Act 2025 and the
/// Nigeria Tax Administration Act 2025: personal income tax on the Fourth
/// Schedule bands after the eligible deductions in section 30, business
/// profits for sole traders and companies with one year of capital allowance
/// at the First Schedule Table I rates, companies income tax at 0% for small
/// companies and 30% otherwise, the 4% development levy, and VAT at 7.5% for
/// registered persons.
///
/// It does not compute the minimum effective tax rate for large groups and
/// multinational members (NTA section 57), state and local government
/// levies, or the minimum-wage exemption in NTA section 58.
///
/// Every amount is in kobo, and every computed slice is rounded down to a
/// whole kobo: band tax through [applyTaxBands], the consolidated relief
/// allowance, the minimum tax, rent relief, capital allowances, companies
/// income tax, the tertiary education tax, the development levy and VAT.
/// Rounding down keeps a claim within the receipt and matches the contract's
/// band helper.
///
/// [report] throws [ArgumentError] when the input is not Nigerian and
/// [UnsupportedTaxYearException] when the year's rates are missing.
final class NgTaxRules implements TaxRulePack {
  /// Creates the Nigeria rule pack.
  const NgTaxRules();

  static const Set<int> _supportedStartYears = {2025, 2026};

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.ng;

  @override
  TaxPackManifest get manifest => ngTaxManifest;

  @override
  Set<int> get supportedStartYears => _supportedStartYears;

  @override
  TaxRuleSet ruleSet(int startYear) => _ngRuleSetFor(startYear);

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
  List<TaxCategory> categoriesFor(EntityKind kind) => switch (kind) {
    EntityKind.individual => _NgTaxCategories.individual,
    EntityKind.soleTrader => _NgTaxCategories.soleTrader,
    EntityKind.company => _NgTaxCategories.company,
  };

  @override
  TaxCategory? category(String code) => _NgTaxCategories.byCode[code];

  @override
  TaxReport report(TaxInput input) {
    final table = _tableFor(input);
    return switch (input.profile.entityKind) {
      EntityKind.individual => _individualReport(input, table),
      EntityKind.soleTrader => _soleTraderReport(input, table),
      EntityKind.company => _companyReport(input, table),
    };
  }

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) {
    final table = _tableFor(input);
    return switch (input.profile.entityKind) {
      EntityKind.individual => _individualOpportunities(
        input,
        report,
        table,
      ),
      EntityKind.soleTrader => _soleTraderOpportunities(input, table),
      EntityKind.company => _companyOpportunities(input, table),
    };
  }
}

/// The rule set for [startYear], or the unsupported-year error.
TaxRuleSet _ngRuleSetFor(int startYear) {
  final ruleSet = _ngRuleSetsByStartYear[startYear];
  if (ruleSet == null) {
    throw UnsupportedTaxYearException(TaxJurisdiction.ng, startYear);
  }
  return ruleSet;
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
