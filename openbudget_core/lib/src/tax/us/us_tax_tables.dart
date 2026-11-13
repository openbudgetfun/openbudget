import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';
import 'package:openbudget_core/src/tax/us/us_profile.dart';

/// The date the federal figures in this pack were last checked against the
/// IRS sources in [usTaxSources].
final DateTime usRulesVerifiedOn = DateTime.utc(2026, 11, 5);

/// The IRS pages every report cites.
final List<Uri> usTaxSources = List.unmodifiable(<Uri>[
  Uri.parse('https://www.irs.gov/pub/irs-drop/rp-24-40.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-drop/rp-25-32.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/i1040gi.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040s1.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040sc.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040sse.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-prior/f1040sse--2025.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040sa.pdf'),
  Uri.parse('https://www.irs.gov/instructions/i1040sca'),
  Uri.parse(
    'https://www.irs.gov/newsroom/'
    'schedule-1-a-additional-deductions-what-to-know-about-the-new-form',
  ),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8995.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8995a.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8959.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8960.pdf'),
  Uri.parse('https://www.irs.gov/taxtopics/tc559'),
  Uri.parse(
    'https://www.irs.gov/credits-deductions/individuals/child-tax-credit',
  ),
  Uri.parse(
    'https://www.irs.gov/businesses/small-businesses-self-employed/'
    'questions-and-answers-for-the-additional-medicare-tax',
  ),
  Uri.parse('https://www.irs.gov/publications/p587'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/p505.pdf'),
  Uri.parse('https://www.irs.gov/publications/p560'),
  Uri.parse('https://www.irs.gov/publications/p969'),
  Uri.parse('https://www.irs.gov/individuals/net-investment-income-tax'),
  Uri.parse(
    'https://www.irs.gov/businesses/small-businesses-self-employed/'
    'self-employment-tax-social-security-and-medicare-taxes',
  ),
  Uri.parse(
    'https://www.irs.gov/businesses/small-businesses-self-employed/'
    'estimated-taxes',
  ),
  Uri.parse(
    'https://www.irs.gov/businesses/small-businesses-self-employed/'
    'simplified-option-for-home-office-deduction',
  ),
  Uri.parse('https://www.irs.gov/taxtopics/tc409'),
  Uri.parse('https://www.irs.gov/newsroom/qualified-business-income-deduction'),
  Uri.parse(
    'https://www.irs.gov/retirement-plans/'
    'cola-increases-for-dollar-limitations-on-benefits-and-contributions',
  ),
  Uri.parse('https://www.irs.gov/pub/irs-drop/n-24-80.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-drop/n-25-67.pdf'),
  Uri.parse(
    'https://www.irs.gov/newsroom/'
    '401k-limit-increases-to-24500-for-2026-ira-limit-increases-to-7500',
  ),
]);

/// The version, sources and verification date of each supported year.
final Map<int, TaxRuleSet> usRuleSetsByStartYear = Map.unmodifiable({
  for (final startYear in const [2025, 2026])
    startYear: TaxRuleSet(
      startYear: startYear,
      revision: 1,
      verifiedOn: usRulesVerifiedOn,
      sources: usTaxSources,
    ),
});

/// The inflation-adjusted federal figures for one calendar tax year.
final class UsTaxYearTable {
  const UsTaxYearTable({
    required this.startYear,
    required this.ordinaryBrackets,
    required this.standardDeduction,
    required this.longTermCapitalGainsBands,
    required this.qualifiedBusinessIncomeThreshold,
    required this.netInvestmentIncomeThreshold,
    required this.additionalMedicareThreshold,
    required this.socialSecurityWageBaseMinor,
    required this.sepContributionLimitMinor,
    required this.deferralLimitMinor,
    required this.iraLimitMinor,
    required this.hsaSelfOnlyLimitMinor,
    required this.hsaFamilyLimitMinor,
    required this.qbiPhaseInRange,
    required this.saltCapMinor,
    required this.saltPhaseDownThreshold,
    required this.saltFloorMinor,
    required this.childTaxCreditPerChildMinor,
    required this.childTaxCreditPhaseOutThreshold,
    required this.otherDependentCreditMinor,
    required this.qualifiedTipsCapMinor,
    required this.qualifiedOvertimeCap,
    required this.vehicleLoanInterestCapMinor,
    required this.seniorDeductionPerPersonMinor,
    required this.tipsOvertimePhaseOutThreshold,
    required this.vehicleLoanPhaseOutThreshold,
    required this.seniorPhaseOutThreshold,
    this.qbiMinimumDeductionMinor,
    this.qbiMinimumIncomeMinor,
  });

  /// The calendar year the tax year starts in.
  final int startYear;

  final Map<UsFilingStatus, List<TaxBand>> ordinaryBrackets;

  final Map<UsFilingStatus, int> standardDeduction;

  final Map<UsFilingStatus, List<TaxBand>> longTermCapitalGainsBands;

  final Map<UsFilingStatus, int> qualifiedBusinessIncomeThreshold;

  /// The width of the section 199A phase-in range that starts at
  /// [qualifiedBusinessIncomeThreshold] (IRC 199A(b)(3)). 2025:
  /// 50,000 (100,000 joint); 2026: 75,000 (150,000 joint). Rev. Proc.
  /// 2024-40 and 2025-32 (P).
  final Map<UsFilingStatus, int> qbiPhaseInRange;

  /// Statutory, not indexed for inflation.
  final Map<UsFilingStatus, int> netInvestmentIncomeThreshold;

  /// Statutory, not indexed for inflation.
  final Map<UsFilingStatus, int> additionalMedicareThreshold;

  /// The cap on deductible state and local taxes before the phase-down
  /// (IRC 164(b)(6), added by OBBBA). 2025: 40,000; 2026: 40,400; +1% a
  /// year to 2029, then 10,000. The 2025 worksheet is in the Schedule A
  /// instructions (P).
  final int saltCapMinor;

  /// Modified AGI above which the SALT cap phases down (P).
  final int saltPhaseDownThreshold;

  /// The SALT cap never falls below this floor (P).
  final int saltFloorMinor;

  /// The child tax credit per qualifying child under 17, 2025 and 2026
  /// (OBBBA; https://www.irs.gov/credits-deductions/individuals/child-tax-credit).
  final int childTaxCreditPerChildMinor;

  /// Modified AGI above which the child tax credit phases out. Statutory:
  /// 400,000 joint (and qualifying surviving spouse), 200,000 others;
  /// not indexed (P).
  final Map<UsFilingStatus, int> childTaxCreditPhaseOutThreshold;

  /// The nonrefundable credit for each dependent who is not a qualifying
  /// child, 2025 and 2026 (P).
  final int otherDependentCreditMinor;

  /// Schedule 1-A qualified tips cap per return, 2025 to 2028 (IRC 224, P).
  final int qualifiedTipsCapMinor;

  /// Schedule 1-A qualified overtime premium cap. 12,500, or 25,000 on a
  /// joint return (IRC 225, P).
  final Map<UsFilingStatus, int> qualifiedOvertimeCap;

  /// Schedule 1-A passenger-vehicle loan interest cap (IRC 163(h)(4), P).
  final int vehicleLoanInterestCapMinor;

  /// Schedule 1-A senior deduction per qualified individual aged 65 by
  /// December 31, 2025 to 2028 (IRC 151(d)(5)... statute; P).
  final int seniorDeductionPerPersonMinor;

  /// Modified AGI above which the tips and overtime deductions phase out:
  /// 150,000, or 300,000 joint (P).
  final Map<UsFilingStatus, int> tipsOvertimePhaseOutThreshold;

  /// Modified AGI above which the vehicle loan interest deduction phases
  /// out: 100,000, or 200,000 joint. MFS is half, following the usual MFS
  /// pattern (I; verify against the Schedule 1-A instructions).
  final Map<UsFilingStatus, int> vehicleLoanPhaseOutThreshold;

  /// Modified AGI above which the senior deduction phases out: 75,000, or
  /// 150,000 joint (P).
  final Map<UsFilingStatus, int> seniorPhaseOutThreshold;

  final int socialSecurityWageBaseMinor;
  final int sepContributionLimitMinor;
  final int deferralLimitMinor;
  final int iraLimitMinor;
  final int hsaSelfOnlyLimitMinor;
  final int hsaFamilyLimitMinor;

  /// The OBBBA minimum QBI deduction, for years it applies.
  final int? qbiMinimumDeductionMinor;

  /// The QBI needed before [qbiMinimumDeductionMinor] applies.
  final int? qbiMinimumIncomeMinor;

  List<TaxBand> ordinaryBracketsFor(UsFilingStatus status) =>
      ordinaryBrackets[status]!;

  int standardDeductionFor(UsFilingStatus status) => standardDeduction[status]!;

  List<TaxBand> longTermCapitalGainsBandsFor(UsFilingStatus status) =>
      longTermCapitalGainsBands[status]!;

  int qualifiedBusinessIncomeThresholdFor(UsFilingStatus status) =>
      qualifiedBusinessIncomeThreshold[status]!;

  int qbiPhaseInRangeFor(UsFilingStatus status) => qbiPhaseInRange[status]!;

  int netInvestmentIncomeThresholdFor(UsFilingStatus status) =>
      netInvestmentIncomeThreshold[status]!;

  int additionalMedicareThresholdFor(UsFilingStatus status) =>
      additionalMedicareThreshold[status]!;

  int childTaxCreditPhaseOutThresholdFor(UsFilingStatus status) =>
      childTaxCreditPhaseOutThreshold[status]!;

  int qualifiedOvertimeCapFor(UsFilingStatus status) =>
      qualifiedOvertimeCap[status]!;

  int tipsOvertimePhaseOutThresholdFor(UsFilingStatus status) =>
      tipsOvertimePhaseOutThreshold[status]!;

  int vehicleLoanPhaseOutThresholdFor(UsFilingStatus status) =>
      vehicleLoanPhaseOutThreshold[status]!;

  int seniorPhaseOutThresholdFor(UsFilingStatus status) =>
      seniorPhaseOutThreshold[status]!;
}

const List<TaxBand> _brackets2025Single = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_192_500),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 4_847_500),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_335_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 19_730_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_052_500),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 62_635_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2025Joint = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 2_385_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 9_695_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 20_670_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 39_460_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 50_105_000),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 75_160_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2025Separate = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_192_500),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 4_847_500),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_335_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 19_730_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_052_500),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 37_580_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2025Household = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_700_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 6_485_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_335_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 19_730_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_050_000),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 62_635_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2026Single = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_240_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 5_040_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_570_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 20_177_500),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_622_500),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 64_060_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2026Joint = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 2_480_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 10_080_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 21_140_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 40_355_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 51_245_000),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 76_870_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2026Separate = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_240_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 5_040_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_570_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 20_177_500),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_622_500),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 38_435_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _brackets2026Household = [
  TaxBand(label: '10%', rateBasisPoints: 1000, ceilingMinor: 1_770_000),
  TaxBand(label: '12%', rateBasisPoints: 1200, ceilingMinor: 6_745_000),
  TaxBand(label: '22%', rateBasisPoints: 2200, ceilingMinor: 10_570_000),
  TaxBand(label: '24%', rateBasisPoints: 2400, ceilingMinor: 20_175_000),
  TaxBand(label: '32%', rateBasisPoints: 3200, ceilingMinor: 25_620_000),
  TaxBand(label: '35%', rateBasisPoints: 3500, ceilingMinor: 64_060_000),
  TaxBand(label: '37%', rateBasisPoints: 3700),
];

