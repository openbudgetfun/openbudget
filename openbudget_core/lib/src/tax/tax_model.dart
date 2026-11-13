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

/// How well sourced a figure or rule is (docs/tax-jurisdictions.md,
/// section 5.1).
enum TaxEvidenceGrade {
  /// Statute, official gazette, the authority's own page, form or
  /// instructions, or the authority's published calculator.
  primary,

  /// A Big Four or law-firm summary, a reputable tax publisher, or an
  /// intergovernmental compilation for figures it does not itself enact.
  secondary,

  /// Derived by the researcher from primary or secondary material, or a
  /// design inference.
  inferred,
}

/// The unit a [TaxFigure]'s value is counted in.
enum TaxFigureUnit {
  /// Minor units of the jurisdiction's currency, such as pence.
  currencyMinor,

  /// Basis points: 2000 is 20%.
  rateBasisPoints,

  /// A plain percentage, such as a share of income.
  percent,

  /// A counted number, such as a kilometre allowance step.
  count,
}

/// One named figure of a rule set, such as the personal allowance.
///
/// Knowledge cards quote named figures by id
/// (docs/money-guide.md, section 4.1), so a report and an answer can never
/// disagree on a headline number. The value is whatever the pack's tables
/// already carried; naming it adds the source, grade and verified-on date.
@immutable
final class TaxFigure {
  const TaxFigure({
    required this.id,
    required this.value,
    required this.unit,
    required this.source,
    required this.grade,
    required this.verifiedOn,
  });

  /// Stable identifier, unique in its rule set: `personalAllowance`.
  final String id;

  /// The figure in [unit]; a secondary-grade figure computes a liability
  /// only with a visible caveat.
  final int value;

  final TaxFigureUnit unit;

  /// The authority page the figure came from.
  final Uri source;

  final TaxEvidenceGrade grade;

  /// When the figure was last checked against [source].
  final DateTime verifiedOn;
}

/// One thing a rule pack could not verify, in plain language
/// (docs/tax-jurisdictions.md, section 5.4).
///
/// Caveats are data ported from the country skills' "Unverified and
/// changing" lists. A report carries only the caveats that touch the
/// sections and rule keys it used.
@immutable
final class TaxRuleCaveat {
  const TaxRuleCaveat({
    required this.id,
    required this.text,
    required this.grade,
    required this.recheckBy,
    this.sections = const {},
    this.keys = const {},
    this.announced = false,
  });

  /// Stable identifier, unique in its pack and prefixed by country:
  /// `gb.student-loan-unearned-threshold`.
  final String id;

  /// One plain sentence saying what could not be verified.
  final String text;

  /// How well sourced the statement behind the caveat is.
  final TaxEvidenceGrade grade;

  /// The last day the caveat is trusted without a re-check.
  final DateTime recheckBy;

  /// The report sections the caveat touches.
  final Set<TaxSection> sections;

  /// The rule keys and figure ids the caveat touches, such as
  /// `studentLoans` or `personalAllowance`.
  final Set<String> keys;

  /// True when the caveat describes a change that is announced but not
  /// yet law.
  final bool announced;

  /// Whether this caveat touches any of the used [sections] or [keys].
  bool touches({
    Set<TaxSection> sections = const {},
    Set<String> keys = const {},
  }) {
    for (final section in this.sections) {
      if (sections.contains(section)) {
        return true;
      }
    }
    for (final key in this.keys) {
      if (keys.contains(key)) {
        return true;
      }
    }
    return false;
  }
}

/// The version, sources and verification date of one year's figures.
@immutable
final class TaxRuleSet {
  const TaxRuleSet({
    required this.startYear,
    required this.revision,
    required this.verifiedOn,
    required this.sources,
    this.caveats = const [],
    this.figures = const {},
  });

  final int startYear;

  /// Bumped whenever any figure in the year changes.
  final int revision;

  /// When the figures were last checked against [sources].
  final DateTime verifiedOn;

  /// The authority pages the figures came from.
  final List<Uri> sources;

  /// What could not be verified, ported from the country skill's
  /// "Unverified and changing" list.
  final List<TaxRuleCaveat> caveats;

