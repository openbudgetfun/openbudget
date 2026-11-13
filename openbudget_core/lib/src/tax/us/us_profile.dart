import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';

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
@immutable
final class UsDependent {
  const UsDependent({
    required this.underSeventeen,
    required this.hasValidSsn,
  });

  UsDependent.fromJson(Map<String, Object?> json)
    : underSeventeen = taxProfileField<bool>(json, 'underSeventeen') ?? false,
      hasValidSsn = taxProfileField<bool>(json, 'hasValidSsn') ?? false;

  /// Under 17 on December 31 of the tax year.
  final bool underSeventeen;

  /// Has an SSN valid for employment issued by the return due date.
  final bool hasValidSsn;

  Map<String, Object?> toJson() => {
    'underSeventeen': underSeventeen,
    'hasValidSsn': hasValidSsn,
  };
}

/// The facts about a United States taxpayer that change how their figures
/// are taxed.
@immutable
final class UsTaxProfile extends TaxProfile {
  const UsTaxProfile({
    required super.entityKind,
    super.salesTaxRegistered,
    super.taxResident,
    super.usPerson,
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
    ...baseJson(),
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

/// Decodes a US profile.
UsTaxProfile usProfileFromJson(Map<String, Object?> json) {
  final common = taxProfileCommonJson(json);
  return UsTaxProfile(
    entityKind: common.entityKind,
    salesTaxRegistered: common.salesTaxRegistered,
    taxResident: common.taxResident,
    usPerson: common.usPerson,
    filingStatus:
        taxProfileEnumField(json, 'filingStatus', UsFilingStatus.values) ??
        UsFilingStatus.single,
    homeOfficeMethod:
        taxProfileEnumField(
          json,
          'homeOfficeMethod',
          UsHomeOfficeMethod.values,
        ) ??
        UsHomeOfficeMethod.simplified,
    specifiedServiceTrade:
        taxProfileField<bool>(json, 'specifiedServiceTrade') ?? false,
    foreignEarnedIncomeExclusionMinor:
        taxProfileNonNegativeInt(json, 'foreignEarnedIncomeExclusionMinor') ??
        0,
    taxpayer65OrOlder:
        taxProfileField<bool>(json, 'taxpayer65OrOlder') ?? false,
    spouse65OrOlder: taxProfileField<bool>(json, 'spouse65OrOlder') ?? false,
    taxpayerHasSsn: taxProfileField<bool>(json, 'taxpayerHasSsn') ?? true,
    spouseHasSsn: taxProfileField<bool>(json, 'spouseHasSsn') ?? true,
    dependents: [
      for (final dependent
          in taxProfileField<List<Object?>>(json, 'dependents') ?? const [])
        switch (dependent) {
          final Map<String, Object?> fields => UsDependent.fromJson(fields),
          _ => throw FormatException(
            'Tax profile field "dependents" must hold objects',
            dependent,
          ),
        },
    ],
  );
}

/// The questions the US pack asks after [commonTaxProfileQuestions], in
/// form order.
///
/// The three dependent questions are one stored field in the end: the
/// counts of dependents under and over 17 and their shared SSN answer
/// compose into the `dependents` list the profile stores, so their keys
/// name the answers, not a stored field.
const usTaxProfileQuestions = <TaxProfileQuestion>[
  TaxChoiceQuestion(
    key: 'filingStatus',
    labelKey: 'taxQUsFilingStatus',
    options: [
      TaxChoiceOption(value: 'single', labelKey: 'taxQUsFilingStatusSingle'),
      TaxChoiceOption(
        value: 'marriedFilingJointly',
        labelKey: 'taxQUsFilingStatusMarriedFilingJointly',
      ),
      TaxChoiceOption(
        value: 'marriedFilingSeparately',
        labelKey: 'taxQUsFilingStatusMarriedFilingSeparately',
      ),
      TaxChoiceOption(
        value: 'headOfHousehold',
        labelKey: 'taxQUsFilingStatusHeadOfHousehold',
      ),
      TaxChoiceOption(
        value: 'qualifyingSurvivingSpouse',
        labelKey: 'taxQUsFilingStatusQualifyingSurvivingSpouse',
      ),
    ],
  ),
  TaxBoolQuestion(
    key: 'taxpayerHasSsn',
    labelKey: 'taxQUsTaxpayerHasSsn',
    helpKey: 'taxQUsTaxpayerHasSsnHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxBoolQuestion(
    key: 'spouseHasSsn',
    labelKey: 'taxQUsSpouseHasSsn',
    helpKey: 'taxQUsSpouseHasSsnHelp',
    appliesTo: {EntityKind.individual},
    visibleWhen: TaxProfileCondition('filingStatus', {
      'marriedFilingJointly',
    }),
  ),
  TaxBoolQuestion(
    key: 'taxpayer65OrOlder',
    labelKey: 'taxQUsTaxpayer65OrOlder',
    appliesTo: {EntityKind.individual},
  ),
  TaxBoolQuestion(
    key: 'spouse65OrOlder',
    labelKey: 'taxQUsSpouse65OrOlder',
    appliesTo: {EntityKind.individual},
    visibleWhen: TaxProfileCondition('filingStatus', {
      'marriedFilingJointly',
    }),
  ),
  TaxCountQuestion(
    key: 'dependentsUnder17',
    labelKey: 'taxQUsDependentsUnder17',
    helpKey: 'taxQUsDependentsUnder17Help',
    appliesTo: {EntityKind.individual},
  ),
  TaxCountQuestion(
    key: 'dependents17OrOlder',
    labelKey: 'taxQUsDependents17OrOlder',
    helpKey: 'taxQUsDependents17OrOlderHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxBoolQuestion(
    key: 'dependentsHaveSsn',
    labelKey: 'taxQUsDependentsHaveSsn',
    helpKey: 'taxQUsDependentsHaveSsnHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxMoneyQuestion(
    key: 'foreignEarnedIncomeExclusionMinor',
    labelKey: 'taxQUsForeignEarnedIncomeExclusion',
    helpKey: 'taxQUsForeignEarnedIncomeExclusionHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxBoolQuestion(
    key: 'specifiedServiceTrade',
    labelKey: 'taxQUsSpecifiedServiceTrade',
    helpKey: 'taxQUsSpecifiedServiceTradeHelp',
    appliesTo: {EntityKind.soleTrader},
  ),
  TaxChoiceQuestion(
    key: 'homeOfficeMethod',
    labelKey: 'taxQUsHomeOfficeMethod',
    options: [
      TaxChoiceOption(
        value: 'simplified',
        labelKey: 'taxQUsHomeOfficeMethodSimplified',
      ),
      TaxChoiceOption(
        value: 'regular',
        labelKey: 'taxQUsHomeOfficeMethodRegular',
      ),
    ],
    appliesTo: {EntityKind.soleTrader},
  ),
];
