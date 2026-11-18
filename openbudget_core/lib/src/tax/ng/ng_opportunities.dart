part of 'ng_tax_rules.dart';

final Uri _ntaUri = Uri.parse(
  'https://www.nrs.gov.ng/uploads/NIGERIA_TAX_ACT_2025_ef6bb812a5.pdf',
);

final Uri _ntaaUri = Uri.parse('https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf');

/// Opportunities on an individual's return.
List<TaxOpportunity> _individualOpportunities(
  TaxInput input,
  TaxReport report,
  _NgTaxTable table,
) {
  final position = _individualPosition(input, table);
  final annualRent = switch (input.profile) {
    NgTaxProfile(:final annualRentMinor) => math.max(0, annualRentMinor),
    _ => 0,
  };
  // 2026 follows the gazetted Nigeria Tax Act (primary); 2025 follows the
  // repealed PITA and CITA, known only through secondary summaries.
  final figuresPrimary = table.regime == _NgRegime.nta;
  final figureGrade = figuresPrimary
      ? TaxEvidenceGrade.primary
      : TaxEvidenceGrade.secondary;
  final ruleYear = input.year.label;
  final opportunities = <TaxOpportunity>[];

  // Rent relief is an NTA s.30 relief; the old regime has the consolidated
  // relief allowance instead and cannot be claimed by recording rent.
  if (table.regime == _NgRegime.nta) {
    if (annualRent == 0) {
      opportunities.add(
        TaxOpportunity(
          id: 'ng.rent_relief',
          title: 'Rent relief',
          explanation:
              'Rent relief is 20% of the annual rent you pay, capped at '
              'N500,000. Add your annual rent to the Nigeria tax profile so '
              'the return can claim it, and keep the tenancy agreement and '
              'receipts.',
          source: _ntaUri,
          ruleYear: ruleYear,
          needsEvidence: true,
          assumptions: const [
            'The relief needs the tenancy agreement and rent receipts as evidence.',
            'The cap is per year of assessment on rent for your home.',
          ],
        ),
      );
    } else {
      final taxWithRelief = _taxOn(position.chargeableIncome, table.bands);
      final taxWithoutRelief = _taxOn(
        math.max(0, position.totalIncome - position.reliefs),
        table.bands,
      );
      opportunities.add(
        TaxOpportunity(
          id: 'ng.rent_relief',
          title: 'Rent relief',
          explanation:
              'The return claims ${_naira(position.statutoryRelief)} of rent '
              'relief: 20% of ${_naira(annualRent)}, within the N500,000 cap. '
              'Keep the tenancy agreement and rent receipts as evidence.',
          estimatedSavingMinor: taxWithoutRelief - taxWithRelief,
          source: _ntaUri,
          ruleYear: ruleYear,
          needsEvidence: true,
          assumptions: const [
            'The rent recorded on the tax profile is the annual rent for your home.',
            'The relief needs the tenancy agreement and rent receipts as evidence.',
          ],
        ),
      );
    }
  }

  final pension = position.amounts['ng.ind.relief.pension'] ?? 0;
  if (pension > 0) {
    final taxWithRelief = _taxOn(position.chargeableIncome, table.bands);
    final taxWithoutRelief = _taxOn(
      math.max(
        0,
        position.totalIncome -
            (position.reliefs - pension) -
            position.statutoryRelief,
      ),
      table.bands,
    );
    opportunities.add(
      TaxOpportunity(
        id: 'ng.voluntary_pension',
        title: 'Pension contributions reduce taxable income',
        explanation:
            '${_naira(pension)} of Pension Reform Act contributions is '
            'deducted from total income. Additional voluntary contributions '
            'may also qualify; confirm the limits with your pension '
            'administrator.',
        // The saving is recomputed with the year's bands, which are only
        // secondary-sourced under the old regime: no number until the Act
        // texts are read.
        estimatedSavingMinor: figuresPrimary
            ? taxWithoutRelief - taxWithRelief
            : null,
        source: _ntaUri,
        ruleYear: ruleYear,
        grade: figureGrade,
        needsEvidence: true,
        assumptions: const [
          'Contributions are to a Pension Reform Act scheme; the scheme statement is the evidence.',
          'Additional voluntary contributions have separate limits set by the pension administrator.',
        ],
      ),
    );
  } else {
    opportunities.add(
      TaxOpportunity(
        id: 'ng.voluntary_pension',
        title: 'Voluntary pension contributions',
        explanation:
            'Contributions under the Pension Reform Act are deductible from '
            'total income. Confirm the approved scheme and limits with your '
            'pension administrator before contributing.',
        source: _ntaUri,
        ruleYear: ruleYear,
        grade: figureGrade,
      ),
    );
  }

  final credit = report.alreadyPaidMinor > 0
      ? ' The report already credits ${_naira(report.alreadyPaidMinor)} of tax '
            'paid.'
      : '';
  opportunities.add(
    TaxOpportunity(
      id: 'ng.annual_return',
      title: 'Annual return filing',
      explanation:
          'Every taxable person files an annual return, even when no tax is '
          'due. The Nigeria Tax Administration Act 2025 sets no federal filing '
          'date; your state internal revenue service publishes it.$credit',
      source: _ntaaUri,
      ruleYear: ruleYear,
      grade: figureGrade,
      assumptions: const [
        'The federal law sets no single filing date; the state internal revenue service publishes it.',
      ],
    ),
  );

  return opportunities;
}

