import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_categories.dart';
import 'package:openbudget_core/src/tax/gb/gb_income_tax.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

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
  Set<int> get supportedStartYears => gbRatesByStartYear.keys.toSet();

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
  List<TaxCategory> categoriesFor(TaxEntityKind kind) => List.unmodifiable(
    gbCategories.where((category) => category.entityKinds.contains(kind)),
  );

  @override
  TaxCategory? category(String code) => gbCategoriesByCode[code];

  @override
  TaxReport report(TaxInput input) {
    final rates = _ratesFor(input);
    final profile = _profileFor(input);
    return switch (profile.entityKind) {
      TaxEntityKind.individual => _individualReport(profile, input, rates),
      TaxEntityKind.soleTrader => _soleTraderReport(profile, input, rates),
      TaxEntityKind.company => _companyReport(profile, input, rates),
    };
  }

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) {
    final rates = _ratesFor(input);
    final profile = _profileFor(input);
    return switch (profile.entityKind) {
      TaxEntityKind.individual => _individualOpportunities(
        profile,
        input,
        rates,
        report,
      ),
      TaxEntityKind.soleTrader => _vatThresholdOpportunities(
        input,
        rates,
        _EntryTotals.of(input.entries, TaxEntityKind.soleTrader),
        'gb.se.turnover',
        profile.salesTaxRegistered,
      ),
      TaxEntityKind.company => _vatThresholdOpportunities(
        input,
        rates,
        _EntryTotals.of(input.entries, TaxEntityKind.company),
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
          reportReference: 'SA103F box 64',
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
      if (figures.studentLoanMinor > 0)
        TaxReportLine(
          label:
              'Student loan repayments '
              '(${_studentLoanLabel(profile.studentLoanPlan!)})',
          amountMinor: figures.studentLoanMinor,
        ),
      if (totals['gb.ind.pension_contributions'] != 0)
        _categoryLine(totals, 'gb.ind.pension_contributions'),
      if (totals['gb.ind.gift_aid'] != 0)
        _categoryLine(totals, 'gb.ind.gift_aid'),
      if (taxPaid != 0) _categoryLine(totals, 'gb.ind.tax_paid'),
      TaxReportLine(
        label: balance >= 0 ? 'Balance due' : 'Refund due',
        amountMinor: balance.abs(),
      ),
    ];

    return TaxReport(
      year: input.year,
      entityKind: TaxEntityKind.individual,
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
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  TaxReport _soleTraderReport(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
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
        TaxReportLine(
          label: 'Trading income allowance',
          amountMinor: figures.tradingAllowanceMinor,
          reportReference: 'SA103F box 16.1',
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
        ),
      if (figures.taxableProfitMinor >= 0)
        TaxReportLine(
          label: 'Net business profit for tax purposes',
          amountMinor: figures.taxableProfitMinor,
          reportReference: 'SA103F box 64',
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
      entityKind: TaxEntityKind.soleTrader,
      lines: lines,
      liabilities: liabilities,
      alreadyPaidMinor: taxPaid,
      assumptions: _soleTraderAssumptions(profile),
      sources: gbRateSources,
      rulesVerifiedOn: gbRulesVerifiedOn,
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  TaxReport _companyReport(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final figures = _companyFigures(input.entries, rates);
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
      if (figures.capitalAllowancesMinor != 0)
        TaxReportLine(
          label: 'Annual Investment Allowance',
          amountMinor: figures.capitalAllowancesMinor,
          code: 'gb.co.capital_allowances',
          entryCount: totals.counts['gb.co.capital_allowances'] ?? 0,
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
      entityKind: TaxEntityKind.company,
      lines: lines,
      liabilities: liabilities,
      alreadyPaidMinor: taxPaid,
      assumptions: _companyAssumptions(profile),
      sources: gbRateSources,
      rulesVerifiedOn: gbRulesVerifiedOn,
      uncategorizedCount: figures.uncategorizedCount,
    );
  }

  // ── Individual computation ────────────────────────────────────────────

  _IndividualFigures _individualFigures(
    GbTaxProfile profile,
    TaxInput input,
    GbTaxYearRates rates,
  ) {
    final totals = _EntryTotals.of(input.entries, TaxEntityKind.individual);

    var linkedProfit = 0;
    var linkedBusinesses = 0;
    for (final linked in input.linked) {
      if (linked.profile.entityKind != TaxEntityKind.soleTrader) {
        continue;
      }
      linkedProfit += _soleTraderFigures(
        linked.entries,
        rates,
      ).taxableProfitMinor;
      linkedBusinesses++;
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

    final plan = profile.studentLoanPlan;
    final studentLoan = plan == null
        ? 0
        : rates.studentLoans[plan]!.repaymentOn(
            (tax.totalIncomeMinor ~/ 100) * 100,
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
      if (studentLoan > 0)
        TaxLiability(
          label:
              'Student loan repayments '
              '(${_studentLoanLabel(plan!)})',
          amountMinor: studentLoan,
        ),
    ];

    return _IndividualFigures(
      totals: totals,
      linkedProfitMinor: linkedProfit,
      linkedBusinesses: linkedBusinesses,
      nonSavingsMinor: nonSavings,
      savingsMinor: savings,
      dividendsMinor: dividends,
      tax: tax,
      netGainsMinor: netGains,
      taxableGainsMinor: taxableGains,
      cgtTaxMinor: cgtTax,
      class4TaxMinor: class4Tax,
      studentLoanMinor: studentLoan,
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

  // ── Sole trader computation ───────────────────────────────────────────

  _SoleTraderFigures _soleTraderFigures(
    List<TaxEntry> entries,
    GbTaxYearRates rates,
  ) {
    final totals = _EntryTotals.of(entries, TaxEntityKind.soleTrader);
    final turnover = totals['gb.se.turnover'];
    final otherIncome = totals['gb.se.other_income'];
    final depreciation = totals['gb.se.depreciation'];
    final capitalAllowances = totals['gb.se.capital_allowances'];
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

  _CompanyFigures _companyFigures(
    List<TaxEntry> entries,
    GbTaxYearRates rates,
  ) {
    final totals = _EntryTotals.of(entries, TaxEntityKind.company);
    final turnover = totals['gb.co.turnover'];
    final otherIncome = totals['gb.co.other_income'];
    final interest = totals['gb.co.interest_received'];
    final depreciation = totals['gb.co.depreciation'];
    final capitalAllowances = totals['gb.co.capital_allowances'];
    final expenses = <String, int>{
      for (final code in _companyExpenseCodes)
        if (totals[code] != 0) code: totals[code],
    };
    final totalExpenses = expenses.values.fold(
      0,
      (sum, amount) => sum + amount,
    );

    final tradingProfit = turnover - totalExpenses - capitalAllowances;
    final totalProfits = tradingProfit + otherIncome + interest;
    final chargeable = math.max(0, totalProfits);
    final tax = _corporationTax(rates, chargeable);

    return _CompanyFigures(
      totals: totals,
      depreciationMinor: depreciation,
      capitalAllowancesMinor: capitalAllowances,
      tradingProfitMinor: tradingProfit,
      totalProfitsMinor: totalProfits,
      chargeableMinor: chargeable,
      grossCorporationTaxMinor: tax.gross,
      marginalReliefMinor: tax.relief,
      corporationTaxMinor: tax.tax,
      uncategorizedCount: totals.uncategorizedCount,
    );
  }

  ({int gross, int relief, int tax}) _corporationTax(
    GbTaxYearRates rates,
    int profitMinor,
  ) {
    final profit = (profitMinor ~/ 100) * 100;
    if (profit <= 0) {
      return (gross: 0, relief: 0, tax: 0);
    }
    if (profit <= rates.corporationTaxLowerLimitMinor) {
      final tax =
          profit * rates.corporationTaxSmallProfitsRateBasisPoints ~/ 10000;
      return (gross: tax, relief: 0, tax: tax);
    }
    final gross = profit * rates.corporationTaxMainRateBasisPoints ~/ 10000;
    if (profit >= rates.corporationTaxUpperLimitMinor) {
      return (gross: gross, relief: 0, tax: gross);
    }
    final relief =
        (rates.corporationTaxUpperLimitMinor - profit) *
        rates.corporationTaxMarginalReliefBasisPoints ~/
        10000;
    return (gross: gross, relief: relief, tax: math.max(0, gross - relief));
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
          final vat = entry.salesTaxMinor * entry.businessUsePercent ~/ 100;
          if (vat != 0) {
            hasEntries = true;
            if (category.kind == TaxCategoryKind.income) {
              output += vat;
            } else {
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
          input += entry.salesTaxMinor > 0
              ? entry.salesTaxMinor
              : entry.amountMinor;
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
    final opportunities = <TaxOpportunity>[
      TaxOpportunity(
        id: 'gb.pension_annual_allowance',
        title: 'Use your pension annual allowance',
        explanation:
            'You can pay up to ${_money(rates.pensionAnnualAllowanceMinor)} '
            'into private pensions this year and get tax relief at your '
            'marginal rate, capped at 100% of your earnings. Your provider adds '
            '20% at source and any higher-rate relief is claimed through Self '
            'Assessment.',
        source: Uri.parse(
          'https://www.gov.uk/tax-on-your-private-pension/annual-allowance',
        ),
        deadline: yearEnd,
      ),
    ];

    final totalIncome = figures.tax.totalIncomeMinor;
    final taperEnd =
        rates.personalAllowanceIncomeLimitMinor +
        2 * rates.personalAllowanceMinor;
    if (totalIncome > rates.personalAllowanceIncomeLimitMinor &&
        totalIncome <= taperEnd) {
      final needed = totalIncome - rates.personalAllowanceIncomeLimitMinor;
      final marginal = _marginalRate(profile, rates, figures, _IncomeKind.top);
      final saving = math.max(0, marginal - 2000) * needed ~/ 10000;
      opportunities.add(
        TaxOpportunity(
          id: 'gb.pension_taper',
          title: 'Restore your personal allowance',
          explanation:
              'Your income of ${_money(totalIncome)} has reduced your personal '
              'allowance to ${_money(figures.tax.personalAllowanceMinor)}. A '
              'gross pension contribution of ${_money(needed)} would bring it '
              'back to ${_money(rates.personalAllowanceMinor)}. Your marginal '
              'rate is about ${_percent(marginal)}; after the 20% relief already '
              'added at source this is estimated to cut your Self Assessment '
              'bill by ${_money(saving)}.',
          estimatedSavingMinor: saving,
          source: Uri.parse('https://www.gov.uk/income-tax-rates'),
          deadline: yearEnd,
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
          title: 'Shelter savings and dividends in an ISA',
          explanation:
              'You can put ${_money(rates.isaAllowanceMinor)} into ISAs each '
              'year, and interest and dividends inside them are tax free. '
              'Sheltering the ${_money(sheltered)} of savings income and '
              'dividends in this report is estimated to '
              '${saving > 0 ? 'save ${_money(saving)}' : 'save nothing at your current rates, but it protects future growth'}.',
          estimatedSavingMinor: saving > 0 ? saving : null,
          source: Uri.parse('https://www.gov.uk/individual-savings-accounts'),
          deadline: yearEnd,
        ),
      );
    }

    var allowanceBase = 0;
    for (final linked in input.linked) {
      if (linked.profile.entityKind != TaxEntityKind.soleTrader) {
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
            title: 'Trading allowance beats your expenses',
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
            deadline: yearEnd,
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
          title: 'Use your Capital Gains Tax annual exempt amount',
          explanation:
              'You have ${_money(unused)} of the '
              '${_money(rates.capitalGainsAnnualExemptAmountMinor)} annual '
              'exempt amount left. Gains up to that amount are tax free; at '
              '${_percent(rate)} they would otherwise cost ${_money(saving)}.',
          estimatedSavingMinor: saving,
          source: Uri.parse(
            'https://www.gov.uk/guidance/capital-gains-tax-rates-and-allowances',
          ),
          deadline: yearEnd,
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
    final paidShare = report.totalLiabilityMinor == 0
        ? 100
        : report.alreadyPaidMinor * 100 ~/ report.totalLiabilityMinor;
    final needsPaymentsOnAccount = balance > 100000 && paidShare < 80;
    final deadlineMessage = balance < 0
        ? 'Your entries show a refund of ${_money(balance.abs())} before any '
              'payments on account. The return and any payment must reach HMRC '
              'by 31 January following the tax year.'
        : needsPaymentsOnAccount
        ? 'Your balance due is ${_money(balance)}. HMRC will normally ask for '
              'it by 31 January, plus a first payment on account of '
              '${_money(balance ~/ 2)} towards next year, with a second payment '
              'of the same amount on 31 July. Payments on account are not '
              'required when the bill is under £1,000 or 80% was collected at '
              'source.'
        : 'Your Self Assessment return and any tax due must reach HMRC by '
              '31 January following the tax year. Your balance due is '
              '${_money(balance)}.';
    opportunities.add(
      TaxOpportunity(
        id: 'gb.self_assessment_deadline',
        title: 'Budget for the 31 January deadline',
        explanation: deadlineMessage,
        source: Uri.parse(
          'https://www.gov.uk/understand-self-assessment-bill/payments-on-account',
        ),
        deadline: DateTime.utc(input.year.startYear + 1, 1, 31),
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
        title: 'Watch the VAT registration threshold',
        explanation:
            'Your turnover is ${_money(turnover)}. You must register for VAT '
            'when taxable turnover for any rolling 12 months goes over '
            '${_money(rates.vatRegistrationThresholdMinor)}, or you expect it '
            'to in the next 30 days. You have ${_money(headroom)} of headroom.',
        source: Uri.parse(
          'https://www.gov.uk/vat-registration/when-to-register',
        ),
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
      if (company.profile.entityKind != TaxEntityKind.company) {
        continue;
      }
      final companyFigures = _companyFigures(company.entries, rates);
      final profit = companyFigures.totalProfitsMinor;
      if (profit <= 0) {
        continue;
      }

      int costWith(int salaryMinor) => _directorCost(
        profile: profile,
        rates: rates,
        figures: figures,
        profitMinor: profit,
        salaryMinor: salaryMinor,
      );

      final dividendOnly = costWith(0);
      var bestCost = dividendOnly;
      var bestSalary = 0;
      for (final salary in <int>[
        5000 * 100,
        12570 * 100,
        50270 * 100,
        profit,
      ]) {
        if (salary > profit) {
          continue;
        }
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
        title: 'Compare a director’s salary with dividends',
        explanation:
            'Your company’s profit before directors’ pay and Corporation Tax '
            'is ${_money(profit)}. Taking ${_money(bestSalary)} as salary and '
            'the rest as dividends is estimated to cost ${_money(bestCost)} in '
            'Corporation Tax, employer and employee National Insurance and '
            'income tax, against ${_money(dividendOnly)} for dividends only: a '
            'saving of ${_money(saving)}. Assumes the profit is before any pay '
            'or dividend to the director, no Employment Allowance, no '
            'associated companies and that all profit is distributed; if the '
            'books already include the director’s pay, treat this as '
            'illustrative.',
        estimatedSavingMinor: saving,
        source: Uri.parse('https://www.gov.uk/tax-on-dividends'),
        deadline: DateTime.utc(input.year.startYear + 1, 4, 5),
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
  }) {
    final employerNic =
        math.max(0, salaryMinor - rates.class1SecondaryThresholdMinor) *
        rates.class1EmployerRateBasisPoints ~/
        10000;
    final companyProfit = profitMinor - salaryMinor - employerNic;
    final corporationTax = _corporationTax(
      rates,
      math.max(0, companyProfit),
    ).tax;
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
    'The personal allowance tapers by £1 for each full £2 of income above £100,000 and is nil from £125,140.',
    'Property income is treated as non-savings income; the £1,000 property allowance and finance cost relief are not modelled.',
    if (profile.scottishTaxpayer)
      'Scottish rates apply to non-savings income. Savings and dividends are taxed at UK rates, as the Scottish rates do not apply to them.'
    else
      'England, Wales and Northern Ireland rates apply to non-savings income.',
    'The personal savings allowance and the starting rate for savings are decided using the UK basic rate limit.',
    'Only the standard personal allowance is claimed. Marriage Allowance, Blind Person’s Allowance, Gift Aid and other reliefs are not modelled.',
    if (_hasReliefs(figures)) 'Pension contributions and Gift Aid donations are reported but not deducted; their relief depends on the scheme and is not modelled.',
    'Trading losses reduce other income but are not carried forward or set against capital gains.',
    'Class 2 National Insurance is not charged: profits above ${_money(rates.class2SmallProfitsThresholdMinor)} are treated as paid, and voluntary contributions are not modelled.',
    'Class 4 National Insurance is charged on the combined profit of all self-employments, rounded down to whole pounds.',
    'Student loan repayments are based on total income before allowances.',
    if (figures.netGainsMinor > 0) 'Capital Gains Tax covers only the disposals entered. Losses, reliefs and the 60-day property return are not modelled; the annual exempt amount is set against the gains.',
    'No payments on account are included; tax already paid is what was recorded.',
  ];

  bool _hasReliefs(_IndividualFigures figures) =>
      figures.totals['gb.ind.pension_contributions'] != 0 ||
      figures.totals['gb.ind.gift_aid'] != 0;

  List<String> _soleTraderAssumptions(GbTaxProfile profile) => <String>[
    'The figures are the taxable profit of the trade before the personal allowance; the owner’s individual report taxes them.',
    'Entries are treated as the business accounts. Cash basis and traditional accounting are not distinguished.',
    'Profits are computed in pence; the owner’s individual report rounds taxable income down to whole pounds.',
    'The £1,000 trading allowance is used automatically when it is larger than actual allowable expenses, unless capital allowances are claimed. It cannot be used with capital allowances.',
    'Only the Annual Investment Allowance is modelled, at 100% of the expenditure recorded. Writing-down allowances, balancing charges and cars are not modelled.',
    'Depreciation is not deducted; it is shown as a disallowable expense and added back.',
    'Business use is applied through each entry’s business use percentage. Stock valuation, private use adjustments, losses carried forward and basis period reform are not modelled.',
    if (profile.salesTaxRegistered)
      'VAT is reported separately and excluded from turnover and expenses. Output VAT comes from sales entries’ sales tax and gb.vat.output; input VAT from purchase entries’ sales tax and gb.vat.input.'
    else
      'The books are not VAT registered, so no VAT summary is shown.',
  ];

  List<String> _companyAssumptions(GbTaxProfile profile) => <String>[
    'No associated companies: the £50,000 and £250,000 limits are not reduced.',
    'No exempt distributions from other companies, so augmented profits equal taxable total profits.',
    'The accounting period is taken to match the tax year supplied. The rates for the financial years starting 1 April 2025 and 1 April 2026 are identical, so no apportionment between financial years is needed. The five days of April 2027 fall in a financial year whose rates were not set when these figures were checked; the 2026 rates are applied.',
    'Corporation Tax is 19% up to £50,000, 25% from £250,000, and the main rate less marginal relief in between, using the 3/200 standard fraction.',
    'Profits are rounded down to whole pounds and Corporation Tax down to the penny.',
    'No losses, group relief, qualifying donations, research and development relief or ring-fence profits are modelled.',
    'Depreciation is not deducted; it is shown as a disallowable expense and added back. Only the Annual Investment Allowance is modelled.',
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
          category.entityKinds.contains(TaxEntityKind.soleTrader) &&
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
          category.entityKinds.contains(TaxEntityKind.company) &&
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

  factory _EntryTotals.of(Iterable<TaxEntry> entries, TaxEntityKind kind) {
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
    required this.nonSavingsMinor,
    required this.savingsMinor,
    required this.dividendsMinor,
    required this.tax,
    required this.netGainsMinor,
    required this.taxableGainsMinor,
    required this.cgtTaxMinor,
    required this.class4TaxMinor,
    required this.studentLoanMinor,
    required this.tradeProfitMinor,
    required this.liabilities,
    required this.totalTaxMinor,
  });

  final _EntryTotals totals;
  final int linkedProfitMinor;
  final int linkedBusinesses;
  final int nonSavingsMinor;
  final int savingsMinor;
  final int dividendsMinor;
  final GbIncomeTaxComputation tax;
  final int netGainsMinor;
  final int taxableGainsMinor;
  final int cgtTaxMinor;
  final int class4TaxMinor;
  final int studentLoanMinor;
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
    required this.capitalAllowancesMinor,
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
  final int capitalAllowancesMinor;
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
