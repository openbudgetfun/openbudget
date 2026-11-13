part of 'ng_tax_rules.dart';

/// Which body of law a Nigerian year of assessment follows.
///
/// The Nigeria Tax Act 2025 is in force from 1 January 2026 (NTA s.203) and
/// repeals PITA, CITA and the VAT Act (NTA s.196). Income earned in calendar
/// 2025 stays under the repealed laws, so the regime follows the year of the
/// basis period, not the filing year.
enum _NgRegime {
  /// The repealed Personal Income Tax Act, Companies Income Tax Act and
  /// Value Added Tax Act, for income earned in calendar 2025.
  pitaCita,

  /// The Nigeria Tax Act 2025 and Nigeria Tax Administration Act 2025, for
  /// income from 1 January 2026.
  nta,
}

/// The rates that apply to one Nigerian year of assessment.
final class _NgTaxTable {
  const _NgTaxTable({
    required this.regime,
    required this.bands,
    required this.rentReliefBasisPoints,
    required this.rentReliefCapMinor,
    required this.craFloorMinor,
    required this.craPercentBasisPoints,
    required this.craShareBasisPoints,
    required this.minimumTaxBasisPoints,
    required this.citBasisPoints,
    required this.citMediumBasisPoints,
    required this.mediumCompanyTurnoverFloorMinor,
    required this.mediumCompanyTurnoverCeilingMinor,
    required this.developmentLevyBasisPoints,
    required this.tertiaryEducationTaxBasisPoints,
    required this.minimumEtrTurnoverMinor,
    required this.vatBasisPoints,
    required this.smallCompanyTurnoverCeilingMinor,
    required this.smallCompanyTurnoverCeilingAltMinor,
    required this.smallCompanyFixedAssetsCeilingMinor,
    required this.vatSmallBusinessTurnoverCeilingMinor,
    required this.vatSmallBusinessFixedAssetsCeilingMinor,
    required this.sourceUrls,
  });

  /// The body of law this table implements.
  final _NgRegime regime;

  /// Progressive bands, applied to chargeable income.
  ///
  /// NTA regime: the Fourth Schedule to the Nigeria Tax Act 2025. Old
  /// regime: the PITA bands as summarised by secondary sources.
  final List<TaxBand> bands;

  /// NTA s.30(2)(a)(vi): 20% of annual rent paid. Unused under the old
  /// regime, which has no rent relief.
  final int rentReliefBasisPoints;

  /// NTA s.30(2)(a)(vi): the rent relief cap, N500,000.
  final int rentReliefCapMinor;

  /// Old regime (PITA, secondary): the consolidated relief allowance floor,
  /// the higher of N200,000 or 1% of gross income.
  final int craFloorMinor;

  /// Old regime (PITA, secondary): 1% of gross income, compared against
  /// [craFloorMinor].
  final int craPercentBasisPoints;

  /// Old regime (PITA, secondary): a further 20% of gross income added to
  /// the consolidated relief allowance.
  final int craShareBasisPoints;

  /// Old regime (PITA, secondary): minimum tax of 1% of gross income,
  /// payable where it exceeds the progressive tax. Removed from 2026.
  final int minimumTaxBasisPoints;

  /// The companies income tax rate for a company above the medium tier:
  /// NTA s.56(b) 30%; CITA large-company 30% (secondary).
  final int citBasisPoints;

  /// The companies income tax rate between the medium floor and ceiling:
  /// CITA medium-company 20% (secondary). Unused under the NTA, which has
  /// no medium tier.
  final int citMediumBasisPoints;

  /// Old regime (CITA, secondary): turnover at or below this floor is a
  /// small company at 0% (N25,000,000). Unused under the NTA.
  final int mediumCompanyTurnoverFloorMinor;

  /// Old regime (CITA, secondary): turnover at or below this ceiling but
  /// above the floor is a medium company at 20% (N100,000,000). Unused
  /// under the NTA.
  final int mediumCompanyTurnoverCeilingMinor;

  /// NTA s.59: 4% development levy on assessable profits, other than small
  /// and non-resident companies. Unused under the old regime, which charges
  /// TETFund, NASENI and NITDA levies instead.
  final int developmentLevyBasisPoints;

  /// Old regime (CITA as amended, secondary): 3% tertiary education tax on
  /// assessable profits, small companies exempt. Unused under the NTA.
  final int tertiaryEducationTaxBasisPoints;

  /// NTA s.57: the 15% minimum effective tax rate reaches companies with
  /// aggregate turnover of N20,000,000,000 or more (and constituent
  /// entities of multinational groups at any turnover). Zero under the old
  /// regime, which has no minimum effective tax rate.
  final int minimumEtrTurnoverMinor;

  /// VAT on taxable supplies: NTA s.148; 7.5% under the old law as well
  /// (secondary).
  final int vatBasisPoints;