/// Opportunities for a sole trade.
List<TaxOpportunity> _soleTraderOpportunities(
  TaxInput input,
  _NgTaxTable table,
) {
  final position = _businessPosition(
    entries: input.entries,
    kind: EntityKind.soleTrader,
    reclaimVat: input.profile.salesTaxRegistered,
  );
  final figuresPrimary = table.regime == _NgRegime.nta;
  final ruleYear = input.year.label;
  final opportunities = <TaxOpportunity>[
    _vatOpportunity(
      position: position,
      table: table,
      registered: input.profile.salesTaxRegistered,
      professionalServicesCode: 'ng.biz.revenue.professional_services',
      ruleYear: ruleYear,
      figuresPrimary: figuresPrimary,
    ),
  ];

  if (position.capitalAllowance > 0) {
    opportunities.add(
      TaxOpportunity(
        id: 'ng.capital_allowance',
        title: 'Capital allowance on business assets',
        explanation:
            '${_naira(position.capitalExpenditure)} of capital additions gives '
            'a ${_naira(position.capitalAllowance)} allowance at the First '
            'Schedule Table I rates. The tax saved depends on the owner '
            'marginal rate on the personal return.',
        source: _ntaUri,
        ruleYear: ruleYear,
        grade: figuresPrimary
            ? TaxEvidenceGrade.primary
            : TaxEvidenceGrade.secondary,
        needsEvidence: true,
        assumptions: const [
          'The allowance method and the notional carry forward follow the First Schedule Table I rates and are not yet confirmed against the enacted text.',
          'Purchase invoices for the assets are the evidence.',
        ],
      ),
    );
  }

  return opportunities;
}

/// Opportunities for a company.
List<TaxOpportunity> _companyOpportunities(TaxInput input, _NgTaxTable table) {
  final position = _businessPosition(
    entries: input.entries,
    kind: EntityKind.company,
    reclaimVat: input.profile.salesTaxRegistered,
  );
  final figuresPrimary = table.regime == _NgRegime.nta;
  final ruleYear = input.year.label;
  final small = switch (table.regime) {
    _NgRegime.nta => _isSmallCompany(position, table, input.profile),
    _NgRegime.pitaCita =>
      position.turnover <= table.mediumCompanyTurnoverFloorMinor,
  };
  final opportunities = <TaxOpportunity>[];

  if (small) {
    final String smallExplanation;
    final String levyTitle;
    switch (table.regime) {
      case _NgRegime.nta:
        smallExplanation =
            'Turnover of ${_naira(position.turnover)} is within the '
            '${_naira(_smallCompanyCeilingMinor(table, input.profile))} '
            'ceiling, the company does not provide professional services, and '
            'fixed assets are assumed below N250,000,000. The company pays '
            '0% instead of 30% companies income tax. Exempt status holds '
            'only if the turnover and fixed-asset conditions are both met; '
            'the two 2025 Acts disagree on the turnover figure, so no '
            'saving is quantified until the enacted text is confirmed.';
        levyTitle = 'Small companies are outside the development levy';
      case _NgRegime.pitaCita:
        smallExplanation =
            'Turnover of ${_naira(position.turnover)} is within the '
            '${_naira(table.mediumCompanyTurnoverFloorMinor)} small company '
            'ceiling under the old Companies Income Tax Act. The company pays '
            '0% companies income tax instead of the 20% or 30% tiers. The '
            '2025 old-regime figures come from secondary summaries, so no '
            'saving is quantified until the Act texts are read.';
        levyTitle = 'Small companies are outside the tertiary education tax';
    }
    opportunities
      ..add(
        TaxOpportunity(
          id: 'ng.small_company',
          title: 'Small company status',
          explanation: smallExplanation,
          // The status turns on the small-company turnover ceiling, which
          // the two 2025 Acts dispute (secondary): no number until the
          // enacted correction is read.
          source: _ntaUri,
          ruleYear: ruleYear,
          grade: TaxEvidenceGrade.secondary,
          assumptions: const [
            'Exempt status holds only if the turnover and fixed-asset conditions are both met.',
            'The Nigeria Tax Act and the Tax Administration Act disagree on the turnover ceiling; the profile chooses which applies.',
          ],
        ),
      )
      ..add(
        TaxOpportunity(
          id: 'ng.development_levy',
          title: levyTitle,
          explanation:
              'The levy is charged on the assessable profits of companies '
              'other than small companies. The report does not charge it; '
              'the exemption follows the same disputed small-company '
              'ceiling, so no amount is quantified here.',
          source: _ntaUri,
          ruleYear: ruleYear,
          grade: TaxEvidenceGrade.secondary,
        ),
      );
  } else {
    final String reason;
    switch (table.regime) {
      case _NgRegime.nta:
        final ceiling = _smallCompanyCeilingMinor(table, input.profile);
        reason = position.turnover > ceiling
            ? 'Turnover of ${_naira(position.turnover)} is above the '
                  '${_naira(ceiling)} small company ceiling.'
            : position.amounts.containsKey(
                'ng.co.revenue.professional_services',
              )
            ? 'A company providing professional services is not a small '
                  'company.'
            : 'Capital additions of ${_naira(position.capitalExpenditure)} '
                  'exceed the N250,000,000 fixed asset ceiling.';
      case _NgRegime.pitaCita:
        reason =
            'Turnover of ${_naira(position.turnover)} is above the '
            '${_naira(table.mediumCompanyTurnoverFloorMinor)} small company '
            'ceiling under the old Companies Income Tax Act.';
    }
    opportunities.add(
      TaxOpportunity(
        id: 'ng.small_company',
        title: 'Small company status not available',
        explanation: reason,
        source: _ntaUri,
        ruleYear: ruleYear,
        grade: TaxEvidenceGrade.secondary,
      ),
    );
  }

  opportunities
    ..add(
      _vatOpportunity(
        position: position,
        table: table,
        registered: input.profile.salesTaxRegistered,
        professionalServicesCode: 'ng.co.revenue.professional_services',
        ruleYear: ruleYear,
        figuresPrimary: figuresPrimary,
      ),
    )
    ..add(
      TaxOpportunity(
        id: 'ng.company_return',
        title: 'Company return filing deadline',
        explanation:
            'A company in business for more than 18 months files its return '
            'within six months after the end of its accounting year. With a 31 '
            'December year end, the ${input.year.startYear} return is due by 30 '
            'June ${input.year.startYear + 1}.',
        deadline: DateTime.utc(input.year.startYear + 1, 6, 30),
        source: _ntaaUri,
        ruleYear: ruleYear,
        grade: figuresPrimary
            ? TaxEvidenceGrade.primary
            : TaxEvidenceGrade.secondary,
        assumptions: const [
          'The deadline counts six months from the end of the accounting year, assuming a 31 December year end.',
        ],
      ),
    );

  return opportunities;
}

