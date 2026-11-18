import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_profile.dart';

/// Whether a self-employed person's profit is gewerblich (§ 15 EStG,
/// Anlage G, trade tax with the § 35 credit) or freiberuflich (§ 18 EStG,
/// Anlage S, no trade tax).
enum DeEinkunftsArt {
  /// Freie Berufe: no Gewerbesteuer, filed on Anlage S.
  freiberuflich,

  /// Gewerbebetrieb: Gewerbesteuer and the § 35 EStG credit, Anlage G.
  gewerblich,
}

/// The sixteen Länder. Church tax is state and church law, so the rate
/// follows the Land: 8 % in Bayern and Baden-Württemberg, 9 % everywhere
/// else.
enum DeBundesland {
  badenWuerttemberg('Baden-Württemberg'),
  bayern('Bayern'),
  berlin('Berlin'),
  brandenburg('Brandenburg'),
  bremen('Bremen'),
  hamburg('Hamburg'),
  hessen('Hessen'),
  mecklenburgVorpommern('Mecklenburg-Vorpommern'),
  niedersachsen('Niedersachsen'),
  nordrheinWestfalen('Nordrhein-Westfalen'),
  rheinlandPfalz('Rheinland-Pfalz'),
  saarland('Saarland'),
  sachsen('Sachsen'),
  sachsenAnhalt('Sachsen-Anhalt'),
  schleswigHolstein('Schleswig-Holstein'),
  thueringen('Thüringen');

  const DeBundesland(this.label);

  /// The name the Land uses for itself.
  final String label;

  /// Kirchensteuer-Hebesatz of the Land (§ 51a Abs. 1 EStG naming the
  /// Grundsteuer of the Kirchen as 8 % or 9 % of the income tax).
  int get churchTaxRateBasisPoints =>
      this == DeBundesland.bayern || this == DeBundesland.badenWuerttemberg
      ? 800
      : 900;
}

/// The facts about a German taxpayer that change how their figures are
/// taxed.
@immutable
final class DeTaxProfile extends TaxProfile {
  const DeTaxProfile({
    required super.entityKind,
    super.salesTaxRegistered,
    super.taxResident,
    super.usPerson,
    this.jointAssessment = false,
    this.churchTax = false,
    this.churchTaxState,
    this.smallBusinessExemption = true,
    this.einkunftsArt = DeEinkunftsArt.gewerblich,
    this.children = 0,
    this.spouseEmployed = false,
    this.statutoryPensionMinor = 0,
    this.previousYearTurnoverMinor = 0,
    this.commuteKmOneWay = 0,
    this.commuteDays = 0,
  });

  @override
  TaxJurisdiction get jurisdiction => TaxJurisdiction.de;

  /// Zusammenveranlagung: spouses assessed jointly under the splitting
  /// method.
  final bool jointAssessment;

  /// Whether the taxpayer belongs to a church that levies Kirchensteuer.
  ///
  /// The rate itself comes from [churchTaxState]. A profile parsed from old
  /// JSON carries only this flag; the pack then assumes the 9 % the old
  /// behaviour assumed.
  final bool churchTax;

  /// The Land whose Kirchensteuer rate applies. Null when the taxpayer has
  /// not named it, in which case [churchTax] alone triggers the 9 %
  /// assumption.
  final DeBundesland? churchTaxState;

  /// The Kirchensteuer rate this profile triggers, in basis points: the
  /// Land's rate when named, the old 9 % assumption for the bare flag, zero
  /// otherwise.
  int get churchTaxRateBasisPoints => switch (churchTaxState) {
    final state? => state.churchTaxRateBasisPoints,
    null => churchTax ? 900 : 0,
  };

  /// Kleinunternehmerregelung (§ 19 UStG): no VAT charged or reclaimed.
  final bool smallBusinessExemption;

  /// For a sole trader: whether the profit is gewerblich or freiberuflich.
  /// Defaults to gewerblich, what the pack assumed before the field existed.
  final DeEinkunftsArt einkunftsArt;

  /// Children the taxpayer receives Kindergeld for. The pack assumes a full
  /// twelve months per child.
  final int children;

