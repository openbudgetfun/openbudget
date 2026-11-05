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
    required this.statutoryRelief,
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

  /// The statutory allowance that reduces total income before the reliefs
  /// the user records: rent relief under the NTA, the consolidated relief
  /// allowance under the old regime.
  final int statutoryRelief;

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

  final totalIncome = income + gains + _linkedProfit(input);

  final statutoryRelief = switch (table.regime) {
    // NTA s.30(2)(a)(vi): 20% of annual rent paid, capped at N500,000.
    _NgRegime.nta => switch (input.profile) {
      NgTaxProfile(:final annualRentMinor) => _rentRelief(
        math.max(0, annualRentMinor),
        table,
      ),
      _ => 0,
    },
    // PITA consolidated relief allowance (secondary): the higher of
    // N200,000 or 1% of gross income, plus 20% of gross income.
    _NgRegime.pitaCita => _consolidatedReliefAllowance(totalIncome, table),
  };

  final chargeableIncome = math.max(
    0,
    totalIncome - reliefs - statutoryRelief,
  );
  final recordedTaxPaid = _sumKind(amounts, TaxCategoryKind.taxPaid);
  final linkedPaid = _linkedTaxPaid(input);

  return _IndividualPosition(
    amounts: amounts,
    counts: counts,
    uncategorized: totals.uncategorized,
    gains: gains,
    capitalLoss: capitalLoss,
    linkedTaxPaid: linkedPaid,
    linkedLines: _linkedLines(input),
    skippedLinkedInputs: _skippedLinkedInputs(input),
    reliefs: reliefs,
    statutoryRelief: statutoryRelief,
    totalIncome: totalIncome,
    chargeableIncome: chargeableIncome,
    alreadyPaid: recordedTaxPaid + linkedPaid,
  );
}

/// The profit of the sole trades linked to an individual.
int _linkedProfit(TaxInput input) {
  var profit = 0;
  for (final business in _linkedSoleTrades(input)) {
    if (business.totalProfit > 0) {
      profit += business.totalProfit;
    }
  }
  return profit;
}

/// The tax the linked sole trades already paid, credited on the personal
/// return.
int _linkedTaxPaid(TaxInput input) {
  var paid = 0;
  for (final business in _linkedSoleTrades(input)) {
    paid += business.taxPaid;
  }
  return paid;
}

/// Report lines for the linked sole trades.
List<TaxReportLine> _linkedLines(TaxInput input) {
  final links = _linkedSoleTrades(input);
  final lines = <TaxReportLine>[];
  for (final (index, business) in links.indexed) {
    final suffix = links.length == 1 ? '' : ' ${index + 1}';
    if (business.totalProfit > 0) {
      lines.add(
        TaxReportLine(
          label: 'Profit from linked business$suffix',
          amountMinor: business.totalProfit,
        ),
      );
    }
    if (business.lossMinor > 0) {
      lines.add(
        TaxReportLine(
          label: 'Loss from linked business$suffix (carried forward)',
          amountMinor: business.lossMinor,
        ),
      );
    }
  }
  return lines;
}

/// The sole trades linked to [input], ignoring every other kind of book.
List<_BusinessPosition> _linkedSoleTrades(TaxInput input) => [
  for (final link in input.linked)
    if (link.profile.entityKind == TaxEntityKind.soleTrader)
      _businessPosition(
        entries: link.entries,
        kind: TaxEntityKind.soleTrader,
        reclaimVat: link.profile.salesTaxRegistered,
      ),
];

/// How many linked inputs were not sole trades and were left out.
int _skippedLinkedInputs(TaxInput input) => input.linked
    .where((link) => link.profile.entityKind != TaxEntityKind.soleTrader)
    .length;

