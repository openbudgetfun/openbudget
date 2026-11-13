import 'package:openbudget_core/src/tax/de/de_categories.dart';
import 'package:openbudget_core/src/tax/de/de_opportunities.dart';
import 'package:openbudget_core/src/tax/de/de_reports.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// Germany's tax rules for the Veranlagungszeiträume in [deTaxTables].
///
/// The pack covers the calendar year, the § 32a EStG tariff with the splitting
/// method, Solidaritätszuschlag and Kirchensteuer at the rate of the
/// taxpayer's Bundesland, Kinderfreibeträge with the Günstigerprüfung against
/// the Kindergeld, the Entfernungspauschale of § 9 Abs. 1 Satz 3 Nr. 4 EStG,
/// the Homeoffice-Tagespauschale and the Arbeitszimmer of § 4 Abs. 5 EStG,
/// the Einnahmen-Überschuss-Rechnung of a sole trader — Freiberufler without
/// Gewerbesteuer, Gewerbetreibende with the § 35 credit —, the corporate
/// taxes of a GmbH or UG, Umsatzsteuer with the § 19 Kleinunternehmer test of
/// the previous and current year, and filing deadlines rolled forward by
/// § 108 Abs. 3 AO.
///
/// Every figure is a constant of one year's table, so the same input always
/// produces the same report. The sources and the date they were checked are
/// part of every report.
final class DeTaxRules implements TaxRulePack {
  const DeTaxRules();

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.de;

  @override
  TaxPackManifest get manifest => deTaxManifest;

  @override
  Set<int> get supportedStartYears => Set.unmodifiable(deTaxTables.keys);

  @override
  TaxRuleSet ruleSet(int startYear) => deRuleSetFor(startYear);

  @override
  TaxYear taxYearFor(DateTime date) => taxYear(date.year);

  @override
  TaxYear taxYear(int startYear) {
    if (!deTaxTables.containsKey(startYear)) {
      throw UnsupportedTaxYearException(TaxJurisdiction.de, startYear);
    }
    return TaxYear(
      jurisdiction: TaxJurisdiction.de,
      startYear: startYear,
      start: DateTime.utc(startYear),
      end: DateTime.utc(startYear + 1),
      label: '$startYear',
    );
  }

  @override
  List<TaxCategory> categoriesFor(EntityKind kind) => switch (kind) {
    EntityKind.individual => deIndividualCategories,
    EntityKind.soleTrader => deSoleTraderCategories,
    EntityKind.company => deCompanyCategories,
  };

  @override
  TaxCategory? category(String code) => deCategories[code];

  @override
  TaxReport report(TaxInput input) =>
      deReport(input, _tableFor(input.year.startYear));

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) =>
      deOpportunities(input, report, _tableFor(input.year.startYear));

  DeTaxTable _tableFor(int startYear) {
    final table = deTaxTables[startYear];
    if (table == null) {
      throw UnsupportedTaxYearException(TaxJurisdiction.de, startYear);
    }
    return table;
  }
}
