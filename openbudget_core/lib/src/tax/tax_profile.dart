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
      TaxJurisdiction.gb => GbTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        scottishTaxpayer: json['scottishTaxpayer'] as bool? ?? false,
        studentLoanPlan: switch (json['studentLoanPlan']) {
          final String plan => GbStudentLoanPlan.values.byName(plan),
          _ => null,
        },
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        filingStatus: UsFilingStatus.values.byName(
          json['filingStatus'] as String? ?? UsFilingStatus.single.name,
        ),
        homeOfficeMethod: switch (json['homeOfficeMethod']) {
          final String method => UsHomeOfficeMethod.values.byName(method),
          _ => UsHomeOfficeMethod.simplified,
        },
        specifiedServiceTrade: json['specifiedServiceTrade'] as bool? ?? false,
        foreignEarnedIncomeExclusionMinor:
            json['foreignEarnedIncomeExclusionMinor'] as int? ?? 0,
        taxpayer65OrOlder: json['taxpayer65OrOlder'] as bool? ?? false,
        spouse65OrOlder: json['spouse65OrOlder'] as bool? ?? false,
        taxpayerHasSsn: json['taxpayerHasSsn'] as bool? ?? true,
        spouseHasSsn: json['spouseHasSsn'] as bool? ?? true,
        dependents: [
          for (final dependent
              in json['dependents'] as List<Object?>? ?? const [])
            UsDependent.fromJson(dependent! as Map<String, Object?>),
        ],
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
enum GbStudentLoanPlan { plan1, plan2, plan4, plan5, postgraduate }

final class GbTaxProfile extends TaxProfile {
  const GbTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.scottishTaxpayer = false,
    this.studentLoanPlan,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

  @override
  final bool salesTaxRegistered;

  /// Scottish taxpayers pay income tax on non-savings income at Scottish
  /// rates.
  final bool scottishTaxpayer;

  final GbStudentLoanPlan? studentLoanPlan;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'scottishTaxpayer': scottishTaxpayer,
    'studentLoanPlan': ?studentLoanPlan?.name,
  };
}

enum UsFilingStatus {
  single,
  marriedFilingJointly,
  marriedFilingSeparately,
  headOfHousehold,

  /// A taxpayer whose spouse died within the two tax years before the year
  /// of the return and who has a dependent child at home. It uses the
  /// married-filing-jointly brackets, standard deduction and thresholds.
  qualifyingSurvivingSpouse,
}

/// How business-use-of-home expenses are claimed on Schedule C.
enum UsHomeOfficeMethod {
  /// $5 per square foot up to 300 square feet, capped at $1,500.
  simplified,

  /// Actual expenses on Form 8829; not subject to the $1,500 cap.
  regular,
}

/// One person claimed as a dependent on a US return.
///
/// Age matters only through the under-17 line that separates the child tax
/// credit from the credit for other dependents.
final class UsDependent {
  const UsDependent({
    required this.underSeventeen,
    required this.hasValidSsn,
  });

  UsDependent.fromJson(Map<String, Object?> json)
    : underSeventeen = json['underSeventeen'] as bool? ?? false,
      hasValidSsn = json['hasValidSsn'] as bool? ?? false;

  /// Under 17 on December 31 of the tax year.
  final bool underSeventeen;

  /// Has an SSN valid for employment issued by the return due date.
  final bool hasValidSsn;

  Map<String, Object?> toJson() => {
    'underSeventeen': underSeventeen,
    'hasValidSsn': hasValidSsn,
  };
}

final class UsTaxProfile extends TaxProfile {
  const UsTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.filingStatus = UsFilingStatus.single,
    this.homeOfficeMethod = UsHomeOfficeMethod.simplified,
    this.specifiedServiceTrade = false,
    this.foreignEarnedIncomeExclusionMinor = 0,
    this.taxpayer65OrOlder = false,
    this.spouse65OrOlder = false,
    this.taxpayerHasSsn = true,
    this.spouseHasSsn = true,
    this.dependents = const [],
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.us;

  @override
  final bool salesTaxRegistered;

  final UsFilingStatus filingStatus;

  /// The Schedule C method used for business use of home; the $1,500 cap
  /// applies to [UsHomeOfficeMethod.simplified] only.
  final UsHomeOfficeMethod homeOfficeMethod;

  /// The trade is a specified service trade or business (SSTB) for the
  /// qualified business income phase-out.
  final bool specifiedServiceTrade;

  /// The foreign earned income exclusion claimed on Form 2555. It is added
  /// back to modified adjusted gross income for the net investment income
  /// tax, the SALT phase-down, and the Schedule 1-A phase-outs.
  final int foreignEarnedIncomeExclusionMinor;

  /// The taxpayer is 65 or older on December 31 (Schedule 1-A senior
  /// deduction).
  final bool taxpayer65OrOlder;

  /// The spouse is 65 or older on December 31 (Schedule 1-A senior
  /// deduction on a joint return).
  final bool spouse65OrOlder;

  /// The taxpayer has an SSN valid for employment (Schedule 1-A and the
  /// child tax credit require one).
  final bool taxpayerHasSsn;

  /// The spouse has an SSN valid for employment.
  final bool spouseHasSsn;

  /// The people claimed as dependents this year.
  final List<UsDependent> dependents;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'filingStatus': filingStatus.name,
    'homeOfficeMethod': homeOfficeMethod.name,
    'specifiedServiceTrade': specifiedServiceTrade,
    'foreignEarnedIncomeExclusionMinor': foreignEarnedIncomeExclusionMinor,
    'taxpayer65OrOlder': taxpayer65OrOlder,
    'spouse65OrOlder': spouse65OrOlder,
    'taxpayerHasSsn': taxpayerHasSsn,
    'spouseHasSsn': spouseHasSsn,
    'dependents': [for (final dependent in dependents) dependent.toJson()],
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
