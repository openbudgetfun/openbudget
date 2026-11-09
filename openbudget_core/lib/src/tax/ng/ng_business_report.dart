part of 'ng_tax_rules.dart';

/// The profit position of a sole trade or a company for one year.
final class _BusinessPosition {
  const _BusinessPosition({
    required this.amounts,
    required this.counts,
    required this.uncategorized,
    required this.turnover,
    required this.gains,
    required this.capitalLoss,
    required this.allowableExpenses,
    required this.capitalExpenditure,
    required this.capitalAllowance,
    required this.assessableProfit,
    required this.totalProfit,
    required this.unusedCapitalAllowance,
    required this.lossMinor,
    required this.taxPaid,
    required this.outputVat,
    required this.inputVat,
  });

  /// Category totals, before capital allowances.
  final Map<String, int> amounts;

  final Map<String, int> counts;
  final int uncategorized;

  /// Turnover from income categories.
  final int turnover;

  /// Net chargeable gains included in total profits.
  final int gains;

  /// Capital losses, which do not reduce other income.
  final int capitalLoss;

  final int allowableExpenses;
  final int capitalExpenditure;
  final int capitalAllowance;
  final int assessableProfit;
  final int totalProfit;
  final int unusedCapitalAllowance;
  final int lossMinor;
  final int taxPaid;
  final int outputVat;
  final int inputVat;

  int get netVat => outputVat - inputVat;
}

/// Computes the profit position for a sole trade or a company.
_BusinessPosition _businessPosition({
  required List<TaxEntry> entries,
  required EntityKind kind,
  required bool reclaimVat,
}) {
  final totals = _totals(
    entries,
    kind,
    amountOf: (entry, category) =>
        _amountFor(entry, category, reclaimVat: reclaimVat),
  );
  final amounts = totals.amounts;
  final counts = totals.counts;

  final turnover = _sumKind(amounts, TaxCategoryKind.income);
  final proceeds = _sumKind(amounts, TaxCategoryKind.disposalProceeds);
  final costs = _sumKind(amounts, TaxCategoryKind.disposalCost);
  final gains = math.max(0, proceeds - costs);
  final capitalLoss = math.max(0, costs - proceeds);

  var allowableExpenses = 0;
  var capitalExpenditure = 0;
  var capitalAllowance = 0;
  for (final MapEntry(key: code, value: amount) in amounts.entries) {
    final rate = _NgTaxCategories.capitalAllowanceRates[code];
    if (rate != null) {
      capitalExpenditure += amount;
      capitalAllowance += amount * rate ~/ 10000;
      continue;
    }
    final category = _NgTaxCategories.byCode[code]!;
    if (category.kind == TaxCategoryKind.expense) {
      allowableExpenses += amount;
    }
  }
  if (!reclaimVat) {
    // Input VAT is a cost when the business cannot reclaim it.
    allowableExpenses += _sumKind(amounts, TaxCategoryKind.salesTaxPaid);
  }

  final grossIncome = turnover + gains;
  final assessableProfit = math.max(0, grossIncome - allowableExpenses);
  final totalProfit = math.max(0, assessableProfit - capitalAllowance);

  final taxPaid = _sumKind(amounts, TaxCategoryKind.taxPaid);

  var outputVat = 0;
  var inputVat = 0;
  if (reclaimVat) {
    outputVat = _sumKind(amounts, TaxCategoryKind.salesTaxCollected);
    inputVat = _sumKind(amounts, TaxCategoryKind.salesTaxPaid);
    for (final entry in entries) {
      final category = _NgTaxCategories.byCode[entry.categoryCode];
      if (category == null || !category.entityKinds.contains(kind)) {
        continue;
      }
      final categoryKind = category.kind;
      if (categoryKind == TaxCategoryKind.income ||
          categoryKind == TaxCategoryKind.disposalProceeds) {
        outputVat += entry.salesTaxMinor;
      } else if (categoryKind == TaxCategoryKind.expense) {
        inputVat += entry.salesTaxMinor;
      }
    }
  }

  return _BusinessPosition(
    amounts: amounts,
    counts: counts,
    uncategorized: totals.uncategorized,
    turnover: turnover,
    gains: gains,
    capitalLoss: capitalLoss,
    allowableExpenses: allowableExpenses,
    capitalExpenditure: capitalExpenditure,
    capitalAllowance: capitalAllowance,
    assessableProfit: assessableProfit,
    totalProfit: totalProfit,
    unusedCapitalAllowance: math.max(0, capitalAllowance - assessableProfit),
    lossMinor: math.max(0, allowableExpenses - grossIncome),
    taxPaid: taxPaid,
    outputVat: outputVat,
    inputVat: inputVat,
  );
}

