import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// The facts about a taxpayer that change how their figures are taxed.
///
/// Each jurisdiction has its own profile, so only the questions that matter
/// there can be asked and stored.
@immutable
sealed class TaxProfile {
  const TaxProfile({required this.entityKind});

  final TaxEntityKind entityKind;

  TaxJurisdiction get jurisdiction;

  /// Whether the books are registered for VAT or sales tax.
  bool get salesTaxRegistered;

  Map<String, Object?> toJson();

  static TaxProfile fromJson(Map<String, Object?> json) {
    final entityKind = TaxEntityKind.values.byName(
      json['entityKind']! as String,
    );
    final registered = json['salesTaxRegistered'] as bool? ?? false;
    return switch (TaxJurisdiction.fromCountryCode(
      json['jurisdiction']! as String,
    )) {
      TaxJurisdiction.gb => gbProfileFromJson(
        json,
        entityKind,
        salesTaxRegistered: registered,
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        filingStatus: UsFilingStatus.values.byName(
          json['filingStatus'] as String? ?? UsFilingStatus.single.name,
        ),
      ),
      TaxJurisdiction.ng => NgTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        annualRentMinor: json['annualRentMinor'] as int? ?? 0,
        smallCompanyCeiling: switch (json['smallCompanyCeiling']) {
          final String ceiling => NgSmallCompanyCeiling.values.byName(ceiling),
          _ => NgSmallCompanyCeiling.ntaGazette,
        },
        mneGroupMember: json['mneGroupMember'] as bool? ?? false,
      ),
      TaxJurisdiction.de => DeTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        jointAssessment: json['jointAssessment'] as bool? ?? false,
        churchTax: json['churchTax'] as bool? ?? false,
        smallBusinessExemption: json['smallBusinessExemption'] as bool? ?? true,
      ),
      null => throw FormatException(
        'Unknown jurisdiction',
        json['jurisdiction'],
      ),
    };
  }

  Map<String, Object?> _baseJson() => {
    'jurisdiction': jurisdiction.countryCode,
    'entityKind': entityKind.name,
    'salesTaxRegistered': salesTaxRegistered,
  };
}

/// Student loan repayment plans HMRC collects through Self Assessment.
///
/// [postgraduate] never appears in [GbTaxProfile.studentLoanPlan]: a
/// postgraduate loan is held alongside an undergraduate plan, so it is a
/// separate flag. The value stays in the enum so old profiles that stored
/// the postgraduate loan in `studentLoanPlan` still parse.
enum GbStudentLoanPlan { plan1, plan2, plan4, plan5, postgraduate }

final class GbTaxProfile extends TaxProfile {
  const GbTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.scottishTaxpayer = false,
    this.studentLoanPlan,
    this.postgraduateLoan = false,
    this.accountingPeriodEndMonth = 3,
    this.accountingPeriodEndDay = 31,
    this.associatedCompanies = 0,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

  @override
  final bool salesTaxRegistered;

  /// Scottish taxpayers pay income tax on non-savings income at Scottish
  /// rates.
  final bool scottishTaxpayer;

  /// The undergraduate repayment plan, when there is one. A person can hold
  /// an undergraduate plan and a postgraduate loan at the same time, so the
  /// two are separate facts.
  final GbStudentLoanPlan? studentLoanPlan;

  /// Whether a postgraduate loan is repaid through Self Assessment as well.
  final bool postgraduateLoan;

  /// The company accounting period's end day, as month (1 to 12) and day
  /// (1 to 31). Corporation Tax is assessed on accounting periods, not on
  /// the 6 April tax year. Defaults to 31 March, the most common
  /// small-company year end.
  final int accountingPeriodEndMonth;
  final int accountingPeriodEndDay;

  /// Other companies under common control, excluding this one. Each one
  /// divides the £50,000 and £250,000 Corporation Tax limits.
  final int associatedCompanies;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'scottishTaxpayer': scottishTaxpayer,
    'studentLoanPlan': ?studentLoanPlan?.name,
    // Omitted when default, so profiles saved before these fields existed
    // keep their exact stored shape.
    'postgraduateLoan': ?(postgraduateLoan ? true : null),
    'accountingPeriodEndMonth': ?(accountingPeriodEndMonth == 3
        ? null
        : accountingPeriodEndMonth),
    'accountingPeriodEndDay': ?(accountingPeriodEndDay == 31
        ? null
        : accountingPeriodEndDay),
    'associatedCompanies': ?(associatedCompanies > 0
        ? associatedCompanies
        : null),
  };
}

