import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_calendar.dart';
import 'package:openbudget_core/src/tax/gb/gb_capital_allowances.dart';
import 'package:openbudget_core/src/tax/gb/gb_categories.dart';
import 'package:openbudget_core/src/tax/gb/gb_corporation_tax.dart';
import 'package:openbudget_core/src/tax/gb/gb_income_tax.dart';
import 'package:openbudget_core/src/tax/gb/gb_payments_on_account.dart';
import 'package:openbudget_core/src/tax/gb/gb_profile.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// What the United Kingdom pack covers, and how mature it is.
///
/// The company return, indirect tax, capital gains and filing calendar are
/// partial: pools and writing-down allowances, VAT return boxes and schemes,
/// capital losses and share matching, and the full deadline calendar are not
/// modelled yet.
const TaxPackManifest gbTaxManifest = TaxPackManifest(
  maturity: TaxPackMaturity.preview,
  sections: {
    TaxSection.personalReturn: TaxSectionCoverage.full,
    TaxSection.selfEmployment: TaxSectionCoverage.full,
    TaxSection.companyReturn: TaxSectionCoverage.partial,
    TaxSection.indirectTax: TaxSectionCoverage.partial,
    TaxSection.capitalGains: TaxSectionCoverage.partial,
    TaxSection.digitalAssets: TaxSectionCoverage.notBuilt,
    TaxSection.filingCalendar: TaxSectionCoverage.partial,
    TaxSection.payroll: TaxSectionCoverage.notBuilt,
  },
);

/// The United Kingdom rule pack: HMRC Income Tax, National Insurance,
/// Capital Gains Tax, Corporation Tax and VAT.
///
/// The pack is pure. Every rate lives in [gbRatesByStartYear] with the
/// gov.uk pages it was checked against, so a report can be reproduced and
/// audited.
///
/// Rounding follows HMRC: taxable income is rounded down to whole pounds,
/// each band slice's tax is rounded down to the penny, and Corporation Tax
/// and National Insurance are computed on whole pounds of profit.
///
/// [TaxReport.uncategorizedCount] counts entries whose category is unknown
/// and entries whose category belongs to a different kind of books, because
/// neither can be applied to the report.
final class GbTaxRules implements TaxRulePack {
  /// A const pack: the rules are the same for every caller.
  const GbTaxRules();

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.gb;

  @override
  List<TaxDeadline> deadlines(TaxYear period, TaxProfile profile) {
    requireTaxDeadlineInput(this, period, profile);
    return gbDeadlines(period, profile as GbTaxProfile);
  }

  @override
  TaxPackManifest get manifest => gbTaxManifest;

  @override
  Set<int> get supportedStartYears => gbRatesByStartYear.keys.toSet();

  @override
  TaxRuleSet ruleSet(int startYear) {
    final ruleSet = gbRuleSetsByStartYear[startYear];
    if (ruleSet == null) {
      throw UnsupportedTaxYearException(TaxJurisdiction.gb, startYear);
    }
    return ruleSet;
  }

  @override
  TaxProfile profileFromJson(Map<String, Object?> json) =>
      gbProfileFromJson(json);

  @override
  List<TaxProfileQuestion> profileQuestions(EntityKind kind) =>
      taxProfileQuestionsFor(kind, [
        ...commonTaxProfileQuestions,
        ...gbTaxProfileQuestions,
      ]);

  @override
  TaxYear taxYearFor(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final startsThisYear = !day.isBefore(DateTime.utc(day.year, 4, 6));
    return taxYear(startsThisYear ? day.year : day.year - 1);
  }

  @override
  TaxYear taxYear(int startYear) {
    if (!gbRatesByStartYear.containsKey(startYear)) {
      throw UnsupportedTaxYearException(TaxJurisdiction.gb, startYear);
    }
    final nextYear = startYear + 1;
    return TaxYear(
      jurisdiction: TaxJurisdiction.gb,
      startYear: startYear,
      start: DateTime.utc(startYear, 4, 6),
      end: DateTime.utc(nextYear, 4, 6),
      label: '$startYear/${(nextYear % 100).toString().padLeft(2, '0')}',
    );
  }

  @override
  List<TaxCategory> categoriesFor(EntityKind kind) => List.unmodifiable(
    gbCategories.where((category) => category.entityKinds.contains(kind)),
  );

  @override
  TaxCategory? category(String code) => gbCategoriesByCode[code];

  @override
  String? mapUniversalCategory(String universalCode, EntityKind kind) =>
      gbMapUniversalCategory(universalCode, kind);