  /// The default small-company turnover ceiling (N50,000,000 under the NTA
  /// gazette, whose section number is unverified; CITA's N25,000,000 in the
  /// old regime). [smallCompanyTurnoverCeilingAltMinor] carries the
  /// alternative NTA-era figure.
  final int smallCompanyTurnoverCeilingMinor;

  /// The alternative NTA-era ceiling (N100,000,000 per the NTAA "small
  /// business" definition, section unverified). Zero under the old regime,
  /// where the two repealed Acts do not conflict.
  final int smallCompanyTurnoverCeilingAltMinor;

  /// The small-company fixed asset ceiling (N250,000,000). Zero under the
  /// old regime, whose secondary sources describe turnover tiers only.
  final int smallCompanyFixedAssetsCeilingMinor;

  /// The VAT small business turnover ceiling: N100,000,000 under the NTAA
  /// "small business" definition (section unverified; NTAA s.22(4)-(5)
  /// governs the return duty); N25,000,000 under the old Value Added Tax
  /// Act registration threshold (secondary).
  final int vatSmallBusinessTurnoverCeilingMinor;

  /// The VAT small business fixed asset ceiling (N250,000,000).
  final int vatSmallBusinessFixedAssetsCeilingMinor;

  /// The texts these figures were checked against. Old-regime entries list
  /// secondary sources: the PITA and CITA texts were not read.
  final List<String> sourceUrls;
}

/// The 2026 tables, under the Nigeria Tax Act 2025.
///
/// Checked on 5 November 2026 against the official gazette published by the
/// Nigeria Revenue Service and the certified Nigeria Tax Administration Act
/// gazette hosted by the Tax Appeal Tribunal.
const _ngTable2026 = _NgTaxTable(
  regime: _NgRegime.nta,
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
  // The old-regime consolidated relief allowance and minimum tax do not
  // exist under the NTA.
  craFloorMinor: 0,
  craPercentBasisPoints: 0,
  craShareBasisPoints: 0,
  minimumTaxBasisPoints: 0,
  // NTA section 56: a small company pays 0% and any other company pays 30%.
  // The gazette text read shows no scheduled reduction to 25%.
  citBasisPoints: 3000,
  // The NTA has no medium-company tier.
  citMediumBasisPoints: 0,
  mediumCompanyTurnoverFloorMinor: 0,
  mediumCompanyTurnoverCeilingMinor: 0,
  // NTA section 59: 4% of assessable profits, other than small companies
  // and non-resident companies.
  developmentLevyBasisPoints: 400,
  // The old tertiary education tax is repealed; the development levy
  // replaces it from 1 January 2026.
  tertiaryEducationTaxBasisPoints: 0,
  // NTA section 57: the 15% minimum effective tax rate applies to
  // constituent entities of MNE groups and to any other company with
  // aggregate turnover of N20,000,000,000 or more.
  minimumEtrTurnoverMinor: 2_000_000_000_000,
  // NTA section 148: VAT at 7.5% of taxable supplies.
  vatBasisPoints: 750,
  // The definition of a small company in the NTA: gross turnover of
  // N50,000,000 or less a year. The definition sits in the interpretation
  // provisions and its section number is unverified in the research.
  smallCompanyTurnoverCeilingMinor: 5_000_000_000,
  // The NTAA "small business" definition instead says gross turnover of
  // N100,000,000 or less. Officials describe the N50,000,000 figure as a
  // gazetting error, but no enacted correction was found as of
  // 5 November 2026, so both values are carried and the user chooses.
  smallCompanyTurnoverCeilingAltMinor: 10_000_000_000,
  // The definition of a small company: total fixed assets not exceeding
  // N250,000,000.
  smallCompanyFixedAssetsCeilingMinor: 25_000_000_000,
  // The NTAA "small business" definition: gross turnover of N100,000,000 or
  // less with fixed assets of not more than N250,000,000, excluding
  // professional services. That is the VAT small business threshold
  // (NTAA s.22(4)-(5)); the definition's own section number is unverified.
  vatSmallBusinessTurnoverCeilingMinor: 10_000_000_000,
  vatSmallBusinessFixedAssetsCeilingMinor: 25_000_000_000,
  sourceUrls: [
    'https://www.nrs.gov.ng/uploads/NIGERIA_TAX_ACT_2025_ef6bb812a5.pdf',
    'https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf',
  ],
);