/// Decodes a GB profile, reading the pre-2027 JSON shape too: profiles
/// written before the postgraduate loan got its own flag stored it in
/// `studentLoanPlan`.
GbTaxProfile gbProfileFromJson(
  Map<String, Object?> json,
  TaxEntityKind entityKind, {
  required bool salesTaxRegistered,
}) {
  final legacyPlan = switch (json['studentLoanPlan']) {
    final String plan => GbStudentLoanPlan.values.byName(plan),
    _ => null,
  };
  final undergradPlan =
      legacyPlan == null || legacyPlan == GbStudentLoanPlan.postgraduate
      ? null
      : legacyPlan;
  final postgraduate =
      json['postgraduateLoan'] as bool? ??
      legacyPlan == GbStudentLoanPlan.postgraduate;
  return GbTaxProfile(
    entityKind: entityKind,
    salesTaxRegistered: salesTaxRegistered,
    scottishTaxpayer: json['scottishTaxpayer'] as bool? ?? false,
    studentLoanPlan: undergradPlan,
    postgraduateLoan: postgraduate,
    accountingPeriodEndMonth: json['accountingPeriodEndMonth'] as int? ?? 3,
    accountingPeriodEndDay: json['accountingPeriodEndDay'] as int? ?? 31,
    associatedCompanies: json['associatedCompanies'] as int? ?? 0,
  );
}

enum UsFilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,
}

final class UsTaxProfile extends TaxProfile {
  const UsTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.filingStatus = UsFilingStatus.single,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.us;

  @override
  final bool salesTaxRegistered;

  final UsFilingStatus filingStatus;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'filingStatus': filingStatus.name,
  };
}

/// Which gross-turnover figure decides small-company status in Nigeria.
///
/// The two 2025 Acts disagree: the Nigeria Tax Act gazette defines a small
/// company at N50,000,000 or less, while the Nigeria Tax Administration Act
/// defines a "small business" at N100,000,000 or less. Officials describe the
/// N50,000,000 figure as a gazetting error, but no enacted correction was
/// found as of 5 November 2026, so the default stays on the Act that charges
/// the tax and the user can switch.
enum NgSmallCompanyCeiling {
  /// The Nigeria Tax Act gazette: gross turnover of N50,000,000 or less.
  ntaGazette,

  /// The Nigeria Tax Administration Act: gross turnover of N100,000,000 or
  /// less.
  ntaaIntended,
}

final class NgTaxProfile extends TaxProfile {
  const NgTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.annualRentMinor = 0,
    this.smallCompanyCeiling = NgSmallCompanyCeiling.ntaGazette,
    this.mneGroupMember = false,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.ng;

  @override
  final bool salesTaxRegistered;

  /// Annual rent paid on a home, for rent relief under the Nigeria Tax Act.
  ///
  /// The 2025 regime has no rent relief; the pack ignores this for a 2025
  /// year of assessment.
  final int annualRentMinor;

  /// Which turnover figure decides small-company status for 2026.
  final NgSmallCompanyCeiling smallCompanyCeiling;

  /// Whether the books belong to a constituent entity of a multinational
  /// group, which brings the 15% minimum effective tax rate (NTA s.57) into
  /// scope regardless of turnover.
  final bool mneGroupMember;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'annualRentMinor': annualRentMinor,
    'smallCompanyCeiling': smallCompanyCeiling.name,
    'mneGroupMember': mneGroupMember,
  };
}

final class DeTaxProfile extends TaxProfile {
  const DeTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.jointAssessment = false,
    this.churchTax = false,
    this.smallBusinessExemption = true,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.de;

  @override
  final bool salesTaxRegistered;

  /// Zusammenveranlagung: spouses assessed jointly under the splitting
  /// method.
  final bool jointAssessment;

  /// Kirchensteuer is due on top of income tax.
  final bool churchTax;

  /// Kleinunternehmerregelung (§19 UStG): no VAT charged or reclaimed.
  final bool smallBusinessExemption;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'jointAssessment': jointAssessment,
    'churchTax': churchTax,
    'smallBusinessExemption': smallBusinessExemption,
  };
}
