import 'package:openbudget_core/openbudget_core.dart';

/// The pack under test.
const ngRules = NgTaxRules();

/// Builds an entry dated in the 2026 tax year.
TaxEntry ngEntry(
  String code,
  int naira, {
  int businessUsePercent = 100,
  int salesTaxNaira = 0,
  int month = 6,
  int? amountMinor,
}) => TaxEntry(
  date: DateTime.utc(2026, month, 15),
  amountMinor: amountMinor ?? naira * 100,
  categoryCode: code,
  businessUsePercent: businessUsePercent,
  salesTaxMinor: salesTaxNaira * 100,
);

/// Builds a Nigerian input for the 2026 year unless [startYear] says otherwise.
TaxInput ngInput({
  required TaxProfile profile,
  required List<TaxEntry> entries,
  List<TaxInput> linked = const [],
  int startYear = 2026,
}) => TaxInput(
  profile: profile,
  year: ngRules.taxYear(startYear),
  entries: entries,
  linked: linked,
);

/// An individual resident in Nigeria.
NgTaxProfile ngIndividual({int annualRentNaira = 0, bool vat = false}) =>
    NgTaxProfile(
      entityKind: EntityKind.individual,
      annualRentMinor: annualRentNaira * 100,
      salesTaxRegistered: vat,
    );

/// A sole trade owned by a Nigerian individual.
NgTaxProfile ngSoleTrader({bool vat = false}) =>
    NgTaxProfile(entityKind: EntityKind.soleTrader, salesTaxRegistered: vat);

/// A Nigerian company.
NgTaxProfile ngCompany({bool vat = false}) =>
    NgTaxProfile(entityKind: EntityKind.company, salesTaxRegistered: vat);

/// The report line whose label starts with [prefix].
TaxReportLine ngLine(TaxReport report, String prefix) =>
    report.lines.firstWhere((line) => line.label.startsWith(prefix));

/// The liability whose label starts with [prefix].
TaxLiability ngLiability(TaxReport report, String prefix) =>
    report.liabilities.firstWhere((l) => l.label.startsWith(prefix));
