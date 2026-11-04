import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';
import 'package:openbudget_core/src/tax/us/us_tax_categories.dart';
import 'package:openbudget_core/src/tax/us/us_tax_tables.dart';

/// The United States federal tax rules.
///
/// The pack covers calendar years 2025 and 2026, using the figures in
/// Revenue Procedure 2024-40, Revenue Procedure 2025-32, and the One Big
/// Beautiful Bill Act amendments those procedures reflect. State and local
/// taxes, credits, and alternative minimum tax are outside its scope.
final class UsTaxRules implements TaxRulePack {
  const UsTaxRules();

  static final Map<String, TaxCategory> _categoriesByCode = {
    for (final category in allUsTaxCategories) category.code: category,
  };

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.us;

  @override
  Set<int> get supportedStartYears => const {2025, 2026};

  @override
  TaxYear taxYear(int startYear) => TaxYear(
    jurisdiction: TaxJurisdiction.us,
    startYear: startYear,
    start: DateTime.utc(startYear),
    end: DateTime.utc(startYear + 1),
    label: '$startYear',
  );

  @override
  TaxYear taxYearFor(DateTime date) => taxYear(date.year);

  @override
  List<TaxCategory> categoriesFor(TaxEntityKind kind) => switch (kind) {
    TaxEntityKind.individual => usIndividualCategories,
    TaxEntityKind.soleTrader => usScheduleCCategories,
    TaxEntityKind.company => usCompanyCategories,
  };

  @override
  TaxCategory? category(String code) => _categoriesByCode[code];

  @override
  TaxReport report(TaxInput input) {
    _requireUsInput(input);
    final table = _tableFor(input.year.startYear);
    return switch (input.profile.entityKind) {
      TaxEntityKind.individual => _individualReport(
        input,
        table,
        _filingStatus(input.profile),
      ),
      TaxEntityKind.soleTrader => _soleTraderReport(input),
      TaxEntityKind.company => _companyReport(input),
    };
  }

  @override
  List<TaxOpportunity> opportunities(TaxInput input, TaxReport report) {
    _requireUsInput(input);
    final table = _tableFor(input.year.startYear);
    return switch (input.profile.entityKind) {
      TaxEntityKind.individual => _individualOpportunities(
        input,
        report,
        table,
      ),
      TaxEntityKind.company => _companyOpportunities(report),
      TaxEntityKind.soleTrader => const [],
    };
  }

  UsTaxYearTable _tableFor(int startYear) => switch (startYear) {
    2025 => usTaxYear2025,
    2026 => usTaxYear2026,
    _ => throw UnsupportedTaxYearException(TaxJurisdiction.us, startYear),
  };

  void _requireUsInput(TaxInput input) {
    if (input.profile.jurisdiction != TaxJurisdiction.us) {
      throw ArgumentError.value(
        input.profile,
        'input.profile',
        'UsTaxRules only supports US profiles',
      );
    }
    if (input.year.jurisdiction != TaxJurisdiction.us) {
      throw ArgumentError.value(
        input.year,
        'input.year',
        'UsTaxRules only supports US tax years',
      );
    }
  }

  UsFilingStatus _filingStatus(TaxProfile profile) => switch (profile) {
    UsTaxProfile(:final filingStatus) => filingStatus,
    _ => throw ArgumentError.value(
      profile,
      'profile',
      'US individual rules need a UsTaxProfile',
    ),
  };

  _CategoryTotals _totalsFor(TaxInput input, TaxEntityKind kind) {
    final known = {for (final category in categoriesFor(kind)) category.code};
    final amounts = <String, int>{};
    final counts = <String, int>{};
    var uncategorized = 0;
    for (final entry in input.entries) {
      if (!input.year.contains(entry.date)) {
        continue;
      }
      if (!known.contains(entry.categoryCode)) {
        uncategorized++;
        continue;
      }
      final amount = _entryAmount(entry);
      amounts.update(
        entry.categoryCode,
        (sum) => sum + amount,
        ifAbsent: () => amount,
      );
      counts.update(entry.categoryCode, (sum) => sum + 1, ifAbsent: () => 1);
    }
    return _CategoryTotals(
      amounts: amounts,
      counts: counts,
      uncategorizedCount: uncategorized,
    );
  }

  int _entryAmount(TaxEntry entry) {
    final allowable = entry.allowableMinor;
    return switch (entry.categoryCode) {
      'us.sch_c.meals' => allowable * 50 ~/ 100,
      _ => allowable,
    };
  }

  _ScheduleCComputation _scheduleCComputation(TaxInput input) {
    final totals = _totalsFor(input, TaxEntityKind.soleTrader);
    final amounts = Map<String, int>.of(totals.amounts);
    final rawHomeOffice = amounts['us.sch_c.home_office'] ?? 0;
    final homeOffice = _min(rawHomeOffice, _homeOfficeCapMinor);
    if (homeOffice != rawHomeOffice) {
      amounts['us.sch_c.home_office'] = homeOffice;
    }
    final adjusted = _CategoryTotals(
      amounts: amounts,
      counts: totals.counts,
      uncategorizedCount: totals.uncategorizedCount,
    );
    final grossReceipts = adjusted['us.sch_c.gross_receipts'];
    final returns = adjusted['us.sch_c.returns_and_allowances'];
    final costOfGoodsSold = adjusted['us.sch_c.cost_of_goods_sold'];
    final grossProfit = grossReceipts - returns - costOfGoodsSold;
    final grossIncome = grossProfit + adjusted['us.sch_c.other_income'];
    final totalExpenses = usScheduleCCategories
        .where(
          (category) =>
              category.kind == TaxCategoryKind.expense &&
              category.code != 'us.sch_c.returns_and_allowances' &&
              category.code != 'us.sch_c.cost_of_goods_sold' &&
              category.code != 'us.sch_c.home_office',
        )
        .fold(0, (sum, category) => sum + adjusted[category.code]);
    final tentativeProfit = grossIncome - totalExpenses;
    final netProfit = tentativeProfit - homeOffice;
    return _ScheduleCComputation(
      totals: adjusted,
      grossProfit: grossProfit,
      grossIncome: grossIncome,
      totalExpenses: totalExpenses,
      tentativeProfit: tentativeProfit,
      netProfit: netProfit,
    );
  }

