part of 'ng_tax_rules.dart';

/// An individual's income and reliefs for one year.
final class _IndividualPosition {
  const _IndividualPosition({
    required this.amounts,
    required this.counts,
    required this.uncategorized,
    required this.gains,
    required this.capitalLoss,
    required this.linkedTaxPaid,
    required this.linkedLines,
    required this.skippedLinkedInputs,
    required this.reliefs,
    required this.rentRelief,
    required this.totalIncome,
    required this.chargeableIncome,
    required this.alreadyPaid,
  });

  final Map<String, int> amounts;
  final Map<String, int> counts;
  final int uncategorized;

  final int gains;
  final int capitalLoss;

  final int linkedTaxPaid;
  final List<TaxReportLine> linkedLines;
  final int skippedLinkedInputs;

  final int reliefs;
  final int rentRelief;
  final int totalIncome;
  final int chargeableIncome;
  final int alreadyPaid;
}

/// Computes the income, reliefs and credits on an individual's return.
_IndividualPosition _individualPosition(TaxInput input, _NgTaxTable table) {
  final totals = _totals(input.entries, TaxEntityKind.individual);
  final amounts = totals.amounts;
  final counts = totals.counts;

  final income = _sumKind(amounts, TaxCategoryKind.income);

  final proceeds = _sumKind(amounts, TaxCategoryKind.disposalProceeds);
  final costs = _sumKind(amounts, TaxCategoryKind.disposalCost);
  final gains = math.max(0, proceeds - costs);
  final capitalLoss = math.max(0, costs - proceeds);

  var reliefs = 0;
  for (final category in _NgTaxCategories.individual) {
    if (category.kind == TaxCategoryKind.relief) {
      reliefs += amounts[category.code] ?? 0;
    }
  }

  final annualRent = switch (input.profile) {
    NgTaxProfile(:final annualRentMinor) => math.max(0, annualRentMinor),
    _ => 0,
  };
  final rentRelief = _rentRelief(annualRent, table);

  final soleTraderLinks = input.linked
      .where((link) => link.profile.entityKind == TaxEntityKind.soleTrader)
      .length;
  var linkedProfit = 0;
  var linkedTaxPaid = 0;
  var linkedNumber = 0;
  var skippedLinkedInputs = 0;
  final linkedLines = <TaxReportLine>[];
  for (final link in input.linked) {
    if (link.profile.entityKind != TaxEntityKind.soleTrader) {
      skippedLinkedInputs += 1;
      continue;
    }
    linkedNumber += 1;
    final business = _businessPosition(
      entries: link.entries,
      kind: TaxEntityKind.soleTrader,
      reclaimVat: link.profile.salesTaxRegistered,
    );
    linkedTaxPaid += business.taxPaid;
    final suffix = soleTraderLinks == 1 ? '' : ' $linkedNumber';
    if (business.totalProfit > 0) {
      linkedProfit += business.totalProfit;
      linkedLines.add(
        TaxReportLine(
          label: 'Profit from linked business$suffix',
          amountMinor: business.totalProfit,
        ),
      );
    }
    if (business.lossMinor > 0) {
      linkedLines.add(
        TaxReportLine(
          label: 'Loss from linked business$suffix (carried forward)',
          amountMinor: business.lossMinor,
        ),
      );
    }
  }

  final totalIncome = income + gains + linkedProfit;
  final chargeableIncome = math.max(0, totalIncome - reliefs - rentRelief);
  final alreadyPaid =
      _sumKind(amounts, TaxCategoryKind.taxPaid) + linkedTaxPaid;

  return _IndividualPosition(
    amounts: amounts,
    counts: counts,
    uncategorized: totals.uncategorized,
    gains: gains,
    capitalLoss: capitalLoss,
    linkedTaxPaid: linkedTaxPaid,
    linkedLines: linkedLines,
    skippedLinkedInputs: skippedLinkedInputs,
    reliefs: reliefs,
    rentRelief: rentRelief,
    totalIncome: totalIncome,
    chargeableIncome: chargeableIncome,
    alreadyPaid: alreadyPaid,
  );
}

/// Builds an individual's report.
TaxReport _individualReport(TaxInput input, _NgTaxTable table) {
  final position = _individualPosition(input, table);
  final slices = applyTaxBands(position.chargeableIncome, table.bands);
  final tax = sumBandTax(slices);
  const catalog = _NgTaxCategories.individual;

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
    ...position.linkedLines,
    TaxReportLine(
      label: 'Total income',
      amountMinor: position.totalIncome,
      reportReference: 'NTA 2025 s.28',
    ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.relief,
    ),
    if (position.rentRelief > 0)
      TaxReportLine(
        label: 'Rent relief (20% of annual rent, capped at N500,000)',
        amountMinor: position.rentRelief,
        reportReference: 'NTA 2025 s.30(2)(a)(vi)',
      ),
    TaxReportLine(
      label: 'Chargeable income',
      amountMinor: position.chargeableIncome,
      reportReference: 'NTA 2025 s.30',
    ),
    ..._categoryLines(
      catalog,
      position.amounts,
      position.counts,
      kind: TaxCategoryKind.taxPaid,
    ),
    if (position.linkedTaxPaid > 0)
      TaxReportLine(
        label: 'Tax paid by linked businesses',
        amountMinor: position.linkedTaxPaid,
      ),
  ];

  final assumptions = <String>[
    ..._baseAssumptions(),
    'Rent relief uses the annual rent recorded in the profile; keep the tenancy agreement and rent receipts as evidence.',
    'Worldwide income is included for a resident individual; foreign tax credits are not modelled.',
    'Franked dividends and final-tax interest are excluded from total income.',
    'Capital gains exemptions and reliefs in Part VIII (private residence, personal chattels, motor vehicles, gifts, certain share disposals) are not modelled; record exempt disposals out of scope.',
    'Employment exemptions and benefits-in-kind valuation rules are not modelled; record the taxable value only.',
    'Pension, NHF and NHIS deductions use the amounts recorded; statutory caps and approved-scheme conditions are not checked.',
    'Business losses and unused capital allowances are carried forward, not offset against other income.',
    'The minimum-wage exemption in section 58 is not modelled.',
    'Tax deducted at source is credited only when recorded as a tax-paid category.',
  ];
  if (position.skippedLinkedInputs > 0) {
    assumptions.add(
      '${position.skippedLinkedInputs} linked input(s) were not sole trades and were left out of this return.',
    );
  }

  return TaxReport(
    year: input.year,
    entityKind: TaxEntityKind.individual,
    lines: lines,
    liabilities: [
      TaxLiability(
        label: 'Personal income tax',
        amountMinor: tax,
        bands: slices,
      ),
    ],
    alreadyPaidMinor: position.alreadyPaid,
    assumptions: assumptions,
    sources: [for (final url in table.sourceUrls) Uri.parse(url)],
    rulesVerifiedOn: _ngRulesVerifiedOn,
    uncategorizedCount: position.uncategorized,
  );
}