  @override
  TaxReport report(TaxInput input) {
    final rates = _ratesFor(input);
    final profile = _profileFor(input);
    return switch (profile.entityKind) {
      EntityKind.individual => _individualReport(profile, input, rates),
      EntityKind.soleTrader => _soleTraderReport(profile, input, rates),
      EntityKind.company => _companyReport(profile, input, rates),
    };
  }

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) {
    final rates = _ratesFor(input);
    final profile = _profileFor(input);
    return switch (profile.entityKind) {
      EntityKind.individual => _individualOpportunities(
        profile,
        input,
        rates,
        report,
      ),
      EntityKind.soleTrader => _vatThresholdOpportunities(
        input,
        rates,
        _EntryTotals.of(input.entries, EntityKind.soleTrader),
        'gb.se.turnover',
        profile.salesTaxRegistered,
      ),
      EntityKind.company => _vatThresholdOpportunities(
        input,
        rates,
        _EntryTotals.of(input.entries, EntityKind.company),
        'gb.co.turnover',
        profile.salesTaxRegistered,
      ),
    };
  }

  // ── Reports ───────────────────────────────────────────────────────────

  TaxReport _individualReport(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final rules = ruleSet(input.year.startYear);
    final figures = _individualFigures(profile, input, rates);
    final totals = figures.totals;
    final taxPaid = totals['gb.ind.tax_paid'];
    final totalLiability = figures.totalTaxMinor;
    final balance = totalLiability - taxPaid;

    final lines = <TaxReportLine>[
      if (totals['gb.ind.employment'] != 0)
        _categoryLine(totals, 'gb.ind.employment'),
      if (totals['gb.ind.self_employment'] != 0)
        _categoryLine(totals, 'gb.ind.self_employment'),
      if (totals['gb.ind.property'] != 0)
        _categoryLine(totals, 'gb.ind.property'),
      if (totals['gb.ind.other_income'] != 0)
        _categoryLine(totals, 'gb.ind.other_income'),
      if (figures.linkedProfitMinor != 0)
        TaxReportLine(
          label: figures.linkedBusinesses == 1
              ? 'Profit from linked sole-trade business'
              : 'Profit from ${figures.linkedBusinesses} linked sole-trade '
                    'businesses',
          amountMinor: figures.linkedProfitMinor,
          // The trading allowance is deducted at box 73 and the taxable
          // profit it produces is box 76, which is the figure that flows to
          // the SA100 tax calculation. Without it the profit is box 64.
          reportReference: figures.linkedTradingAllowanceUsed
              ? 'SA103F box 76'
              : 'SA103F box 64',
        ),
      if (totals['gb.ind.savings'] != 0)
        _categoryLine(totals, 'gb.ind.savings'),
      if (totals['gb.ind.dividends'] != 0)
        _categoryLine(totals, 'gb.ind.dividends'),
      TaxReportLine(
        label: 'Total income',
        amountMinor: figures.tax.totalIncomeMinor,
      ),
      TaxReportLine(
        label: 'Personal allowance',
        amountMinor: figures.tax.personalAllowanceMinor,
        figureId: 'personalAllowance',
      ),
      TaxReportLine(
        label: 'Taxable income',
        amountMinor: figures.tax.taxableIncomeMinor,
      ),
      if (figures.tax.taxableNonSavingsMinor > 0)
        TaxReportLine(
          label: 'Income tax on non-savings income',
          amountMinor: figures.tax.nonSavingsTaxMinor,
        ),
      if (figures.tax.taxableSavingsMinor > 0)
        TaxReportLine(
          label: 'Income tax on savings income',
          amountMinor: figures.tax.savingsTaxMinor,
        ),
      if (figures.tax.taxableDividendsMinor > 0)
        TaxReportLine(
          label: 'Income tax on dividend income',
          amountMinor: figures.tax.dividendTaxMinor,
        ),
      if (figures.netGainsMinor > 0) ...[
        TaxReportLine(
          label: 'Chargeable gains',
          amountMinor: figures.netGainsMinor,
        ),
        TaxReportLine(
          label: 'Capital Gains Tax annual exempt amount',
          amountMinor: math.min(
            figures.netGainsMinor,
            rates.capitalGainsAnnualExemptAmountMinor,
          ),
          figureId: 'capitalGainsAnnualExemptAmount',
        ),
        TaxReportLine(
          label: 'Taxable gains',
          amountMinor: figures.taxableGainsMinor,
        ),
      ],
      if (figures.tradeProfitMinor > 0)
        TaxReportLine(
          label:
              figures.tradeProfitMinor >= rates.class2SmallProfitsThresholdMinor
              ? 'Class 2 National Insurance (treated as paid)'
              : 'Class 2 National Insurance (not payable)',
          amountMinor: 0,
        ),
      if (figures.class4TaxMinor > 0)
        TaxReportLine(
          label: 'Class 4 National Insurance',
          amountMinor: figures.class4TaxMinor,
        ),
      if (figures.undergraduateLoanMinor > 0)
        TaxReportLine(
          label:
              'Student loan repayments '
              '(${_studentLoanLabel(profile.studentLoanPlan!)})',
          amountMinor: figures.undergraduateLoanMinor,
        ),
      if (figures.postgraduateLoanMinor > 0)
        TaxReportLine(
          label: 'Student loan repayments (Postgraduate Loan)',
          amountMinor: figures.postgraduateLoanMinor,
        ),
      if (totals['gb.ind.pension_contributions'] != 0)
        _categoryLine(totals, 'gb.ind.pension_contributions'),
      if (totals['gb.ind.gift_aid'] != 0)
        _categoryLine(totals, 'gb.ind.gift_aid'),
      if (taxPaid != 0) _categoryLine(totals, 'gb.ind.tax_paid'),
      if (figures.paymentsOnAccount.required) ...[
        TaxReportLine(
          label:
              'First payment on account towards next year, due '
              '${_date(figures.paymentsOnAccount.firstDue)}',
          amountMinor: figures.paymentsOnAccount.instalmentMinor,
        ),
        TaxReportLine(
          label:
              'Second payment on account towards next year, due '
              '${_date(figures.paymentsOnAccount.secondDue)}',
          amountMinor: figures.paymentsOnAccount.instalmentMinor,
        ),
      ],
      TaxReportLine(
        label: balance >= 0 ? 'Balance due' : 'Refund due',
        amountMinor: balance.abs(),
      ),
    ];

    return TaxReport(
      year: input.year,
      entityKind: EntityKind.individual,
      lines: lines,
      liabilities: figures.liabilities,
      alreadyPaidMinor: taxPaid,
      assumptions: _individualAssumptions(
        profile: profile,
        figures: figures,
        rates: rates,
      ),
      sources: gbRateSources,
      rulesVerifiedOn: gbRulesVerifiedOn,
      rulesVersion: rules.versionFor(TaxJurisdiction.gb),
      maturity: manifest.maturity,
      coverage: manifest.sections,
      caveats: rules.caveatsTouching(
        sections: {
          TaxSection.personalReturn,
          if (totals['gb.ind.self_employment'] != 0 ||
              figures.linkedBusinesses > 0)
            TaxSection.selfEmployment,
          if (figures.netGainsMinor > 0) TaxSection.capitalGains,
        },
        keys: {
          // The student-loan working sheet runs whenever a plan or the
          // postgraduate loan is on the profile, even before any income.
          if (profile.studentLoanPlan != null || profile.postgraduateLoan)
            'studentLoans',
        },
      ),
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  TaxReport _soleTraderReport(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final rules = ruleSet(input.year.startYear);
    final figures = _soleTraderFigures(input.entries, rates);
    final totals = figures.totals;
    final taxPaid = totals['gb.se.tax_paid'];
    final vat = _vatSummary(input.entries);
    final vatRegistered = profile.salesTaxRegistered;
    final liabilities = <TaxLiability>[
      if (vatRegistered && vat.dueMinor != 0)
        TaxLiability(label: 'VAT', amountMinor: vat.dueMinor),
    ];
    final balance =
        liabilities.fold(0, (sum, liability) => sum + liability.amountMinor) -
        taxPaid;

    final lines = <TaxReportLine>[
      _categoryLine(totals, 'gb.se.turnover'),
      if (totals['gb.se.other_income'] != 0)
        _categoryLine(totals, 'gb.se.other_income'),
      for (final code in _soleTraderExpenseCodes)
        if (totals[code] != 0) _categoryLine(totals, code),
      if (figures.depreciationMinor != 0)
        TaxReportLine(
          label: 'Depreciation (disallowable, added back)',
          amountMinor: figures.depreciationMinor,
          code: 'gb.se.depreciation',
          reportReference: 'SA103F box 29',
          entryCount: totals.counts['gb.se.depreciation'] ?? 0,
        ),
      if (figures.tradingAllowanceUsed) ...[
        TaxReportLine(
          label: 'Allowable expenses recorded (not deducted)',
          amountMinor: figures.totalExpensesMinor,
        ),
        // The trading allowance is deducted at box 73, adjusted profit, and
        // the taxable profit it produces is box 76, which flows to the SA100.
        TaxReportLine(
          label: 'Trading income allowance',
          amountMinor: figures.tradingAllowanceMinor,
          reportReference: 'SA103F box 73',
        ),
      ] else
        TaxReportLine(
          label: 'Total allowable expenses',
          amountMinor: figures.totalExpensesMinor,
          reportReference: 'SA103F box 31',
        ),
      if (figures.netProfitMinor >= 0)
        TaxReportLine(
          label: 'Net profit',
          amountMinor: figures.netProfitMinor,
          reportReference: 'SA103F box 47',
        )
      else
        TaxReportLine(
          label: 'Net loss',
          amountMinor: -figures.netProfitMinor,
          reportReference: 'SA103F box 48',
        ),
      if (figures.capitalAllowancesMinor != 0)
        TaxReportLine(
          label: 'Annual Investment Allowance',
          amountMinor: figures.capitalAllowancesMinor,
          code: 'gb.se.capital_allowances',
          reportReference: 'SA103F box 49',
          entryCount: totals.counts['gb.se.capital_allowances'] ?? 0,
          figureId: 'annualInvestmentAllowance',
        ),
      if (figures.capitalAllowancesUnrelievedMinor > 0)
        TaxReportLine(
          label:
              'Capital expenditure above the Annual Investment Allowance cap '
              '(no writing-down allowance modelled yet)',
          amountMinor: figures.capitalAllowancesUnrelievedMinor,
        ),
      if (figures.taxableProfitMinor >= 0)
        TaxReportLine(
          label: 'Net business profit for tax purposes',
          amountMinor: figures.taxableProfitMinor,
          reportReference: figures.tradingAllowanceUsed
              ? 'SA103F box 76'
              : 'SA103F box 64',
        )
      else
        TaxReportLine(
          label: 'Net business loss for tax purposes',
          amountMinor: -figures.taxableProfitMinor,
          reportReference: 'SA103F box 65',
        ),
      if (vatRegistered && vat.hasEntries) ...[
        TaxReportLine(
          label: 'VAT charged on sales (output VAT)',
          amountMinor: vat.outputMinor,
        ),
        TaxReportLine(
          label: 'VAT paid on purchases (input VAT)',
          amountMinor: vat.inputMinor,
        ),
        TaxReportLine(
          label: vat.dueMinor >= 0 ? 'VAT due' : 'VAT repayable',
          amountMinor: vat.dueMinor.abs(),
        ),
      ],
      if (taxPaid != 0) _categoryLine(totals, 'gb.se.tax_paid'),
      if (liabilities.isNotEmpty)
        TaxReportLine(
          label: balance >= 0 ? 'Balance due' : 'Refund due',
          amountMinor: balance.abs(),
        ),
    ];

    return TaxReport(
      year: input.year,
      entityKind: EntityKind.soleTrader,
      lines: lines,
      liabilities: liabilities,
      alreadyPaidMinor: taxPaid,
      assumptions: _soleTraderAssumptions(profile, rates),
      sources: gbRateSources,
      rulesVerifiedOn: gbRulesVerifiedOn,
      rulesVersion: rules.versionFor(TaxJurisdiction.gb),
      maturity: manifest.maturity,
      coverage: manifest.sections,
      caveats: rules.caveatsTouching(
        sections: {
          TaxSection.selfEmployment,
          if (vatRegistered && vat.hasEntries) TaxSection.indirectTax,
        },
      ),
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  TaxReport _companyReport(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final rules = ruleSet(input.year.startYear);
    final figures = _companyFigures(input, rates);
    final totals = figures.totals;
    final taxPaid = totals['gb.co.tax_paid'];
    final vat = _vatSummary(input.entries);
    final vatRegistered = profile.salesTaxRegistered;
    final liabilities = <TaxLiability>[
      if (figures.chargeableMinor > 0)
        TaxLiability(
          label: 'Corporation Tax',
          amountMinor: figures.corporationTaxMinor,
        ),
      if (vatRegistered && vat.dueMinor != 0)
        TaxLiability(label: 'VAT', amountMinor: vat.dueMinor),
    ];
    final balance =
        liabilities.fold(0, (sum, liability) => sum + liability.amountMinor) -
        taxPaid;

    final lines = <TaxReportLine>[
      _categoryLine(totals, 'gb.co.turnover'),
      for (final code in _companyExpenseCodes)
        if (totals[code] != 0) _categoryLine(totals, code),
      if (figures.depreciationMinor != 0)
        TaxReportLine(
          label: 'Depreciation (disallowable, added back)',
          amountMinor: figures.depreciationMinor,
          code: 'gb.co.depreciation',
          entryCount: totals.counts['gb.co.depreciation'] ?? 0,
        ),
      if (figures.allowances.annualInvestmentAllowanceMinor != 0)
        TaxReportLine(
          label: 'Annual Investment Allowance',
          amountMinor: figures.allowances.annualInvestmentAllowanceMinor,
          code: 'gb.co.capital_allowances',
          reportReference: 'CT600 box 690',
          entryCount: totals.counts['gb.co.capital_allowances'] ?? 0,
          figureId: 'annualInvestmentAllowance',
        ),
      if (figures.allowances.unrelievedMinor > 0)
        TaxReportLine(
          label:
              'Capital expenditure with no allowance yet (pools and '
              'writing-down allowances are not modelled)',
          amountMinor: figures.allowances.unrelievedMinor,
        ),
      TaxReportLine(
        label: 'Trading profit',
        amountMinor: figures.tradingProfitMinor,
        reportReference: 'CT600 box 155',
      ),
      if (totals['gb.co.other_income'] != 0)
        _categoryLine(totals, 'gb.co.other_income'),
      if (totals['gb.co.interest_received'] != 0)
        _categoryLine(totals, 'gb.co.interest_received'),
      TaxReportLine(
        label: 'Total profits before deductions and reliefs',
        amountMinor: figures.totalProfitsMinor,
        reportReference: 'CT600 box 235',
      ),
      TaxReportLine(
        label: 'Profits chargeable to Corporation Tax',
        amountMinor: figures.chargeableMinor,
        reportReference: 'CT600 box 315',
      ),
      if (figures.chargeableMinor > 0) ...[
        TaxReportLine(
          label: figures.marginalReliefMinor > 0
              ? 'Corporation Tax at the main rate'
              : 'Corporation Tax at the small profits rate',
          amountMinor: figures.grossCorporationTaxMinor,
          reportReference: 'CT600 box 430',
        ),
        if (figures.marginalReliefMinor > 0)
          TaxReportLine(
            label: 'Marginal relief',
            amountMinor: figures.marginalReliefMinor,
            reportReference: 'CT600 box 435',
          ),
        TaxReportLine(
          label: 'Corporation Tax chargeable',
          amountMinor: figures.corporationTaxMinor,
          reportReference: 'CT600 box 440',
        ),
      ],
      if (vatRegistered && vat.hasEntries) ...[
        TaxReportLine(
          label: 'VAT charged on sales (output VAT)',
          amountMinor: vat.outputMinor,
        ),
        TaxReportLine(
          label: 'VAT paid on purchases (input VAT)',
          amountMinor: vat.inputMinor,
        ),
        TaxReportLine(
          label: vat.dueMinor >= 0 ? 'VAT due' : 'VAT repayable',
          amountMinor: vat.dueMinor.abs(),
        ),
      ],
      if (taxPaid != 0) _categoryLine(totals, 'gb.co.tax_paid'),
      if (liabilities.isNotEmpty)
        TaxReportLine(
          label: balance >= 0 ? 'Balance due' : 'Refund due',
          amountMinor: balance.abs(),
        ),
    ];

    return TaxReport(
      year: input.year,
      entityKind: EntityKind.company,
      lines: lines,
      liabilities: liabilities,
      alreadyPaidMinor: taxPaid,
      assumptions: _companyAssumptions(
        profile: profile,
        ap: figures.accountingPeriod,
        assessment: figures.assessment,
        allowances: figures.allowances,
      ),
      sources: gbRateSources,
      rulesVerifiedOn: gbRulesVerifiedOn,
      rulesVersion: rules.versionFor(TaxJurisdiction.gb),
      maturity: manifest.maturity,
      coverage: manifest.sections,
      caveats: rules.caveatsTouching(
        sections: {
          TaxSection.companyReturn,
          if (vatRegistered && vat.hasEntries) TaxSection.indirectTax,
        },
      ),
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  // ── Individual computation ────────────────────────────────────────────

  _IndividualFigures _individualFigures(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final totals = _EntryTotals.of(input.entries, EntityKind.individual);

    var linkedProfit = 0;
    var linkedBusinesses = 0;
    var linkedTradingAllowanceUsed = false;
    for (final linked in input.linked) {
      if (linked.profile.entityKind != EntityKind.soleTrader) {
        continue;
      }
      final linkedFigures = _soleTraderFigures(linked.entries, rates);
      linkedProfit += linkedFigures.taxableProfitMinor;
      linkedBusinesses++;
      linkedTradingAllowanceUsed |= linkedFigures.tradingAllowanceUsed;
    }

    final nonSavings =
        totals['gb.ind.employment'] +
        totals['gb.ind.self_employment'] +
        totals['gb.ind.property'] +
        totals['gb.ind.other_income'] +
        linkedProfit;
    final savings = totals['gb.ind.savings'];
    final dividends = totals['gb.ind.dividends'];

    final tax = computeGbIncomeTax(
      rates: rates,
      scottishTaxpayer: profile.scottishTaxpayer,
      nonSavingsMinor: nonSavings,
      savingsMinor: savings,
      dividendsMinor: dividends,
      // Gross amounts: the categories record the figure with basic-rate
      // relief included, which is what adjusted net income subtracts.
      pensionContributionsMinor: totals['gb.ind.pension_contributions'],
      giftAidMinor: totals['gb.ind.gift_aid'],
    );

    final proceeds = totals['gb.ind.capital_gains_proceeds'];
    final cost = totals['gb.ind.capital_gains_cost'];
    final netGains = (math.max(0, proceeds - cost) ~/ 100) * 100;
    final taxableGains = math.max(
      0,
      netGains - rates.capitalGainsAnnualExemptAmountMinor,
    );
    final remainingBasicBand = math.max(
      0,
      rates.basicRateLimitMinor - tax.taxableIncomeMinor,
    );
    final cgtSlices = applyTaxBands(taxableGains, <TaxBand>[
      TaxBand(
        label: 'Capital Gains Tax basic rate',
        rateBasisPoints: rates.capitalGainsBasicRateBasisPoints,
        ceilingMinor: remainingBasicBand,
      ),
      TaxBand(
        label: 'Capital Gains Tax higher rate',
        rateBasisPoints: rates.capitalGainsHigherRateBasisPoints,
      ),
    ]);
    final cgtTax = sumBandTax(cgtSlices);

    final tradeProfit = math.max(
      0,
      totals['gb.ind.self_employment'] + linkedProfit,
    );
    final class4Slices = _class4Slices(rates, tradeProfit);
    final class4Tax = sumBandTax(class4Slices);

    // Student loans: an undergraduate plan and a postgraduate loan can both
    // run at once, each on the SA110 working sheet's income base.
    final repaymentBase = _studentLoanRepaymentBase(
      rates,
      totals,
      linkedProfit,
    );
    final undergraduatePlan = profile.studentLoanPlan;
    final undergraduateLoan = undergraduatePlan == null
        ? 0
        : rates.studentLoans[undergraduatePlan]!.repaymentOn(repaymentBase);
    final postgraduateLoan = profile.postgraduateLoan
        ? rates.studentLoans[GbStudentLoanPlan.postgraduate]!.repaymentOn(
            repaymentBase,
          )
        : 0;

    final paymentsOnAccount = computeGbPaymentsOnAccount(
      rates: rates,
      startYear: input.year.startYear,
      // Payments on account cover Income Tax and Class 4 only; CGT,
      // student loan repayments and HICBC are settled with the balancing
      // payment. Tax recorded as paid stands in for tax collected at
      // source (PAYE and withholding).
      incomeTaxAndClass4Minor: tax.totalTaxMinor + class4Tax,
      taxCollectedAtSourceMinor: totals['gb.ind.tax_paid'],
    );

    final liabilities = <TaxLiability>[
      if (tax.taxableNonSavingsMinor > 0)
        TaxLiability(
          label: profile.scottishTaxpayer
              ? 'Income Tax on non-savings income (Scottish rates)'
              : 'Income Tax on non-savings income',
          amountMinor: tax.nonSavingsTaxMinor,
          bands: tax.nonSavingsSlices,
        ),
      if (tax.taxableSavingsMinor > 0)
        TaxLiability(
          label: 'Income Tax on savings income',
          amountMinor: tax.savingsTaxMinor,
          bands: tax.savingsSlices,
        ),
      if (tax.taxableDividendsMinor > 0)
        TaxLiability(
          label: 'Income Tax on dividend income',
          amountMinor: tax.dividendTaxMinor,
          bands: tax.dividendSlices,
        ),
      if (taxableGains > 0)
        TaxLiability(
          label: 'Capital Gains Tax',
          amountMinor: cgtTax,
          bands: cgtSlices,
        ),
      if (class4Tax > 0)
        TaxLiability(
          label: 'Class 4 National Insurance',
          amountMinor: class4Tax,
          bands: class4Slices,
        ),
      if (undergraduateLoan > 0)
        TaxLiability(
          label:
              'Student loan repayments '
              '(${_studentLoanLabel(undergraduatePlan!)})',
          amountMinor: undergraduateLoan,
        ),
      if (postgraduateLoan > 0)
        TaxLiability(
          label: 'Student loan repayments (Postgraduate Loan)',
          amountMinor: postgraduateLoan,
        ),
    ];

    return _IndividualFigures(
      totals: totals,
      linkedProfitMinor: linkedProfit,
      linkedBusinesses: linkedBusinesses,
      linkedTradingAllowanceUsed: linkedTradingAllowanceUsed,
      nonSavingsMinor: nonSavings,
      savingsMinor: savings,
      dividendsMinor: dividends,
      tax: tax,
      netGainsMinor: netGains,
      taxableGainsMinor: taxableGains,
      cgtTaxMinor: cgtTax,
      class4TaxMinor: class4Tax,
      undergraduateLoanMinor: undergraduateLoan,
      postgraduateLoanMinor: postgraduateLoan,
      paymentsOnAccount: paymentsOnAccount,
      tradeProfitMinor: tradeProfit,
      liabilities: liabilities,
      totalTaxMinor: liabilities.fold(
        0,
        (sum, liability) => sum + liability.amountMinor,
      ),
    );
  }

  List<TaxBandSlice> _class4Slices(GbTaxYearRates rates, int profitMinor) {
    final profit = (profitMinor ~/ 100) * 100;
    if (profit <= rates.class4LowerProfitsLimitMinor) {
      return const [];
    }
    final mainBase =
        math.min(profit, rates.class4UpperProfitsLimitMinor) -
        rates.class4LowerProfitsLimitMinor;
    return <TaxBandSlice>[
      if (mainBase > 0)
        TaxBandSlice(
          label: 'Class 4 main rate',
          baseMinor: mainBase,
          rateBasisPoints: rates.class4LowerRateBasisPoints,
          taxMinor: mainBase * rates.class4LowerRateBasisPoints ~/ 10000,
        ),
      if (profit > rates.class4UpperProfitsLimitMinor)
        TaxBandSlice(
          label: 'Class 4 additional rate',
          baseMinor: profit - rates.class4UpperProfitsLimitMinor,
          rateBasisPoints: rates.class4UpperRateBasisPoints,
          taxMinor:
              (profit - rates.class4UpperProfitsLimitMinor) *
              rates.class4UpperRateBasisPoints ~/
              10000,
        ),
    ];
  }

  /// The SA110 working sheet's student-loan repayment base: earned income
  /// (employment, self-employment including linked trades, property and
  /// other taxable income) plus savings and dividends only above the
  /// rule-data unearned threshold, less gross pension contributions. The
  /// unearned threshold follows the SA110 notes (K31 and K32, 2026); the
  /// uk-personal-tax skill flags its exact mechanics as needing
  /// confirmation.
  int _studentLoanRepaymentBase(
    GbTaxYearRates rates,
    _EntryTotals totals,
    int linkedProfitMinor,
  ) {
    final earned =
        totals['gb.ind.employment'] +
        totals['gb.ind.self_employment'] +
        totals['gb.ind.property'] +
        totals['gb.ind.other_income'] +
        linkedProfitMinor;
    final unearned = totals['gb.ind.savings'] + totals['gb.ind.dividends'];
    return math.max<int>(
      0,
      earned +
          math.max<int>(
            0,
            unearned - rates.studentLoanUnearnedIncomeThresholdMinor,
          ) -
          totals['gb.ind.pension_contributions'],
    );
  }

  // ── Sole trader computation ───────────────────────────────────────────

  _SoleTraderFigures _soleTraderFigures(
    List<TaxEntry> entries,
    GbTaxYearRates rates,
  ) {
    final totals = _EntryTotals.of(entries, EntityKind.soleTrader);
    final turnover = totals['gb.se.turnover'];
    final otherIncome = totals['gb.se.other_income'];
    final depreciation = totals['gb.se.depreciation'];
    // The Annual Investment Allowance is capped at the rule-data maximum,
    // which the tax year is assumed to cover in full. Cars never qualify,
    // and writing-down allowances for the excess are not modelled yet.
    final capitalAllowances = math.min(
      totals['gb.se.capital_allowances'],
      rates.annualInvestmentAllowanceCapMinor,
    );
    final capitalAllowancesUnrelieved =
        totals['gb.se.capital_allowances'] - capitalAllowances;
    final expenses = <String, int>{
      for (final code in _soleTraderExpenseCodes)
        if (totals[code] != 0) code: totals[code],
    };
    final totalExpenses = expenses.values.fold(
      0,
      (sum, amount) => sum + amount,
    );
    final grossIncome = turnover + otherIncome;

    var tradingAllowanceUsed = false;
    var deduction = totalExpenses;
    if (capitalAllowances == 0 &&
        totalExpenses < rates.tradingAllowanceMinor &&
        grossIncome > 0) {
      final allowance = math.min(rates.tradingAllowanceMinor, grossIncome);
      if (allowance > deduction) {
        tradingAllowanceUsed = true;
        deduction = allowance;
      }
    }

    final netProfit = grossIncome - deduction;
    final taxableProfit = tradingAllowanceUsed
        ? netProfit
        : netProfit - capitalAllowances;

    return _SoleTraderFigures(
      totals: totals,
      totalExpensesMinor: totalExpenses,
      depreciationMinor: depreciation,
      capitalAllowancesMinor: capitalAllowances,
      capitalAllowancesUnrelievedMinor: capitalAllowancesUnrelieved,
      tradingAllowanceUsed: tradingAllowanceUsed,
      tradingAllowanceMinor: tradingAllowanceUsed
          ? deduction
          : rates.tradingAllowanceMinor,
      netProfitMinor: netProfit,
      taxableProfitMinor: taxableProfit,
      uncategorizedCount: totals.uncategorizedCount,
    );
  }

  // ── Company computation ───────────────────────────────────────────────

  _CompanyFigures _companyFigures(TaxInput input, GbTaxYearRates rates) {
    final profile = input.profile as GbTaxProfile;
    final totals = _EntryTotals.of(input.entries, EntityKind.company);
    final turnover = totals['gb.co.turnover'];
    final otherIncome = totals['gb.co.other_income'];
    final interest = totals['gb.co.interest_received'];
    final depreciation = totals['gb.co.depreciation'];
    final accountingPeriod = gbAccountingPeriodFor(
      taxYear: input.year,
      endMonth: profile.accountingPeriodEndMonth,
      endDay: profile.accountingPeriodEndDay,
    );
    // The recorded figure is qualifying plant and machinery expenditure
    // claimed at 100%. It takes the AIA route, capped and pro-rated for the
    // accounting period; companies could fully expense new plant or take
    // the 50% special-rate first-year allowance instead, but the books do
    // not record the asset types. Cars never reach the AIA, and pools and
    // writing-down allowances are not modelled yet.
    final allowances = computeGbCapitalAllowances(
      rates: rates,
      aiaCapMinor:
          rates.annualInvestmentAllowanceCapMinor *
          gbAccountingPeriodMonths(accountingPeriod) ~/
          12,
      additions: GbCapitalAllowanceAdditions(
        otherQualifyingMinor: totals['gb.co.capital_allowances'],
      ),
      company: true,
    );
    final expenses = <String, int>{
      for (final code in _companyExpenseCodes)
        if (totals[code] != 0) code: totals[code],
    };
    final totalExpenses = expenses.values.fold(
      0,
      (sum, amount) => sum + amount,
    );

    final tradingProfit = turnover - totalExpenses - allowances.totalMinor;
    final totalProfits = tradingProfit + otherIncome + interest;
    final chargeable = math.max(0, totalProfits);
    final assessment = computeGbCorporationTax(
      ap: accountingPeriod,
      chargeableProfitsMinor: chargeable,
      associatedCompanies: profile.associatedCompanies,
    );

    return _CompanyFigures(
      totals: totals,
      depreciationMinor: depreciation,
      allowances: allowances,
      accountingPeriod: accountingPeriod,
      assessment: assessment,
      tradingProfitMinor: tradingProfit,
      totalProfitsMinor: totalProfits,
      chargeableMinor: chargeable,
      grossCorporationTaxMinor: assessment.grossTaxMinor,
      marginalReliefMinor: assessment.marginalReliefMinor,
      corporationTaxMinor: assessment.taxMinor,
      uncategorizedCount: totals.uncategorizedCount,
    );
  }

  // ── VAT ───────────────────────────────────────────────────────────────

  _VatSummary _vatSummary(List<TaxEntry> entries) {
    var output = 0;
    var input = 0;
    var hasEntries = false;
    for (final entry in entries) {
      final category = gbCategoriesByCode[entry.categoryCode];
      if (category == null) {
        continue;
      }
      switch (category.kind) {
        case TaxCategoryKind.income:
        case TaxCategoryKind.expense:
          // Business-use apportionment is an input-tax rule: VAT is owed on
          // the whole sale, but only the business share of input VAT is
          // reclaimable.
          if (category.kind == TaxCategoryKind.income) {
            if (entry.salesTaxMinor != 0) {
              hasEntries = true;
              output += entry.salesTaxMinor;
            }
          } else {
            final vat = entry.salesTaxMinor * entry.businessUsePercent ~/ 100;
            if (vat != 0) {
              hasEntries = true;
              input += vat;
            }
          }
        case TaxCategoryKind.salesTaxCollected:
          hasEntries = true;
          output += entry.salesTaxMinor > 0
              ? entry.salesTaxMinor
              : entry.amountMinor;
        case TaxCategoryKind.salesTaxPaid:
          hasEntries = true;
          input +=
              (entry.salesTaxMinor > 0
                  ? entry.salesTaxMinor
                  : entry.amountMinor) *
              entry.businessUsePercent ~/
              100;
        case TaxCategoryKind.disposalProceeds:
        case TaxCategoryKind.disposalCost:
        case TaxCategoryKind.relief:
        case TaxCategoryKind.taxPaid:
        case TaxCategoryKind.outOfScope:
          break;
      }
    }
    return _VatSummary(
      outputMinor: output,
      inputMinor: input,
      dueMinor: output - input,
      hasEntries: hasEntries,
    );
  }

  // ── Opportunities ─────────────────────────────────────────────────────

  List<TaxOpportunity> _individualOpportunities(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
    TaxReport report,
  ) {
    final figures = _individualFigures(profile, input, rates);
    final yearEnd = DateTime.utc(input.year.startYear + 1, 4, 5);
    final ruleYear = input.year.label;
    final opportunities = <TaxOpportunity>[
      TaxOpportunity(
        id: 'gb.pension_annual_allowance',
        title: 'Pension annual allowance',
        explanation:
            'You can pay up to ${_money(rates.pensionAnnualAllowanceMinor)} '
            'into private pensions this year and get tax relief at your '
            'marginal rate, capped at 100% of your earnings. Your provider adds '
            '20% at source and any higher-rate relief is claimed through Self '
            'Assessment.',
        source: Uri.parse(
          'https://www.gov.uk/tax-on-your-private-pension/annual-allowance',
        ),
        ruleYear: ruleYear,
        deadline: yearEnd,
        assumptions: const [
          'Relief is capped at 100% of UK relevant earnings in the year.',
          'The £60,000 annual allowance assumes no unused allowance carried forward and no taper from adjusted net income above £260,000.',
          'The tax-free cash and the state pension are outside these figures.',
        ],
      ),
    ];

    final adjustedNetIncome = figures.tax.adjustedNetIncomeMinor;
    final taperEnd =
        rates.personalAllowanceIncomeLimitMinor +
        2 * rates.personalAllowanceMinor;
    if (adjustedNetIncome > rates.personalAllowanceIncomeLimitMinor &&
        adjustedNetIncome <= taperEnd) {
      final needed =
          adjustedNetIncome - rates.personalAllowanceIncomeLimitMinor;
      final marginal = _marginalRate(profile, rates, figures, _IncomeKind.top);
      // The provider has already added basic-rate relief at source, so a
      // gross contribution cuts the Self Assessment bill by the marginal
      // rate less that relief.
      final saving =
          math.max(
            0,
            marginal - rates.pensionReliefAtSourceBasicRateBasisPoints,
          ) *
          needed ~/
          10000;
      opportunities.add(
        TaxOpportunity(
          id: 'gb.pension_taper',
          title: 'Personal allowance taper and pension contributions',
          explanation:
              'Your adjusted net income of ${_money(adjustedNetIncome)} has '
              'reduced your personal allowance to '
              '${_money(figures.tax.personalAllowanceMinor)}. A gross pension '
              'contribution of ${_money(needed)} would bring it back to '
              '${_money(rates.personalAllowanceMinor)}. Your marginal rate is '
              'about ${_percent(marginal)}; after the 20% relief already added '
              'at source this is estimated to cut your Self Assessment bill by '
              '${_money(saving)}.',
          estimatedSavingMinor: saving,
          source: Uri.parse('https://www.gov.uk/income-tax-rates'),
          ruleYear: ruleYear,
          deadline: yearEnd,
          assumptions: const [
            'The contribution is a gross personal pension contribution paid before the tax year ends.',
            'The estimate uses your marginal rate on your top slice of income; Scottish rate taxpayers use Scottish rates.',
            'Income recorded outside OpenBudget would change the taper.',
          ],
        ),
      );
    }

    final savingsAndDividends = figures.savingsMinor + figures.dividendsMinor;
    if (savingsAndDividends > 0) {
      final sheltered = math.min(rates.isaAllowanceMinor, savingsAndDividends);
      final shelteredSavings = math.min(sheltered, figures.savingsMinor);
      final shelteredDividends = sheltered - shelteredSavings;
      final scenario = computeGbIncomeTax(
        rates: rates,
        scottishTaxpayer: profile.scottishTaxpayer,
        nonSavingsMinor: figures.nonSavingsMinor,
        savingsMinor: figures.savingsMinor - shelteredSavings,
        dividendsMinor: figures.dividendsMinor - shelteredDividends,
      );
      final saving = figures.tax.totalTaxMinor - scenario.totalTaxMinor;
      opportunities.add(
        TaxOpportunity(
          id: 'gb.isa_allowance',
          title: 'ISA allowance for savings and dividends',
          explanation:
              'You can put ${_money(rates.isaAllowanceMinor)} into ISAs each '
              'year, and interest and dividends inside them are tax free. '
              'Sheltering the ${_money(sheltered)} of savings income and '
              'dividends in this report is estimated to '
              '${saving > 0 ? 'save ${_money(saving)}' : 'save nothing at your current rates, but it protects future growth'}.',
          estimatedSavingMinor: saving > 0 ? saving : null,
          source: Uri.parse('https://www.gov.uk/individual-savings-accounts'),
          ruleYear: ruleYear,
          deadline: yearEnd,
          assumptions: const [
            'The estimate compares today\u2019s tax with the same income sheltered in an ISA; it does not predict future interest or dividend rates.',
            'The ISA subscription limit is per tax year and cannot be carried forward.',
            'Which ISA product to use is a choice this guidance does not make.',
          ],
        ),
      );
    }

    var allowanceBase = 0;
    for (final linked in input.linked) {
      if (linked.profile.entityKind != EntityKind.soleTrader) {
        continue;
      }
      final trade = _soleTraderFigures(linked.entries, rates);
      if (!trade.tradingAllowanceUsed) {
        continue;
      }
      final savingBase = trade.tradingAllowanceMinor - trade.totalExpensesMinor;
      if (savingBase > 0) {
        allowanceBase += savingBase;
      }
    }
    if (allowanceBase > 0) {
      final marginal = _marginalRate(
        profile,
        rates,
        figures,
        _IncomeKind.nonSavings,
      );
      final saving = allowanceBase * marginal ~/ 10000;
      if (saving > 0) {
        opportunities.add(
          TaxOpportunity(
            id: 'gb.trading_allowance',
            title: 'Trading allowance compared with recorded expenses',
            explanation:
                'The ${_money(rates.tradingAllowanceMinor)} trading allowance '
                'replaces actual expenses for a trade. Your recorded expenses '
                'are lower, so the allowance is used and is estimated to save '
                '${_money(saving)}. It cannot be used with capital '
                'allowances.',
            estimatedSavingMinor: saving,
            source: Uri.parse(
              'https://www.gov.uk/guidance/tax-free-allowances-on-property-'
              'and-trading-income',
            ),
            ruleYear: ruleYear,
            deadline: yearEnd,
            assumptions: const [
              'The trade\u2019s allowable expenses are the ones recorded in OpenBudget; unrecorded costs would change the comparison.',
              'The allowance cannot be claimed in a year the trade claims capital allowances.',
            ],
          ),
        );
      }
    }

    if (figures.netGainsMinor > 0 &&
        figures.netGainsMinor < rates.capitalGainsAnnualExemptAmountMinor) {
      final unused =
          rates.capitalGainsAnnualExemptAmountMinor - figures.netGainsMinor;
      final rate =
          figures.tax.taxableIncomeMinor + figures.netGainsMinor <=
              rates.basicRateLimitMinor
          ? rates.capitalGainsBasicRateBasisPoints
          : rates.capitalGainsHigherRateBasisPoints;
      final saving = unused * rate ~/ 10000;
      opportunities.add(
        TaxOpportunity(
          id: 'gb.capital_gains_annual_exempt_amount',
          title: 'Capital Gains Tax annual exempt amount',
          explanation:
              'You have ${_money(unused)} of the '
              '${_money(rates.capitalGainsAnnualExemptAmountMinor)} annual '
              'exempt amount left. Gains up to that amount are tax free; at '
              '${_percent(rate)} they would otherwise cost ${_money(saving)}.',
          estimatedSavingMinor: saving,
          source: Uri.parse(
            'https://www.gov.uk/guidance/capital-gains-tax-rates-and-allowances',
          ),
          ruleYear: ruleYear,
          deadline: yearEnd,
          assumptions: const [
            'The estimate values unused exempt amount at the rate your gains would otherwise bear this year.',
            'Unused exempt amount cannot be carried to a later year.',
            'Disposals and costs are limited to the entries recorded in OpenBudget.',
          ],
        ),
      );
    }

    final directorSplit = _directorSplitOpportunity(
      profile,
      input,
      rates,
      figures,
    );
    if (directorSplit != null) {
      opportunities.add(directorSplit);
    }

    final balance = report.balanceDueMinor;
    final paymentsOnAccount = figures.paymentsOnAccount;
    final instalmentText = paymentsOnAccount.required
        ? 'HMRC also expects two payments on account towards next year: '
              '${_money(paymentsOnAccount.instalmentMinor)} by '
              '${_date(paymentsOnAccount.firstDue)} and the same again by '
              '${_date(paymentsOnAccount.secondDue)}. They are '
              '${rates.paymentsOnAccountInstalmentSharePercent}% of this '
              'year’s Income Tax and Class 4 National Insurance of '
              '${_money(paymentsOnAccount.baseMinor)} less tax collected at '
              'source, and do not cover Capital Gains Tax, student loan '
              'repayments or the High Income Child Benefit Charge.'
        : 'No payments on account are due towards next year: the statutory '
              'rule skips them when the year’s Income Tax and Class 4, less '
              'tax collected at source, is under '
              '${_money(rates.paymentsOnAccountMinimumMinor)} or more than '
              '${rates.paymentsOnAccountCollectedSharePercent}% of it was '
              'collected at source.';
    final deadlineMessage = balance < 0
        ? 'Your entries show a refund of ${_money(balance.abs())} before any '
              'payments on account. The return and any payment must reach HMRC '
              'by 31 January following the tax year.'
        : 'Your balance due is ${_money(balance)}. HMRC will normally ask for '
              'it by 31 January. $instalmentText';
    opportunities.add(
      TaxOpportunity(
        id: 'gb.self_assessment_deadline',
        title: 'Self Assessment payment deadline',
        explanation: deadlineMessage,
        source: Uri.parse(
          'https://www.gov.uk/understand-self-assessment-bill/payments-on-account',
        ),
        ruleYear: ruleYear,
        deadline: DateTime.utc(input.year.startYear + 1, 1, 31),
        assumptions: const [
          'The balance and instalments follow the entries recorded in OpenBudget only.',
          'Payments on account already made for this year cannot be separated from tax recorded as paid.',
        ],
      ),
    );

    return opportunities;
  }

  List<TaxOpportunity> _vatThresholdOpportunities(
    TaxInput input,
    GbTaxYearRates rates,
    _EntryTotals totals,
    String turnoverCode,
    bool salesTaxRegistered,
  ) {
    if (salesTaxRegistered) {
      return const [];
    }
    final turnover = totals[turnoverCode];
    if (turnover < rates.vatRegistrationThresholdMinor * 3 ~/ 4) {
      return const [];
    }
    final headroom = math.max(
      0,
      rates.vatRegistrationThresholdMinor - turnover,
    );
    return <TaxOpportunity>[
      TaxOpportunity(
        id: 'gb.vat_registration_threshold',
        title: 'VAT registration threshold',
        explanation:
            'Your turnover is ${_money(turnover)}. VAT registration becomes '
            'due when taxable turnover for any rolling 12 months goes over '
            '${_money(rates.vatRegistrationThresholdMinor)}, or is expected '
            'to in the next 30 days. You have ${_money(headroom)} of headroom.',
        source: Uri.parse(
          'https://www.gov.uk/vat-registration/when-to-register',
        ),
        ruleYear: input.year.label,
        assumptions: const [
          'Turnover is the year\u2019s taxable turnover recorded in OpenBudget, not a rolling 12-month total.',
          'Registration may be due earlier under the 30-day expectation rule.',
        ],
      ),
    ];
  }

  TaxOpportunity? _directorSplitOpportunity(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
    _IndividualFigures figures,
  ) {
    for (final company in input.linked) {
      if (company.profile.entityKind != EntityKind.company) {
        continue;
      }
      final companyProfile = company.profile as GbTaxProfile;
      final companyFigures = _companyFigures(company, rates);
      final profit = companyFigures.totalProfitsMinor;
      if (profit <= 0) {
        continue;
      }
      final accountingPeriod = companyFigures.accountingPeriod;
      final associates = companyProfile.associatedCompanies;
      final wages = companyFigures.totals['gb.co.wages'];

      // s2(4A) NICA 2014: the Employment Allowance is not available to a
      // company whose only employee paid above the secondary threshold is a
      // sole director. The books record one wages total and the profit is
      // assumed to be before any pay, so wages at or above the threshold
      // are read as another employee paid above it; stated in the text
      // either way.
      final employmentAllowanceAvailable =
          wages >= rates.class1SecondaryThresholdMinor;

      GbCorporationTaxAssessment assess(int profitMinor) =>
          computeGbCorporationTax(
            ap: accountingPeriod,
            chargeableProfitsMinor: profitMinor,
            associatedCompanies: associates,
          );

      int costWith(int salaryMinor) => _directorCost(
        profile: profile,
        rates: rates,
        figures: figures,
        profitMinor: profit,
        salaryMinor: salaryMinor,
        employmentAllowanceAvailable: employmentAllowanceAvailable,
        assess: assess,
      );

      final dividendOnly = costWith(0);
      // Candidate salaries are the year's Class 1 thresholds from rule
      // data, never hard-coded "optimal" figures.
      final candidates = <int>{
        rates.class1LowerEarningsLimitMinor,
        rates.class1SecondaryThresholdMinor,
        rates.class1PrimaryThresholdMinor,
        rates.class1UpperEarningsLimitMinor,
        profit,
      }.where((salary) => salary <= profit).toList()..sort();
      var bestCost = dividendOnly;
      var bestSalary = 0;
      for (final salary in candidates) {
        final cost = costWith(salary);
        if (cost < bestCost) {
          bestCost = cost;
          bestSalary = salary;
        }
      }
      final saving = dividendOnly - bestCost;
      if (saving <= 0) {
        continue;
      }
      return TaxOpportunity(
        id: 'gb.director_salary_vs_dividend',
        title: 'Director salary compared with dividends',
        explanation:
            'Your company\u2019s profit before directors\u2019 pay and Corporation Tax '
            'is ${_money(profit)}. As guidance only, taking '
            '${_money(bestSalary)} as salary and the rest as dividends is '
            'estimated to cost ${_money(bestCost)} in Corporation Tax, '
            'employer and employee National Insurance and income tax, against '
            '${_money(dividendOnly)} for dividends only: a saving of '
            '${_money(saving)}. The salaries compared are the year\u2019s '
            'National Insurance thresholds. Employment Allowance is treated '
            'as ${employmentAllowanceAvailable ? 'available, because the books show wages above the secondary threshold beyond the director\u2019s pay' : 'unavailable, because a company whose sole director is the only employee paid above the secondary threshold cannot claim it'}. '
            'Assumes the profit is before any pay or dividend to the director '
            'and that all profit is distributed; if the books already include '
            'the director\u2019s pay, treat this as illustrative. This is a '
            'comparison to check, not a recommendation.',
        estimatedSavingMinor: saving,
        source: Uri.parse('https://www.gov.uk/tax-on-dividends'),
        ruleYear: input.year.label,
        deadline: DateTime.utc(input.year.startYear + 1, 4, 5),
        assumptions: const [
          'The company\u2019s profit is before any director\u2019s pay or dividend, and all profit is distributed.',
          'The salaries compared are the year\u2019s Class 1 National Insurance thresholds from rule data, not a recommended figure.',
          'Dividend legality, the director\u2019s other income and shareholdings are outside this comparison; an accountant can check the whole position.',
        ],
      );
    }
    return null;
  }

  int _directorCost({
    required GbTaxProfile profile,
    required GbTaxYearRates rates,
    required _IndividualFigures figures,
    required int profitMinor,
    required int salaryMinor,
    required bool employmentAllowanceAvailable,
    required GbCorporationTaxAssessment Function(int profitMinor) assess,
  }) {
    var employerNic =
        math.max<int>(
          0,
          salaryMinor - rates.class1SecondaryThresholdMinor,
        ) *
        rates.class1EmployerRateBasisPoints ~/
        10000;
    if (employmentAllowanceAvailable) {
      employerNic = math.max<int>(
        0,
        employerNic - rates.employmentAllowanceMinor,
      );
    }
    final companyProfit = profitMinor - salaryMinor - employerNic;
    final corporationTax = assess(math.max<int>(0, companyProfit)).taxMinor;
    final dividend = math.max(0, companyProfit - corporationTax);
    final tax = computeGbIncomeTax(
      rates: rates,
      scottishTaxpayer: profile.scottishTaxpayer,
      nonSavingsMinor: figures.nonSavingsMinor + salaryMinor,
      savingsMinor: figures.savingsMinor,
      dividendsMinor: figures.dividendsMinor + dividend,
    );
    final employeeNic = _class1EmployeeNic(rates, salaryMinor);
    return corporationTax + employerNic + tax.totalTaxMinor + employeeNic;
  }

  int _class1EmployeeNic(GbTaxYearRates rates, int salaryMinor) {
    final salary = (salaryMinor ~/ 100) * 100;
    final main =
        math.min(salary, rates.class1UpperEarningsLimitMinor) -
        rates.class1PrimaryThresholdMinor;
    final mainNic = main > 0
        ? main * rates.class1EmployeeRateBasisPoints ~/ 10000
        : 0;
    final upperNic = salary > rates.class1UpperEarningsLimitMinor
        ? (salary - rates.class1UpperEarningsLimitMinor) *
              rates.class1EmployeeUpperRateBasisPoints ~/
              10000
        : 0;
    return mainNic + upperNic;
  }

  int _marginalRate(
    GbTaxProfile profile,
    GbTaxYearRates rates,
    _IndividualFigures figures,
    _IncomeKind kind,
  ) {
    const bump = 10000;
    final resolved = kind == _IncomeKind.top
        ? figures.dividendsMinor > 0
              ? _IncomeKind.dividends
              : figures.savingsMinor > 0
              ? _IncomeKind.savings
              : _IncomeKind.nonSavings
        : kind;
    final bumped = computeGbIncomeTax(
      rates: rates,
      scottishTaxpayer: profile.scottishTaxpayer,
      nonSavingsMinor:
          figures.nonSavingsMinor +
          (resolved == _IncomeKind.nonSavings ? bump : 0),
      savingsMinor:
          figures.savingsMinor + (resolved == _IncomeKind.savings ? bump : 0),
      dividendsMinor:
          figures.dividendsMinor +
          (resolved == _IncomeKind.dividends ? bump : 0),
    );
    return (bumped.totalTaxMinor - figures.tax.totalTaxMinor) * 10000 ~/ bump;
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  GbTaxYearRates _ratesFor(TaxInput input) {
    if (input.year.jurisdiction != TaxJurisdiction.gb) {
      throw ArgumentError.value(
        input.year,
        'input.year',
        'is not a United Kingdom tax year',
      );
    }
    final rates = gbRatesByStartYear[input.year.startYear];
    if (rates == null) {
      throw UnsupportedTaxYearException(
        TaxJurisdiction.gb,
        input.year.startYear,
      );
    }
    return rates;
  }

  GbTaxProfile _profileFor(TaxInput input) {
    final profile = input.profile;
    if (profile is! GbTaxProfile) {
      throw ArgumentError.value(
        profile,
        'input.profile',
        'is not a United Kingdom tax profile',
      );
    }
    return profile;
  }

  TaxReportLine _categoryLine(_EntryTotals totals, String code) {
    final category = gbCategoriesByCode[code]!;
    return TaxReportLine(
      label: category.label,
      amountMinor: totals[code],
      code: code,
      reportReference: category.reportReference,
      entryCount: totals.counts[code] ?? 0,
    );
  }

  List<String> _individualAssumptions({
    required GbTaxProfile profile,
    required _IndividualFigures figures,
    required GbTaxYearRates rates,
  }) => <String>[
    'Income is limited to the entries recorded in OpenBudget; income held elsewhere is not included.',
    'The personal allowance is set against non-savings income first, then savings, then dividends.',
    'Taxable income is rounded down to whole pounds and each tax slice down to the penny, in your favour.',
    'The personal allowance tapers by £1 for each full £2 of adjusted net income above £100,000 and is nil from £125,140. Gross pension contributions and Gift Aid donations reduce adjusted net income.',
    'Property income is treated as non-savings income; the £1,000 property allowance and finance cost relief are not modelled.',
    if (profile.scottishTaxpayer)
      'Scottish rates apply to non-savings income. Savings and dividends are taxed at UK rates, as the Scottish rates do not apply to them.'
    else
      'England, Wales and Northern Ireland rates apply to non-savings income.',
    'The personal savings allowance and the starting rate for savings are decided using the UK basic rate limit.',
    'Only the standard personal allowance is claimed. Marriage Allowance, Blind Person’s Allowance and pension band extension are not modelled.',
    if (_hasReliefs(figures)) 'Pension contributions and Gift Aid donations are shown as recorded and reduce adjusted net income for the allowance taper; their band extension and scheme-specific relief are not modelled.',
    'Trading losses reduce other income but are not carried forward or set against capital gains.',
    'Class 2 National Insurance is not charged: profits above ${_money(rates.class2SmallProfitsThresholdMinor)} are treated as paid, and voluntary contributions are not modelled.',
    'Class 4 National Insurance is charged on the combined profit of all self-employments, rounded down to whole pounds.',
    'Student loan repayments follow the SA110 working sheet: earned income plus savings and dividends only above ${_money(rates.studentLoanUnearnedIncomeThresholdMinor)}, less gross pension contributions, each plan rounded down to whole pounds. An undergraduate plan and a postgraduate loan can run at the same time.',
    if (figures.netGainsMinor > 0) 'Capital Gains Tax covers only the disposals entered. Losses, reliefs and the 60-day property return are not modelled; the annual exempt amount is set against the gains.',
    if (figures.paymentsOnAccount.required)
      'Two payments on account towards next year are estimated at ${rates.paymentsOnAccountInstalmentSharePercent}% of this year’s Income Tax and Class 4 National Insurance (${_money(figures.paymentsOnAccount.baseMinor)} less tax recorded as paid): ${_money(figures.paymentsOnAccount.instalmentMinor)} each, due ${_date(figures.paymentsOnAccount.firstDue)} and ${_date(figures.paymentsOnAccount.secondDue)}. Tax recorded as paid is treated as collected at source; payments on account already made for this year cannot be separated from it.'
    else
      'No payments on account are due towards next year: the year’s Income Tax and Class 4, less tax recorded as paid, is under ${_money(rates.paymentsOnAccountMinimumMinor)} or more than ${rates.paymentsOnAccountCollectedSharePercent}% was collected at source.',
  ];

  bool _hasReliefs(_IndividualFigures figures) =>
      figures.totals['gb.ind.pension_contributions'] != 0 ||
      figures.totals['gb.ind.gift_aid'] != 0;

  List<String> _soleTraderAssumptions(
    GbTaxProfile profile,
    GbTaxYearRates rates,
  ) => <String>[
    'The figures are the taxable profit of the trade before the personal allowance; the owner’s individual report taxes them.',
    'Entries are treated as the business accounts. Cash basis and traditional accounting are not distinguished.',
    'Profits are computed in pence; the owner’s individual report rounds taxable income down to whole pounds.',
    'The £1,000 trading allowance is used automatically when it is larger than actual allowable expenses, unless capital allowances are claimed. It cannot be used with capital allowances.',
    'Only the Annual Investment Allowance is modelled, at 100% of the expenditure recorded and capped at ${_money(rates.annualInvestmentAllowanceCapMinor)}. Writing-down allowances, balancing charges and cars are not modelled.',
    'Depreciation is not deducted; it is shown as a disallowable expense and added back.',
    'Business use is applied through each entry’s business use percentage. Stock valuation, private use adjustments, losses carried forward and basis period reform are not modelled.',
    if (profile.salesTaxRegistered)
      'VAT is reported separately and excluded from turnover and expenses. Output VAT comes from sales entries’ sales tax and gb.vat.output; input VAT from purchase entries’ sales tax and gb.vat.input.'
    else
      'The books are not VAT registered, so no VAT summary is shown.',
  ];

  List<String> _companyAssumptions({
    required GbTaxProfile profile,
    required GbAccountingPeriod ap,
    required GbCorporationTaxAssessment assessment,
    required GbCapitalAllowances allowances,
  }) => <String>[
    'The accounting period runs ${_date(ap.start)} to ${_date(ap.end)}: Corporation Tax follows the company’s year end, not the 6 April tax year. The entries recorded in the tax year are assumed to be this period’s accounts.',
    if (profile.associatedCompanies > 0)
      '${profile.associatedCompanies} associated ${profile.associatedCompanies == 1 ? 'company divides' : 'companies divide'} the £50,000 and £250,000 limits by ${profile.associatedCompanies + 1}.'
    else
      'No associated companies: the £50,000 and £250,000 limits are not reduced.',
    'No exempt distributions from other companies, so augmented profits equal taxable total profits.',
    if (assessment.parts.length > 1)
      'The accounting period straddles 1 April, so profits are apportioned by day across the financial years it covers and each part is charged for its own financial year.'
    else if (assessment.parts.isNotEmpty)
      'The accounting period sits inside the financial year starting 1 April ${assessment.parts.single.financialYearStartYear}.',
    'Corporation Tax is 19% up to £50,000, 25% from £250,000, and the main rate less marginal relief in between, using the 3/200 standard fraction. The rates are held at 19% and 25% for the financial years starting 1 April 2025, 1 April 2026 and 1 April 2027, so parts falling in FY2027 use the same row; the FY2027 hold was confirmed when these figures were checked.',
    'Profits are rounded down to whole pounds and Corporation Tax down to the penny.',
    'No losses, group relief, qualifying donations, research and development relief or ring-fence profits are modelled.',
    'Depreciation is not deducted; it is shown as a disallowable expense and added back.',
    'The Annual Investment Allowance is capped at ${_money(allowances.aiaCapMinor)} for this period and never covers cars. Companies can fully expense new and unused main-rate plant and take a 50% first-year allowance on new and unused special-rate plant, but the recorded figure is claimed through the Annual Investment Allowance because the asset types are not recorded. Pools, writing-down allowances and balancing charges are not modelled yet, so any expenditure left unrelieved is shown as such.',
    'Employment Allowance is not modelled.',
    if (profile.salesTaxRegistered)
      'VAT is reported separately and excluded from turnover and expenses.'
    else
      'The company is not VAT registered, so no VAT summary is shown.',
  ];
}

// ── Private data ────────────────────────────────────────────────────────

/// SA103F boxes 17 to 30, in return order.
final List<String> _soleTraderExpenseCodes = gbCategories
    .where(
      (category) =>
          category.entityKinds.contains(EntityKind.soleTrader) &&
          category.kind == TaxCategoryKind.expense &&
          category.code != 'gb.se.depreciation' &&
          category.code != 'gb.se.capital_allowances',
    )
    .map((category) => category.code)
    .toList(growable: false);

/// Company expense categories, in computation order.
final List<String> _companyExpenseCodes = gbCategories
    .where(
      (category) =>
          category.entityKinds.contains(EntityKind.company) &&
          category.kind == TaxCategoryKind.expense &&
          category.code != 'gb.co.depreciation' &&
          category.code != 'gb.co.capital_allowances',
    )
    .map((category) => category.code)
    .toList(growable: false);

enum _IncomeKind { nonSavings, savings, dividends, top }

@immutable
final class _EntryTotals {
  const _EntryTotals(this.amounts, this.counts, this.uncategorizedCount);

  factory _EntryTotals.of(Iterable<TaxEntry> entries, EntityKind kind) {
    final amounts = <String, int>{};
    final counts = <String, int>{};
    var uncategorized = 0;
    for (final entry in entries) {
      final category = gbCategoriesByCode[entry.categoryCode];
      if (category == null || !category.entityKinds.contains(kind)) {
        uncategorized++;
        continue;
      }
      final amount = category.kind == TaxCategoryKind.taxPaid
          ? entry.amountMinor
          : entry.allowableMinor;
      amounts.update(
        entry.categoryCode,
        (sum) => sum + amount,
        ifAbsent: () => amount,
      );
      counts.update(
        entry.categoryCode,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    return _EntryTotals(amounts, counts, uncategorized);
  }

  final Map<String, int> amounts;
  final Map<String, int> counts;
  final int uncategorizedCount;

  int operator [](String code) => amounts[code] ?? 0;
}

@immutable
final class _IndividualFigures {
  const _IndividualFigures({
    required this.totals,
    required this.linkedProfitMinor,
    required this.linkedBusinesses,
    required this.linkedTradingAllowanceUsed,
    required this.nonSavingsMinor,
    required this.savingsMinor,
    required this.dividendsMinor,
    required this.tax,
    required this.netGainsMinor,
    required this.taxableGainsMinor,
    required this.cgtTaxMinor,
    required this.class4TaxMinor,
    required this.undergraduateLoanMinor,
    required this.postgraduateLoanMinor,
    required this.paymentsOnAccount,
    required this.tradeProfitMinor,
    required this.liabilities,
    required this.totalTaxMinor,
  });

  final _EntryTotals totals;
  final int linkedProfitMinor;
  final int linkedBusinesses;

  /// Whether any linked sole trade claimed the trading allowance, which
  /// moves its SA103F reference from box 64 to box 76.
  final bool linkedTradingAllowanceUsed;
  final int nonSavingsMinor;
  final int savingsMinor;
  final int dividendsMinor;
  final GbIncomeTaxComputation tax;
  final int netGainsMinor;
  final int taxableGainsMinor;
  final int cgtTaxMinor;
  final int class4TaxMinor;
  final int undergraduateLoanMinor;
  final int postgraduateLoanMinor;
  final GbPaymentsOnAccount paymentsOnAccount;
  final int tradeProfitMinor;
  final List<TaxLiability> liabilities;
  final int totalTaxMinor;

  int get uncategorizedCount => totals.uncategorizedCount;
}

@immutable
final class _SoleTraderFigures {
  const _SoleTraderFigures({
    required this.totals,
    required this.totalExpensesMinor,
    required this.depreciationMinor,
    required this.capitalAllowancesMinor,
    required this.capitalAllowancesUnrelievedMinor,
    required this.tradingAllowanceUsed,
    required this.tradingAllowanceMinor,
    required this.netProfitMinor,
    required this.taxableProfitMinor,
    required this.uncategorizedCount,
  });

  final _EntryTotals totals;
  final int totalExpensesMinor;
  final int depreciationMinor;
  final int capitalAllowancesMinor;
  final int capitalAllowancesUnrelievedMinor;
  final bool tradingAllowanceUsed;
  final int tradingAllowanceMinor;
  final int netProfitMinor;
  final int taxableProfitMinor;
  final int uncategorizedCount;
}

@immutable
final class _CompanyFigures {
  const _CompanyFigures({
    required this.totals,
    required this.depreciationMinor,
    required this.allowances,
    required this.accountingPeriod,
    required this.assessment,
    required this.tradingProfitMinor,
    required this.totalProfitsMinor,
    required this.chargeableMinor,
    required this.grossCorporationTaxMinor,
    required this.marginalReliefMinor,
    required this.corporationTaxMinor,
    required this.uncategorizedCount,
  });

  final _EntryTotals totals;
  final int depreciationMinor;
  final GbCapitalAllowances allowances;
  final GbAccountingPeriod accountingPeriod;
  final GbCorporationTaxAssessment assessment;
  final int tradingProfitMinor;
  final int totalProfitsMinor;
  final int chargeableMinor;
  final int grossCorporationTaxMinor;
  final int marginalReliefMinor;
  final int corporationTaxMinor;
  final int uncategorizedCount;
}

@immutable
final class _VatSummary {
  const _VatSummary({
    required this.outputMinor,
    required this.inputMinor,
    required this.dueMinor,
    required this.hasEntries,
  });

  final int outputMinor;
  final int inputMinor;
  final int dueMinor;
  final bool hasEntries;
}

// ── Formatting for opportunity text ─────────────────────────────────────

const List<String> _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// A date-only value as `31 March 2027`.
String _date(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

String _money(int amountMinor) {
  final negative = amountMinor < 0;
  final absolute = amountMinor.abs();
  final pounds = absolute ~/ 100;
  final pence = absolute % 100;
  final digits = pounds.toString();
  final buffer = StringBuffer();
  if (negative) {
    buffer.write('-');
  }
  buffer.write('£');
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[index]);
  }
  if (pence != 0) {
    buffer.write('.${pence.toString().padLeft(2, '0')}');
  }
  return buffer.toString();
}

String _percent(int basisPoints) {
  final whole = basisPoints ~/ 100;
  final fraction = basisPoints % 100;
  if (fraction == 0) {
    return '$whole%';
  }
  final digits = fraction
      .toString()
      .padLeft(2, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '$whole.$digits%';
}

String _studentLoanLabel(GbStudentLoanPlan plan) => switch (plan) {
  GbStudentLoanPlan.plan1 => 'Plan 1',
  GbStudentLoanPlan.plan2 => 'Plan 2',
  GbStudentLoanPlan.plan4 => 'Plan 4',
  GbStudentLoanPlan.plan5 => 'Plan 5',
  GbStudentLoanPlan.postgraduate => 'Postgraduate Loan',
};