  _CompanyComputation _companyComputation(TaxInput input) {
    final totals = _totalsFor(input, TaxEntityKind.company);
    final grossReceipts = totals['us.co.gross_receipts'];
    final returns = totals['us.co.returns_and_allowances'];
    final costOfGoodsSold = totals['us.co.cost_of_goods_sold'];
    final grossProfit = grossReceipts - returns - costOfGoodsSold;
    final totalIncome =
        grossProfit +
        totals['us.co.dividends'] +
        totals['us.co.interest'] +
        totals['us.co.gross_rents'] +
        totals['us.co.gross_royalties'] +
        totals['us.co.capital_gain_net_income'] -
        totals['us.co.capital_loss'] +
        totals['us.co.net_gain'] -
        totals['us.co.net_loss'] +
        totals['us.co.other_income'];
    final totalDeductions = usCompanyCategories
        .where(
          (category) =>
              category.kind == TaxCategoryKind.expense &&
              category.code != 'us.co.returns_and_allowances' &&
              category.code != 'us.co.cost_of_goods_sold' &&
              category.code != 'us.co.capital_loss' &&
              category.code != 'us.co.net_loss',
        )
        .fold(0, (sum, category) => sum + totals[category.code]);
    final taxableIncome = totalIncome - totalDeductions;
    final tax = _max(0, taxableIncome) * _corporateRateBasisPoints ~/ 10000;
    return _CompanyComputation(
      totals: totals,
      grossProfit: grossProfit,
      totalIncome: totalIncome,
      totalDeductions: totalDeductions,
      taxableIncome: taxableIncome,
      tax: tax,
      alreadyPaid: totals['us.co.estimated_tax_payments'],
    );
  }

  _IndividualComputation _individualComputation(
    TaxInput input,
    UsTaxYearTable table,
  ) {
    final status = _filingStatus(input.profile);
    final totals = _totalsFor(input, TaxEntityKind.individual);
    var linkedBusinessProfit = 0;
    var linkedBusinessCount = 0;
    var linkedUncategorized = 0;
    for (final linked in input.linked) {
      if (linked.profile.entityKind != TaxEntityKind.soleTrader ||
          linked.profile.jurisdiction != TaxJurisdiction.us ||
          linked.year.startYear != input.year.startYear) {
        continue;
      }
      final business = _scheduleCComputation(linked);
      linkedBusinessProfit += business.netProfit;
      linkedBusinessCount++;
      linkedUncategorized += business.totals.uncategorizedCount;
    }

    final wages = totals['us.ind.wages'];
    final shortTermGains = totals['us.ind.short_term_capital_gains'];
    final longTermGains = totals['us.ind.long_term_capital_gains'];
    final capitalGainDistributions =
        totals['us.ind.capital_gain_distributions'];
    var remainingLoss = totals['us.ind.capital_losses'];
    final shortTermLossApplied = _min(shortTermGains, remainingLoss);
    remainingLoss -= shortTermLossApplied;
    final shortTermNet = shortTermGains - shortTermLossApplied;
    final longTermGross = longTermGains + capitalGainDistributions;
    final longTermLossApplied = _min(longTermGross, remainingLoss);
    remainingLoss -= longTermLossApplied;
    final longTermNet = longTermGross - longTermLossApplied;
    final capitalLossLimit = status == UsFilingStatus.marriedFilingSeparately
        ? _marriedSeparateCapitalLossLimitMinor
        : _capitalLossLimitMinor;
    final allowedCapitalLoss = _min(remainingLoss, capitalLossLimit);

    final ordinaryIncome =
        wages +
        totals['us.ind.taxable_interest'] +
        totals['us.ind.dividends'] +
        shortTermNet +
        totals['us.ind.other_income'] +
        linkedBusinessProfit -
        allowedCapitalLoss;
    final preferentialIncome =
        totals['us.ind.qualified_dividends'] + longTermNet;
    final totalIncome = ordinaryIncome + preferentialIncome;

    final seTax = _selfEmploymentTax(
      businessProfit: linkedBusinessProfit,
      wages: wages,
      table: table,
      status: status,
    );
    final hsaContribution = totals['us.ind.hsa_contribution'];
    final iraContribution = totals['us.ind.ira_contribution'];
    final selfEmployedRetirement = totals['us.ind.self_employed_retirement'];
    final adjustments =
        seTax.half + hsaContribution + iraContribution + selfEmployedRetirement;
    final adjustedGrossIncome = _max(0, totalIncome - adjustments);

    final standardDeduction = table.standardDeductionFor(status);
    final itemizedDeductions = totals['us.ind.itemized_deductions'];
    final usingItemized = itemizedDeductions > standardDeduction;
    final deduction = usingItemized ? itemizedDeductions : standardDeduction;
    final preQbiTaxable = _max(0, adjustedGrossIncome - deduction);

    final qbiBase = _max(
      0,
      linkedBusinessProfit - seTax.half - selfEmployedRetirement,
    );
    final qbiThreshold = table.qualifiedBusinessIncomeThresholdFor(status);
    var qbiDeduction = 0;
    if (qbiBase > 0 && preQbiTaxable <= qbiThreshold) {
      final incomeLimitBase = _max(0, preQbiTaxable - preferentialIncome);
      qbiDeduction = _min(
        qbiBase * _qbiRateBasisPoints ~/ 10000,
        incomeLimitBase * _qbiRateBasisPoints ~/ 10000,
      );
      final minimumDeduction = table.qbiMinimumDeductionMinor;
      final minimumIncome = table.qbiMinimumIncomeMinor;
      if (minimumDeduction != null &&
          minimumIncome != null &&
          qbiBase >= minimumIncome) {
        qbiDeduction = _max(
          qbiDeduction,
          _min(minimumDeduction, preQbiTaxable),
        );
      }
    }
    final taxableIncome = _max(0, preQbiTaxable - qbiDeduction);
    final preferentialTaxable = _min(preferentialIncome, taxableIncome);
    final ordinaryTaxable = taxableIncome - preferentialTaxable;

    final ordinarySlices = applyTaxBands(
      ordinaryTaxable,
      table.ordinaryBracketsFor(status),
    );
    final ordinaryTax = sumBandTax(ordinarySlices);
    final capitalGainsSlices = applyTaxBands(
      preferentialTaxable,
      table.longTermCapitalGainsBandsFor(status),
      startMinor: ordinaryTaxable,
    );
    final capitalGainsTax = sumBandTax(capitalGainsSlices);

    final investmentIncome =
        totals['us.ind.taxable_interest'] +
        totals['us.ind.dividends'] +
        totals['us.ind.qualified_dividends'] +
        shortTermNet +
        longTermNet -
        allowedCapitalLoss;
    final netInvestmentIncome = _max(0, investmentIncome);
    final modifiedAdjustedGrossIncome =
        adjustedGrossIncome + totals['us.ind.tax_exempt_interest'];
    final excessMagi = _max(
      0,
      modifiedAdjustedGrossIncome -
          table.netInvestmentIncomeThresholdFor(status),
    );
    final netInvestmentIncomeTax =
        _min(netInvestmentIncome, excessMagi) * _niitRateBasisPoints ~/ 10000;

    final alreadyPaid =
        totals['us.ind.federal_withholding'] +
        totals['us.ind.estimated_tax_payments'];
    final totalTax =
        ordinaryTax + capitalGainsTax + netInvestmentIncomeTax + seTax.tax;
    return _IndividualComputation(
      totals: totals,
      filingStatus: status,
      linkedBusinessProfit: linkedBusinessProfit,
      linkedBusinessCount: linkedBusinessCount,
      linkedUncategorizedCount: linkedUncategorized,
      seTax: seTax,
      ordinaryTaxable: ordinaryTaxable,
      preferentialTaxable: preferentialTaxable,
      ordinarySlices: ordinarySlices,
      ordinaryTax: ordinaryTax,
      capitalGainsSlices: capitalGainsSlices,
      capitalGainsTax: capitalGainsTax,
      netInvestmentIncomeTax: netInvestmentIncomeTax,
      totalIncome: totalIncome,
      adjustments: adjustments,
      adjustedGrossIncome: adjustedGrossIncome,
      standardDeduction: standardDeduction,
      itemizedDeductions: itemizedDeductions,
      usingItemized: usingItemized,
      qbiDeduction: qbiDeduction,
      taxableIncome: taxableIncome,
      totalTax: totalTax,
      alreadyPaid: alreadyPaid,
      shortTermNet: shortTermNet,
      longTermNet: longTermNet,
      allowedCapitalLoss: allowedCapitalLoss,
      preferentialIncome: preferentialIncome,
      hsaContribution: hsaContribution,
      iraContribution: iraContribution,
      selfEmployedRetirement: selfEmployedRetirement,
    );
  }