const List<TaxBand> _capitalGains2025Single = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 4_835_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 53_340_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2025Joint = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 9_670_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 60_005_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2025Separate = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 4_835_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 30_000_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2025Household = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 6_475_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 56_670_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2026Single = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 4_945_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 54_550_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2026Joint = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 9_890_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 61_370_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2026Separate = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 4_945_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 30_685_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

const List<TaxBand> _capitalGains2026Household = [
  TaxBand(label: '0%', rateBasisPoints: 0, ceilingMinor: 6_620_000),
  TaxBand(label: '15%', rateBasisPoints: 1500, ceilingMinor: 57_960_000),
  TaxBand(label: '20%', rateBasisPoints: 2000),
];

/// NIIT and Additional Medicare thresholds. Both are statutory and the
/// qualifying surviving spouse uses the joint threshold
/// (https://www.irs.gov/taxtopics/tc559 and the Additional Medicare Q&A).
const Map<UsFilingStatus, int> _niitAndMedicareThresholds = {
  UsFilingStatus.single: 20_000_000,
  UsFilingStatus.marriedFilingJointly: 25_000_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 25_000_000,
  UsFilingStatus.marriedFilingSeparately: 12_500_000,
  UsFilingStatus.headOfHousehold: 20_000_000,
};

/// Child tax credit phase-out start. Statutory: 400,000 joint, 200,000
/// every other status including MFS; the qualifying surviving spouse uses
/// the joint figure.
const Map<UsFilingStatus, int> _childTaxCreditPhaseOutThresholds = {
  UsFilingStatus.single: 20_000_000,
  UsFilingStatus.marriedFilingJointly: 40_000_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 40_000_000,
  UsFilingStatus.marriedFilingSeparately: 20_000_000,
  UsFilingStatus.headOfHousehold: 20_000_000,
};

