part of 'ng_tax_rules.dart';

/// Whether a company meets the small company definition in the Nigeria Tax
/// Act 2025.
///
/// Fixed assets are not tracked by OpenBudget, so the pack assumes they are
/// below the ceiling unless the year's capital additions already exceed it.
bool _isSmallCompany(_BusinessPosition position, _NgTaxTable table) {
  if (position.turnover > table.smallCompanyTurnoverCeilingMinor) {
    return false;
  }
  if (position.amounts.containsKey('ng.co.revenue.professional_services')) {
    return false;
  }
  return position.capitalExpenditure <=
      table.smallCompanyFixedAssetsCeilingMinor;
}

/// Builds a company's report.
TaxReport _companyReport(TaxInput input, _NgTaxTable table) {
  final position = _businessPosition(
    entries: input.entries,
    kind: TaxEntityKind.company,
    reclaimVat: input.profile.salesTaxRegistered,
  );
  final small = _isSmallCompany(position, table);
  final citRate = small ? 0 : table.citBasisPoints;
  final cit = position.totalProfit * citRate ~/ 10000;
  final levy = small
      ? 0
      : position.assessableProfit * table.developmentLevyBasisPoints ~/ 10000;

  final liabilities = <TaxLiability>[
    TaxLiability(
      label: small
          ? 'Companies income tax (small company at 0%)'
          : 'Companies income tax',
      amountMinor: cit,
      bands: [
        TaxBandSlice(
          label: small ? 'Small company at 0%' : 'Total profits at 30%',
          baseMinor: position.totalProfit,
          rateBasisPoints: citRate,
          taxMinor: cit,
        ),
      ],
    ),
    if (!small && position.assessableProfit > 0)
      TaxLiability(
        label: 'Development levy',
        amountMinor: levy,
        bands: [
          TaxBandSlice(
            label: 'Assessable profits at 4%',
            baseMinor: position.assessableProfit,
            rateBasisPoints: table.developmentLevyBasisPoints,
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
    ..._vatLines(position, input.profile.salesTaxRegistered),
  ];

  final assumptions = <String>[
    ..._baseAssumptions(),
    'Company resident in Nigeria for tax purposes.',
    'Accounting period assumed to end on 31 December.',
    'Total fixed assets are assumed not to exceed N250,000,000 unless capital additions in the year already exceed that ceiling; OpenBudget does not track a balance sheet.',
    'Small company status is inferred from turnover and professional-services revenue; a company providing professional services is never small.',
    if (!small &&
        position.turnover > table.smallCompanyTurnoverCeilingMinor &&
        position.turnover <= table.vatSmallBusinessTurnoverCeilingMinor)
      'Turnover is above the N50,000,000 small company ceiling in section 202 of the Nigeria Tax Act but within the N100,000,000 in section 147 of the Nigeria Tax Administration Act. Official guidance and the reform committee treat N100,000,000 as the intended figure, so this company may qualify for the 0% rate; confirm with the Nigeria Revenue Service before relying on either.',
    'The minimum effective tax rate in section 57 is not modelled: it applies to constituent entities of MNE groups with group turnover of at least EUR 750,000,000 and to other companies with aggregate turnover of N50,000,000,000 or more.',
    'The 30% companies income tax rate applies; the Act allows a Presidential Order, on the advice of the National Economic Council, to reduce it to 25%. No such Order was in force when the rules were checked.',
    'Capital allowance is one year at the First Schedule Table I rates on current-year additions; prior-year assets, disposals and balancing charges are not tracked.',
    'Business expenses are assumed to be wholly and exclusively incurred in producing the income; no expense is reclassified.',
    'Capital gains exemptions in Part VIII (for example, certain share disposals) are not modelled; record exempt disposals out of scope.',
    'Capital losses are carried forward and do not reduce other income.',
    'Losses brought forward and loss relief across separate trades are not tracked; the report uses the current year only.',
    'The substitution of dividend for total profit in section 9 is not modelled; dividends paid are recorded out of scope.',
    if (input.profile.salesTaxRegistered) ...[
      'VAT is output tax less input tax; a credit is carried forward, not refunded, unless the supplies are zero-rated.',
      'Input VAT is treated as fully recoverable; the Act requires apportionment where supplies are partly exempt.',
    ] else
      'The company is not registered for VAT; no VAT is charged and input VAT is part of the cost.',
    'Tax paid at source is credited against income tax; input VAT is not part of the balance due.',
  ];

  return TaxReport(
    year: input.year,
    entityKind: TaxEntityKind.company,
    lines: lines,
    liabilities: liabilities,
    alreadyPaidMinor: position.taxPaid,
    assumptions: assumptions,
    sources: [for (final url in table.sourceUrls) Uri.parse(url)],
    rulesVerifiedOn: _ngRulesVerifiedOn,
    uncategorizedCount: position.uncategorized,
  );
}