/// Builds the category, profit and tax lines of a business report.
List<TaxReportLine> _businessLines({
  required List<TaxCategory> catalog,
  required _BusinessPosition position,
  required String profitLabel,
  required bool reclaimVat,
}) {
  final lines = <TaxReportLine>[
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.income,
    ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.outOfScope,
    ),
    if (position.gains > 0 || position.capitalLoss > 0) ...[
      TaxReportLine(
        label: 'Disposal proceeds',
        amountMinor: _sumKind(
          position.amounts,
          TaxCategoryKind.disposalProceeds,
        ),
        reportReference: 'NTA 2025 s.33',
      ),
      TaxReportLine(
        label: 'Acquisition cost',
        amountMinor: _sumKind(position.amounts, TaxCategoryKind.disposalCost),
        reportReference: 'NTA 2025 s.39',
      ),
    ],
    if (position.gains > 0)
      TaxReportLine(
        label: 'Chargeable gains (proceeds less cost)',
        amountMinor: position.gains,
        reportReference: 'NTA 2025 s.33',
      ),
    if (position.capitalLoss > 0)
      TaxReportLine(
        label: 'Capital loss (carried forward)',
        amountMinor: position.capitalLoss,
      ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.expense,
    ),
    if (!reclaimVat)
      ..._categoryLines(
        catalog,
        position.amounts,
        position.counts,
        kind: TaxCategoryKind.salesTaxPaid,
      ),
    TaxReportLine(
      label: 'Total allowable expenses',
      amountMinor: position.allowableExpenses,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxReportLine(
      label: 'Assessable profits',
      amountMinor: position.assessableProfit,
      reportReference: 'NTA 2025 s.22',
    ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.expense,
      capital: true,
    ),
    ..._capitalAllowanceLines(catalog, position),
    TaxReportLine(
      label: profitLabel,
      amountMinor: position.totalProfit,
      reportReference: 'NTA 2025 s.27',
    ),
    if (position.unusedCapitalAllowance > 0)
      TaxReportLine(
        label: 'Unused capital allowance carried forward',
        amountMinor: position.unusedCapitalAllowance,
      ),
    if (position.lossMinor > 0)
      TaxReportLine(
        label: 'Loss carried forward',
        amountMinor: position.lossMinor,
      ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.taxPaid,
    ),
  ];
  return lines;
}

/// One line per capital category showing that year's allowance.
Iterable<TaxReportLine> _capitalAllowanceLines(
  List<TaxCategory> catalog,
  _BusinessPosition position,
) sync* {
  for (final category in catalog) {
    final rate = _NgTaxCategories.capitalAllowanceRates[category.code];
    if (rate == null) {
      continue;
    }
    final expenditure = position.amounts[category.code];
    if (expenditure == null || expenditure == 0) {
      continue;
    }
    yield TaxReportLine(
      label: 'Capital allowance: ${category.label}',
      amountMinor: expenditure * rate ~/ 10000,
      reportReference: 'NTA 2025 First Schedule Table I',
    );
  }
  if (position.capitalAllowance > 0) {
    yield TaxReportLine(
      label: 'Total capital allowance',
      amountMinor: position.capitalAllowance,
      reportReference: 'NTA 2025 First Schedule Table I',
    );
  }
}