/// Schedule 1-A overtime premium caps: 12,500, doubled on a joint return.
const Map<UsFilingStatus, int> _qualifiedOvertimeCaps2025 = {
  UsFilingStatus.single: 1_250_000,
  UsFilingStatus.marriedFilingJointly: 2_500_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 2_500_000,
  UsFilingStatus.marriedFilingSeparately: 1_250_000,
  UsFilingStatus.headOfHousehold: 1_250_000,
};

/// Schedule 1-A tips and overtime phase-out start: 150,000, or 300,000
/// joint. MFS cannot claim either deduction, so its entry is unused.
const Map<UsFilingStatus, int> _tipsOvertimePhaseOutThresholds = {
  UsFilingStatus.single: 15_000_000,
  UsFilingStatus.marriedFilingJointly: 30_000_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 30_000_000,
  UsFilingStatus.marriedFilingSeparately: 15_000_000,
  UsFilingStatus.headOfHousehold: 15_000_000,
};

/// Schedule 1-A vehicle loan interest phase-out start: 100,000, or 200,000
/// joint; MFS half (I, not read; verify against the instructions).
const Map<UsFilingStatus, int> _vehicleLoanPhaseOutThresholds = {
  UsFilingStatus.single: 10_000_000,
  UsFilingStatus.marriedFilingJointly: 20_000_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 20_000_000,
  UsFilingStatus.marriedFilingSeparately: 5_000_000,
  UsFilingStatus.headOfHousehold: 10_000_000,
};

