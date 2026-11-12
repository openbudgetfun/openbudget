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
  final opportunities = <TaxOpportunity>[];

  // Rent relief is an NTA s.30 relief; the old regime has the consolidated
  // relief allowance instead and cannot be claimed by recording rent.
  if (table.regime == _NgRegime.nta) {
    if (annualRent == 0) {
      opportunities.add(
        TaxOpportunity(
          id: 'ng.rent_relief',
          title: 'Claim rent relief',
          explanation:
              'Rent relief is 20% of the annual rent you pay, capped at '
              'N500,000. Add your annual rent to the Nigeria tax profile so '
              'the return can claim it, and keep the tenancy agreement and '
              'receipts.',
          source: _ntaUri,
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
          title: 'Rent relief claimed',
          explanation:
              'The return claims ${_naira(position.statutoryRelief)} of rent '
              'relief: 20% of ${_naira(annualRent)}, within the N500,000 cap. '
              'Keep the tenancy agreement and rent receipts as evidence.',
          estimatedSavingMinor: taxWithoutRelief - taxWithRelief,
          source: _ntaUri,
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
        estimatedSavingMinor: taxWithoutRelief - taxWithRelief,
        source: _ntaUri,
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
      title: 'File your annual return',
      explanation:
          'Every taxable person files an annual return, even when no tax is '
          'due. The Nigeria Tax Administration Act 2025 sets no federal filing '
          'date; your state internal revenue service publishes it.$credit',
      source: _ntaaUri,
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
  final opportunities = <TaxOpportunity>[
    _vatOpportunity(
      position: position,
      table: table,
      registered: input.profile.salesTaxRegistered,
      professionalServicesCode: 'ng.biz.revenue.professional_services',
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
  final small = switch (table.regime) {
    _NgRegime.nta => _isSmallCompany(position, table, input.profile),
    _NgRegime.pitaCita =>
      position.turnover <= table.mediumCompanyTurnoverFloorMinor,
  };
  final opportunities = <TaxOpportunity>[];

  if (small) {
    final citRate = _citRateBasisPoints(position.turnover, table);
    final citSaving = position.totalProfit * citRate ~/ 10000;
    final levyRate = switch (table.regime) {
      _NgRegime.nta => table.developmentLevyBasisPoints,
      _NgRegime.pitaCita => table.tertiaryEducationTaxBasisPoints,
    };
    final levySaving = position.assessableProfit * levyRate ~/ 10000;
    final String smallExplanation;
    final String levyTitle;
    switch (table.regime) {
      case _NgRegime.nta:
        smallExplanation =
            'Turnover of ${_naira(position.turnover)} is within the '
            '${_naira(_smallCompanyCeilingMinor(table, input.profile))} '
            'ceiling, the company does not provide professional services, and '
            'fixed assets are assumed below N250,000,000. The company pays '
            '0% instead of 30% companies income tax.';
        levyTitle = 'Small companies are outside the development levy';
      case _NgRegime.pitaCita:
        smallExplanation =
            'Turnover of ${_naira(position.turnover)} is within the '
            '${_naira(table.mediumCompanyTurnoverFloorMinor)} small company '
            'ceiling under the old Companies Income Tax Act. The company pays '
            '0% companies income tax instead of the 20% or 30% tiers.';
        levyTitle = 'Small companies are outside the tertiary education tax';
    }
    opportunities
      ..add(
        TaxOpportunity(
          id: 'ng.small_company',
          title: 'Small company status',
          explanation: smallExplanation,
          estimatedSavingMinor: citSaving,
          source: _ntaUri,
        ),
      )
      ..add(
        TaxOpportunity(
          id: 'ng.development_levy',
          title: levyTitle,
          explanation:
              'The levy is charged on the assessable profits of companies '
              'other than small companies. The report does not charge it.',
          estimatedSavingMinor: levySaving,
          source: _ntaUri,
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
      ),
    )
    ..add(
      TaxOpportunity(
        id: 'ng.company_return',
        title: 'File the company return within six months of the year end',
        explanation:
            'A company in business for more than 18 months files its return '
            'within six months after the end of its accounting year. With a 31 '
            'December year end, the ${input.year.startYear} return is due by 30 '
            'June ${input.year.startYear + 1}.',
        deadline: DateTime.utc(input.year.startYear + 1, 6, 30),
        source: _ntaaUri,
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
        ? 'Small business VAT: consider opting out'
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
    title = registered ? 'VAT returns are due monthly' : 'Register for VAT';
    explanation = registered
        ? 'The business is above the small business ceiling, provides '
              'professional services, or has fixed assets above N250,000,000. '
              'File VAT returns by the 21st day of the following month and '
              'remit output tax less input tax.'
        : 'The business is above the $ceiling small business ceiling, '
              'provides professional services, or has fixed assets above '
              'N250,000,000. Register for VAT, charge ${_percent(
                table.vatBasisPoints,
              )} on taxable supplies and file returns by the 21st day of the '
              'following month.';
  }

  return TaxOpportunity(
    id: 'ng.vat_registration',
    title: title,
    explanation: explanation,
    source: _ntaaUri,
  );
}
