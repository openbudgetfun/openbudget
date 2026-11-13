import 'package:meta/meta.dart';
import 'package:openbudget_core/src/generated/entity_kind.dart';

export 'package:openbudget_core/src/generated/entity_kind.dart';

/// A country whose tax rules OpenBudget can apply.
enum TaxJurisdiction {
  /// United Kingdom: HM Revenue & Customs.
  gb('GB', 'GBP'),

  /// United States, federal only: Internal Revenue Service.
  us('US', 'USD'),

  /// Nigeria: Nigeria Revenue Service, under the Nigeria Tax Act 2025.
  ng('NG', 'NGN'),

  /// Germany: Bundeszentralamt für Steuern and the Länder tax offices.
  de('DE', 'EUR');

  const TaxJurisdiction(this.countryCode, this.currencyCode);

  /// ISO 3166-1 alpha-2 code.
  final String countryCode;

  /// ISO 4217 code every amount in this jurisdiction's reports is in.
  final String currencyCode;

  static TaxJurisdiction? fromCountryCode(String code) {
    for (final jurisdiction in values) {
      if (jurisdiction.countryCode == code.toUpperCase()) {
        return jurisdiction;
      }
    }
    return null;
  }
}

/// One part of a country's tax system a rule pack may compute.
enum TaxSection {
  personalReturn,
  selfEmployment,
  companyReturn,
  indirectTax,
  capitalGains,
  digitalAssets,
  filingCalendar,
  payroll,
}

/// How completely a pack covers one [TaxSection].
enum TaxSectionCoverage {
  /// The section computes everything the pack contract requires.
  full,

  /// The section computes, but leaves named parts out.
  partial,

  /// The pack explains the section and points to a professional, and
  /// computes nothing.
  signpostOnly,

  /// The tax does not exist for the entity kind in this country.
  notApplicable,

  /// The pack does not cover the section yet.
  notBuilt,
}

/// Whether a pack's figures have been checked by a tax professional.
enum TaxPackMaturity {
  /// New packs ship here: the figures are sourced but not yet reviewed.
  preview,

  /// A qualified professional has checked one year of output for each entity
  /// kind the pack covers.
  reviewed,
}

/// What a rule pack covers, per section, and how mature it is.
@immutable
final class TaxPackManifest {
  const TaxPackManifest({required this.maturity, required this.sections});

  final TaxPackMaturity maturity;

  /// Every [TaxSection] the pack knows about, with its coverage.
  final Map<TaxSection, TaxSectionCoverage> sections;

  /// The coverage of [section], or [TaxSectionCoverage.notBuilt] when the
  /// manifest does not name it.
  TaxSectionCoverage coverageOf(TaxSection section) =>
      sections[section] ?? TaxSectionCoverage.notBuilt;
}

/// The version, sources and verification date of one year's figures.
@immutable
final class TaxRuleSet {
  const TaxRuleSet({
    required this.startYear,
    required this.revision,
    required this.verifiedOn,
    required this.sources,
  });

  final int startYear;

  /// Bumped whenever any figure in the year changes.
  final int revision;

  /// When the figures were last checked against [sources].
  final DateTime verifiedOn;

  /// The authority pages the figures came from.
  final List<Uri> sources;

  /// The version recorded on reports, exports and proposals: `gb-2026-r1`.
  String versionFor(TaxJurisdiction jurisdiction) =>
      '${jurisdiction.countryCode.toLowerCase()}-$startYear-r$revision';
}

/// What a tax category does in a computation.
enum TaxCategoryKind {
  /// Taxable income or turnover.
  income,

  /// A deductible business expense or allowable cost.
  expense,

  /// Disposal proceeds of a chargeable asset.
  disposalProceeds,

  /// Acquisition cost of a disposed chargeable asset.
  disposalCost,

  /// A contribution that earns relief, such as a pension payment or gift.
  relief,

  /// Tax already paid or withheld, such as PAYE or withholding tax.
  taxPaid,

  /// Sales tax charged to customers (output VAT).
  salesTaxCollected,

  /// Sales tax paid on purchases (input VAT), reclaimable when registered.
  salesTaxPaid,

  /// Money that is outside tax entirely: transfers, gifts received, loans.
  outOfScope,
}

/// One line of a jurisdiction's tax category catalog.
///
/// Envelopes carry a default category, and a transaction may override it.
@immutable
class TaxCategory {
  const TaxCategory({
    required this.code,
    required this.label,
    required this.kind,
    required this.entityKinds,
    this.labelKey,
    this.reportReference,
    this.description,
  });

  /// Stable identifier, prefixed by jurisdiction: `gb.se.office_costs`.
  final String code;

  /// The name the tax authority uses, in its own language.
  final String label;

  final TaxCategoryKind kind;

  /// The kinds of books this category may appear in.
  final Set<EntityKind> entityKinds;

  /// The ARB key that localises this category in the app, when the
  /// catalogue is not written in the authority's own wording. Universal
  /// categories carry one; country packs label themselves.
  final String? labelKey;

  /// Where the total lands on the official return, such as
  /// `SA103F box 20` or `Schedule C line 18`.
  final String? reportReference;

  final String? description;

  @override
  bool operator ==(Object other) => other is TaxCategory && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// A jurisdiction's tax year: the half-open range `[start, end)`.
@immutable
class TaxYear implements Comparable<TaxYear> {
  const TaxYear({
    required this.jurisdiction,
    required this.startYear,
    required this.start,
    required this.end,
    required this.label,
  });

  final TaxJurisdiction jurisdiction;

  /// The calendar year the tax year starts in. Rule tables are keyed by it.
  final int startYear;