/// The VAT registration and small business opportunity shared by both
/// business kinds.
TaxOpportunity _vatOpportunity({
  required _BusinessPosition position,
  required _NgTaxTable table,
  required bool registered,
  required String professionalServicesCode,
  required String ruleYear,
  required bool figuresPrimary,
}) {
  final professional = position.amounts.containsKey(professionalServicesCode);
  final small =
      position.turnover <= table.vatSmallBusinessTurnoverCeilingMinor &&
      !professional &&
      position.capitalExpenditure <=
          table.vatSmallBusinessFixedAssetsCeilingMinor;
  final ceiling = _naira(table.vatSmallBusinessTurnoverCeilingMinor);

  final String title;
  final String explanation;
  if (small) {
    title = registered
        ? 'Small business VAT opt-out'
        : 'Small business VAT exemption';
    explanation = registered
        ? 'Turnover of ${_naira(position.turnover)} is within the '
              '$ceiling small business ceiling. A small business may opt '
              'out of VAT registration, charging and monthly returns by '
              'written notice to the Service.'
        : 'Turnover of ${_naira(position.turnover)} is within the '
              '$ceiling small business ceiling, the business does not '
              'provide professional services, and fixed assets are assumed '
              'below N250,000,000. A small business need not register for '
              'VAT, charge VAT or file monthly returns.';
  } else {
    title = registered ? 'VAT returns are due monthly' : 'VAT registration';
    explanation = registered
        ? 'The business is above the small business ceiling, provides '
              'professional services, or has fixed assets above N250,000,000. '
              'VAT returns are due by the 21st day of the following month and '
              'remit output tax less input tax.'
        : 'The business is above the $ceiling small business ceiling, '
              'provides professional services, or has fixed assets above '
              'N250,000,000. VAT registration brings ${_percent(
                table.vatBasisPoints,
              )} on taxable supplies and returns due by the 21st day of the '
              'following month.';
  }

  return TaxOpportunity(
    id: 'ng.vat_registration',
    title: title,
    explanation: explanation,
    source: _ntaaUri,
    ruleYear: ruleYear,
    grade: figuresPrimary
        ? TaxEvidenceGrade.primary
        : TaxEvidenceGrade.secondary,
    assumptions: const [
      'The small business ceiling is the rolling 12-month gross turnover test with the fixed-asset limit.',
      'Professional services companies are outside the small business rules regardless of turnover.',
    ],
  );
}
