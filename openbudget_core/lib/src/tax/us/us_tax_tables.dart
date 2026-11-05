import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// The date the federal figures in this pack were last checked against the
/// IRS sources in [usTaxSources].
final DateTime usRulesVerifiedOn = DateTime.utc(2026, 11, 4);

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
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040es.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-prior/f1040es--2025.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f1120.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/i1120.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8995.pdf'),
  Uri.parse('https://www.irs.gov/pub/irs-pdf/f8959.pdf'),
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
    this.qbiMinimumDeductionMinor,
    this.qbiMinimumIncomeMinor,
  });

  /// The calendar year the tax year starts in.
  final int startYear;

  final Map<UsFilingStatus, List<TaxBand>> ordinaryBrackets;
  final Map<UsFilingStatus, int> standardDeduction;
  final Map<UsFilingStatus, List<TaxBand>> longTermCapitalGainsBands;
  final Map<UsFilingStatus, int> qualifiedBusinessIncomeThreshold;

  /// Statutory, not indexed for inflation.
  final Map<UsFilingStatus, int> netInvestmentIncomeThreshold;

  /// Statutory, not indexed for inflation.
  final Map<UsFilingStatus, int> additionalMedicareThreshold;

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

  int netInvestmentIncomeThresholdFor(UsFilingStatus status) =>
      netInvestmentIncomeThreshold[status]!;

  int additionalMedicareThresholdFor(UsFilingStatus status) =>
      additionalMedicareThreshold[status]!;
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

const Map<UsFilingStatus, int> _niitThresholds = {
  UsFilingStatus.single: 20_000_000,
  UsFilingStatus.marriedFilingJointly: 25_000_000,
  UsFilingStatus.marriedFilingSeparately: 12_500_000,
  UsFilingStatus.headOfHousehold: 20_000_000,
};

const UsTaxYearTable usTaxYear2025 = UsTaxYearTable(
  startYear: 2025,
  ordinaryBrackets: {
    UsFilingStatus.single: _brackets2025Single,
    UsFilingStatus.marriedFilingJointly: _brackets2025Joint,
    UsFilingStatus.marriedFilingSeparately: _brackets2025Separate,
    UsFilingStatus.headOfHousehold: _brackets2025Household,
  },
  standardDeduction: {
    UsFilingStatus.single: 1_575_000,
    UsFilingStatus.marriedFilingJointly: 3_150_000,
    UsFilingStatus.marriedFilingSeparately: 1_575_000,
    UsFilingStatus.headOfHousehold: 2_362_500,
  },
  longTermCapitalGainsBands: {
    UsFilingStatus.single: _capitalGains2025Single,
    UsFilingStatus.marriedFilingJointly: _capitalGains2025Joint,
    UsFilingStatus.marriedFilingSeparately: _capitalGains2025Separate,
    UsFilingStatus.headOfHousehold: _capitalGains2025Household,
  },
  qualifiedBusinessIncomeThreshold: {
    UsFilingStatus.single: 19_730_000,
    UsFilingStatus.marriedFilingJointly: 39_460_000,
    UsFilingStatus.marriedFilingSeparately: 19_730_000,
    UsFilingStatus.headOfHousehold: 19_730_000,
  },
  netInvestmentIncomeThreshold: _niitThresholds,
  additionalMedicareThreshold: _niitThresholds,
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
    UsFilingStatus.marriedFilingSeparately: _brackets2026Separate,
    UsFilingStatus.headOfHousehold: _brackets2026Household,
  },
  standardDeduction: {
    UsFilingStatus.single: 1_610_000,
    UsFilingStatus.marriedFilingJointly: 3_220_000,
    UsFilingStatus.marriedFilingSeparately: 1_610_000,
    UsFilingStatus.headOfHousehold: 2_415_000,
  },
  longTermCapitalGainsBands: {
    UsFilingStatus.single: _capitalGains2026Single,
    UsFilingStatus.marriedFilingJointly: _capitalGains2026Joint,
    UsFilingStatus.marriedFilingSeparately: _capitalGains2026Separate,
    UsFilingStatus.headOfHousehold: _capitalGains2026Household,
  },
  qualifiedBusinessIncomeThreshold: {
    UsFilingStatus.single: 20_175_000,
    UsFilingStatus.marriedFilingJointly: 40_350_000,
    UsFilingStatus.marriedFilingSeparately: 20_177_500,
    UsFilingStatus.headOfHousehold: 20_175_000,
  },
  netInvestmentIncomeThreshold: _niitThresholds,
  additionalMedicareThreshold: _niitThresholds,
  socialSecurityWageBaseMinor: 18_450_000,
  sepContributionLimitMinor: 7_200_000,
  deferralLimitMinor: 2_450_000,
  iraLimitMinor: 750_000,
  hsaSelfOnlyLimitMinor: 440_000,
  hsaFamilyLimitMinor: 875_000,
  qbiMinimumDeductionMinor: 40_000,
  qbiMinimumIncomeMinor: 100_000,
);
