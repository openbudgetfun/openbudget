import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// One pound in minor units, so the tables read in pounds.
const int _pound = 100;

/// A student loan plan's terms for one tax year.
@immutable
final class GbStudentLoanTerms {
  const GbStudentLoanTerms({
    required this.rateBasisPoints,
    this.thresholdMinor,
  });

  /// Income above which repayments start, or null when the plan has not
  /// begun collecting repayments in this year.
  final int? thresholdMinor;

  /// 900 is 9%.
  final int rateBasisPoints;

  /// The share of income above [thresholdMinor] repaid, rounded down to a
  /// whole pound. The SA110 summary reports the Student Loan and
  /// Postgraduate Loan due as whole pounds, rounded down (SA110 notes,
  /// 2026, page TCSN 49; see the uk-personal-tax skill).
  int repaymentOn(int incomeMinor) {
    final threshold = thresholdMinor;
    if (threshold == null || incomeMinor <= threshold) {
      return 0;
    }
    final repayment = (incomeMinor - threshold) * rateBasisPoints ~/ 10000;
    return repayment - repayment % _pound;
  }
}

/// The rates, thresholds and allowances of one United Kingdom tax year.
///
/// Every band ceiling is stated in the "income after allowances" space that
/// [applyTaxBands] uses, so the personal allowance is never counted twice.
@immutable
final class GbTaxYearRates {
  const GbTaxYearRates({
    required this.startYear,
    required this.label,
    required this.personalAllowanceMinor,
    required this.personalAllowanceIncomeLimitMinor,
    required this.rukBands,
    required this.scottishBands,
    required this.savingsBands,
    required this.dividendBands,
    required this.basicRateLimitMinor,
    required this.higherRateLimitMinor,
    required this.startingRateForSavingsMinor,
    required this.personalSavingsAllowanceBasicMinor,
    required this.personalSavingsAllowanceHigherMinor,
    required this.dividendAllowanceMinor,
    required this.capitalGainsAnnualExemptAmountMinor,
    required this.capitalGainsBasicRateBasisPoints,
    required this.capitalGainsHigherRateBasisPoints,
    required this.class2SmallProfitsThresholdMinor,
    required this.class2WeeklyRateMinor,
    required this.class4LowerProfitsLimitMinor,
    required this.class4UpperProfitsLimitMinor,
    required this.class4LowerRateBasisPoints,
    required this.class4UpperRateBasisPoints,
    required this.class1LowerEarningsLimitMinor,
    required this.class1PrimaryThresholdMinor,
    required this.class1SecondaryThresholdMinor,
    required this.class1UpperEarningsLimitMinor,
    required this.class1EmployeeRateBasisPoints,
    required this.class1EmployeeUpperRateBasisPoints,
    required this.class1EmployerRateBasisPoints,
    required this.employmentAllowanceMinor,
    required this.studentLoans,
    required this.tradingAllowanceMinor,
    required this.paymentsOnAccountMinimumMinor,
    required this.paymentsOnAccountCollectedSharePercent,
    required this.paymentsOnAccountInstalmentSharePercent,
    required this.studentLoanUnearnedIncomeThresholdMinor,
    required this.pensionReliefAtSourceBasicRateBasisPoints,
    required this.annualInvestmentAllowanceCapMinor,
    required this.fullExpensingRateBasisPoints,
    required this.specialRateFirstYearAllowanceBasisPoints,
    required this.corporationTaxSmallProfitsRateBasisPoints,
    required this.corporationTaxMainRateBasisPoints,
    required this.corporationTaxLowerLimitMinor,
    required this.corporationTaxUpperLimitMinor,
    required this.corporationTaxMarginalReliefBasisPoints,
    required this.vatRegistrationThresholdMinor,
    required this.vatStandardRateBasisPoints,
    required this.isaAllowanceMinor,
    required this.pensionAnnualAllowanceMinor,
  });

  /// The calendar year the tax year starts in.
  final int startYear;

  /// HMRC's label, such as `2026/27`.
  final String label;

  final int personalAllowanceMinor;