  _SeTax _selfEmploymentTax({
    required int businessProfit,
    required int wages,
    required UsTaxYearTable table,
    required UsFilingStatus status,
  }) {
    final netEarnings = _max(0, businessProfit) * 9235 ~/ 10000;
    if (netEarnings < _selfEmploymentThresholdMinor) {
      return _zeroSeTax;
    }
    final socialSecurityRoom = _max(
      0,
      table.socialSecurityWageBaseMinor - wages,
    );
    final socialSecurityBase = _min(netEarnings, socialSecurityRoom);
    final socialSecurityTax =
        socialSecurityBase * _socialSecurityRateBasisPoints ~/ 10000;
    final medicareTax = netEarnings * _medicareRateBasisPoints ~/ 10000;
    final additionalMedicareBase = _max(
      0,
      netEarnings -
          _max(0, table.additionalMedicareThresholdFor(status) - wages),
    );
    final additionalMedicareTax =
        additionalMedicareBase * _additionalMedicareRateBasisPoints ~/ 10000;
    final tax = socialSecurityTax + medicareTax + additionalMedicareTax;
    return _SeTax(
      tax: tax,
      half: (socialSecurityTax + medicareTax) ~/ 2,
      socialSecurityBase: socialSecurityBase,
      socialSecurityTax: socialSecurityTax,
      medicareBase: netEarnings,
      medicareTax: medicareTax,
      additionalMedicareBase: additionalMedicareBase,
      additionalMedicareTax: additionalMedicareTax,
    );
  }

