import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';
import 'package:openbudget_core/src/tax/us/us_tax_categories.dart';
import 'package:openbudget_core/src/tax/us/us_tax_tables.dart';

export 'package:openbudget_core/src/tax/us/us_tax_categories.dart';
export 'package:openbudget_core/src/tax/us/us_tax_tables.dart';

/// The United States federal tax rules.
///
/// The pack covers calendar years 2025 and 2026, using the figures in
/// Revenue Procedure 2024-40, Revenue Procedure 2025-32, and the One Big
/// Beautiful Bill Act amendments those procedures reflect. State income
/// tax returns and alternative minimum tax are outside its scope; the
/// credits it computes are listed in the individual report assumptions.
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

  UsHomeOfficeMethod _homeOfficeMethod(TaxInput input) =>
      switch (input.profile) {
        UsTaxProfile(:final homeOfficeMethod) => homeOfficeMethod,
        _ => UsHomeOfficeMethod.simplified,
      };

  _ScheduleCComputation _scheduleCComputation(TaxInput input) {
    final totals = _totalsFor(input, TaxEntityKind.soleTrader);
    final amounts = Map<String, int>.of(totals.amounts);
    final rawHomeOffice = amounts['us.sch_c.home_office'] ?? 0;
    // The $1,500 cap applies to the simplified method only; the regular
    // Form 8829 method is uncapped (Publication 587).
    final homeOffice = _homeOfficeMethod(input) == UsHomeOfficeMethod.simplified
        ? _min(rawHomeOffice, _homeOfficeCapMinor)
        : rawHomeOffice;
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
    final profile = switch (input.profile) {
      final UsTaxProfile p => p,
      _ => throw ArgumentError.value(
        input.profile,
        'input.profile',
        'US individual rules need a UsTaxProfile',
      ),
    };
    final status = profile.filingStatus;
    final year = input.year.startYear;
    final totals = _totalsFor(input, TaxEntityKind.individual);
    var linkedBusinessProfit = 0;
    var linkedBusinessWages = 0;
    var linkedBusinessUbia = 0;
    var linkedSstbCount = 0;
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
      linkedBusinessWages += business.totals['us.sch_c.wages'];
      linkedBusinessUbia +=
          business.totals['us.sch_c.ubia_of_qualified_property'];
      if (switch (linked.profile) {
        UsTaxProfile(:final specifiedServiceTrade) => specifiedServiceTrade,
        _ => false,
      }) {
        linkedSstbCount++;
      }
      linkedBusinessCount++;
      linkedUncategorized += business.totals.uncategorizedCount;
    }
    final linkedIsSstb = linkedBusinessCount > 0 && linkedSstbCount > 0;

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
    // AGI may be negative; deductions carry forward to taxable income,
    // which floors at zero (Form 1040 lines 11 and 15).
    final adjustedGrossIncome = totalIncome - adjustments;

    // Modified AGI adds back the foreign earned income exclusion (and the
    // section 931/933 possessions exclusions, not modeled) for the net
    // investment income tax, the SALT phase-down, and Schedule 1-A.
    final modifiedAdjustedGrossIncome =
        adjustedGrossIncome + profile.foreignEarnedIncomeExclusionMinor;

    // Itemized deductions with the SALT cap (IRC 164(b)(6)).
    final itemizedClaimed = totals['us.ind.itemized_deductions'];
    final saltClaimed = totals['us.ind.state_local_taxes'];
    final saltAllowed = _saltAllowedAmount(
      saltClaimed: saltClaimed,
      itemizedClaimed: itemizedClaimed,
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      status: status,
      table: table,
    );
    final allowedItemized = itemizedClaimed - saltClaimed + saltAllowed;
    final standardDeduction = table.standardDeductionFor(status);
    final usingItemized = allowedItemized > standardDeduction;
    final deduction = usingItemized ? allowedItemized : standardDeduction;

    // Schedule 1-A deductions, tax years 2025 to 2028 only (supported
    // years are 2025 and 2026). Allowed with the standard deduction or
    // itemizing (IRC 224 to 225, 163(h)(4), 151(d)(5)).
    final seniorPersons = switch (status) {
      UsFilingStatus.marriedFilingJointly =>
        (profile.taxpayer65OrOlder ? 1 : 0) + (profile.spouse65OrOlder ? 1 : 0),
      UsFilingStatus.qualifyingSurvivingSpouse =>
        profile.taxpayer65OrOlder ? 1 : 0,
      _ => profile.taxpayer65OrOlder ? 1 : 0,
    };
    final schedule1aTips = _schedule1aTips(
      tipsClaimed: totals['us.ind.qualified_tips'],
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      status: status,
      table: table,
    );
    final schedule1aOvertime = _schedule1aOvertime(
      overtimeClaimed: totals['us.ind.qualified_overtime_premium'],
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      status: status,
      table: table,
    );
    final schedule1aVehicleInterest = _schedule1aVehicleInterest(
      interestClaimed: totals['us.ind.vehicle_loan_interest'],
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      status: status,
      table: table,
    );
    final schedule1aSenior = _schedule1aSenior(
      seniorPersons: seniorPersons,
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      status: status,
      table: table,
    );
    final schedule1aTotal =
        schedule1aTips +
        schedule1aOvertime +
        schedule1aVehicleInterest +
        schedule1aSenior;

    final preQbiTaxable = _max(
      0,
      adjustedGrossIncome - deduction - schedule1aTotal,
    );
    final qbiDeduction = _qbiDeduction(
      qbiBase: _max(
        0,
        linkedBusinessProfit - seTax.half - selfEmployedRetirement,
      ),
      preQbiTaxable: preQbiTaxable,
      preferentialIncome: preferentialIncome,
      w2Wages: linkedBusinessWages,
      ubia: linkedBusinessUbia,
      isSstb: linkedIsSstb,
      status: status,
      table: table,
    );
    final taxableIncome = _max(0, preQbiTaxable - qbiDeduction);
    final preferentialTaxable = _min(preferentialIncome, taxableIncome);
    final ordinaryTaxable = taxableIncome - preferentialTaxable;

    final ordinarySlices = applyTaxBands(
      ordinaryTaxable,
      table.ordinaryBracketsFor(status),
    );
    final capitalGainsSlices = applyTaxBands(
      preferentialTaxable,
      table.longTermCapitalGainsBandsFor(status),
      startMinor: ordinaryTaxable,
    );
    // The filed tax: Tax Table below $100,000 of taxable income, Tax
    // Computation Worksheet (the bracket formula) at and above.
    final incomeTax = _incomeTax(
      taxableIncome: taxableIncome,
      ordinaryTaxable: ordinaryTaxable,
      status: status,
      year: year,
      table: table,
    );

    final investmentIncome =
        totals['us.ind.taxable_interest'] +
        totals['us.ind.dividends'] +
        totals['us.ind.qualified_dividends'] +
        shortTermNet +
        longTermNet -
        allowedCapitalLoss;
    final netInvestmentIncome = _max(0, investmentIncome);
    final excessMagi = _max(
      0,
      modifiedAdjustedGrossIncome -
          table.netInvestmentIncomeThresholdFor(status),
    );
    final netInvestmentIncomeTax =
        _min(netInvestmentIncome, excessMagi) * _niitRateBasisPoints ~/ 10000;

    // Additional Medicare tax on wages plus self-employment income
    // together, per Form 8959 (IRC 3101(b)(2)).
    final medicareThreshold = table.additionalMedicareThresholdFor(status);
    final wageAdditionalMedicareBase = _max(0, wages - medicareThreshold);
    final additionalMedicareBase =
        wageAdditionalMedicareBase + seTax.additionalMedicareBase;
    final additionalMedicareTax =
        additionalMedicareBase * _additionalMedicareRateBasisPoints ~/ 10000;

    // Child tax credit and credit for other dependents (IRC 24).
    var qualifyingChildren = 0;
    var otherDependents = 0;
    var dependentsWithoutSsn = 0;
    for (final dependent in profile.dependents) {
      if (!dependent.hasValidSsn) {
        dependentsWithoutSsn++;
        continue;
      }
      dependent.underSeventeen ? qualifyingChildren++ : otherDependents++;
    }
    final grossCredit =
        qualifyingChildren * table.childTaxCreditPerChildMinor +
        otherDependents * table.otherDependentCreditMinor;
    final creditExcessMagi = _max(
      0,
      modifiedAdjustedGrossIncome -
          table.childTaxCreditPhaseOutThresholdFor(status),
    );
    // $50 per $1,000 over the threshold, rounded up to the next $1,000
    // (K: rate and rounding not read from the IRS sources).
    final creditPhaseOut =
        ((creditExcessMagi + 99999) ~/ 100000) * _ctcPhaseOutPerThousandMinor;
    final childTaxCredit = _max(
      0,
      grossCredit - _min(grossCredit, creditPhaseOut),
    );

    final claimantsHaveSsn = switch (status) {
      UsFilingStatus.marriedFilingJointly =>
        profile.taxpayerHasSsn && profile.spouseHasSsn,
      _ => profile.taxpayerHasSsn,
    };
    final alreadyPaid =
        totals['us.ind.federal_withholding'] +
        totals['us.ind.estimated_tax_payments'];
    final totalTaxBeforeCredits =
        incomeTax + netInvestmentIncomeTax + additionalMedicareTax + seTax.tax;
    final creditsApplied = _min(childTaxCredit, totalTaxBeforeCredits);
    final totalTax = totalTaxBeforeCredits - creditsApplied;
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
      capitalGainsSlices: capitalGainsSlices,
      incomeTax: incomeTax,
      netInvestmentIncomeTax: netInvestmentIncomeTax,
      additionalMedicareBase: additionalMedicareBase,
      additionalMedicareTax: additionalMedicareTax,
      totalIncome: totalIncome,
      adjustments: adjustments,
      adjustedGrossIncome: adjustedGrossIncome,
      modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
      standardDeduction: standardDeduction,
      itemizedClaimed: itemizedClaimed,
      saltClaimed: saltClaimed,
      saltAllowed: saltAllowed,
      usingItemized: usingItemized,
      schedule1aTips: schedule1aTips,
      schedule1aOvertime: schedule1aOvertime,
      schedule1aVehicleInterest: schedule1aVehicleInterest,
      schedule1aSenior: schedule1aSenior,
      schedule1aTotal: schedule1aTotal,
      qbiDeduction: qbiDeduction,
      taxableIncome: taxableIncome,
      childTaxCredit: childTaxCredit,
      creditsApplied: creditsApplied,
      dependentsWithoutSsn: dependentsWithoutSsn,
      claimantsHaveSsn: claimantsHaveSsn,
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

  /// The SALT cap and its 30% phase-down to the floor (IRC 164(b)(6)).
  /// Married filing separately halves the cap, threshold, and floor; the
  /// qualifying surviving spouse uses the joint figures. MAGI adds back
  /// the foreign earned income exclusion.
  int _saltAllowedAmount({
    required int saltClaimed,
    required int itemizedClaimed,
    required int modifiedAdjustedGrossIncome,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (saltClaimed <= 0) {
      return 0;
    }
    final mfs = status == UsFilingStatus.marriedFilingSeparately;
    var cap = mfs ? table.saltCapMinor ~/ 2 : table.saltCapMinor;
    final threshold = mfs
        ? table.saltPhaseDownThreshold ~/ 2
        : table.saltPhaseDownThreshold;
    final floor = mfs ? table.saltFloorMinor ~/ 2 : table.saltFloorMinor;
    if (modifiedAdjustedGrossIncome > threshold) {
      final reduction =
          (modifiedAdjustedGrossIncome - threshold) *
          _saltPhaseDownRateBasisPoints ~/
          10000;
      cap = _max(floor, cap - reduction);
    }
    return _min(_min(saltClaimed, itemizedClaimed), cap);
  }

  /// The Schedule 1-A phase-out removes [perThousandMinor] for each $1,000
  /// (or portion thereof) of MAGI over [thresholdMinor]. The "or portion
  /// thereof" treatment for tips, overtime, and senior is I (statute text
  /// read only for vehicle interest; verify against the instructions).
  int _schedule1aPhaseOut({
    required int modifiedAdjustedGrossIncome,
    required int thresholdMinor,
    required int perThousandMinor,
  }) {
    final over = modifiedAdjustedGrossIncome - thresholdMinor;
    if (over <= 0) {
      return 0;
    }
    return ((over + 99999) ~/ 100000) * perThousandMinor;
  }

  int _schedule1aTips({
    required int tipsClaimed,
    required int modifiedAdjustedGrossIncome,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (tipsClaimed <= 0 || status == UsFilingStatus.marriedFilingSeparately) {
      return 0;
    }
    // The phase-out reduces the cap; the deduction is the lesser of the
    // tips and the reduced cap.
    final cap = _max(
      0,
      table.qualifiedTipsCapMinor -
          _schedule1aPhaseOut(
            modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
            thresholdMinor: table.tipsOvertimePhaseOutThresholdFor(status),
            perThousandMinor: _tipsOvertimePhaseOutPerThousandMinor,
          ),
    );
    return _min(tipsClaimed, cap);
  }

  int _schedule1aOvertime({
    required int overtimeClaimed,
    required int modifiedAdjustedGrossIncome,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (overtimeClaimed <= 0 ||
        status == UsFilingStatus.marriedFilingSeparately) {
      return 0;
    }
    final cap = _max(
      0,
      table.qualifiedOvertimeCapFor(status) -
          _schedule1aPhaseOut(
            modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
            thresholdMinor: table.tipsOvertimePhaseOutThresholdFor(status),
            perThousandMinor: _tipsOvertimePhaseOutPerThousandMinor,
          ),
    );
    return _min(overtimeClaimed, cap);
  }

  int _schedule1aVehicleInterest({
    required int interestClaimed,
    required int modifiedAdjustedGrossIncome,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (interestClaimed <= 0) {
      return 0;
    }
    final cap = _max(
      0,
      table.vehicleLoanInterestCapMinor -
          _schedule1aPhaseOut(
            modifiedAdjustedGrossIncome: modifiedAdjustedGrossIncome,
            thresholdMinor: table.vehicleLoanPhaseOutThresholdFor(status),
            perThousandMinor: _vehicleInterestPhaseOutPerThousandMinor,
          ),
    );
    return _min(interestClaimed, cap);
  }

  int _schedule1aSenior({
    required int seniorPersons,
    required int modifiedAdjustedGrossIncome,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (seniorPersons <= 0 ||
        status == UsFilingStatus.marriedFilingSeparately) {
      return 0;
    }
    // The 6% phase-out applies once to the combined amount above the
    // filing-status threshold; per-person application is not confirmed
    // (I; verify against the Schedule 1-A instructions).
    final over = _max(
      0,
      modifiedAdjustedGrossIncome - table.seniorPhaseOutThresholdFor(status),
    );
    return _max(
      0,
      seniorPersons * table.seniorDeductionPerPersonMinor -
          over * _seniorPhaseOutRateBasisPoints ~/ 10000,
    );
  }

  /// The section 199A qualified business income deduction.
  ///
  /// At or below the threshold this is the Form 8995 computation. Above it,
  /// the deduction phases in over the year's phase-in range (IRC
  /// 199A(b)(3)): a specified service trade or business loses its
  /// component across the range; any other business is reduced toward the
  /// W-2 wage / UBIA limitation (IRC 199A(b)(2), Form 8995-A), so a
  /// business with no W-2 wages and no UBIA phases to zero.
  ///
  /// Linked businesses are combined; the per-business Form 8995-A
  /// worksheets are not modeled.
  int _qbiDeduction({
    required int qbiBase,
    required int preQbiTaxable,
    required int preferentialIncome,
    required int w2Wages,
    required int ubia,
    required bool isSstb,
    required UsFilingStatus status,
    required UsTaxYearTable table,
  }) {
    if (qbiBase <= 0) {
      return 0;
    }
    final qbiAmount = qbiBase * _qbiRateBasisPoints ~/ 10000;
    final incomeLimitBase = _max(0, preQbiTaxable - preferentialIncome);
    final incomeLimit = incomeLimitBase * _qbiRateBasisPoints ~/ 10000;
    final fullDeduction = _min(qbiAmount, incomeLimit);
    final threshold = table.qualifiedBusinessIncomeThresholdFor(status);
    if (preQbiTaxable <= threshold) {
      final minimumDeduction = table.qbiMinimumDeductionMinor;
      final minimumIncome = table.qbiMinimumIncomeMinor;
      if (minimumDeduction != null &&
          minimumIncome != null &&
          qbiBase >= minimumIncome) {
        return _max(fullDeduction, _min(minimumDeduction, preQbiTaxable));
      }
      return fullDeduction;
    }
    final over = preQbiTaxable - threshold;
    final applicableBp = _min(
      10000,
      over * 10000 ~/ table.qbiPhaseInRangeFor(status),
    );
    if (isSstb) {
      return fullDeduction * (10000 - applicableBp) ~/ 10000;
    }
    final wageLimit = _min(
      _max(
        w2Wages * _wageLimitRateBasisPoints ~/ 10000,
        w2Wages * _wageUbiaWageRateBasisPoints ~/ 10000 +
            ubia * _wageUbiaPropertyRateBasisPoints ~/ 10000,
      ),
      incomeLimit,
    );
    final reductionBase = _min(
      _max(0, qbiAmount - wageLimit),
      _max(0, incomeLimit - wageLimit),
    );
    return _max(
      0,
      fullDeduction - applicableBp * reductionBase ~/ 10000,
    );
  }

  /// The filed income tax: the IRS Tax Table below $100,000 of taxable
  /// income, the Tax Computation Worksheet (bracket formula) at and above.
  /// Both work on whole dollars: taxable income is rounded to whole
  /// dollars first, half up, and the ordinary/preferential parts are
  /// rounded separately so they still add to the whole.
  ///
  /// With preferential income the Qualified Dividends and Capital Gain
  /// Tax Worksheet comparison applies under the same $100,000 rule: the
  /// smaller of (tax on the ordinary part) + (0/15/20% tax on the
  /// preferential part, whole dollars) and (tax on the whole taxable
  /// income).
  int _incomeTax({
    required int taxableIncome,
    required int ordinaryTaxable,
    required UsFilingStatus status,
    required int year,
    required UsTaxYearTable table,
  }) {
    final whole = usRoundToDollars(taxableIncome);
    final wholeOrdinary = usRoundToDollars(ordinaryTaxable);
    final wholePreferential = _max(0, whole - wholeOrdinary);
    final brackets = table.ordinaryBracketsFor(status);
    final preferentialBands = table.longTermCapitalGainsBandsFor(status);
    // Each amount the worksheet taxes picks its own method: the Tax Table
    // below $100,000, the Tax Computation Worksheet at and above.
    int ordinaryTaxOn(int amountMinor) =>
        amountMinor ~/ 100 >= usTaxTableThresholdDollars
        ? sumBandTax(applyTaxBands(amountMinor, brackets))
        : usIncomeTaxFromTable(amountMinor, status, year);
    if (wholePreferential == 0) {
      return ordinaryTaxOn(whole);
    }
    final preferentialPart = usRoundToDollars(
      sumBandTax(
        applyTaxBands(
          wholePreferential,
          preferentialBands,
          startMinor: wholeOrdinary,
        ),
      ),
    );
    return _min(
      ordinaryTaxOn(wholeOrdinary) + preferentialPart,
      ordinaryTaxOn(whole),
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
    final tax = socialSecurityTax + medicareTax;
    // The self-employment part of the Additional Medicare tax uses the
    // 92.35% figure, with the threshold reduced (not below zero) by
    // Medicare wages (Form 8959). The tax itself is computed at the
    // individual level, combined with the wages part.
    final additionalMedicareBase = _max(
      0,
      netEarnings -
          _max(
            0,
            table.additionalMedicareThresholdFor(status) - wages,
          ),
    );
    return _SeTax(
      tax: tax,
      half: tax ~/ 2,
      socialSecurityBase: socialSecurityBase,
      socialSecurityTax: socialSecurityTax,
      medicareBase: netEarnings,
      medicareTax: medicareTax,
      additionalMedicareBase: additionalMedicareBase,
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
      if (computation.usingItemized && computation.saltClaimed > 0)
        TaxReportLine(
          label: 'State and local taxes allowed after the SALT cap',
          amountMinor: computation.saltAllowed,
          reportReference: 'Schedule A (Form 1040), line 5e',
        ),
      if (computation.schedule1aTotal > 0)
        TaxReportLine(
          label: 'Schedule 1-A additional deductions',
          amountMinor: computation.schedule1aTotal,
          reportReference: 'Form 1040, line 13b',
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
      if (computation.incomeTax > 0)
        TaxReportLine(
          label: 'Federal income tax',
          amountMinor: computation.incomeTax,
          reportReference: 'Form 1040, line 16',
        ),
      if (computation.netInvestmentIncomeTax > 0)
        TaxReportLine(
          label: 'Net investment income tax',
          amountMinor: computation.netInvestmentIncomeTax,
          reportReference: 'Form 8960, line 17',
        ),
      if (computation.additionalMedicareTax > 0)
        TaxReportLine(
          label: 'Additional Medicare tax',
          amountMinor: computation.additionalMedicareTax,
          reportReference: 'Form 8959',
        ),
      if (computation.seTax.tax > 0)
        TaxReportLine(
          label: 'Self-employment tax',
          amountMinor: computation.seTax.tax,
          reportReference: 'Schedule SE (Form 1040), line 12',
        ),
      if (computation.creditsApplied > 0)
        TaxReportLine(
          label: 'Child tax credit and credit for other dependents',
          amountMinor: computation.creditsApplied,
          reportReference: 'Form 1040, line 19',
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
        if (computation.incomeTax > 0)
          TaxLiability(
            label: 'Federal income tax',
            amountMinor: computation.incomeTax,
            bands: [
              ...computation.ordinarySlices,
              ...computation.capitalGainsSlices,
            ],
          ),
        if (computation.netInvestmentIncomeTax > 0)
          TaxLiability(
            label: 'Net investment income tax',
            amountMinor: computation.netInvestmentIncomeTax,
          ),
        if (computation.additionalMedicareTax > 0)
          TaxLiability(
            label: 'Additional Medicare tax',
            amountMinor: computation.additionalMedicareTax,
            bands: [
              TaxBandSlice(
                label: 'Additional Medicare 0.9%',
                baseMinor: computation.additionalMedicareBase,
                rateBasisPoints: _additionalMedicareRateBasisPoints,
                taxMinor: computation.additionalMedicareTax,
              ),
            ],
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
            ],
          ),
        // A nonrefundable credit is a negative liability so the balance
        // due reflects it.
        if (computation.creditsApplied > 0)
          TaxLiability(
            label: 'Child tax credit and credit for other dependents',
            amountMinor: -computation.creditsApplied,
          ),
      ],
      alreadyPaidMinor: computation.alreadyPaid,
      assumptions: _individualAssumptions(
        table,
        computation,
        uncategorizedCount,
      ),
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
        _homeOfficeMethod(input),
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
    _IndividualComputation computation,
    int uncategorizedCount,
  ) {
    final status = computation.filingStatus;
    return [
      ..._commonAssumptions,
      _aTaxTable,
      _aStandardVsItemized,
      _aSalt,
      _aSchedule1aScope,
      _aSchedule1aRounding,
      if (status == UsFilingStatus.marriedFilingSeparately) _aSchedule1aMfs,
      _aSchedule1aSeniorPhaseOut,
      if (computation.schedule1aTotal > 0 && !computation.claimantsHaveSsn)
        _aMissingSsn,
      if (computation.dependentsWithoutSsn > 0)
        _aDependentWithoutSsn(computation.dependentsWithoutSsn),
      _aCtcPhaseOut,
      _aNoActc,
      _aNoAgeDeductions,
      _qbiAssumption(table, status),
      _aQbiAboveThreshold(table, status),
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
  }

  List<String> _soleTraderAssumptions(
    UsHomeOfficeMethod homeOfficeMethod,
    int uncategorizedCount,
  ) => [
    _aFederalOnly,
    _aSchCOnly,
    _aCalendarYear,
    _aCents,
    _aMeals,
    switch (homeOfficeMethod) {
      UsHomeOfficeMethod.simplified => _aHomeOfficeSimplified,
      UsHomeOfficeMethod.regular => _aHomeOfficeRegular,
    },
    _aHomeOfficeGrossIncome,
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
              'this report, phased in above the '
              '${_dollarAmount(table.qualifiedBusinessIncomeThresholdFor(computation.filingStatus))} '
              'threshold with the W-2 wage and UBIA limitation. Raising the '
              "business's W-2 wages or the unadjusted basis of qualified "
              'property can lift the limitation; a specified service trade '
              'or business phases out instead. These are planning estimates; '
              'Form 8995-A computes each business separately.',
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

    if (computation.itemizedClaimed > 0 &&
        computation.itemizedClaimed != computation.standardDeduction) {
      final itemizing =
          computation.usingItemized &&
          computation.itemizedClaimed > computation.standardDeduction;
      final difference = itemizing
          ? computation.itemizedClaimed - computation.standardDeduction
          : computation.standardDeduction - computation.itemizedClaimed;
      opportunities.add(
        TaxOpportunity(
          id: 'us.standard_vs_itemized',
          title: itemizing
              ? 'Itemize deductions'
              : 'Take the standard deduction',
          explanation: itemizing
              ? 'Your itemized total exceeds the standard deduction by '
                    '${_dollarAmount(difference)}. This report already uses '
                    'the itemized amount after the SALT cap.'
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

const String _aFederalOnly = 'Federal only; no state income tax return.';
const String _aCalendarYear = 'Calendar tax year, January 1 to December 31.';
const String _aCents =
    r'Amounts are computed in cents. Below $100,000 of taxable income the '
    'filed tax uses the IRS Tax Table and is rounded to whole dollars; the '
    'Tax Computation Worksheet above that keeps cents.';
const String _aNoAmt =
    'No alternative minimum tax, net operating loss deduction, or loss '
    'carryforward is computed.';
const String _aOpportunityEstimates =
    'Opportunity savings are estimates at the top marginal income tax rate '
    'and ignore interactions with the net investment income tax, QBI '
    'deduction, self-employment tax, and credits.';
const String _aTaxTable =
    r'Below $100,000 of taxable income the filed tax reproduces the IRS Tax '
    'Table: the bracket formula on the midpoint of the row containing the '
    'taxable income, rounded to whole dollars. The method is derived from '
    'IRS practice and must be checked against the printed 2025 and 2026 '
    'Tax Table; the band breakdown shown with this report lists the '
    'statutory brackets, not the Table midpoint.';
const String _aStandardVsItemized =
    'The standard deduction and the itemized total are compared; itemized '
    'deductions are not recomputed line by line except for the SALT cap.';
const String _aSalt =
    r'State and local taxes are capped for itemizers at $40,000 (2025) or '
    r'$40,400 (2026), reduced by 30% of modified AGI over $500,000 '
    r'($505,000 for 2026) to a $10,000 floor; married filing separately '
    'halves the cap, threshold, and floor. Other Schedule A limits '
    '(medical, charitable, mortgage interest) are not recomputed.';
const String _aSchedule1aScope =
    'Schedule 1-A conditions are not verified: the tipped-occupation list, '
    'employer evidence for tips and overtime, the vehicle loan rules (new '
    'vehicle, first lien, VIN, United States assembly), and the '
    'self-employed tips limits are taken as entered.';
const String _aSchedule1aRounding =
    r'The Schedule 1-A phase-outs remove $100 or $200 for each $1,000 (or '
    r'portion of $1,000) of modified AGI over the threshold. The statute '
    'confirms "or portion thereof" only for vehicle loan interest; the same '
    'treatment for tips, overtime, and senior is inferred until the '
    'Schedule 1-A instructions are read.';
const String _aSchedule1aMfs =
    'Married filing separately cannot claim the tips, overtime, or senior '
    'deductions.';
const String _aSchedule1aSeniorPhaseOut =
    'The senior deduction phase-out applies the 6% reduction once to the '
    'combined amount above the filing-status threshold; whether the IRS '
    'applies it per person instead is not confirmed.';
const String _aMissingSsn =
    'A Schedule 1-A deduction was computed without an SSN on file for '
    'everyone claiming it; the IRS requires an SSN that is valid for '
    'employment.';
String _aDependentWithoutSsn(int count) =>
    '$count dependent(s) without an SSN valid for employment earn no child '
    'tax credit or credit for other dependents.';
const String _aCtcPhaseOut =
    r'The child tax credit phase-out of $50 per $1,000 of modified AGI over '
    r'the threshold, rounded up to the next $1,000, is general knowledge not '
    'read from the IRS sources; verify against the Form 1040 instructions.';
const String _aNoActc =
    'The refundable additional child tax credit (Form 8812) is not '
    'computed; the credit here is nonrefundable and limited to the tax.';
const String _aNoAgeDeductions =
    'The additional standard deduction for age 65 or blind is not computed; '
    'the Schedule 1-A senior deduction uses the age-65 profile flags.';
const String _aQbiBase =
    'Qualified business income is linked-business profit less the deductible '
    'part of self-employment tax and self-employed retirement contributions '
    'entered in the books.';
const String _aMultipleBusinesses =
    'Multiple linked businesses are combined for the QBI computation; the '
    'per-business Form 8995-A worksheets and QBI loss carryforwards are not '
    'modeled.';
const String _aSeOnlyLinked =
    'Self-employment tax is computed only on the net profit of linked '
    'sole-proprietor businesses. All wages are assumed to be subject to '
    'Social Security and Medicare up to the wage base.';
const String _aHalfSeDeduction =
    'The deduction for one-half of self-employment tax excludes the '
    'Additional Medicare Tax, which is not deductible.';
const String _aAdditionalMedicare =
    'The Additional Medicare Tax applies to Medicare wages plus '
    'self-employment income above the filing-status threshold, computed '
    'together on Form 8959; the self-employment part uses the 92.35% '
    'figure, and Additional Medicare Tax already withheld from wages is '
    'not credited.';
const String _aNiit =
    'Net investment income tax is 3.8% of the lesser of net investment '
    'income or modified adjusted gross income above the filing-status '
    'threshold. Modified adjusted gross income is adjusted gross income '
    'plus the foreign earned income exclusion; tax-exempt interest is not '
    'added back.';
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
const String _aHomeOfficeSimplified =
    r'The home office deduction uses the simplified method and is capped at $1,500 (300 square feet at $5 per square foot).';
const String _aHomeOfficeRegular =
    'The home office deduction uses the regular Form 8829 method; the '
    r'$1,500 simplified-method cap does not apply.';
const String _aHomeOfficeGrossIncome =
    'The home office deduction is not limited to gross income from the '
    'business use, and no Form 8829 carryover is tracked.';
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
  _aNoAmt,
  _aCalendarYear,
  _aCents,
  _aOpportunityEstimates,
];

String _qbiAssumption(UsTaxYearTable table, UsFilingStatus status) =>
    'The qualified business income deduction is 20% of qualified business '
    'income, limited to 20% of taxable income before the deduction minus '
    'net capital gain. At or below the '
    '${_dollarAmount(table.qualifiedBusinessIncomeThresholdFor(status))} '
    'threshold this is the Form 8995 computation.';

String _aQbiAboveThreshold(UsTaxYearTable table, UsFilingStatus status) =>
    'Above the threshold the deduction phases in over the '
    '${_dollarAmount(table.qbiPhaseInRangeFor(status))} range with the '
    'W-2 wage and unadjusted-basis limitation; a specified service trade or '
    'business phases out across the range instead. The 2026 minimum '
    'deduction interaction above the threshold is not modeled.';

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

/// The SALT cap falls by 30% of MAGI over the threshold (IRC 164(b)(6),
/// statutory).
const int _saltPhaseDownRateBasisPoints = 3000;

/// Schedule 1-A phase-outs: $100 per $1,000 for tips and overtime (IRC
/// 224, 225) and $200 per $1,000 for vehicle loan interest (IRC
/// 163(h)(4)); 6% of MAGI over the threshold for the senior deduction.
const int _tipsOvertimePhaseOutPerThousandMinor = 10000;
const int _vehicleInterestPhaseOutPerThousandMinor = 20000;
const int _seniorPhaseOutRateBasisPoints = 600;

/// The child tax credit phase-out, $50 per $1,000 (K: not read from the
/// IRS sources).
const int _ctcPhaseOutPerThousandMinor = 5000;

/// The section 199A W-2 wage limitation: the greater of 50% of W-2 wages
/// or 25% of wages plus 2.5% of the unadjusted basis of qualified property
/// (IRC 199A(b)(2)(B), statutory).
const int _wageLimitRateBasisPoints = 5000;
const int _wageUbiaWageRateBasisPoints = 2500;
const int _wageUbiaPropertyRateBasisPoints = 250;

const _SeTax _zeroSeTax = _SeTax(
  tax: 0,
  half: 0,
  socialSecurityBase: 0,
  socialSecurityTax: 0,
  medicareBase: 0,
  medicareTax: 0,
  additionalMedicareBase: 0,
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
  });

  final int tax;
  final int half;
  final int socialSecurityBase;
  final int socialSecurityTax;
  final int medicareBase;
  final int medicareTax;

  /// The self-employment part of the Additional Medicare tax base; the tax
  /// itself is computed with the wages part on Form 8959.
  final int additionalMedicareBase;
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
    required this.capitalGainsSlices,
    required this.incomeTax,
    required this.netInvestmentIncomeTax,
    required this.additionalMedicareBase,
    required this.additionalMedicareTax,
    required this.totalIncome,
    required this.adjustments,
    required this.adjustedGrossIncome,
    required this.modifiedAdjustedGrossIncome,
    required this.standardDeduction,
    required this.itemizedClaimed,
    required this.saltClaimed,
    required this.saltAllowed,
    required this.usingItemized,
    required this.schedule1aTips,
    required this.schedule1aOvertime,
    required this.schedule1aVehicleInterest,
    required this.schedule1aSenior,
    required this.schedule1aTotal,
    required this.qbiDeduction,
    required this.taxableIncome,
    required this.childTaxCredit,
    required this.creditsApplied,
    required this.dependentsWithoutSsn,
    required this.claimantsHaveSsn,
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
  final List<TaxBandSlice> capitalGainsSlices;

  /// The filed income tax: Tax Table below $100,000, worksheet above.
  final int incomeTax;
  final int netInvestmentIncomeTax;
  final int additionalMedicareBase;
  final int additionalMedicareTax;
  final int totalIncome;
  final int adjustments;
  final int adjustedGrossIncome;
  final int modifiedAdjustedGrossIncome;
  final int standardDeduction;
  final int itemizedClaimed;
  final int saltClaimed;
  final int saltAllowed;
  final bool usingItemized;
  final int schedule1aTips;
  final int schedule1aOvertime;
  final int schedule1aVehicleInterest;
  final int schedule1aSenior;
  final int schedule1aTotal;
  final int qbiDeduction;
  final int taxableIncome;
  final int childTaxCredit;
  final int creditsApplied;
  final int dependentsWithoutSsn;

  /// Whether everyone claiming a Schedule 1-A deduction has an SSN on
  /// file.
  final bool claimantsHaveSsn;
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