  /// Adjusted net income above which the personal allowance tapers.
  final int personalAllowanceIncomeLimitMinor;

  /// England, Wales and Northern Ireland income tax on non-savings income.
  final List<TaxBand> rukBands;

  /// Scottish income tax on non-savings income.
  final List<TaxBand> scottishBands;

  /// UK rates for savings income, applied on top of non-savings income.
  final List<TaxBand> savingsBands;

  /// UK dividend rates, applied on top of savings income.
  final List<TaxBand> dividendBands;

  /// The UK basic rate limit in after-allowance terms.
  final int basicRateLimitMinor;

  /// The UK higher rate limit in after-allowance terms.
  final int higherRateLimitMinor;

  /// The 0% starting rate for savings, before it is reduced by other income.
  final int startingRateForSavingsMinor;

  final int personalSavingsAllowanceBasicMinor;
  final int personalSavingsAllowanceHigherMinor;
  final int dividendAllowanceMinor;

  final int capitalGainsAnnualExemptAmountMinor;
  final int capitalGainsBasicRateBasisPoints;
  final int capitalGainsHigherRateBasisPoints;

  final int class2SmallProfitsThresholdMinor;
  final int class2WeeklyRateMinor;
  final int class4LowerProfitsLimitMinor;
  final int class4UpperProfitsLimitMinor;
  final int class4LowerRateBasisPoints;
  final int class4UpperRateBasisPoints;

  /// Class 1 thresholds are annual, as a company director is assessed.
  final int class1LowerEarningsLimitMinor;
  final int class1PrimaryThresholdMinor;
  final int class1SecondaryThresholdMinor;
  final int class1UpperEarningsLimitMinor;
  final int class1EmployeeRateBasisPoints;
  final int class1EmployeeUpperRateBasisPoints;
  final int class1EmployerRateBasisPoints;

  /// The annual Employment Allowance against employer Class 1 NIC. A company
  /// cannot claim it when all its secondary Class 1 earnings in the year go
  /// to one director who is the only employee paid above the secondary
  /// threshold (s2(4A) NICA 2014).
  final int employmentAllowanceMinor;

  final Map<GbStudentLoanPlan, GbStudentLoanTerms> studentLoans;

  /// The trading allowance, an alternative to deducting expenses.
  final int tradingAllowanceMinor;

  /// Payments on account are two instalments of
  /// [paymentsOnAccountInstalmentSharePercent] of the year's Income Tax plus
  /// Class 4 NIC, less tax collected at source. They are not needed when
  /// that amount is under [paymentsOnAccountMinimumMinor], or when more than
  /// [paymentsOnAccountCollectedSharePercent] percent of it was collected at
  /// source (SA110 working sheet A356 to A358).
  final int paymentsOnAccountMinimumMinor;
  final int paymentsOnAccountCollectedSharePercent;
  final int paymentsOnAccountInstalmentSharePercent;

  /// The SA110 student-loan working sheet counts unearned income only above
  /// this threshold (lines K31 and K32, SA110 notes 2026). The exact
  /// mechanics are flagged as needing confirmation in the uk-personal-tax
  /// skill.
  final int studentLoanUnearnedIncomeThresholdMinor;

  /// The basic-rate relief a pension provider adds at source. Used to state
  /// the net cost of a gross pension contribution in the taper opportunity.
  final int pensionReliefAtSourceBasicRateBasisPoints;

  /// The Annual Investment Allowance cap for one 12-month accounting or tax
  /// year, pro-rated for a shorter period.
  final int annualInvestmentAllowanceCapMinor;

  /// Companies may fully expense new and unused main-rate plant and
  /// machinery bought from 1 April 2023 (not cars). 10000 is 100%.
  final int fullExpensingRateBasisPoints;

  /// The first-year allowance for companies on new and unused special-rate
  /// plant, same conditions. 5000 is 50%; the remaining cost waits for the
  /// special-rate pool, which is not modelled yet.
  final int specialRateFirstYearAllowanceBasisPoints;

  final int corporationTaxSmallProfitsRateBasisPoints;
  final int corporationTaxMainRateBasisPoints;
  final int corporationTaxLowerLimitMinor;
  final int corporationTaxUpperLimitMinor;