  TaxReport _individualReport(
    TaxInput input,
    UsTaxYearTable table,
    UsFilingStatus status,
  ) {
    final computation = _individualComputation(input, table);
    final uncategorizedCount =
        computation.totals.uncategorizedCount +
        computation.linkedUncategorizedCount;
    final balanceDue = computation.totalTax - computation.alreadyPaid;
    final lines = <TaxReportLine>[
      ..._categoryLines(computation.totals, usIndividualCategories),
      if (computation.linkedBusinessCount > 0)
        TaxReportLine(
          label: 'Schedule C net profit',
          amountMinor: computation.linkedBusinessProfit,
          reportReference: 'Schedule 1 (Form 1040), line 3',
        ),
      TaxReportLine(
        label: 'Total income',
        amountMinor: computation.totalIncome,
        reportReference: 'Form 1040, line 9',
      ),
      if (computation.seTax.half > 0)
        TaxReportLine(
          label: 'Deductible part of self-employment tax',
          amountMinor: computation.seTax.half,
          reportReference: 'Schedule 1 (Form 1040), line 15',
        ),
      if (computation.adjustments > 0)
        TaxReportLine(
          label: 'Adjustments to income',
          amountMinor: computation.adjustments,
          reportReference: 'Schedule 1 (Form 1040), line 26',
        ),
      TaxReportLine(
        label: 'Adjusted gross income',
        amountMinor: computation.adjustedGrossIncome,
        reportReference: 'Form 1040, line 11a',
      ),
      if (!computation.usingItemized)
        TaxReportLine(
          label: 'Standard deduction',
          amountMinor: computation.standardDeduction,
          reportReference: 'Form 1040, line 12e',
        ),
      if (computation.qbiDeduction > 0)
        TaxReportLine(
          label: 'Qualified business income deduction',
          amountMinor: computation.qbiDeduction,
          reportReference: 'Form 1040, line 13a',
        ),
      TaxReportLine(
        label: 'Taxable income',
        amountMinor: computation.taxableIncome,
        reportReference: 'Form 1040, line 15',
      ),
      if (computation.ordinaryTax + computation.capitalGainsTax > 0)
        TaxReportLine(
          label: 'Federal income tax',
          amountMinor: computation.ordinaryTax + computation.capitalGainsTax,
          reportReference: 'Form 1040, line 16',
        ),
      if (computation.netInvestmentIncomeTax > 0)
        TaxReportLine(
          label: 'Net investment income tax',
          amountMinor: computation.netInvestmentIncomeTax,
          reportReference: 'Form 8960, line 17',
        ),
      if (computation.seTax.tax > 0)
        TaxReportLine(
          label: 'Self-employment tax',
          amountMinor: computation.seTax.tax,
          reportReference: 'Schedule SE (Form 1040), line 12',
        ),
      TaxReportLine(
        label: 'Total tax',
        amountMinor: computation.totalTax,
        reportReference: 'Form 1040, line 24',
      ),
      TaxReportLine(
        label: 'Total payments',
        amountMinor: computation.alreadyPaid,
        reportReference: 'Form 1040, line 33',
      ),
      if (balanceDue >= 0)
        TaxReportLine(
          label: 'Amount you owe',
          amountMinor: balanceDue,
          reportReference: 'Form 1040, line 37',
        )
      else
        TaxReportLine(
          label: 'Amount overpaid',
          amountMinor: -balanceDue,
          reportReference: 'Form 1040, line 34',
        ),
    ];
    return TaxReport(
      year: input.year,
      entityKind: TaxEntityKind.individual,
      lines: lines,
      liabilities: [
        if (computation.ordinaryTax > 0)
          TaxLiability(
            label: 'Income tax (ordinary rates)',
            amountMinor: computation.ordinaryTax,
            bands: computation.ordinarySlices,
          ),
        if (computation.capitalGainsTax > 0)
          TaxLiability(
            label: 'Income tax (capital gains and qualified dividends)',
            amountMinor: computation.capitalGainsTax,
            bands: computation.capitalGainsSlices,
          ),
        if (computation.netInvestmentIncomeTax > 0)
          TaxLiability(
            label: 'Net investment income tax',
            amountMinor: computation.netInvestmentIncomeTax,
          ),
        if (computation.seTax.tax > 0)
          TaxLiability(
            label: 'Self-employment tax',
            amountMinor: computation.seTax.tax,
            bands: [
              if (computation.seTax.socialSecurityTax > 0)
                TaxBandSlice(
                  label: 'Social Security 12.4%',
                  baseMinor: computation.seTax.socialSecurityBase,
                  rateBasisPoints: _socialSecurityRateBasisPoints,
                  taxMinor: computation.seTax.socialSecurityTax,
                ),
              if (computation.seTax.medicareTax > 0)
                TaxBandSlice(
                  label: 'Medicare 2.9%',
                  baseMinor: computation.seTax.medicareBase,
                  rateBasisPoints: _medicareRateBasisPoints,
                  taxMinor: computation.seTax.medicareTax,
                ),
              if (computation.seTax.additionalMedicareTax > 0)
                TaxBandSlice(
                  label: 'Additional Medicare 0.9%',
                  baseMinor: computation.seTax.additionalMedicareBase,
                  rateBasisPoints: _additionalMedicareRateBasisPoints,
                  taxMinor: computation.seTax.additionalMedicareTax,
                ),
            ],
          ),
      ],
      alreadyPaidMinor: computation.alreadyPaid,
      assumptions: _individualAssumptions(table, status, uncategorizedCount),
      sources: usTaxSources,
      rulesVerifiedOn: usRulesVerifiedOn,
      uncategorizedCount: uncategorizedCount,
    );
  }

  TaxReport _soleTraderReport(TaxInput input) {
    final computation = _scheduleCComputation(input);
    final lines = <TaxReportLine>[
      ..._categoryLines(computation.totals, usScheduleCCategories),
      TaxReportLine(
        label: 'Gross profit',
        amountMinor: computation.grossProfit,
        reportReference: 'Schedule C (Form 1040), line 5',
      ),
      TaxReportLine(
        label: 'Gross income',
        amountMinor: computation.grossIncome,
        reportReference: 'Schedule C (Form 1040), line 7',
      ),
      TaxReportLine(
        label: 'Total expenses before expenses for business use of home',
        amountMinor: computation.totalExpenses,
        reportReference: 'Schedule C (Form 1040), line 28',
      ),
      TaxReportLine(
        label: 'Tentative profit or (loss)',
        amountMinor: computation.tentativeProfit,
        reportReference: 'Schedule C (Form 1040), line 29',
      ),
      TaxReportLine(
        label: 'Net profit or (loss)',
        amountMinor: computation.netProfit,
        reportReference: 'Schedule C (Form 1040), line 31',
      ),
    ];
    return TaxReport(
      year: input.year,
      entityKind: TaxEntityKind.soleTrader,
      lines: lines,
      liabilities: const [],
      alreadyPaidMinor: 0,
      assumptions: _soleTraderAssumptions(
        computation.totals.uncategorizedCount,
      ),
      sources: usTaxSources,
      rulesVerifiedOn: usRulesVerifiedOn,
      uncategorizedCount: computation.totals.uncategorizedCount,
    );
  }

  TaxReport _companyReport(TaxInput input) {
    final computation = _companyComputation(input);
    final balanceDue = computation.tax - computation.alreadyPaid;
    final lines = <TaxReportLine>[
      ..._categoryLines(computation.totals, usCompanyCategories),
      TaxReportLine(
        label: 'Gross profit',
        amountMinor: computation.grossProfit,
        reportReference: 'Form 1120, line 3',
      ),
      TaxReportLine(
        label: 'Total income',
        amountMinor: computation.totalIncome,
        reportReference: 'Form 1120, line 11',
      ),
      TaxReportLine(
        label: 'Total deductions',
        amountMinor: computation.totalDeductions,
        reportReference: 'Form 1120, line 27',
      ),
      TaxReportLine(
        label: 'Taxable income',
        amountMinor: computation.taxableIncome,
        reportReference: 'Form 1120, line 30',
      ),
      TaxReportLine(
        label: 'Total tax',
        amountMinor: computation.tax,
        reportReference: 'Form 1120, line 31',
      ),
      TaxReportLine(
        label: 'Total payments',
        amountMinor: computation.alreadyPaid,
        reportReference: 'Form 1120, line 33',
      ),
      if (balanceDue >= 0)
        TaxReportLine(
          label: 'Amount owed',
          amountMinor: balanceDue,
          reportReference: 'Form 1120, line 35',
        )
      else
        TaxReportLine(
          label: 'Amount overpaid',
          amountMinor: -balanceDue,
          reportReference: 'Form 1120, line 36',
        ),
    ];
    return TaxReport(
      year: input.year,
      entityKind: TaxEntityKind.company,
      lines: lines,
      liabilities: [
        if (computation.tax > 0)
          TaxLiability(
            label: 'Federal income tax (21%)',
            amountMinor: computation.tax,
            bands: [
              TaxBandSlice(
                label: '21%',
                baseMinor: computation.taxableIncome,
                rateBasisPoints: _corporateRateBasisPoints,
                taxMinor: computation.tax,
              ),
            ],
          ),
      ],
      alreadyPaidMinor: computation.alreadyPaid,
      assumptions: _companyAssumptions(computation.totals.uncategorizedCount),
      sources: usTaxSources,
      rulesVerifiedOn: usRulesVerifiedOn,
      uncategorizedCount: computation.totals.uncategorizedCount,
    );
  }

