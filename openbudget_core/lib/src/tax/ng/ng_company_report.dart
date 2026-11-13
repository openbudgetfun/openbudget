part of 'ng_tax_rules.dart';

/// The gross-turnover ceiling that decides small-company status, following
/// the user's choice between the two conflicting statutory figures.
///
/// The Nigeria Tax Act gazette says N50,000,000 and the Nigeria Tax
/// Administration Act says N100,000,000; the pack defaults to the Act that
/// charges the tax and never silently chooses.
int _smallCompanyCeilingMinor(_NgTaxTable table, TaxProfile profile) =>
    switch (profile) {
      NgTaxProfile(:final smallCompanyCeiling) => switch (smallCompanyCeiling) {
        NgSmallCompanyCeiling.ntaGazette =>
          table.smallCompanyTurnoverCeilingMinor,
        NgSmallCompanyCeiling.ntaaIntended =>
          table.smallCompanyTurnoverCeilingAltMinor,
      },
      // The pack rejects non-Nigerian profiles before this is reached.
      _ => table.smallCompanyTurnoverCeilingMinor,
    };

/// Whether a company meets the small company definition in the Nigeria Tax
/// Act 2025.
///
/// Fixed assets are not tracked by OpenBudget, so the pack assumes they are
/// below the ceiling unless the year's capital additions already exceed it.
bool _isSmallCompany(
  _BusinessPosition position,
  _NgTaxTable table,
  TaxProfile profile,
) {
  if (position.turnover > _smallCompanyCeilingMinor(table, profile)) {
    return false;
  }
  if (position.amounts.containsKey('ng.co.revenue.professional_services')) {
    return false;
  }
  return position.capitalExpenditure <=
      table.smallCompanyFixedAssetsCeilingMinor;
}

/// The companies income tax rate for [turnoverMinor].
///
/// Under the NTA every company other than a small company pays the single
/// rate in s.56. Under the old CITA regime (secondary sources) turnover
/// tiers give 0% at or below the small floor, 20% up to the medium ceiling
/// and 30% above it.
int _citRateBasisPoints(int turnoverMinor, _NgTaxTable table) =>
    switch (table.regime) {
      _NgRegime.nta => table.citBasisPoints,
      _NgRegime.pitaCita => switch (turnoverMinor) {
        _ when turnoverMinor <= table.mediumCompanyTurnoverFloorMinor => 0,
        _ when turnoverMinor <= table.mediumCompanyTurnoverCeilingMinor =>
          table.citMediumBasisPoints,
        _ => table.citBasisPoints,
      },
    };

/// A plain percentage for labels: 3000 is `30%`, 750 is `7.5%`.
String _percent(int basisPoints) {
  final whole = basisPoints ~/ 100;
  final hundredths = basisPoints % 100;
  if (hundredths == 0) {
    return '$whole%';
  }
  if (hundredths % 10 == 0) {
    return '$whole.${hundredths ~/ 10}%';
  }
  return '$whole.${hundredths.toString().padLeft(2, '0')}%';
}