/// Schedule 1-A senior deduction phase-out start: 75,000, or 150,000
/// joint. MFS cannot claim the senior deduction, so its entry is unused.
const Map<UsFilingStatus, int> _seniorPhaseOutThresholds = {
  UsFilingStatus.single: 7_500_000,
  UsFilingStatus.marriedFilingJointly: 15_000_000,
  UsFilingStatus.qualifyingSurvivingSpouse: 15_000_000,
  UsFilingStatus.marriedFilingSeparately: 7_500_000,
  UsFilingStatus.headOfHousehold: 7_500_000,
};

const UsTaxYearTable usTaxYear2025 = UsTaxYearTable(
  startYear: 2025,
  ordinaryBrackets: {
    UsFilingStatus.single: _brackets2025Single,
    UsFilingStatus.marriedFilingJointly: _brackets2025Joint,
    UsFilingStatus.qualifyingSurvivingSpouse: _brackets2025Joint,
    UsFilingStatus.marriedFilingSeparately: _brackets2025Separate,
    UsFilingStatus.headOfHousehold: _brackets2025Household,
  },
  standardDeduction: {
    UsFilingStatus.single: 1_575_000,
    UsFilingStatus.marriedFilingJointly: 3_150_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 3_150_000,
    UsFilingStatus.marriedFilingSeparately: 1_575_000,
    UsFilingStatus.headOfHousehold: 2_362_500,
  },
  longTermCapitalGainsBands: {
    UsFilingStatus.single: _capitalGains2025Single,
    UsFilingStatus.marriedFilingJointly: _capitalGains2025Joint,
    UsFilingStatus.qualifyingSurvivingSpouse: _capitalGains2025Joint,
    UsFilingStatus.marriedFilingSeparately: _capitalGains2025Separate,
    UsFilingStatus.headOfHousehold: _capitalGains2025Household,
  },
  qualifiedBusinessIncomeThreshold: {
    UsFilingStatus.single: 19_730_000,
    UsFilingStatus.marriedFilingJointly: 39_460_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 39_460_000,
    UsFilingStatus.marriedFilingSeparately: 19_730_000,
    UsFilingStatus.headOfHousehold: 19_730_000,
  },
  qbiPhaseInRange: {
    UsFilingStatus.single: 5_000_000,
    UsFilingStatus.marriedFilingJointly: 10_000_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 10_000_000,
    UsFilingStatus.marriedFilingSeparately: 5_000_000,
    UsFilingStatus.headOfHousehold: 5_000_000,
  },
  netInvestmentIncomeThreshold: _niitAndMedicareThresholds,
  additionalMedicareThreshold: _niitAndMedicareThresholds,
  saltCapMinor: 4_000_000,
  saltPhaseDownThreshold: 50_000_000,
  saltFloorMinor: 1_000_000,
  childTaxCreditPerChildMinor: 220_000,
  childTaxCreditPhaseOutThreshold: _childTaxCreditPhaseOutThresholds,
  otherDependentCreditMinor: 50_000,
  qualifiedTipsCapMinor: 2_500_000,
  qualifiedOvertimeCap: _qualifiedOvertimeCaps2025,
  vehicleLoanInterestCapMinor: 1_000_000,
  seniorDeductionPerPersonMinor: 600_000,
  tipsOvertimePhaseOutThreshold: _tipsOvertimePhaseOutThresholds,
  vehicleLoanPhaseOutThreshold: _vehicleLoanPhaseOutThresholds,
  seniorPhaseOutThreshold: _seniorPhaseOutThresholds,
  socialSecurityWageBaseMinor: 17_610_000,
  sepContributionLimitMinor: 7_000_000,
  deferralLimitMinor: 2_350_000,
  iraLimitMinor: 700_000,
  hsaSelfOnlyLimitMinor: 430_000,
  hsaFamilyLimitMinor: 855_000,
);