  List<TaxReportLine> _categoryLines(
    _CategoryTotals totals,
    List<TaxCategory> categories,
  ) {
    final lines = <TaxReportLine>[];
    for (final category in categories) {
      final entryCount = totals.countOf(category.code);
      final amount = totals[category.code];
      if (entryCount == 0 && amount == 0) {
        continue;
      }
      lines.add(
        TaxReportLine(
          label: category.label,
          amountMinor: amount,
          code: category.code,
          reportReference: category.reportReference,
          entryCount: entryCount,
        ),
      );
    }
    return lines;
  }

  List<String> _individualAssumptions(
    UsTaxYearTable table,
    UsFilingStatus status,
    int uncategorizedCount,
  ) => [
    ..._commonAssumptions,
    _aStandardVsItemized,
    _aNoAgeDeductions,
    _qbiAssumption(table, status),
    if (table.qbiMinimumDeductionMinor != null &&
        table.qbiMinimumIncomeMinor != null)
      _qbiMinimumAssumption(table),
    _aQbiBase,
    _aMultipleBusinesses,
    _aSeOnlyLinked,
    _aHalfSeDeduction,
    _aAdditionalMedicare,
    _aNiit,
    _aNiitScope,
    _aCapitalLosses,
    _aQualifiedDividends,
    _aReliefAsEntered,
    _aOtherAdjustments,
    _aLinkedOnly,
    if (uncategorizedCount > 0) _uncategorizedAssumption(uncategorizedCount),
  ];

  List<String> _soleTraderAssumptions(int uncategorizedCount) => [
    _aFederalOnly,
    _aSchCOnly,
    _aCalendarYear,
    _aCents,
    _aMeals,
    _aHomeOffice,
    _aSection179,
    _aVehicle,
    _aCogs,
    if (uncategorizedCount > 0) _uncategorizedAssumption(uncategorizedCount),
  ];

  List<String> _companyAssumptions(int uncategorizedCount) => [
    _aFederalOnly,
    _aCOnly,
    _aCalendarYear,
    _aCents,
    _aCorporateRate,
    _aNoCorporateExtras,
    _aCompanyDeductionLimits,
    _aCompanyLosses,
    _aNetLoss,
    _aCogs,
    _aEstimatedPayments,
    if (uncategorizedCount > 0) _uncategorizedAssumption(uncategorizedCount),
  ];