  /// The named figures knowledge cards quote, keyed by id.
  final Map<String, TaxFigure> figures;

  /// The caveats that touch any of the used [sections] or [keys]; a report
  /// carries only these.
  List<TaxRuleCaveat> caveatsTouching({
    Set<TaxSection> sections = const {},
    Set<String> keys = const {},
  }) => [
    for (final caveat in caveats)
      if (caveat.touches(sections: sections, keys: keys)) caveat,
  ];

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
    this.figureId,
  });

  final String label;
  final int amountMinor;

  /// The [TaxCategory.code] this line totals, when it totals one.
  final String? code;

  final String? reportReference;
  final int entryCount;

  /// The [TaxFigure.id] this line presents, when it presents one. Lines
  /// whose figure is secondary-grade show a "from a secondary source"
  /// badge.
  final String? figureId;
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
/// An opportunity built on a secondary or inferred figure carries that
/// [grade] and no [estimatedSavingMinor], an announced rule never feeds a
/// saving, and a [signpostOnly] row explains the rule and points to a
/// professional instead of quantifying one (tax-planning-guardrails).
///
/// The title is a neutral noun phrase, never an imperative addressed to
/// the user; the wording lint test enforces it.
@immutable
class TaxOpportunity {
  const TaxOpportunity({
    required this.id,
    required this.title,
    required this.explanation,
    required this.source,
    required this.ruleYear,
    this.estimatedSavingMinor,
    this.deadline,
    this.grade = TaxEvidenceGrade.primary,
    this.announced = false,
    this.signpostOnly = false,
    this.needsEvidence = false,
    this.assumptions = const [],
  }) : assert(
         estimatedSavingMinor == null || grade == TaxEvidenceGrade.primary,
         'a saving may only be computed on primary-grade figures',
       ),
       assert(
         !announced || estimatedSavingMinor == null,
         'an announced rule is not law yet and never feeds a saving',
       ),
       assert(
         !signpostOnly || estimatedSavingMinor == null,
         'a signpost-only row computes no saving',
       );

  /// Stable identifier, such as `gb.pension_annual_allowance`.
  final String id;

  final String title;
  final String explanation;

  /// The estimated tax saved if acted on, when it can be computed. Null
  /// whenever [grade] is not primary, [announced] is true,
  /// [signpostOnly] is true, or the saving depends on a fact the books do
  /// not hold.
  final int? estimatedSavingMinor;

  /// The last day acting on it counts for the year.
  final DateTime? deadline;

  /// The authority's guidance for it.
  final Uri source;

  /// The tax year whose rules the figures come from, as the authority
  /// writes it: `2026/27` or `2026`.
  final String ruleYear;

  /// How well sourced the key figure behind this opportunity is. A
  /// secondary or inferred grade shows with the row and carries no saving.
  final TaxEvidenceGrade grade;

  /// True when the rule is announced but not yet law. Labelled "announced,
  /// not yet law" and never used in arithmetic.
  final bool announced;

  /// True when the topic is reserved to a professional in this country (a
  /// `GuidancePerimeter` signpost-only topic): the row explains the
  /// general rule, computes nothing and signposts.
  final bool signpostOnly;

  /// True when acting on the relief needs evidence the books do not hold
  /// (receipts, day logs, statements); the guide asks for the evidence,
  /// not only the number.
  final bool needsEvidence;

  /// What the explanation assumes, in plain sentences.
  final List<String> assumptions;
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
    this.caveats = const [],
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

  /// The rule-set caveats that touch the sections and rule keys this
  /// report used: "what we could not verify" (docs/tax-jurisdictions.md,
  /// section 5.4).
  final List<TaxRuleCaveat> caveats;

  /// Entries whose category this rule pack does not know.
  final int uncategorizedCount;

  String get currencyCode => year.jurisdiction.currencyCode;

  int get totalLiabilityMinor =>
      liabilities.fold(0, (sum, liability) => sum + liability.amountMinor);

  /// Positive when more is owed, negative when a refund is due.
  int get balanceDueMinor => totalLiabilityMinor - alreadyPaidMinor;
}