  /// First day of the year, at midnight, as a date-only UTC value.
  final DateTime start;

  /// First day of the next year, exclusive.
  final DateTime end;

  /// How the authority writes the year: `2026/27` or `2026`.
  final String label;

  bool contains(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    return !day.isBefore(start) && day.isBefore(end);
  }

  @override
  int compareTo(TaxYear other) => start.compareTo(other.start);

  @override
  bool operator ==(Object other) =>
      other is TaxYear &&
      other.jurisdiction == jurisdiction &&
      other.startYear == startYear;

  @override
  int get hashCode => Object.hash(jurisdiction, startYear);

  @override
  String toString() => '${jurisdiction.countryCode} $label';
}

/// One taxable fact, already converted to the jurisdiction's currency.
///
/// The server builds entries from transactions: the amount is converted at
/// the transaction date's rate, the category comes from the transaction or
/// its envelope, and [businessUsePercent] apportions mixed-use costs.
@immutable
class TaxEntry {
  const TaxEntry({
    required this.date,
    required this.amountMinor,
    required this.categoryCode,
    this.businessUsePercent = 100,
    this.salesTaxMinor = 0,
    this.sourceId,
    this.note,
  }) : assert(
         amountMinor >= 0,
         'amounts are magnitudes; the category signs them',
       ),
       assert(
         businessUsePercent >= 0 && businessUsePercent <= 100,
         'businessUsePercent is a percentage',
       );

  final DateTime date;

  /// Magnitude in minor units, including any sales tax.
  final int amountMinor;

  final String categoryCode;

  final int businessUsePercent;

  /// The sales tax inside [amountMinor], when the receipt shows it.
  final int salesTaxMinor;

  /// The transaction this entry came from, for drill-down.
  final String? sourceId;

  final String? note;

  /// [amountMinor] less sales tax, apportioned to business use, rounded
  /// down so a claim never exceeds the receipt.
  int get allowableMinor =>
      ((amountMinor - salesTaxMinor) * businessUsePercent) ~/ 100;
}

/// One figure of a tax report: a category total or a computed amount.
@immutable
class TaxReportLine {
  const TaxReportLine({
    required this.label,
    required this.amountMinor,
    this.code,
    this.reportReference,
    this.entryCount = 0,
  });

  final String label;
  final int amountMinor;

  /// The [TaxCategory.code] this line totals, when it totals one.
  final String? code;

  final String? reportReference;
  final int entryCount;
}

/// One tax a report computes, such as income tax or Class 4 NICs.
@immutable
class TaxLiability {
  const TaxLiability({
    required this.label,
    required this.amountMinor,
    this.bands = const [],
  });

  final String label;
  final int amountMinor;

  /// How [amountMinor] was built, band by band.
  final List<TaxBandSlice> bands;
}

/// The part of a base that fell in one rate band.
@immutable
class TaxBandSlice {
  const TaxBandSlice({
    required this.label,
    required this.baseMinor,
    required this.rateBasisPoints,
    required this.taxMinor,
  });

  final String label;
  final int baseMinor;

  /// 2000 is 20%.
  final int rateBasisPoints;

  final int taxMinor;
}

/// A legal way to owe less, found in a person's own figures.
///
/// OpenBudget shows opportunities as guidance, never as regulated advice;
/// each one says what it assumes and links to the authority's guidance.
@immutable
class TaxOpportunity {
  const TaxOpportunity({
    required this.id,
    required this.title,
    required this.explanation,
    required this.source,
    this.estimatedSavingMinor,
    this.deadline,
  });

  /// Stable identifier, such as `gb.pension_annual_allowance`.
  final String id;

  final String title;
  final String explanation;

  /// The estimated tax saved if acted on, when it can be computed.
  final int? estimatedSavingMinor;

  /// The last day acting on it counts for the year.
  final DateTime? deadline;

  /// The authority's guidance for it.
  final Uri source;
}

/// The computed position for one entity and tax year.
@immutable
class TaxReport {
  const TaxReport({
    required this.year,
    required this.entityKind,
    required this.lines,
    required this.liabilities,
    required this.alreadyPaidMinor,
    required this.assumptions,
    required this.sources,
    required this.rulesVerifiedOn,
    required this.rulesVersion,
    required this.maturity,
    required this.coverage,
    this.uncategorizedCount = 0,
  });

  final TaxYear year;
  final EntityKind entityKind;

  /// Category totals and computed figures, in return order.
  final List<TaxReportLine> lines;

  final List<TaxLiability> liabilities;

  /// Tax already paid or withheld for the year.
  final int alreadyPaidMinor;

  /// Plain statements of what the computation assumed, shown with the
  /// report, such as "No other income outside OpenBudget".
  final List<String> assumptions;

  /// The authority pages the rates came from.
  final List<Uri> sources;

  /// When the rule figures were last checked against [sources].
  final DateTime rulesVerifiedOn;

  /// The rule pack version that produced this report: `gb-2026-r1`.
  final String rulesVersion;

  /// Whether the pack's figures have been checked by a tax professional.
  final TaxPackMaturity maturity;

  /// How completely the pack covers each section.
  final Map<TaxSection, TaxSectionCoverage> coverage;

  /// Entries whose category this rule pack does not know.
  final int uncategorizedCount;

  String get currencyCode => year.jurisdiction.currencyCode;

  int get totalLiabilityMinor =>
      liabilities.fold(0, (sum, liability) => sum + liability.amountMinor);

  /// Positive when more is owed, negative when a refund is due.
  int get balanceDueMinor => totalLiabilityMinor - alreadyPaidMinor;
}