  List<TaxOpportunity> _individualOpportunities(
    TaxInput input,
    TaxReport report,
    UsTaxYearTable table,
  ) {
    final computation = _individualComputation(input, table);
    final opportunities = <TaxOpportunity>[];
    final year = input.year.startYear;
    final deadline = DateTime.utc(year + 1, 4, 15);

    if (computation.linkedBusinessProfit > 0) {
      final netEarnings = _max(
        0,
        computation.linkedBusinessProfit - computation.seTax.half,
      );
      final sepRoom = _min(
        netEarnings * _selfEmployedSepRateBasisPoints ~/ 10000,
        table.sepContributionLimitMinor,
      );
      final deferralRoom = _min(table.deferralLimitMinor, netEarnings);
      final maximumRoom = _min(
        table.sepContributionLimitMinor,
        sepRoom + deferralRoom,
      );
      final room = _max(0, maximumRoom - computation.selfEmployedRetirement);
      if (room > 0) {
        opportunities.add(
          TaxOpportunity(
            id: 'us.sep_ira_or_solo_401k',
            title: 'SEP-IRA or Solo 401(k) contribution room',
            explanation:
                'A SEP-IRA allows 20% of net self-employment earnings, up to '
                '${_dollarAmount(table.sepContributionLimitMinor)} for $year. '
                'A Solo 401(k) can add an employee deferral of up to '
                '${_dollarAmount(table.deferralLimitMinor)}, with total '
                'additions capped at '
                '${_dollarAmount(table.sepContributionLimitMinor)}. This '
                'assumes no employees, no other plan contributions, and no '
                'age-50 catch-up. Estimated room: ${_dollarAmount(room)}.',
            estimatedSavingMinor: _savingForDeduction(room, computation, table),
            deadline: deadline,
            source: Uri.parse('https://www.irs.gov/publications/p560'),
          ),
        );
      }
    }

    if (computation.qbiDeduction > 0) {
      opportunities.add(
        TaxOpportunity(
          id: 'us.qbi',
          title: 'Qualified business income deduction',
          explanation:
              'A 20% deduction for qualified business income is applied in '
              'this report. Taxable income before the deduction is at or '
              'below '
              '${_dollarAmount(table.qualifiedBusinessIncomeThresholdFor(computation.filingStatus))}. '
              'The above-threshold W-2 wage and UBIA phase-ins and specified '
              'service trade or business limits are not modeled.',
          estimatedSavingMinor: _savingForDeduction(
            computation.qbiDeduction,
            computation,
            table,
          ),
          source: Uri.parse(
            'https://www.irs.gov/newsroom/qualified-business-income-deduction',
          ),
        ),
      );
    }

    final selfEmploymentCompensation = _max(
      0,
      computation.linkedBusinessProfit -
          computation.seTax.half -
          computation.selfEmployedRetirement,
    );
    final earnedIncome = _max(
      0,
      computation.totals['us.ind.wages'] + selfEmploymentCompensation,
    );
    final iraRoom = _max(
      0,
      _min(table.iraLimitMinor, earnedIncome) - computation.iraContribution,
    );
    if (iraRoom > 0 && computation.totalTax > 0) {
      opportunities.add(
        TaxOpportunity(
          id: 'us.traditional_ira',
          title: 'Traditional IRA contribution',
          explanation:
              'The annual IRA contribution limit is '
              '${_dollarAmount(table.iraLimitMinor)} for $year, and the '
              'contribution cannot exceed taxable compensation. The deduction '
              'phases out if you or your spouse are covered by a workplace '
              'retirement plan; OpenBudget assumes neither of you is covered. '
              'Age-50 catch-up is not modeled. Estimated room: '
              '${_dollarAmount(iraRoom)}.',
          estimatedSavingMinor: _savingForDeduction(
            iraRoom,
            computation,
            table,
          ),
          deadline: deadline,
          source: Uri.parse(
            'https://www.irs.gov/retirement-plans/'
            'cola-increases-for-dollar-limitations-on-benefits-and-'
            'contributions',
          ),
        ),
      );
    }

    final hsaRoom = _max(
      0,
      table.hsaSelfOnlyLimitMinor - computation.hsaContribution,
    );
    if (hsaRoom > 0 && computation.totalTax > 0) {
      opportunities.add(
        TaxOpportunity(
          id: 'us.hsa',
          title: 'Health savings account contribution',
          explanation:
              'Requires high-deductible health plan coverage and no '
              'disqualifying coverage. The $year self-only limit is '
              '${_dollarAmount(table.hsaSelfOnlyLimitMinor)}; the family '
              'limit is ${_dollarAmount(table.hsaFamilyLimitMinor)}. Employer '
              'contributions and the age-55 catch-up are not modeled. '
              'Estimated room uses the self-only limit: '
              '${_dollarAmount(hsaRoom)}.',
          estimatedSavingMinor: _savingForDeduction(
            hsaRoom,
            computation,
            table,
          ),
          deadline: deadline,
          source: Uri.parse('https://www.irs.gov/publications/p969'),
        ),
      );
    }

    if (computation.itemizedDeductions > 0 &&
        computation.itemizedDeductions != computation.standardDeduction) {
      final itemizing =
          computation.itemizedDeductions > computation.standardDeduction;
      final difference = itemizing
          ? computation.itemizedDeductions - computation.standardDeduction
          : computation.standardDeduction - computation.itemizedDeductions;
      opportunities.add(
        TaxOpportunity(
          id: 'us.standard_vs_itemized',
          title: itemizing
              ? 'Itemize deductions'
              : 'Take the standard deduction',
          explanation: itemizing
              ? 'Your itemized total exceeds the standard deduction by '
                    '${_dollarAmount(difference)}. This report already uses '
                    'the itemized amount.'
              : 'The standard deduction exceeds your itemized total by '
                    '${_dollarAmount(difference)}. This report already uses '
                    'the standard deduction.',
          estimatedSavingMinor: _savingForDeduction(
            difference,
            computation,
            table,
          ),
          source: Uri.parse('https://www.irs.gov/pub/irs-pdf/f1040sa.pdf'),
        ),
      );
    }

    if (computation.shortTermNet + computation.longTermNet > 0) {
      final ordinaryRate = _marginalOrdinaryRate(
        computation.ordinaryTaxable,
        table.ordinaryBracketsFor(computation.filingStatus),
      );
      final capitalGainsRate = _marginalCapitalGainsRate(computation, table);
      final saving =
          computation.shortTermNet * ordinaryRate ~/ 10000 +
          computation.longTermNet * capitalGainsRate ~/ 10000;
      opportunities.add(
        TaxOpportunity(
          id: 'us.tax_loss_harvesting',
          title: 'Harvest capital losses',
          explanation: r'A loss equal to your net capital gains would offset them. Losses must be realized by December 31. If losses exceed gains, up to $3,000 ($1,500 if married filing separately) can offset ordinary income and the excess carries forward.',
          estimatedSavingMinor: saving,
          deadline: DateTime.utc(year, 12, 31),
          source: Uri.parse('https://www.irs.gov/taxtopics/tc409'),
        ),
      );
    }

    if (report.balanceDueMinor >= 100000) {
      final estimatedTaxDates = _estimatedTaxDates(year);
      opportunities.add(
        TaxOpportunity(
          id: 'us.estimated_tax',
          title: 'Pay quarterly estimated tax',
          explanation:
              'This report shows ${_dollarAmount(report.balanceDueMinor)} '
              'still due. To avoid an underpayment penalty, pay at least 90% '
              "of $year's tax or 100% of the prior year's tax, whichever is "
              'smaller; use 110% of the prior year tax if prior-year AGI was '
              'more than ${_dollarAmount(15000000)} '
              '(${_dollarAmount(7500000)} if married filing separately). '
              'Payments are due ${_dateList(estimatedTaxDates)}.',
          deadline: estimatedTaxDates.last,
          source: Uri.parse(
            'https://www.irs.gov/businesses/small-businesses-self-employed/'
            'estimated-taxes',
          ),
        ),
      );
    }

    return opportunities;
  }

  List<TaxOpportunity> _companyOpportunities(TaxReport report) {
    if (report.balanceDueMinor < 50000) {
      return const [];
    }
    return [
      TaxOpportunity(
        id: 'us.company_estimated_tax',
        title: 'Pay corporate estimated tax',
        explanation: r'A corporation generally must pay estimated tax if it expects to owe $500 or more when the return is filed. Payments are due on the 15th day of the 4th, 6th, 9th, and 12th months of the tax year.',
        deadline: DateTime.utc(report.year.startYear, 12, 15),
        source: Uri.parse(
          'https://www.irs.gov/businesses/small-businesses-self-employed/'
          'estimated-taxes',
        ),
      ),
    ];
  }

  int _savingForDeduction(
    int amount,
    _IndividualComputation computation,
    UsTaxYearTable table,
  ) {
    if (amount <= 0) {
      return 0;
    }
    final ordinaryRoom = _min(amount, computation.ordinaryTaxable);
    final remaining = amount - ordinaryRoom;
    final preferentialRoom = _min(remaining, computation.preferentialTaxable);
    final ordinaryRate = _marginalOrdinaryRate(
      computation.ordinaryTaxable,
      table.ordinaryBracketsFor(computation.filingStatus),
    );
    final capitalGainsRate = _marginalCapitalGainsRate(computation, table);
    return ordinaryRoom * ordinaryRate ~/ 10000 +
        preferentialRoom * capitalGainsRate ~/ 10000;
  }