/// The 2025 tables, under the repealed PITA, CITA and Value Added Tax Act.
///
/// Secondary-sourced (S): the figures come from PwC, KPMG and other
/// summaries because the PITA and CITA texts were not read. Every 2025
/// report carries that quality note in its assumptions.
const _ngTable2025 = _NgTaxTable(
  regime: _NgRegime.pitaCita,
  // PITA progressive bands (secondary: PwC
  // https://taxsummaries.pwc.com/nigeria/individual/significant-developments):
  // first N300,000 at 7%; next N300,000 at 11%; next N500,000 at 15%; next
  // N500,000 at 19%; next N1,600,000 at 21%; above N3,200,000 at 24%.
  bands: [
    TaxBand(
      label: 'First N300,000 at 7%',
      rateBasisPoints: 700,
      ceilingMinor: 30_000_000,
    ),
    TaxBand(
      label: 'Next N300,000 at 11%',
      rateBasisPoints: 1100,
      ceilingMinor: 60_000_000,
    ),
    TaxBand(
      label: 'Next N500,000 at 15%',
      rateBasisPoints: 1500,
      ceilingMinor: 110_000_000,
    ),
    TaxBand(
      label: 'Next N500,000 at 19%',
      rateBasisPoints: 1900,
      ceilingMinor: 160_000_000,
    ),
    TaxBand(
      label: 'Next N1,600,000 at 21%',
      rateBasisPoints: 2100,
      ceilingMinor: 320_000_000,
    ),
    TaxBand(label: 'Above N3,200,000 at 24%', rateBasisPoints: 2400),
  ],
  // PITA has no rent relief; that relief is introduced by NTA s.30(2)(a)(vi)
  // from 2026.
  rentReliefBasisPoints: 0,
  rentReliefCapMinor: 0,
  // PITA consolidated relief allowance (secondary): the higher of N200,000
  // or 1% of gross income, plus 20% of gross income.
  craFloorMinor: 20_000_000,
  craPercentBasisPoints: 100,
  craShareBasisPoints: 2000,
  // PITA minimum tax (secondary): 1% of gross income, payable where it
  // exceeds the progressive tax. A claimed "N30,000 a month" minimum tax
  // conflicts with the sources and is not used.
  minimumTaxBasisPoints: 100,
  // CITA as amended (secondary): large companies at 30%.
  citBasisPoints: 3000,
  // CITA as amended (secondary): medium companies (turnover above N25m and
  // at or below N100m) at 20%.
  citMediumBasisPoints: 2000,
  mediumCompanyTurnoverFloorMinor: 2_500_000_000,
  mediumCompanyTurnoverCeilingMinor: 10_000_000_000,
  // The NTA development levy starts in 2026; the 2025 levies (TETFund,
  // NASENI, NITDA) are replaced here by the tertiary education tax.
  developmentLevyBasisPoints: 0,
  // CITA as amended (secondary): 3% tertiary education tax on assessable
  // profits, small companies exempt.
  tertiaryEducationTaxBasisPoints: 300,
  // No minimum effective tax rate under the old law.
  minimumEtrTurnoverMinor: 0,
  // VAT stayed at 7.5% under the old law (secondary).
  vatBasisPoints: 750,
  // CITA small company (secondary): gross turnover up to N25,000,000. The
  // 2025 computation uses the medium tier fields directly; this value is
  // carried for reference.
  smallCompanyTurnoverCeilingMinor: 2_500_000_000,
  // The two repealed Acts do not conflict, so there is no alternative
  // ceiling and no fixed asset ceiling in the secondary sources.
  smallCompanyTurnoverCeilingAltMinor: 0,
  smallCompanyFixedAssetsCeilingMinor: 0,
  // Old Value Added Tax Act registration threshold (secondary): gross
  // turnover of N25,000,000 or less with fixed assets of not more than
  // N250,000,000.
  vatSmallBusinessTurnoverCeilingMinor: 2_500_000_000,
  vatSmallBusinessFixedAssetsCeilingMinor: 25_000_000_000,
  sourceUrls: [
    // Secondary sources; the PITA and CITA texts were not read.
    'https://taxsummaries.pwc.com/nigeria/individual/significant-developments',
    'https://assets.kpmg.com/content/dam/kpmg/ng/pdf/clarification-on-the-exemption-of-small-companies-from-income-tax.pdf',
    'https://www.commenda.io/nigeria/corporate-tax-rates',
  ],
);

const _ngTables = <int, _NgTaxTable>{2025: _ngTable2025, 2026: _ngTable2026};

/// The date the tables above were last checked against the gazetted texts
/// and the cited secondary sources.
final DateTime _ngRulesVerifiedOn = DateTime.utc(2026, 11, 5);

/// The version, sources and verification date of each supported year.
final Map<int, TaxRuleSet> _ngRuleSetsByStartYear = Map.unmodifiable({
  for (final entry in _ngTables.entries)
    entry.key: TaxRuleSet(
      startYear: entry.key,
      revision: 1,
      verifiedOn: _ngRulesVerifiedOn,
      sources: [
        for (final url in entry.value.sourceUrls) Uri.parse(url),
      ],
    ),
});
