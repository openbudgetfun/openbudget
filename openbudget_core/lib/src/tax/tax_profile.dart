import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// The facts about a taxpayer that change how their figures are taxed.
///
/// Each jurisdiction has its own profile, so only the questions that matter
/// there can be asked and stored.
@immutable
sealed class TaxProfile {
  const TaxProfile({required this.entityKind});

  final EntityKind entityKind;

  TaxJurisdiction get jurisdiction;

  /// Whether the books are registered for VAT or sales tax.
  bool get salesTaxRegistered;

  Map<String, Object?> toJson();

  static TaxProfile fromJson(Map<String, Object?> json) {
    final entityKind = _requiredEnum(json, 'entityKind', EntityKind.values);
    final registered = _field<bool>(json, 'salesTaxRegistered') ?? false;
    final jurisdictionCode = _required<String>(json, 'jurisdiction');
    return switch (TaxJurisdiction.fromCountryCode(jurisdictionCode)) {
      TaxJurisdiction.gb => gbProfileFromJson(
        json,
        entityKind,
        salesTaxRegistered: registered,
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        filingStatus:
            _enumField(json, 'filingStatus', UsFilingStatus.values) ??
            UsFilingStatus.single,
        homeOfficeMethod:
            _enumField(json, 'homeOfficeMethod', UsHomeOfficeMethod.values) ??
            UsHomeOfficeMethod.simplified,
        specifiedServiceTrade:
            _field<bool>(json, 'specifiedServiceTrade') ?? false,
        foreignEarnedIncomeExclusionMinor:
            _nonNegativeInt(json, 'foreignEarnedIncomeExclusionMinor') ?? 0,
        taxpayer65OrOlder: _field<bool>(json, 'taxpayer65OrOlder') ?? false,
        spouse65OrOlder: _field<bool>(json, 'spouse65OrOlder') ?? false,
        taxpayerHasSsn: _field<bool>(json, 'taxpayerHasSsn') ?? true,
        spouseHasSsn: _field<bool>(json, 'spouseHasSsn') ?? true,
        dependents: [
          for (final dependent
              in _field<List<Object?>>(json, 'dependents') ?? const [])
            switch (dependent) {
              final Map<String, Object?> fields => UsDependent.fromJson(fields),
              _ => throw FormatException(
                'Tax profile field "dependents" must hold objects',
                dependent,
              ),
            },
        ],
      ),
      TaxJurisdiction.ng => NgTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        annualRentMinor: _nonNegativeInt(json, 'annualRentMinor') ?? 0,
        smallCompanyCeiling:
            _enumField(
              json,
              'smallCompanyCeiling',
              NgSmallCompanyCeiling.values,
            ) ??
            NgSmallCompanyCeiling.ntaGazette,
        mneGroupMember: _field<bool>(json, 'mneGroupMember') ?? false,
      ),
      TaxJurisdiction.de => DeTaxProfile(
        entityKind: entityKind,
        salesTaxRegistered: registered,
        jointAssessment: _field<bool>(json, 'jointAssessment') ?? false,
        churchTax: _field<bool>(json, 'churchTax') ?? false,
        // Old JSON stored only the flag; the flag alone keeps the 9 %
        // assumption the old pack computed with.
        churchTaxState: _enumField(
          json,
          'churchTaxState',
          DeBundesland.values,
        ),
        smallBusinessExemption:
            _field<bool>(json, 'smallBusinessExemption') ?? true,
        // Old JSON had no Einkunftsart and the pack treated every sole
        // trader as a Gewerbebetrieb.
        einkunftsArt:
            _enumField(json, 'einkunftsArt', DeEinkunftsArt.values) ??
            DeEinkunftsArt.gewerblich,
        children: _nonNegativeInt(json, 'children') ?? 0,
        spouseEmployed: _field<bool>(json, 'spouseEmployed') ?? false,
        statutoryPensionMinor:
            _nonNegativeInt(json, 'statutoryPensionMinor') ?? 0,
        previousYearTurnoverMinor:
            _nonNegativeInt(json, 'previousYearTurnoverMinor') ?? 0,
        commuteKmOneWay: _nonNegativeInt(json, 'commuteKmOneWay') ?? 0,
        commuteDays: _nonNegativeInt(json, 'commuteDays') ?? 0,
      ),
      null => throw FormatException('Unknown jurisdiction', jurisdictionCode),
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
  EntityKind entityKind, {
  required bool salesTaxRegistered,
}) {
  final legacyPlan = _enumField(
    json,
    'studentLoanPlan',
    GbStudentLoanPlan.values,
  );
  final undergradPlan =
      legacyPlan == null || legacyPlan == GbStudentLoanPlan.postgraduate
      ? null
      : legacyPlan;
  final postgraduate =
      _field<bool>(json, 'postgraduateLoan') ??
      legacyPlan == GbStudentLoanPlan.postgraduate;
  final endMonth = _field<int>(json, 'accountingPeriodEndMonth') ?? 3;
  if (endMonth < 1 || endMonth > 12) {
    throw FormatException(
      'Tax profile field "accountingPeriodEndMonth" must be 1 to 12',
      endMonth,
    );
  }
  final endDay = _field<int>(json, 'accountingPeriodEndDay') ?? 31;
  final lastDay = switch (endMonth) {
    2 => 29,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };
  if (endDay < 1 || endDay > lastDay) {
    throw FormatException(
      'Tax profile field "accountingPeriodEndDay" must be 1 to $lastDay',
      endDay,
    );
  }
  return GbTaxProfile(
    entityKind: entityKind,
    salesTaxRegistered: salesTaxRegistered,
    scottishTaxpayer: _field<bool>(json, 'scottishTaxpayer') ?? false,
    studentLoanPlan: undergradPlan,
    postgraduateLoan: postgraduate,
    accountingPeriodEndMonth: endMonth,
    accountingPeriodEndDay: endDay,
    associatedCompanies: _nonNegativeInt(json, 'associatedCompanies') ?? 0,
  );
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
    : underSeventeen = _field<bool>(json, 'underSeventeen') ?? false,
      hasValidSsn = _field<bool>(json, 'hasValidSsn') ?? false;

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

/// Whether a self-employed person's profit is gewerblich (§ 15 EStG,
/// Anlage G, trade tax with the § 35 credit) or freiberuflich (§ 18 EStG,
/// Anlage S, no trade tax).
enum DeEinkunftsArt {
  /// Freie Berufe: no Gewerbesteuer, filed on Anlage S.
  freiberuflich,

  /// Gewerbebetrieb: Gewerbesteuer and the § 35 EStG credit, Anlage G.
  gewerblich,
}

/// The sixteen Länder. Church tax is state and church law, so the rate
/// follows the Land: 8 % in Bayern and Baden-Württemberg, 9 % everywhere
/// else.
enum DeBundesland {
  badenWuerttemberg('Baden-Württemberg'),
  bayern('Bayern'),
  berlin('Berlin'),
  brandenburg('Brandenburg'),
  bremen('Bremen'),
  hamburg('Hamburg'),
  hessen('Hessen'),
  mecklenburgVorpommern('Mecklenburg-Vorpommern'),
  niedersachsen('Niedersachsen'),
  nordrheinWestfalen('Nordrhein-Westfalen'),
  rheinlandPfalz('Rheinland-Pfalz'),
  saarland('Saarland'),
  sachsen('Sachsen'),
  sachsenAnhalt('Sachsen-Anhalt'),
  schleswigHolstein('Schleswig-Holstein'),
  thueringen('Thüringen');

  const DeBundesland(this.label);

  /// The name the Land uses for itself.
  final String label;

  /// Kirchensteuer-Hebesatz of the Land (§ 51a Abs. 1 EStG naming the
  /// Grundsteuer of the Kirchen as 8 % or 9 % of the income tax).
  int get churchTaxRateBasisPoints =>
      this == DeBundesland.bayern || this == DeBundesland.badenWuerttemberg
      ? 800
      : 900;
}

final class DeTaxProfile extends TaxProfile {
  const DeTaxProfile({
    required super.entityKind,
    this.salesTaxRegistered = false,
    this.jointAssessment = false,
    this.churchTax = false,
    this.churchTaxState,
    this.smallBusinessExemption = true,
    this.einkunftsArt = DeEinkunftsArt.gewerblich,
    this.children = 0,
    this.spouseEmployed = false,
    this.statutoryPensionMinor = 0,
    this.previousYearTurnoverMinor = 0,
    this.commuteKmOneWay = 0,
    this.commuteDays = 0,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.de;

  @override
  final bool salesTaxRegistered;

  /// Zusammenveranlagung: spouses assessed jointly under the splitting
  /// method.
  final bool jointAssessment;

  /// Whether the taxpayer belongs to a church that levies Kirchensteuer.
  ///
  /// The rate itself comes from [churchTaxState]. A profile parsed from old
  /// JSON carries only this flag; the pack then assumes the 9 % the old
  /// behaviour assumed.
  final bool churchTax;

  /// The Land whose Kirchensteuer rate applies. Null when the taxpayer has
  /// not named it, in which case [churchTax] alone triggers the 9 %
  /// assumption.
  final DeBundesland? churchTaxState;

  /// The Kirchensteuer rate this profile triggers, in basis points: the
  /// Land's rate when named, the old 9 % assumption for the bare flag, zero
  /// otherwise.
  int get churchTaxRateBasisPoints => switch (churchTaxState) {
    final state? => state.churchTaxRateBasisPoints,
    null => churchTax ? 900 : 0,
  };

  /// Kleinunternehmerregelung (§ 19 UStG): no VAT charged or reclaimed.
  final bool smallBusinessExemption;

  /// For a sole trader: whether the profit is gewerblich or freiberuflich.
  /// Defaults to gewerblich, what the pack assumed before the field existed.
  final DeEinkunftsArt einkunftsArt;

  /// Children the taxpayer receives Kindergeld for. The pack assumes a full
  /// twelve months per child.
  final int children;

  /// Zusammenveranlagung only: the second spouse also earns wages, so they
  /// claim their own Arbeitnehmer-Pauschbetrag and file their own Anlage N.
  final bool spouseEmployed;

  /// Contributions to the gesetzliche Rentenversicherung, employee and
  /// employer share combined. They reduce the Basisrente headroom of
  /// § 10 Abs. 3 EStG.
  final int statutoryPensionMinor;

  /// Gesamtumsatz of the previous calendar year, for the Kleinunternehmer
  /// test of § 19 Abs. 1 Satz 1 UStG. Zero when the business did not exist.
  final int previousYearTurnoverMinor;

  /// Anlage N: one-way distance in full kilometres to the first workplace,
  /// shortest road connection.
  final int commuteKmOneWay;

  /// Anlage N: days the workplace was visited. Days of illness, holiday,
  /// Dienstreise or Heimarbeit do not count.
  final int commuteDays;

  @override
  Map<String, Object?> toJson() => {
    ..._baseJson(),
    'jointAssessment': jointAssessment,
    'churchTax': churchTax,
    'churchTaxState': ?churchTaxState?.name,
    'smallBusinessExemption': smallBusinessExemption,
    'einkunftsArt': einkunftsArt.name,
    'children': children,
    'spouseEmployed': spouseEmployed,
    'statutoryPensionMinor': statutoryPensionMinor,
    'previousYearTurnoverMinor': previousYearTurnoverMinor,
    'commuteKmOneWay': commuteKmOneWay,
    'commuteDays': commuteDays,
  };
}

// Strict readers for stored and client-supplied profile maps. Each one fails
// with a [FormatException] naming the field, so a malformed profile is
// reported as invalid input rather than crashing with a cast error.

T? _field<T extends Object>(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is T) return value;
  throw FormatException('Tax profile field "$key" must be a $T', value);
}

T _required<T extends Object>(Map<String, Object?> json, String key) =>
    _field<T>(json, key) ??
    (throw FormatException('Tax profile field "$key" is required'));

int? _nonNegativeInt(Map<String, Object?> json, String key) {
  final value = _field<int>(json, key);
  if (value != null && value < 0) {
    throw FormatException(
      'Tax profile field "$key" must not be negative',
      value,
    );
  }
  return value;
}

T? _enumField<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) {
  final name = _field<String>(json, key);
  if (name == null) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Tax profile field "$key" has an unknown value', name);
}

T _requiredEnum<T extends Enum>(
  Map<String, Object?> json,
  String key,
  List<T> values,
) =>
    _enumField(json, key, values) ??
    (throw FormatException('Tax profile field "$key" is required'));