const UsTaxYearTable usTaxYear2026 = UsTaxYearTable(
  startYear: 2026,
  ordinaryBrackets: {
    UsFilingStatus.single: _brackets2026Single,
    UsFilingStatus.marriedFilingJointly: _brackets2026Joint,
    UsFilingStatus.qualifyingSurvivingSpouse: _brackets2026Joint,
    UsFilingStatus.marriedFilingSeparately: _brackets2026Separate,
    UsFilingStatus.headOfHousehold: _brackets2026Household,
  },
  standardDeduction: {
    UsFilingStatus.single: 1_610_000,
    UsFilingStatus.marriedFilingJointly: 3_220_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 3_220_000,
    UsFilingStatus.marriedFilingSeparately: 1_610_000,
    UsFilingStatus.headOfHousehold: 2_415_000,
  },
  longTermCapitalGainsBands: {
    UsFilingStatus.single: _capitalGains2026Single,
    UsFilingStatus.marriedFilingJointly: _capitalGains2026Joint,
    UsFilingStatus.qualifyingSurvivingSpouse: _capitalGains2026Joint,
    UsFilingStatus.marriedFilingSeparately: _capitalGains2026Separate,
    UsFilingStatus.headOfHousehold: _capitalGains2026Household,
  },
  qualifiedBusinessIncomeThreshold: {
    UsFilingStatus.single: 20_175_000,
    UsFilingStatus.marriedFilingJointly: 40_350_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 40_350_000,
    UsFilingStatus.marriedFilingSeparately: 20_177_500,
    UsFilingStatus.headOfHousehold: 20_175_000,
  },
  qbiPhaseInRange: {
    UsFilingStatus.single: 7_500_000,
    UsFilingStatus.marriedFilingJointly: 15_000_000,
    UsFilingStatus.qualifyingSurvivingSpouse: 15_000_000,
    UsFilingStatus.marriedFilingSeparately: 7_500_000,
    UsFilingStatus.headOfHousehold: 7_500_000,
  },
  netInvestmentIncomeThreshold: _niitAndMedicareThresholds,
  additionalMedicareThreshold: _niitAndMedicareThresholds,
  saltCapMinor: 4_040_000,
  saltPhaseDownThreshold: 50_500_000,
  saltFloorMinor: 1_000_000,
  childTaxCreditPerChildMinor: 220_000,
  childTaxCreditPhaseOutThreshold: _childTaxCreditPhaseOutThresholds,
  otherDependentCreditMinor: 50_000,
  qualifiedTipsCapMinor: 2_500_000,
  qualifiedOvertimeCap: _qualifiedOvertimeCaps2025,
  vehicleLoanInterestCapMinor: 1_000_000,
  seniorDeductionPerPersonMinor: 600_000,
  tipsOvertimePhaseOutThreshold: _tipsOvertimePhaseOutThresholds,
  vehicleLoanPhaseOutThreshold: _vehicleLoanPhaseOutThresholds,
  seniorPhaseOutThreshold: _seniorPhaseOutThresholds,
  socialSecurityWageBaseMinor: 18_450_000,
  sepContributionLimitMinor: 7_200_000,
  deferralLimitMinor: 2_450_000,
  iraLimitMinor: 750_000,
  hsaSelfOnlyLimitMinor: 440_000,
  hsaFamilyLimitMinor: 875_000,
  qbiMinimumDeductionMinor: 40_000,
  qbiMinimumIncomeMinor: 100_000,
);

