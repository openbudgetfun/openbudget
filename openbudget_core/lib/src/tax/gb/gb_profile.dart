import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';

/// Student loan repayment plans HMRC collects through Self Assessment.
///
/// [postgraduate] never appears in [GbTaxProfile.studentLoanPlan]: a
/// postgraduate loan is held alongside an undergraduate plan, so it is a
/// separate flag. The value stays in the enum so old profiles that stored
/// the postgraduate loan in `studentLoanPlan` still parse.
enum GbStudentLoanPlan { plan1, plan2, plan4, plan5, postgraduate }

/// The facts about a United Kingdom taxpayer that change how their figures
/// are taxed.
@immutable
final class GbTaxProfile extends TaxProfile {
  const GbTaxProfile({
    required super.entityKind,
    super.salesTaxRegistered,
    super.taxResident,
    super.usPerson,
    this.scottishTaxpayer = false,
    this.studentLoanPlan,
    this.postgraduateLoan = false,
    this.accountingPeriodEndMonth = 3,
    this.accountingPeriodEndDay = 31,
    this.associatedCompanies = 0,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

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
    ...baseJson(),
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
GbTaxProfile gbProfileFromJson(Map<String, Object?> json) {
  final common = taxProfileCommonJson(json);
  final legacyPlan = taxProfileEnumField(
    json,
    'studentLoanPlan',
    GbStudentLoanPlan.values,
  );
  final undergradPlan =
      legacyPlan == null || legacyPlan == GbStudentLoanPlan.postgraduate
      ? null
      : legacyPlan;
  final postgraduate =
      taxProfileField<bool>(json, 'postgraduateLoan') ??
      legacyPlan == GbStudentLoanPlan.postgraduate;
  final endMonth = taxProfileField<int>(json, 'accountingPeriodEndMonth') ?? 3;
  if (endMonth < 1 || endMonth > 12) {
    throw FormatException(
      'Tax profile field "accountingPeriodEndMonth" must be 1 to 12',
      endMonth,
    );
  }
  final endDay = taxProfileField<int>(json, 'accountingPeriodEndDay') ?? 31;
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
    entityKind: common.entityKind,
    salesTaxRegistered: common.salesTaxRegistered,
    taxResident: common.taxResident,
    usPerson: common.usPerson,
    scottishTaxpayer: taxProfileField<bool>(json, 'scottishTaxpayer') ?? false,
    studentLoanPlan: undergradPlan,
    postgraduateLoan: postgraduate,
    accountingPeriodEndMonth: endMonth,
    accountingPeriodEndDay: endDay,
    associatedCompanies:
        taxProfileNonNegativeInt(json, 'associatedCompanies') ?? 0,
  );
}

/// The questions the GB pack asks after [commonTaxProfileQuestions], in
/// form order.
const gbTaxProfileQuestions = <TaxProfileQuestion>[
  TaxBoolQuestion(
    key: 'scottishTaxpayer',
    labelKey: 'taxQGbScottishTaxpayer',
    helpKey: 'taxQGbScottishTaxpayerHelp',
  ),
  TaxChoiceQuestion(
    key: 'studentLoanPlan',
    labelKey: 'taxQGbStudentLoanPlan',
    options: [
      TaxChoiceOption(value: 'plan1', labelKey: 'taxQGbStudentLoanPlanPlan1'),
      TaxChoiceOption(value: 'plan2', labelKey: 'taxQGbStudentLoanPlanPlan2'),
      TaxChoiceOption(value: 'plan4', labelKey: 'taxQGbStudentLoanPlanPlan4'),
      TaxChoiceOption(value: 'plan5', labelKey: 'taxQGbStudentLoanPlanPlan5'),
    ],
    noneLabelKey: 'taxQGbStudentLoanPlanNone',
  ),
  TaxBoolQuestion(
    key: 'postgraduateLoan',
    labelKey: 'taxQGbPostgraduateLoan',
    helpKey: 'taxQGbPostgraduateLoanHelp',
  ),
  TaxMonthDayQuestion(
    key: 'accountingPeriodEnd',
    labelKey: 'taxQGbAccountingPeriodEnd',
    helpKey: 'taxQGbAccountingPeriodEndHelp',
    monthLabelKey: 'taxQGbAccountingPeriodMonth',
    dayLabelKey: 'taxQGbAccountingPeriodDay',
    appliesTo: {EntityKind.company},
  ),
  TaxCountQuestion(
    key: 'associatedCompanies',
    labelKey: 'taxQGbAssociatedCompanies',
    helpKey: 'taxQGbAssociatedCompaniesHelp',
    appliesTo: {EntityKind.company},
  ),
];