/// Output and input VAT lines for a registered business.
List<TaxReportLine> _vatLines(
  _BusinessPosition position,
  bool registered,
  _NgTaxTable table,
) {
  if (!registered || (position.outputVat == 0 && position.inputVat == 0)) {
    return const [];
  }
  return [
    TaxReportLine(
      label: 'Output VAT on taxable supplies',
      amountMinor: position.outputVat,
      reportReference: 'NTA 2025 s.148',
    ),
    TaxReportLine(
      label: 'Input VAT on taxable purchases',
      amountMinor: position.inputVat,
      reportReference: 'NTA 2025 s.156',
    ),
    if (position.inputVat > position.outputVat)
      TaxReportLine(
        label:
            'Excess input VAT (credit carried forward or refundable on '
            'request)',
        amountMinor: position.inputVat - position.outputVat,
        reportReference: switch (table.regime) {
          // NTA s.156(1)-(2): the excess is a carried-forward credit or a
          // refund on request.
          _NgRegime.nta => 'NTA 2025 s.156(1)-(2)',
          _NgRegime.pitaCita => 'VATA (secondary source; section unverified)',
        },
      ),
  ];
}

/// Builds a sole trader's report.
///
/// Income tax is charged on the owner's personal return, so the report shows
/// the profit that feeds it and any VAT due rather than a personal tax figure.
TaxReport _soleTraderReport(TaxInput input, _NgTaxTable table) {
  final position = _businessPosition(
    entries: input.entries,
    kind: EntityKind.soleTrader,
    reclaimVat: input.profile.salesTaxRegistered,
  );
  final registered = input.profile.salesTaxRegistered;
  final vat = _vatLiability(position, table, registered);

  final lines = <TaxReportLine>[
    ..._businessLines(
      catalog: _NgTaxCategories.soleTrader,
      position: position,
      profitLabel: 'Profit chargeable on the owner personal return',
      reclaimVat: registered,
    ),
    ..._vatLines(position, registered, table),
  ];

  final assumptions = <String>[
    ..._baseAssumptions(),
    'The business profit is taxed on the owner personal return; this report shows the profit that feeds it.',
    'Tax deducted at source is credited on the owner personal return, not against this business report.',
    ...switch (table.regime) {
      _NgRegime.nta => [
        'Capital allowance is one year at the First Schedule Table I rates on current-year additions; prior-year assets, disposals and balancing charges are not tracked.',
      ],
      _NgRegime.pitaCita => [
        'The 2025 figures are secondary-sourced (PwC and other summaries); the Personal Income Tax Act text was not read.',
        'Capital allowance is one year at the First Schedule Table I rates on current-year additions; prior-year assets, disposals and balancing charges are not tracked.',
      ],
    },
    'Business expenses are assumed to be wholly and exclusively incurred in producing the income; no expense is reclassified.',
    'VAT is charged only when the business is registered; otherwise input VAT is part of the cost.',
    if (registered) ..._vatAssumptions(table, registered),
  ];

  return TaxReport(
    year: input.year,
    entityKind: EntityKind.soleTrader,
    lines: lines,
    liabilities: [?vat],
    alreadyPaidMinor: 0,
    assumptions: assumptions,
    sources: [for (final url in table.sourceUrls) Uri.parse(url)],
    rulesVerifiedOn: _ngRulesVerifiedOn,
    uncategorizedCount: position.uncategorized,
  );
}

/// The net VAT liability, or null when the business is not registered or has
/// no VAT movement.
TaxLiability? _vatLiability(
  _BusinessPosition position,
  _NgTaxTable table,
  bool registered,
) {
  if (!registered || (position.outputVat == 0 && position.inputVat == 0)) {
    return null;
  }
  return TaxLiability(
    label: 'Value added tax (output less input)',
    amountMinor: math.max(0, position.netVat),
    bands: [
      TaxBandSlice(
        label: 'Output VAT on taxable supplies',
        baseMinor: position.outputVat,
        rateBasisPoints: table.vatBasisPoints,
        taxMinor: position.outputVat,
      ),
      TaxBandSlice(
        label: 'Input VAT on taxable purchases (credit)',
        baseMinor: position.inputVat,
        rateBasisPoints: table.vatBasisPoints,
        taxMinor: -position.inputVat,
      ),
    ],
  );
}