/// Builds an individual's report.
TaxReport _individualReport(TaxInput input, _NgTaxTable table) {
  final position = _individualPosition(input, table);
  final slices = applyTaxBands(position.chargeableIncome, table.bands);
  final progressiveTax = sumBandTax(slices);
  // Old regime (PITA, secondary): minimum tax of 1% of gross income is
  // payable where it exceeds the progressive tax. It does not exist under
  // the NTA.
  final minimumTax = switch (table.regime) {
    _NgRegime.nta => 0,
    _NgRegime.pitaCita =>
      position.totalIncome * table.minimumTaxBasisPoints ~/ 10000,
  };
  final payable = math.max(progressiveTax, minimumTax);
  final chargedSlices = payable > progressiveTax
      ? [
          TaxBandSlice(
            label: 'Minimum tax at 1% of gross income',
            baseMinor: position.totalIncome,
            rateBasisPoints: table.minimumTaxBasisPoints,
            taxMinor: minimumTax,
          ),
        ]
      : slices;
  const catalog = _NgTaxCategories.individual;

  final statutoryReliefLine = switch (table.regime) {
    // NTA s.30(2)(a)(vi).
    _NgRegime.nta when position.statutoryRelief > 0 => TaxReportLine(
      label: 'Rent relief (20% of annual rent, capped at N500,000)',
      amountMinor: position.statutoryRelief,
      reportReference: 'NTA 2025 s.30(2)(a)(vi)',
    ),
    // PITA consolidated relief allowance (secondary source; the section
    // number is unverified).
    _NgRegime.pitaCita when position.statutoryRelief > 0 => TaxReportLine(
      label: 'Consolidated relief allowance',
      amountMinor: position.statutoryRelief,
      reportReference: 'PITA (secondary source; section unverified)',
    ),
    _ => null,
  };

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
    ?statutoryReliefLine,
    if (payable > progressiveTax)
      TaxReportLine(
        label:
            'Minimum tax at 1% of gross income (replaces the lower '
            'progressive tax)',
        amountMinor: minimumTax,
        reportReference: 'PITA (secondary source; section unverified)',
      ),
    TaxReportLine(
      label: 'Chargeable income',
      amountMinor: position.chargeableIncome,
      reportReference: switch (table.regime) {
        _NgRegime.nta => 'NTA 2025 s.30',
        _NgRegime.pitaCita => 'PITA (secondary source; section unverified)',
      },
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
    ...switch (table.regime) {
      _NgRegime.nta => [
        'Rent relief uses the annual rent recorded in the profile; keep the tenancy agreement and rent receipts as evidence.',
      ],
      _NgRegime.pitaCita => [
        'The 2025 figures are secondary-sourced (PwC and other summaries); the Personal Income Tax Act text was not read.',
        'The consolidated relief allowance (the higher of N200,000 or 1% of gross income, plus 20% of gross income) applies instead of the Nigeria Tax Act rent relief; the annual rent recorded in the profile is not used for 2025.',
        'The 1% minimum tax is payable where it exceeds the progressive tax; exemptions from minimum tax are not modelled.',
        'Approved-channel foreign dividend, interest, rent and royalty are recorded out of scope; the old PITA foreign income rules were not researched.',
      ],
    },
    if (table.regime == _NgRegime.nta) 'Foreign dividend, interest, rent and royalty brought into Nigeria through approved channels are exempt (NTA 2025 s.163(1)(s)) and recorded out of scope; foreign employment and business income are not exempt.',
    'Worldwide income is included for a resident individual; foreign tax credits are not modelled.',
    'Franked dividends and final-tax interest are excluded from total income.',
    'Capital gains exemptions and reliefs in Part VIII (private residence, personal chattels, motor vehicles, gifts, certain share disposals) are not modelled; record exempt disposals out of scope.',
    'Employment exemptions and benefits-in-kind valuation rules are not modelled; record the taxable value only.',
    'Pension, NHF and NHIS deductions use the amounts recorded; statutory caps and approved-scheme conditions are not checked.',
    'Business losses and unused capital allowances are carried forward, not offset against other income.',
    if (table.regime == _NgRegime.nta)
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
        amountMinor: payable,
        bands: chargedSlices,
      ),
    ],
    alreadyPaidMinor: position.alreadyPaid,
    assumptions: assumptions,
    sources: [for (final url in table.sourceUrls) Uri.parse(url)],
    rulesVerifiedOn: _ngRulesVerifiedOn,
    uncategorizedCount: position.uncategorized,
  );
}