  /// Zusammenveranlagung only: the second spouse also earns wages, so they
  /// claim their own Arbeitnehmer-Pauschbetrag and file their own Anlage N.
  final bool spouseEmployed;

  /// Contributions to the gesetzliche Rentenversicherung, employee and
  /// employer share combined. They reduce the Basisrente headroom of
  /// § 10 Abs. 3 EStG.
  final int statutoryPensionMinor;

  /// Gesamtumsatz of the previous calendar year, for the Kleinunternehmer
  /// test of § 19 Abs. 1 Satz 1 UStG. Zero when the business did not exist.
  final int previousYearTurnoverMinor;

  /// Anlage N: one-way distance in full kilometres to the first workplace,
  /// shortest road connection.
  final int commuteKmOneWay;

  /// Anlage N: days the workplace was visited. Days of illness, holiday,
  /// Dienstreise or Heimarbeit do not count.
  final int commuteDays;

  @override
  Map<String, Object?> toJson() => {
    ...baseJson(),
    'jointAssessment': jointAssessment,
    'churchTax': churchTax,
    'churchTaxState': ?churchTaxState?.name,
    'smallBusinessExemption': smallBusinessExemption,
    'einkunftsArt': einkunftsArt.name,
    'children': children,
    'spouseEmployed': spouseEmployed,
    'statutoryPensionMinor': statutoryPensionMinor,
    'previousYearTurnoverMinor': previousYearTurnoverMinor,
    'commuteKmOneWay': commuteKmOneWay,
    'commuteDays': commuteDays,
  };
}

/// Decodes a DE profile.
DeTaxProfile deProfileFromJson(Map<String, Object?> json) {
  final common = taxProfileCommonJson(json);
  return DeTaxProfile(
    entityKind: common.entityKind,
    salesTaxRegistered: common.salesTaxRegistered,
    taxResident: common.taxResident,
    usPerson: common.usPerson,
    jointAssessment: taxProfileField<bool>(json, 'jointAssessment') ?? false,
    churchTax: taxProfileField<bool>(json, 'churchTax') ?? false,
    // Old JSON stored only the flag; the flag alone keeps the 9 %
    // assumption the old pack computed with.
    churchTaxState: taxProfileEnumField(
      json,
      'churchTaxState',
      DeBundesland.values,
    ),
    smallBusinessExemption:
        taxProfileField<bool>(json, 'smallBusinessExemption') ?? true,
    // Old JSON had no Einkunftsart and the pack treated every sole
    // trader as a Gewerbebetrieb.
    einkunftsArt:
        taxProfileEnumField(json, 'einkunftsArt', DeEinkunftsArt.values) ??
        DeEinkunftsArt.gewerblich,
    children: taxProfileNonNegativeInt(json, 'children') ?? 0,
    spouseEmployed: taxProfileField<bool>(json, 'spouseEmployed') ?? false,
    statutoryPensionMinor:
        taxProfileNonNegativeInt(json, 'statutoryPensionMinor') ?? 0,
    previousYearTurnoverMinor:
        taxProfileNonNegativeInt(json, 'previousYearTurnoverMinor') ?? 0,
    commuteKmOneWay: taxProfileNonNegativeInt(json, 'commuteKmOneWay') ?? 0,
    commuteDays: taxProfileNonNegativeInt(json, 'commuteDays') ?? 0,
  );
}

