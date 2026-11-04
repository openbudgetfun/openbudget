part of 'ng_tax_rules.dart';

/// The rates that apply to one Nigerian year of assessment.
final class _NgTaxTable {
  const _NgTaxTable({
    required this.bands,
    required this.rentReliefBasisPoints,
    required this.rentReliefCapMinor,
    required this.citBasisPoints,
    required this.developmentLevyBasisPoints,
    required this.vatBasisPoints,
    required this.smallCompanyTurnoverCeilingMinor,
    required this.smallCompanyFixedAssetsCeilingMinor,
    required this.vatSmallBusinessTurnoverCeilingMinor,
    required this.vatSmallBusinessFixedAssetsCeilingMinor,
    required this.sourceUrls,
  });

  /// Fourth Schedule bands, applied to chargeable income.
  final List<TaxBand> bands;

  /// Section 30(2)(a)(vi): 20% of annual rent paid.
  final int rentReliefBasisPoints;

  /// Section 30(2)(a)(vi): the rent relief cap, N500,000.
  final int rentReliefCapMinor;

  /// Section 56(b): companies income tax for other than small companies.
  final int citBasisPoints;

  /// Section 59(1): development levy on assessable profits.
  final int developmentLevyBasisPoints;

  /// Section 148: VAT on taxable supplies.
  final int vatBasisPoints;

  /// Section 56(a) and the definition of a small company: turnover ceiling.
  final int smallCompanyTurnoverCeilingMinor;

  /// The definition of a small company: fixed asset ceiling.
  final int smallCompanyFixedAssetsCeilingMinor;

  /// NTAA 2025 s.147: the VAT small business turnover ceiling.
  final int vatSmallBusinessTurnoverCeilingMinor;

  /// NTAA 2025 s.147: the VAT small business fixed asset ceiling.
  final int vatSmallBusinessFixedAssetsCeilingMinor;

  /// The gazetted texts these figures were checked against.
  final List<String> sourceUrls;
}

/// The 2026 tables.
///
/// Checked on 4 November 2026 against the official gazette published by the
/// Nigeria Revenue Service and the certified Nigeria Tax Administration Act
/// gazette hosted by the Tax Appeal Tribunal.
const _ngTable2026 = _NgTaxTable(
  // Fourth Schedule to the Nigeria Tax Act 2025 (NTA), "Individuals' income
  // tax rates": First N800,000 at 0%; next N2,200,000 at 15%; next
  // N9,000,000 at 18%; next N13,000,000 at 21%; next N25,000,000 at 23%;
  // above N50,000,000 at 25%.
  bands: [
    TaxBand(
      label: 'First N800,000 at 0%',
      rateBasisPoints: 0,
      ceilingMinor: 80_000_000,
    ),
    TaxBand(
      label: 'Next N2,200,000 at 15%',
      rateBasisPoints: 1500,
      ceilingMinor: 300_000_000,
    ),
    TaxBand(
      label: 'Next N9,000,000 at 18%',
      rateBasisPoints: 1800,
      ceilingMinor: 1_200_000_000,
    ),
    TaxBand(
      label: 'Next N13,000,000 at 21%',
      rateBasisPoints: 2100,
      ceilingMinor: 2_500_000_000,
    ),
    TaxBand(
      label: 'Next N25,000,000 at 23%',
      rateBasisPoints: 2300,
      ceilingMinor: 5_000_000_000,
    ),
    TaxBand(label: 'Above N50,000,000 at 25%', rateBasisPoints: 2500),
  ],
  // NTA section 30(2)(a)(vi): rent relief of 20% of annual rent paid,
  // subject to a maximum of N500,000.
  rentReliefBasisPoints: 2000,
  rentReliefCapMinor: 50_000_000,
  // NTA section 56(b): any company other than a small company pays 30%. The
  // Act allows a Presidential Order, on the advice of the National Economic
  // Council, to reduce the rate to 25%; no such order was in force when these
  // tables were checked.
  citBasisPoints: 3000,
  // NTA section 59(1): 4% of assessable profits, other than small companies
  // and non-resident companies.
  developmentLevyBasisPoints: 400,
  // NTA section 148: VAT at 7.5% of taxable supplies.
  vatBasisPoints: 750,
  // NTA section 56(a) and the definition of a small company: gross turnover
  // of N50,000,000 or less a year with total fixed assets not exceeding
  // N250,000,000, excluding businesses providing professional services.
  smallCompanyTurnoverCeilingMinor: 5_000_000_000,
  smallCompanyFixedAssetsCeilingMinor: 25_000_000_000,
  // NTAA 2025 s.147 defines a small business as one with gross turnover of
  // N100,000,000 or less and fixed assets of not more than N250,000,000,
  // excluding professional services. That is the VAT registration threshold.
  vatSmallBusinessTurnoverCeilingMinor: 10_000_000_000,
  vatSmallBusinessFixedAssetsCeilingMinor: 25_000_000_000,
  sourceUrls: [
    'https://www.nrs.gov.ng/uploads/NIGERIA_TAX_ACT_2025_ef6bb812a5.pdf',
    'https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf',
  ],
);

const _ngTables = <int, _NgTaxTable>{2026: _ngTable2026};

/// The date the tables above were last checked against the gazetted texts.
final DateTime _ngRulesVerifiedOn = DateTime.utc(2026, 11, 4);