  int _marginalOrdinaryRate(int taxableIncome, List<TaxBand> bands) {
    if (taxableIncome <= 0) {
      return 0;
    }
    for (final band in bands) {
      final ceiling = band.ceilingMinor;
      if (ceiling == null || taxableIncome <= ceiling) {
        return band.rateBasisPoints;
      }
    }
    return bands.last.rateBasisPoints;
  }

  int _marginalCapitalGainsRate(
    _IndividualComputation computation,
    UsTaxYearTable table,
  ) {
    if (computation.preferentialTaxable <= 0) {
      return 0;
    }
    final slices = applyTaxBands(
      computation.preferentialTaxable,
      table.longTermCapitalGainsBandsFor(computation.filingStatus),
      startMinor: computation.ordinaryTaxable,
    );
    return slices.isEmpty ? 0 : slices.last.rateBasisPoints;
  }
}

const String _dollarSign = r'$';

int _max(int a, int b) => a > b ? a : b;

int _min(int a, int b) => a < b ? a : b;

String _dollar(int minorUnits) => (minorUnits ~/ 100).toString();

String _dollarAmount(int minorUnits) => '$_dollarSign${_dollar(minorUnits)}';

const List<String> _monthNames = [
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

List<DateTime> _estimatedTaxDates(int year) => switch (year) {
  2025 => [
    DateTime.utc(2025, 4, 15),
    DateTime.utc(2025, 6, 16),
    DateTime.utc(2025, 9, 15),
    DateTime.utc(2026, 1, 15),
  ],
  2026 => [
    DateTime.utc(2026, 4, 15),
    DateTime.utc(2026, 6, 15),
    DateTime.utc(2026, 9, 15),
    DateTime.utc(2027, 1, 15),
  ],
  _ => throw UnsupportedTaxYearException(TaxJurisdiction.us, year),
};

String _formatDate(DateTime date) =>
    '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';

String _dateList(List<DateTime> dates) {
  final formatted = dates.map(_formatDate).toList();
  final last = formatted.removeLast();
  return '${formatted.join(', ')}, and $last';
}

const String _aFederalOnly = 'Federal only; no state income tax.';
const String _aNoCredits = 'No credits computed.';
const String _aCalendarYear = 'Calendar tax year, January 1 to December 31.';
const String _aCents =
    'Amounts are computed in cents. The IRS allows whole-dollar rounding on '
    'paper returns; no whole-dollar rounding is applied here.';
const String _aNoAmt =
    'No alternative minimum tax, net operating loss deduction, or loss '
    'carryforward is computed.';
const String _aOpportunityEstimates =
    'Opportunity savings are estimates at the top marginal income tax rate '
    'and ignore interactions with the net investment income tax, QBI '
    'deduction, self-employment tax, and credits.';
const String _aStandardVsItemized =
    'The standard deduction and a single user-entered itemized total are '
    'compared; itemized deductions are not recomputed line by line.';
const String _aNoAgeDeductions =
    'No age-based additional standard deduction, dependent standard '
    'deduction, or senior deduction is computed.';
const String _aQbiBase =
    'Qualified business income is linked-business profit less the deductible '
    'part of self-employment tax and self-employed retirement contributions '
    'entered in the books.';
const String _aMultipleBusinesses =
    'Multiple linked businesses are combined for the simplified QBI '
    'computation; the per-business QBI loss rules are not modeled.';
const String _aSeOnlyLinked =
    'Self-employment tax is computed only on the net profit of linked '
    'sole-proprietor businesses. All wages are assumed to be subject to '
    'Social Security and Medicare up to the wage base.';
const String _aHalfSeDeduction =
    'The deduction for one-half of self-employment tax excludes the '
    'Additional Medicare Tax, which is not deductible.';
const String _aAdditionalMedicare =
    'The Additional Medicare Tax is computed on self-employment income after '
    'reducing the threshold by wages; Additional Medicare Tax withheld from '
    'wages is not computed.';
const String _aNiit =
    'Net investment income tax is 3.8% of the lesser of net investment '
    'income or modified adjusted gross income above the filing-status '
    'threshold. Modified adjusted gross income is adjusted gross income plus '
    'tax-exempt interest; other MAGI adjustments are not modeled.';
const String _aNiitScope =
    'Net investment income is limited to interest, dividends, and capital '
    'gains in these books; rental, royalty, annuity, and passive business '
    'income are not modeled.';
const String _aCapitalLosses =
    r'Capital losses offset short-term gains first, then long-term gains and capital gain distributions. Up to $3,000 ($1,500 if married filing separately) of excess loss is allowed against ordinary income; carryforwards are not tracked.';
const String _aQualifiedDividends =
    'Qualified dividends must be entered only in the qualified-dividend '
    'category and not repeated in ordinary dividends.';
const String _aReliefAsEntered =
    'Health savings account, traditional IRA, and self-employed retirement '
    'deductions are taken as entered; the pack does not verify eligibility, '
    'coverage, age, or contribution limits.';
const String _aOtherAdjustments =
    'No other above-the-line adjustments, such as self-employed health '
    'insurance, educator expenses, or student loan interest, are computed.';
const String _aLinkedOnly =
    'Only linked US inputs whose entity kind is soleTrader and whose tax year '
    'matches the individual report are included.';
const String _aSchCOnly =
    'Schedule C profit only. Income tax and self-employment tax are computed '
    "on the owner's individual report.";
const String _aMeals =
    'Business meals are reduced by 50%; enter the full business-use meal '
    'cost. Exceptions for fully deductible meals are not modeled.';
const String _aHomeOffice =
    r'The home office deduction uses the simplified method and is capped at $1,500 (300 square feet at $5 per square foot).';
const String _aSection179 =
    'Section 179 and depreciation are taken as entered; annual limits and '
    'depreciation schedules are not recomputed.';
const String _aVehicle =
    'Car and truck expenses are taken as entered; standard mileage rates and '
    'vehicle depreciation limits are not computed.';
const String _aCogs =
    'Cost of goods sold is taken as entered; inventory accounting is not '
    'recomputed.';
const String _aCOnly = 'C corporation only; no S corporation election.';
const String _aCorporateRate =
    'The corporate rate is a flat 21% of taxable income (Form 1120, '
    'Schedule J, line 1a).';
const String _aNoCorporateExtras =
    'No dividends-received deduction, net operating loss deduction, '
    'alternative minimum tax, or credits are computed.';
const String _aCompanyLosses =
    'Capital and Form 4797 losses are entered in their own loss categories; '
    'other negative income items are not modeled.';
const String _aCompanyDeductionLimits =
    'Deduction limits for charitable contributions, interest, and '
    'depreciation are not recomputed.';
const String _aNetLoss =
    'A net loss produces no current tax; loss carryforwards are not tracked.';
const String _aEstimatedPayments =
    'Estimated tax payments are credited as entered; no underpayment penalty '
    'is computed.';

const List<String> _commonAssumptions = [
  _aFederalOnly,
  _aNoCredits,
  _aCalendarYear,
  _aCents,
  _aNoAmt,
  _aOpportunityEstimates,
];

String _qbiAssumption(UsTaxYearTable table, UsFilingStatus status) =>
    'The qualified business income deduction is the simplified 20% '
    'computation (Form 8995). It is applied only when taxable income before '
    'the deduction is at or below '
    '${_dollarAmount(table.qualifiedBusinessIncomeThresholdFor(status))}. '
    'Above-threshold W-2 wage and UBIA phase-ins and specified service trade '
    'or business limits are not modeled.';

String _qbiMinimumAssumption(UsTaxYearTable table) =>
    'For ${table.startYear}, the '
    '${_dollarAmount(table.qbiMinimumDeductionMinor!)} minimum deduction for '
    'active qualified business income is applied when QBI is at least '
    '${_dollarAmount(table.qbiMinimumIncomeMinor!)}.';

String _uncategorizedAssumption(int count) =>
    '$count entries use categories this pack does not know and are excluded '
    'from the figures.';

const int _socialSecurityRateBasisPoints = 1240;
const int _medicareRateBasisPoints = 290;
const int _additionalMedicareRateBasisPoints = 90;
const int _niitRateBasisPoints = 380;
const int _qbiRateBasisPoints = 2000;
const int _selfEmployedSepRateBasisPoints = 2000;
const int _corporateRateBasisPoints = 2100;
const int _selfEmploymentThresholdMinor = 40000;
const int _capitalLossLimitMinor = 300000;
const int _marriedSeparateCapitalLossLimitMinor = 150000;
const int _homeOfficeCapMinor = 150000;

const _SeTax _zeroSeTax = _SeTax(
  tax: 0,
  half: 0,
  socialSecurityBase: 0,
  socialSecurityTax: 0,
  medicareBase: 0,
  medicareTax: 0,
  additionalMedicareBase: 0,
  additionalMedicareTax: 0,
);

final class _CategoryTotals {
  const _CategoryTotals({
    required this.amounts,
    required this.counts,
    required this.uncategorizedCount,
  });

  final Map<String, int> amounts;
  final Map<String, int> counts;
  final int uncategorizedCount;

  int operator [](String code) => amounts[code] ?? 0;

  int countOf(String code) => counts[code] ?? 0;
}

final class _SeTax {
  const _SeTax({
    required this.tax,
    required this.half,
    required this.socialSecurityBase,
    required this.socialSecurityTax,
    required this.medicareBase,
    required this.medicareTax,
    required this.additionalMedicareBase,
    required this.additionalMedicareTax,
  });

  final int tax;
  final int half;
  final int socialSecurityBase;
  final int socialSecurityTax;
  final int medicareBase;
  final int medicareTax;
  final int additionalMedicareBase;
  final int additionalMedicareTax;
}

final class _ScheduleCComputation {
  const _ScheduleCComputation({
    required this.totals,
    required this.grossProfit,
    required this.grossIncome,
    required this.totalExpenses,
    required this.tentativeProfit,
    required this.netProfit,
  });

  final _CategoryTotals totals;
  final int grossProfit;
  final int grossIncome;
  final int totalExpenses;
  final int tentativeProfit;
  final int netProfit;
}

final class _CompanyComputation {
  const _CompanyComputation({
    required this.totals,
    required this.grossProfit,
    required this.totalIncome,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.tax,
    required this.alreadyPaid,
  });

  final _CategoryTotals totals;
  final int grossProfit;
  final int totalIncome;
  final int totalDeductions;
  final int taxableIncome;
  final int tax;
  final int alreadyPaid;
}

final class _IndividualComputation {
  const _IndividualComputation({
    required this.totals,
    required this.filingStatus,
    required this.linkedBusinessProfit,
    required this.linkedBusinessCount,
    required this.linkedUncategorizedCount,
    required this.seTax,
    required this.ordinaryTaxable,
    required this.preferentialTaxable,
    required this.ordinarySlices,
    required this.ordinaryTax,
    required this.capitalGainsSlices,
    required this.capitalGainsTax,
    required this.netInvestmentIncomeTax,
    required this.totalIncome,
    required this.adjustments,
    required this.adjustedGrossIncome,
    required this.standardDeduction,
    required this.itemizedDeductions,
    required this.usingItemized,
    required this.qbiDeduction,
    required this.taxableIncome,
    required this.totalTax,
    required this.alreadyPaid,
    required this.shortTermNet,
    required this.longTermNet,
    required this.allowedCapitalLoss,
    required this.preferentialIncome,
    required this.hsaContribution,
    required this.iraContribution,
    required this.selfEmployedRetirement,
  });

  final _CategoryTotals totals;
  final UsFilingStatus filingStatus;
  final int linkedBusinessProfit;
  final int linkedBusinessCount;
  final int linkedUncategorizedCount;
  final _SeTax seTax;
  final int ordinaryTaxable;
  final int preferentialTaxable;
  final List<TaxBandSlice> ordinarySlices;
  final int ordinaryTax;
  final List<TaxBandSlice> capitalGainsSlices;
  final int capitalGainsTax;
  final int netInvestmentIncomeTax;
  final int totalIncome;
  final int adjustments;
  final int adjustedGrossIncome;
  final int standardDeduction;
  final int itemizedDeductions;
  final bool usingItemized;
  final int qbiDeduction;
  final int taxableIncome;
  final int totalTax;
  final int alreadyPaid;
  final int shortTermNet;
  final int longTermNet;
  final int allowedCapitalLoss;
  final int preferentialIncome;
  final int hsaContribution;
  final int iraContribution;
  final int selfEmployedRetirement;
}