/// The taxable income at and above which the Tax Computation Worksheet
/// replaces the Tax Table (Form 1040 instructions).
const int usTaxTableThresholdDollars = 100000;

/// Rounds cents to whole dollars, half up, the way the IRS does on forms.
int usRoundToDollars(int cents) => (cents + 50) ~/ 100 * 100;

/// The filed federal income tax for [taxableIncomeCents].
///
/// This reproduces IRS practice (K: general Form 1040 instruction practice,
/// not read from the printed table; check once against the printed 2025 and
/// 2026 Tax Table before release):
///
/// - Taxable income is rounded to whole dollars first, half up.
/// - Below [usTaxTableThresholdDollars] the Tax Table applies: the tax is
///   the bracket formula on the midpoint of the $50 row containing the
///   taxable income ($25 rows from $25 to $3,000, and three narrow rows
///   0-5, 5-15, 15-25 at the bottom), rounded to whole dollars, half up.
/// - At [usTaxTableThresholdDollars] and above the Tax Computation
///   Worksheet applies: the bracket formula on the exact whole-dollar
///   taxable income, no midpoint.
int usIncomeTaxFromTable(
  int taxableIncomeCents,
  UsFilingStatus status,
  int year,
) {
  final table = switch (year) {
    2025 => usTaxYear2025,
    2026 => usTaxYear2026,
    _ => throw UnsupportedTaxYearException(TaxJurisdiction.us, year),
  };
  final dollars = usRoundToDollars(taxableIncomeCents) ~/ 100;
  if (dollars >= usTaxTableThresholdDollars) {
    // Tax Computation Worksheet: the formula on the rounded whole-dollar
    // taxable income, no midpoint.
    return sumBandTax(
      applyTaxBands(
        dollars * 100,
        table.ordinaryBracketsFor(status),
      ),
    );
  }
  return usRoundToDollars(
    sumBandTax(
      applyTaxBands(
        _taxTableRowMidpointCents(dollars),
        table.ordinaryBracketsFor(status),
      ),
    ),
  );
}

/// The midpoint of the Tax Table row that contains the whole-dollar
/// [dollars], in cents.
int _taxTableRowMidpointCents(int dollars) {
  if (dollars < 5) {
    return 250; // Row 0-5, midpoint 2.50.
  }
  if (dollars < 15) {
    return 1000; // Row 5-15, midpoint 10.
  }
  if (dollars < 25) {
    return 2000; // Row 15-25, midpoint 20.
  }
  if (dollars < 3000) {
    // $25 rows from $25 to $3,000: 25-50, 50-75, ...
    final rowStart = 25 + ((dollars - 25) ~/ 25) * 25;
    return rowStart * 100 + 1250;
  }
  // $50 rows from $3,000 to $100,000: 3,000-3,050, 3,050-3,100, ...
  final rowStart = 3000 + ((dollars - 3000) ~/ 50) * 50;
  return rowStart * 100 + 2500;
}