  /// The marginal relief standard fraction, 3/200, as basis points.
  final int corporationTaxMarginalReliefBasisPoints;

  final int vatRegistrationThresholdMinor;
  final int vatStandardRateBasisPoints;

  final int isaAllowanceMinor;
  final int pensionAnnualAllowanceMinor;

  /// The personal allowance after the £100,000 taper.
  int personalAllowanceFor(int adjustedNetIncomeMinor) {
    if (adjustedNetIncomeMinor <= personalAllowanceIncomeLimitMinor) {
      return personalAllowanceMinor;
    }
    final excess = adjustedNetIncomeMinor - personalAllowanceIncomeLimitMinor;
    // One pound of allowance is lost for each full two pounds of income.
    final reduction = (excess ~/ (2 * _pound)) * _pound;
    final reduced = personalAllowanceMinor - reduction;
    return reduced > 0 ? reduced : 0;
  }
}

const _rates2025 = GbTaxYearRates(
  startYear: 2025,
  label: '2025/26',
  personalAllowanceMinor: 12570 * _pound,
  personalAllowanceIncomeLimitMinor: 100000 * _pound,
  rukBands: [
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4000,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Additional rate', rateBasisPoints: 4500),
  ],
  scottishBands: [
    TaxBand(
      label: 'Starter rate',
      rateBasisPoints: 1900,
      ceilingMinor: 2827 * _pound,
    ),
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 14921 * _pound,
    ),
    TaxBand(
      label: 'Intermediate rate',
      rateBasisPoints: 2100,
      ceilingMinor: 31092 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4200,
      ceilingMinor: 62430 * _pound,
    ),
    TaxBand(
      label: 'Advanced rate',
      rateBasisPoints: 4500,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Top rate', rateBasisPoints: 4800),
  ],
  savingsBands: [
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4000,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Additional rate', rateBasisPoints: 4500),
  ],
  dividendBands: [
    TaxBand(
      label: 'Dividend basic rate',
      rateBasisPoints: 875,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Dividend higher rate',
      rateBasisPoints: 3375,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Dividend additional rate', rateBasisPoints: 3935),
  ],
  basicRateLimitMinor: 37700 * _pound,
  higherRateLimitMinor: 125140 * _pound,
  startingRateForSavingsMinor: 5000 * _pound,
  personalSavingsAllowanceBasicMinor: 1000 * _pound,
  personalSavingsAllowanceHigherMinor: 500 * _pound,
  dividendAllowanceMinor: 500 * _pound,
  capitalGainsAnnualExemptAmountMinor: 3000 * _pound,
  capitalGainsBasicRateBasisPoints: 1800,
  capitalGainsHigherRateBasisPoints: 2400,
  class2SmallProfitsThresholdMinor: 6845 * _pound,
  class2WeeklyRateMinor: 350,
  class4LowerProfitsLimitMinor: 12570 * _pound,
  class4UpperProfitsLimitMinor: 50270 * _pound,
  class4LowerRateBasisPoints: 600,
  class4UpperRateBasisPoints: 200,
  class1LowerEarningsLimitMinor: 6500 * _pound,
  class1PrimaryThresholdMinor: 12570 * _pound,
  class1SecondaryThresholdMinor: 5000 * _pound,
  class1UpperEarningsLimitMinor: 50270 * _pound,
  class1EmployeeRateBasisPoints: 800,
  class1EmployeeUpperRateBasisPoints: 200,
  class1EmployerRateBasisPoints: 1500,
  employmentAllowanceMinor: 10500 * _pound,
  studentLoans: {
    GbStudentLoanPlan.plan1: GbStudentLoanTerms(
      thresholdMinor: 26065 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.plan2: GbStudentLoanTerms(
      thresholdMinor: 28470 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.plan4: GbStudentLoanTerms(
      thresholdMinor: 32745 * _pound,
      rateBasisPoints: 900,
    ),
    // Plan 5 loans first fell due for repayment in April 2026.
    GbStudentLoanPlan.plan5: GbStudentLoanTerms(rateBasisPoints: 900),
    GbStudentLoanPlan.postgraduate: GbStudentLoanTerms(
      thresholdMinor: 21000 * _pound,
      rateBasisPoints: 600,
    ),
  },
  tradingAllowanceMinor: 1000 * _pound,
  paymentsOnAccountMinimumMinor: 1000 * _pound,
  paymentsOnAccountCollectedSharePercent: 80,
  paymentsOnAccountInstalmentSharePercent: 50,
  studentLoanUnearnedIncomeThresholdMinor: 2000 * _pound,
  pensionReliefAtSourceBasicRateBasisPoints: 2000,
  annualInvestmentAllowanceCapMinor: 1000000 * _pound,
  fullExpensingRateBasisPoints: 10000,
  specialRateFirstYearAllowanceBasisPoints: 5000,
  corporationTaxSmallProfitsRateBasisPoints: 1900,
  corporationTaxMainRateBasisPoints: 2500,
  corporationTaxLowerLimitMinor: 50000 * _pound,
  corporationTaxUpperLimitMinor: 250000 * _pound,
  corporationTaxMarginalReliefBasisPoints: 150,
  vatRegistrationThresholdMinor: 90000 * _pound,
  vatStandardRateBasisPoints: 2000,
  isaAllowanceMinor: 20000 * _pound,
  pensionAnnualAllowanceMinor: 60000 * _pound,
);

const _rates2026 = GbTaxYearRates(
  startYear: 2026,
  label: '2026/27',
  personalAllowanceMinor: 12570 * _pound,
  personalAllowanceIncomeLimitMinor: 100000 * _pound,
  rukBands: [
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4000,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Additional rate', rateBasisPoints: 4500),
  ],
  scottishBands: [
    TaxBand(
      label: 'Starter rate',
      rateBasisPoints: 1900,
      ceilingMinor: 3967 * _pound,
    ),
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 16956 * _pound,
    ),
    TaxBand(
      label: 'Intermediate rate',
      rateBasisPoints: 2100,
      ceilingMinor: 31092 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4200,
      ceilingMinor: 62430 * _pound,
    ),
    TaxBand(
      label: 'Advanced rate',
      rateBasisPoints: 4500,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Top rate', rateBasisPoints: 4800),
  ],
  savingsBands: [
    TaxBand(
      label: 'Basic rate',
      rateBasisPoints: 2000,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Higher rate',
      rateBasisPoints: 4000,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Additional rate', rateBasisPoints: 4500),
  ],
  dividendBands: [
    TaxBand(
      label: 'Dividend basic rate',
      rateBasisPoints: 1075,
      ceilingMinor: 37700 * _pound,
    ),
    TaxBand(
      label: 'Dividend higher rate',
      rateBasisPoints: 3575,
      ceilingMinor: 125140 * _pound,
    ),
    TaxBand(label: 'Dividend additional rate', rateBasisPoints: 3935),
  ],
  basicRateLimitMinor: 37700 * _pound,
  higherRateLimitMinor: 125140 * _pound,
  startingRateForSavingsMinor: 5000 * _pound,
  personalSavingsAllowanceBasicMinor: 1000 * _pound,
  personalSavingsAllowanceHigherMinor: 500 * _pound,
  dividendAllowanceMinor: 500 * _pound,
  capitalGainsAnnualExemptAmountMinor: 3000 * _pound,
  capitalGainsBasicRateBasisPoints: 1800,
  capitalGainsHigherRateBasisPoints: 2400,
  class2SmallProfitsThresholdMinor: 7105 * _pound,
  class2WeeklyRateMinor: 365,
  class4LowerProfitsLimitMinor: 12570 * _pound,
  class4UpperProfitsLimitMinor: 50270 * _pound,
  class4LowerRateBasisPoints: 600,
  class4UpperRateBasisPoints: 200,
  class1LowerEarningsLimitMinor: 6708 * _pound,
  class1PrimaryThresholdMinor: 12570 * _pound,
  class1SecondaryThresholdMinor: 5000 * _pound,
  class1UpperEarningsLimitMinor: 50270 * _pound,
  class1EmployeeRateBasisPoints: 800,
  class1EmployeeUpperRateBasisPoints: 200,
  class1EmployerRateBasisPoints: 1500,
  employmentAllowanceMinor: 10500 * _pound,
  studentLoans: {
    GbStudentLoanPlan.plan1: GbStudentLoanTerms(
      thresholdMinor: 26900 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.plan2: GbStudentLoanTerms(
      thresholdMinor: 29385 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.plan4: GbStudentLoanTerms(
      thresholdMinor: 33795 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.plan5: GbStudentLoanTerms(
      thresholdMinor: 25000 * _pound,
      rateBasisPoints: 900,
    ),
    GbStudentLoanPlan.postgraduate: GbStudentLoanTerms(
      thresholdMinor: 21000 * _pound,
      rateBasisPoints: 600,
    ),
  },
  tradingAllowanceMinor: 1000 * _pound,
  paymentsOnAccountMinimumMinor: 1000 * _pound,
  paymentsOnAccountCollectedSharePercent: 80,
  paymentsOnAccountInstalmentSharePercent: 50,
  studentLoanUnearnedIncomeThresholdMinor: 2000 * _pound,
  pensionReliefAtSourceBasicRateBasisPoints: 2000,
  annualInvestmentAllowanceCapMinor: 1000000 * _pound,
  fullExpensingRateBasisPoints: 10000,
  specialRateFirstYearAllowanceBasisPoints: 5000,
  corporationTaxSmallProfitsRateBasisPoints: 1900,
  corporationTaxMainRateBasisPoints: 2500,
  corporationTaxLowerLimitMinor: 50000 * _pound,
  corporationTaxUpperLimitMinor: 250000 * _pound,
  corporationTaxMarginalReliefBasisPoints: 150,
  vatRegistrationThresholdMinor: 90000 * _pound,
  vatStandardRateBasisPoints: 2000,
  isaAllowanceMinor: 20000 * _pound,
  pensionAnnualAllowanceMinor: 60000 * _pound,
);

/// The UK rates this pack knows, by [TaxYear.startYear].
const Map<int, GbTaxYearRates> gbRatesByStartYear = {
  2025: _rates2025,
  2026: _rates2026,
};

/// The pages every figure in [gbRatesByStartYear] was checked against.
///
/// Fetched on [gbRulesVerifiedOn].
final List<Uri> gbRateSources = List.unmodifiable(<Uri>[
  Uri.parse('https://www.gov.uk/income-tax-rates'),
  Uri.parse(
    'https://www.gov.uk/government/publications/rates-and-allowances-income-tax/'
    'income-tax-rates-and-allowances-current-and-past',
  ),
  Uri.parse('https://www.gov.uk/scottish-income-tax'),
  Uri.parse('https://www.gov.uk/scottish-income-tax/2025-to-2026-tax-year'),
  Uri.parse('https://www.gov.uk/tax-on-dividends'),
  Uri.parse(
    'https://www.gov.uk/apply-tax-free-interest-on-savings/how-much-is-tax-free',
  ),
  Uri.parse(
    'https://www.gov.uk/guidance/capital-gains-tax-rates-and-allowances',
  ),
  Uri.parse(
    'https://www.gov.uk/government/publications/rates-and-allowances-national-'
    'insurance-contributions/rates-and-allowances-national-insurance-contributions',
  ),
  Uri.parse('https://www.gov.uk/self-employed-national-insurance-rates'),
  Uri.parse(
    'https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2025-to-2026',
  ),
  Uri.parse(
    'https://www.gov.uk/guidance/rates-and-thresholds-for-employers-2026-to-2027',
  ),
  Uri.parse('https://www.gov.uk/repaying-your-student-loan/what-you-pay'),
  Uri.parse('https://www.gov.uk/guidance/previous-annual-repayment-thresholds'),
  Uri.parse(
    'https://www.gov.uk/government/publications/student-loans-a-guide-to-terms-and-'
    'conditions/student-loans-a-guide-to-terms-and-conditions-2025-to-2026',
  ),
  Uri.parse(
    'https://www.gov.uk/guidance/tax-free-allowances-on-property-and-trading-income',
  ),
  Uri.parse('https://www.gov.uk/corporation-tax-rates'),
  Uri.parse('https://www.gov.uk/guidance/corporation-tax-marginal-relief'),
  Uri.parse(
    'https://www.gov.uk/government/publications/rates-and-allowances-corporation-tax/'
    'rates-and-allowances-corporation-tax',
  ),
  Uri.parse('https://www.gov.uk/guidance/the-company-tax-return-guide'),
  Uri.parse('https://www.gov.uk/vat-registration/when-to-register'),
  Uri.parse('https://www.gov.uk/vat-rates'),
  Uri.parse(
    'https://www.gov.uk/capital-allowances/annual-investment-allowance',
  ),
  Uri.parse('https://www.gov.uk/capital-allowances/full-expensing'),
  Uri.parse('https://www.gov.uk/capital-allowances/first-year-allowances'),
  Uri.parse(
    'https://www.gov.uk/government/publications/employment-allowance-more-'
    'detailed-guidance/single-director-companies-and-employment-allowance-'
    'further-employer-guidance',
  ),
  Uri.parse('https://www.gov.uk/tax-on-your-private-pension/annual-allowance'),
  Uri.parse(
    'https://www.gov.uk/tax-on-your-private-pension/pension-tax-relief',
  ),
  Uri.parse(
    'https://www.gov.uk/government/publications/rates-and-allowances-pension-schemes/'
    'pension-schemes-rates',
  ),
  Uri.parse('https://www.gov.uk/individual-savings-accounts'),
  Uri.parse(
    'https://www.gov.uk/guidance/manage-isa-subscriptions-for-your-investors',
  ),
  Uri.parse(
    'https://www.gov.uk/government/publications/changes-to-tax-rates-for-property-'
    'savings-dividend-income/changes-to-tax-rates-for-property-savings-dividend-income',
  ),
  Uri.parse(
    'https://www.gov.uk/understand-self-assessment-bill/payments-on-account',
  ),
  Uri.parse('https://www.gov.uk/self-assessment-tax-returns/deadlines'),
  Uri.parse(
    'https://www.gov.uk/government/publications/self-assessment-self-employment-full-sa103f',
  ),
]);

/// The day the figures in [gbRatesByStartYear] were last checked.
final DateTime gbRulesVerifiedOn = DateTime.utc(2026, 11, 4);

Uri _gbSource(String url) => Uri.parse(url);

/// The named figures knowledge cards quote for [rates]'s year, each with
/// the gov.uk page it came from. The values are the tables' own; naming
/// them adds no new number.
Map<String, TaxFigure> gbFiguresFor(GbTaxYearRates rates) => Map.unmodifiable({
  for (final figure in [
    TaxFigure(
      id: 'personalAllowance',
      value: rates.personalAllowanceMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/income-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'personalAllowanceTaperThreshold',
      value: rates.personalAllowanceIncomeLimitMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/income-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'basicRateLimit',
      value: rates.basicRateLimitMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/income-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'higherRateLimit',
      value: rates.higherRateLimitMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/income-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'additionalRate',
      value: rates.rukBands.last.rateBasisPoints,
      unit: TaxFigureUnit.rateBasisPoints,
      source: _gbSource('https://www.gov.uk/income-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'dividendAllowance',
      value: rates.dividendAllowanceMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/tax-on-dividends'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'capitalGainsAnnualExemptAmount',
      value: rates.capitalGainsAnnualExemptAmountMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource(
        'https://www.gov.uk/guidance/capital-gains-tax-rates-and-allowances',
      ),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'tradingAllowance',
      value: rates.tradingAllowanceMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource(
        'https://www.gov.uk/guidance/tax-free-allowances-on-property-and-'
        'trading-income',
      ),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'class2WeeklyRate',
      value: rates.class2WeeklyRateMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource(
        'https://www.gov.uk/self-employed-national-insurance-'
        'rates',
      ),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'vatRegistrationThreshold',
      value: rates.vatRegistrationThresholdMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/vat-registration/when-to-register'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'vatStandardRate',
      value: rates.vatStandardRateBasisPoints,
      unit: TaxFigureUnit.rateBasisPoints,
      source: _gbSource('https://www.gov.uk/vat-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'annualInvestmentAllowance',
      value: rates.annualInvestmentAllowanceCapMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource(
        'https://www.gov.uk/capital-allowances/annual-investment-allowance',
      ),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'corporationTaxMainRate',
      value: rates.corporationTaxMainRateBasisPoints,
      unit: TaxFigureUnit.rateBasisPoints,
      source: _gbSource('https://www.gov.uk/corporation-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'corporationTaxSmallProfitsRate',
      value: rates.corporationTaxSmallProfitsRateBasisPoints,
      unit: TaxFigureUnit.rateBasisPoints,
      source: _gbSource('https://www.gov.uk/corporation-tax-rates'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'isaAllowance',
      value: rates.isaAllowanceMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource('https://www.gov.uk/individual-savings-accounts'),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
    TaxFigure(
      id: 'pensionAnnualAllowance',
      value: rates.pensionAnnualAllowanceMinor,
      unit: TaxFigureUnit.currencyMinor,
      source: _gbSource(
        'https://www.gov.uk/tax-on-your-private-pension/annual-allowance',
      ),
      grade: TaxEvidenceGrade.primary,
      verifiedOn: gbRulesVerifiedOn,
    ),
  ])
    figure.id: figure,
});

/// What the uk-personal-tax, uk-company-tax and uk-vat-payroll skills could
/// not verify, as data (their "Unverified and changing" lists). Re-check
/// dates follow those lists.
final List<TaxRuleCaveat> gbRuleCaveats = [
  TaxRuleCaveat(
    id: 'gb.announced-2027-changes',
    text:
        'Savings and property rates of 24, 44 and 49 per cent from April '
        '2027, a 3,000 pound trading allowance, a 500,000 pound BADR limit '
        'and several 2027/28 allowances are announced but not yet law.',
    grade: TaxEvidenceGrade.primary,
    sections: const {TaxSection.personalReturn, TaxSection.selfEmployment},
    recheckBy: DateTime.utc(2027, 1, 30),
    announced: true,
  ),
  TaxRuleCaveat(
    id: 'gb.sa-forms-2025-26',
    text:
        'Return box numbers follow the 2025/26 Self Assessment forms; the '
        '2026/27 forms appear from April 2027 and may renumber them.',
    grade: TaxEvidenceGrade.primary,
    sections: const {
      TaxSection.personalReturn,
      TaxSection.selfEmployment,
      TaxSection.filingCalendar,
    },
    recheckBy: DateTime.utc(2027, 4, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.welsh-and-scottish-2027',
    text:
        'The Welsh rate table and the 2027/28 Scottish property and savings '
        'rates were not researched; the pack applies rUK rates outside '
        'Scotland.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2027, 1, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.student-loan-unearned-threshold',
    text:
        'The student-loan repayment base counts unearned income only above '
        'a threshold whose exact SA110 working-sheet mechanics need '
        'confirmation.',
    grade: TaxEvidenceGrade.inferred,
    keys: const {'studentLoans'},
    recheckBy: DateTime.utc(2027, 1, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.hmrc-rounding-inferences',
    text:
        'HMRC does not publish its per-slice rounding, the exact adjusted '
        'net income definition or the HICBC rounding convention, so the pack '
        'infers each from guidance.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.personalReturn},
    recheckBy: DateTime.utc(2027, 1, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.class4-annual-maximum',
    text:
        'The Class 4 maximum for people who also pay Class 1 National '
        'Insurance was not researched, so the pack does not cap Class 4.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.selfEmployment},
    recheckBy: DateTime.utc(2027, 1, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.mtd-and-penalties',
    text:
        'Making Tax Digital thresholds, the penalty regime for a non-MTD '
        'filer and the interest day-count basis were not confirmed, and the '
        '7.75 per cent late-payment interest rate is only dated to late '
        '2026.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {TaxSection.filingCalendar},
    recheckBy: DateTime.utc(2027, 1, 30),
  ),
  TaxRuleCaveat(
    id: 'gb.ct-announced-allowances',
    text:
        'Budget 2026 announced a 12 per cent writing-down allowance and a '
        '50 per cent special-rate first-year allowance; they are not law '
        'yet, and their interaction with the AIA is unstated.',
    grade: TaxEvidenceGrade.primary,
    sections: const {TaxSection.companyReturn},
    recheckBy: DateTime.utc(2026, 12),
    announced: true,
  ),
  TaxRuleCaveat(
    id: 'gb.ct-unmodelled-reliefs',
    text:
        'Pre-trading expenses, the full disallowable-expense list, loss '
        'relief beyond the restriction, group relief and the R&D PAYE cap '
        'step order were not sourced and are not modelled.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.companyReturn},
    recheckBy: DateTime.utc(2026, 12),
  ),
  TaxRuleCaveat(
    id: 'gb.ct600-boxes',
    text:
        'CT600 box references cover only the boxes the research read; '
        'boxes 170 and 205 that filings use were not in the research notes.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.companyReturn},
    recheckBy: DateTime.utc(2026, 12),
  ),
  TaxRuleCaveat(
    id: 'gb.ct-associates-and-distributions',
    text:
        'Whether dormant associates count in the associates divisor, the '
        'leap-year days denominator and exempt-distribution treatment are '
        'not confirmed.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.companyReturn},
    recheckBy: DateTime.utc(2026, 12),
  ),
  TaxRuleCaveat(
    id: 'gb.companies-house-deadlines',
    text:
        'The nine-month Companies House accounts deadline (21 months for '
        'first accounts) is user-stated, and the accounting reference date '
        'rules were not read.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.filingCalendar},
    recheckBy: DateTime.utc(2026, 12),
  ),
  TaxRuleCaveat(
    id: 'gb.vat-mechanics',
    text:
        'VAT registration timing, the partial exemption de minimis, fuel '
        'scale charges, bad debt relief timing, blocked VAT in box 7 and '
        'box 6 to 9 rounding follow Notices that were read only in part.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.indirectTax},
    recheckBy: DateTime.utc(2027, 4, 5),
  ),
  TaxRuleCaveat(
    id: 'gb.vat-rates-and-schemes',
    text:
        'The effective date of the 3 and 10 per cent VAT late-payment '
        'rates differs between GOV.UK and secondary summaries, and the '
        'flat-rate sector table stored in the research is only partial.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {TaxSection.indirectTax},
    recheckBy: DateTime.utc(2027, 4, 5),
  ),
  TaxRuleCaveat(
    id: 'gb.payroll-spec-gaps',
    text:
        'HMRC publishes no vectors for the 50 per cent regulatory limit, '
        'payrolled benefits, negative pay or week 53, and the per-band NIC '
        'truncation and half-down rounding were inferred from test data.',
    grade: TaxEvidenceGrade.inferred,
    sections: const {TaxSection.payroll},
    recheckBy: DateTime.utc(2027, 4, 5),
  ),
  TaxRuleCaveat(
    id: 'gb.payroll-admin',
    text:
        'RTI field-level rules, P45 handling, National Living Wage '
        'figures, the SMP recovery rate (sources differ between 108.5 and '
        '109 per cent), SSP criteria and auto-enrolment details were not '
        'sourced.',
    grade: TaxEvidenceGrade.secondary,
    sections: const {TaxSection.payroll},
    recheckBy: DateTime.utc(2027, 4, 5),
  ),
];

/// The version, sources, verification date, caveats and named figures of
/// each supported year.
final Map<int, TaxRuleSet> gbRuleSetsByStartYear = Map.unmodifiable({
  for (final entry in gbRatesByStartYear.entries)
    entry.key: TaxRuleSet(
      startYear: entry.key,
      revision: 1,
      verifiedOn: gbRulesVerifiedOn,
      sources: gbRateSources,
      caveats: gbRuleCaveats,
      figures: gbFiguresFor(entry.value),
    ),
});