/// Builds a company's report.
TaxReport _companyReport(TaxInput input, _NgTaxTable table) {
  final position = _businessPosition(
    entries: input.entries,
    kind: EntityKind.company,
    reclaimVat: input.profile.salesTaxRegistered,
  );
  // Old regime (CITA, secondary): a small company is one at or below the
  // N25,000,000 turnover floor; the fixed-asset and professional-services
  // conditions are not modelled from the secondary sources.
  final small = switch (table.regime) {
    _NgRegime.nta => _isSmallCompany(position, table, input.profile),
    _NgRegime.pitaCita =>
      position.turnover <= table.mediumCompanyTurnoverFloorMinor,
  };
  final citRate = small ? 0 : _citRateBasisPoints(position.turnover, table);
  final cit = position.totalProfit * citRate ~/ 10000;
  // NTA s.59 development levy on assessable profits; old regime (CITA,
  // secondary) tertiary education tax at 3% on assessable profits, small
  // companies exempt.
  final levyBasisPoints = small
      ? 0
      : switch (table.regime) {
          _NgRegime.nta => table.developmentLevyBasisPoints,
          _NgRegime.pitaCita => table.tertiaryEducationTaxBasisPoints,
        };
  final levy = position.assessableProfit * levyBasisPoints ~/ 10000;

  final String citLabel;
  final String citSliceLabel;
  if (small) {
    citLabel = 'Companies income tax (small company at 0%)';
    citSliceLabel = 'Small company at 0%';
  } else {
    final rate = _percent(citRate);
    citLabel = switch (table.regime) {
      _NgRegime.nta => 'Companies income tax',
      _NgRegime.pitaCita when citRate == table.citMediumBasisPoints =>
        'Companies income tax (medium company at $rate)',
      _ => 'Companies income tax (large company at $rate)',
    };
    citSliceLabel = switch (table.regime) {
      _NgRegime.nta => 'Total profits at $rate',
      _ => 'Total profits at $rate (CITA turnover tier)',
    };
  }

  final levyLabel = switch (table.regime) {
    _NgRegime.nta => 'Development levy',
    _NgRegime.pitaCita => 'Tertiary education tax',
  };
  final levySliceLabel = switch (table.regime) {
    _NgRegime.nta => 'Assessable profits at ${_percent(levyBasisPoints)}',
    _NgRegime.pitaCita =>
      'Assessable profits at ${_percent(levyBasisPoints)} '
          '(small companies exempt)',
  };

  final liabilities = <TaxLiability>[
    TaxLiability(
      label: citLabel,
      amountMinor: cit,
      bands: [
        TaxBandSlice(
          label: citSliceLabel,
          baseMinor: position.totalProfit,
          rateBasisPoints: citRate,
          taxMinor: cit,
        ),
      ],
    ),
    if (!small && position.assessableProfit > 0 && levyBasisPoints > 0)
      TaxLiability(
        label: levyLabel,
        amountMinor: levy,
        bands: [
          TaxBandSlice(
            label: levySliceLabel,
            baseMinor: position.assessableProfit,
            rateBasisPoints: levyBasisPoints,
            taxMinor: levy,
          ),
        ],
      ),
  ];

  final vat = _vatLiability(position, table, input.profile.salesTaxRegistered);
  if (vat != null) {
    liabilities.add(vat);
  }

  final lines = <TaxReportLine>[
    ..._businessLines(
      catalog: _NgTaxCategories.company,
      position: position,
      profitLabel: 'Total profits',
      reclaimVat: input.profile.salesTaxRegistered,
    ),
    ..._vatLines(position, input.profile.salesTaxRegistered, table),
  ];

  final assumptions = <String>[
    ..._baseAssumptions(),
    'Company resident in Nigeria for tax purposes.',
    'Accounting period assumed to end on 31 December.',
    ...switch (table.regime) {
      _NgRegime.nta => [
        'Total fixed assets are assumed not to exceed N250,000,000 unless capital additions in the year already exceed that ceiling; OpenBudget does not track a balance sheet.',
        'Small company status is inferred from turnover and professional-services revenue; a company providing professional services is never small.',
        // Visible warning for the statutory conflict, shown whenever
        // turnover falls between the two gazetted figures.
        if (position.turnover > table.smallCompanyTurnoverCeilingMinor &&
            position.turnover <= table.smallCompanyTurnoverCeilingAltMinor)
          'Turnover is above the N50,000,000 small company ceiling in the Nigeria Tax Act (the section number is unverified) and within the N100,000,000 "small business" ceiling in the Nigeria Tax Administration Act. The two Acts disagree: officials describe N50,000,000 as a gazetting error and N100,000,000 as the intended figure, and no enacted correction was found as of 5 November 2026. As gazetted this company pays 30% companies income tax plus the 4% development levy; under the Administration Act figure it would pay 0%. Confirm with the Nigeria Revenue Service before relying on either.',
        // NTA s.57: the 15% minimum effective tax rate reaches companies at
        // N20,000,000,000 of aggregate turnover and multinational group
        // members.
        if (position.turnover >= table.minimumEtrTurnoverMinor ||
            (switch (input.profile) {
              NgTaxProfile(:final mneGroupMember) => mneGroupMember,
              _ => false,
            }))
          'The 15% minimum effective tax rate in section 57 applies to this company (aggregate turnover of N20,000,000,000 or more, or a constituent entity of a multinational group). OpenBudget does not compute the top-up: it needs net profits before tax per audited financial statements, less 5% of depreciation and personnel cost.',
        'Companies income tax is 0% for a small company and 30% for any other company under section 56; the gazette shows no other rate.',
        'Capital allowance is one year at the First Schedule Table I rates on current-year additions; prior-year assets, disposals and balancing charges are not tracked.',
      ],
      _NgRegime.pitaCita => [
        'The 2025 figures are secondary-sourced (KPMG, Commenda and other summaries); the Companies Income Tax Act text was not read.',
        'Companies income tax follows the CITA turnover tiers: 0% at or below N25,000,000, 20% above N25,000,000 up to N100,000,000, and 30% above N100,000,000. Fixed-asset conditions and the professional-services exclusion are not modelled for 2025.',
        'The 3% tertiary education tax is charged on assessable profits and small companies are exempt; it replaces the Nigeria Tax Act development levy for 2025.',
      ],
    },
    'Business expenses are assumed to be wholly and exclusively incurred in producing the income; no expense is reclassified.',
    'Capital gains exemptions in Part VIII (for example, certain share disposals) are not modelled; record exempt disposals out of scope.',
    'Capital losses are carried forward and do not reduce other income.',
    'Losses brought forward and loss relief across separate trades are not tracked; the report uses the current year only.',
    'The substitution of dividend for total profit in section 9 is not modelled; dividends paid are recorded out of scope.',
    ..._vatAssumptions(table, input.profile.salesTaxRegistered),
    'Tax paid at source is credited against income tax; input VAT is not part of the balance due.',
  ];

  return TaxReport(
    year: input.year,
    entityKind: EntityKind.company,
    lines: lines,
    liabilities: liabilities,
    alreadyPaidMinor: position.taxPaid,
    assumptions: assumptions,
    sources: [for (final url in table.sourceUrls) Uri.parse(url)],
    rulesVerifiedOn: _ngRulesVerifiedOn,
    rulesVersion: _ngRuleSetFor(
      input.year.startYear,
    ).versionFor(TaxJurisdiction.ng),
    maturity: ngTaxManifest.maturity,
    coverage: ngTaxManifest.sections,
    uncategorizedCount: position.uncategorized,
  );
}

/// What the report assumes about the VAT computation.
List<String> _vatAssumptions(_NgTaxTable table, bool registered) {
  if (!registered) {
    return [
      'The business is not registered for VAT; no VAT is charged and input VAT is part of the cost.',
    ];
  }
  return switch (table.regime) {
    // NTA s.156(1)-(2): excess input tax carries forward as a credit or is
    // refunded on request; s.156(4): zero-rated suppliers may request a
    // refund of input VAT.
    _NgRegime.nta => [
      'VAT is output tax less input tax; excess input tax is carried forward as a credit or may be claimed back as a refund on request (NTA s.156(1)-(2)), and a wholly zero-rated supplier may request a refund of input VAT (s.156(4)).',
      'Input VAT is treated as fully recoverable; the Act requires apportionment where supplies are partly exempt.',
    ],
    _NgRegime.pitaCita => [
      'VAT is output tax less input tax; excess input tax is carried forward as a credit. The refund rules of the old Value Added Tax Act were not researched.',
      'Input VAT is treated as fully recoverable; apportionment where supplies are partly exempt is not modelled for 2025.',
    ],
  };
}