/// The questions the DE pack asks after [commonTaxProfileQuestions], in
/// form order.
const deTaxProfileQuestions = <TaxProfileQuestion>[
  TaxBoolQuestion(
    key: 'jointAssessment',
    labelKey: 'taxQDeJointAssessment',
    helpKey: 'taxQDeJointAssessmentHelp',
  ),
  TaxBoolQuestion(
    key: 'spouseEmployed',
    labelKey: 'taxQDeSpouseEmployed',
    helpKey: 'taxQDeSpouseEmployedHelp',
    appliesTo: {EntityKind.individual},
    visibleWhen: TaxProfileCondition('jointAssessment', {'true'}),
  ),
  TaxBoolQuestion(
    key: 'churchTax',
    labelKey: 'taxQDeChurchTax',
    helpKey: 'taxQDeChurchTaxHelp',
  ),
  TaxChoiceQuestion(
    key: 'churchTaxState',
    labelKey: 'taxQDeChurchState',
    helpKey: 'taxQDeChurchStateHelp',
    options: [
      TaxChoiceOption(
        value: 'badenWuerttemberg',
        labelKey: 'taxQDeChurchStateBadenWuerttemberg',
      ),
      TaxChoiceOption(value: 'bayern', labelKey: 'taxQDeChurchStateBayern'),
      TaxChoiceOption(value: 'berlin', labelKey: 'taxQDeChurchStateBerlin'),
      TaxChoiceOption(
        value: 'brandenburg',
        labelKey: 'taxQDeChurchStateBrandenburg',
      ),
      TaxChoiceOption(value: 'bremen', labelKey: 'taxQDeChurchStateBremen'),
      TaxChoiceOption(value: 'hamburg', labelKey: 'taxQDeChurchStateHamburg'),
      TaxChoiceOption(value: 'hessen', labelKey: 'taxQDeChurchStateHessen'),
      TaxChoiceOption(
        value: 'mecklenburgVorpommern',
        labelKey: 'taxQDeChurchStateMecklenburgVorpommern',
      ),
      TaxChoiceOption(
        value: 'niedersachsen',
        labelKey: 'taxQDeChurchStateNiedersachsen',
      ),
      TaxChoiceOption(
        value: 'nordrheinWestfalen',
        labelKey: 'taxQDeChurchStateNordrheinWestfalen',
      ),
      TaxChoiceOption(
        value: 'rheinlandPfalz',
        labelKey: 'taxQDeChurchStateRheinlandPfalz',
      ),
      TaxChoiceOption(value: 'saarland', labelKey: 'taxQDeChurchStateSaarland'),
      TaxChoiceOption(value: 'sachsen', labelKey: 'taxQDeChurchStateSachsen'),
      TaxChoiceOption(
        value: 'sachsenAnhalt',
        labelKey: 'taxQDeChurchStateSachsenAnhalt',
      ),
      TaxChoiceOption(
        value: 'schleswigHolstein',
        labelKey: 'taxQDeChurchStateSchleswigHolstein',
      ),
      TaxChoiceOption(
        value: 'thueringen',
        labelKey: 'taxQDeChurchStateThueringen',
      ),
    ],
    noneLabelKey: 'taxQDeChurchStateNone',
    visibleWhen: TaxProfileCondition('churchTax', {'true'}),
  ),
  TaxChoiceQuestion(
    key: 'einkunftsArt',
    labelKey: 'taxQDeEinkunftsArt',
    helpKey: 'taxQDeEinkunftsArtHelp',
    options: [
      TaxChoiceOption(
        value: 'freiberuflich',
        labelKey: 'taxQDeEinkunftsArtFreiberuflich',
      ),
      TaxChoiceOption(
        value: 'gewerblich',
        labelKey: 'taxQDeEinkunftsArtGewerblich',
      ),
    ],
    appliesTo: {EntityKind.soleTrader},
  ),
  TaxCountQuestion(
    key: 'children',
    labelKey: 'taxQDeChildren',
    helpKey: 'taxQDeChildrenHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxMoneyQuestion(
    key: 'statutoryPensionMinor',
    labelKey: 'taxQDeStatutoryPension',
    helpKey: 'taxQDeStatutoryPensionHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxCountQuestion(
    key: 'commuteKmOneWay',
    labelKey: 'taxQDeCommuteKm',
    helpKey: 'taxQDeCommuteKmHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxCountQuestion(
    key: 'commuteDays',
    labelKey: 'taxQDeCommuteDays',
    helpKey: 'taxQDeCommuteDaysHelp',
    appliesTo: {EntityKind.individual},
  ),
  TaxMoneyQuestion(
    key: 'previousYearTurnoverMinor',
    labelKey: 'taxQDePriorTurnover',
    helpKey: 'taxQDePriorTurnoverHelp',
    appliesTo: {EntityKind.soleTrader, EntityKind.company},
  ),
  TaxBoolQuestion(
    key: 'smallBusinessExemption',
    labelKey: 'taxQDeSmallBusinessExemption',
    helpKey: 'taxQDeSmallBusinessExemptionHelp',
  ),
];
