import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/money_guide/guidance_block.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_index.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';

/// A rough token count for [text]: its characters divided by four, rounded
/// up (docs/money-guide.md, section 9.3).
///
/// The budgets in the design are estimates, so the server carries no
/// tokenizer dependency.
int estimateTokens(String text) => (text.length / 4).ceil();

/// The Money guide's instructions, kept in one place
/// (docs/money-guide.md, section 7).
///
/// A model call starts with two system messages: [staticRules], identical
/// for every user and entity so the provider's prompt cache is shared, and
/// then [brief], generated per entity. Nothing here identifies the user:
/// the brief carries no entity name, no account and no identifier, and only
/// the conversation and tool results ever leave the server besides it.
abstract final class MoneyGuidePrompt {
  /// The rules of docs/money-guide.md, section 7.2.
  ///
  /// The guardrails come from the `tax-planning-guardrails` skill: wording,
  /// the never-suggest list, the perimeter, signpost triggers and user
  /// approval. This text never varies per entity; the brief carries the
  /// country, the jurisdiction state and the professional to name.
  static const String staticRules = '''
You are the Money guide in OpenBudget. You help one person understand their
money: their envelope plan, their taxes, their crypto, and how the rules where
they live work. You give guidance, not regulated financial, tax, legal or
investment advice. Do not call yourself an adviser.

Facts
- Facts about the person's money come only from tools. Never guess a balance,
  amount, category or date that a tool can answer.
- Facts about rules (laws, rates, thresholds, allowances, deadlines,
  regulation) come only from search_knowledge cards and tax tool results.
  Call search_knowledge before stating any rule. If nothing you were given
  covers it, say you have no checked source for it.
- Cite every rule and every figure with the key from the result, as [^key].
- Amounts are integer minor units with a currency code. Quote them in the
  currency's normal format.

How far you may go: read the jurisdiction line in the brief
- The sections line gives the state of each part of the tax system. Use the
  state of the section the question is about.
- full: explain the rules and the person's figures.
- preview: the same, and say once that these figures are a preview.
- universal: give no income-tax or company-tax rates, allowances, deadlines
  or computed figures for this country beyond the brief. Offer budgeting
  help, the tax summary, the export and a local professional.
- When a card or figure is secondary or inferred, say so. Call an announced
  rule "announced, not yet law" and never use it in arithmetic.

Tax, investments and crypto
- Describe what the law allows and what the figures show. Do not tell the
  person what to do: avoid "you should", "best", "optimal", "we recommend"
  and "guaranteed".
- Show the arithmetic for any saving and what it assumes.
- Say once that this is guidance, not advice, when you discuss tax or
  investments. The app adds the country's full disclaimer.
- Never pick, rank or name products, providers, funds, securities, tokens,
  exchanges or wallets to use. Never suggest allocation, trade timing,
  withdrawal rates, or buying, selling, holding, staking or swapping any
  asset. Never say what people like them usually do.
- Decline anything on the never-suggest list once, plainly, and say why. The
  list: marketed or contrived avoidance schemes; income splitting without
  genuine work or capital; disguised employment; below-market pay to an
  owner of a company; wash sales and round-trip gifts; hiding income,
  accounts or residence; falsified or backdated records; moving money or
  residence only for a tax result; personal costs recorded as business
  costs; repeated company loans to avoid dividend tax.
- Before discussing a relief, make sure the brief says where the person is
  tax resident and whether they are a US person. If either is not recorded,
  ask.
- For reliefs that need evidence, ask for the evidence, not only the number.
- Point to the professional named in the brief when: residence is unclear or
  changed this year; there is income in more than one country; the question
  is about company structure, shares, holdings or loans to or from a
  company; it is a "should I" question about a specific investment or
  asset; a letter, penalty, investigation, late or amended return is
  involved; trusts, inheritance, large gifts, divorce or bankruptcy are
  involved; the person wants to act on a rule that is secondary, inferred or
  announced; or the card is signpost-only.

Budgeting
- For the envelope plan you may suggest options plainly. When a move would
  help, call propose_move_money and say what you proposed.

Changes
- You cannot change anything. Propose tools create suggestions the person
  applies or dismisses. Never claim a change was made.

Style
- Reply in the language of the person's message. Lead with the answer, then
  the figures, then what it assumes. Be brief.
''';

  /// The entity brief for [entity] at [now]: its country, kind, currency and
  /// tax year, the jurisdiction state per section, the perimeter and
  /// professional, and the index of knowledge cards the model may read by id
  /// (docs/money-guide.md, sections 5.4 and 7.1).
  ///
  /// [taxResident] and [usPerson] are the answers recorded on the entity's
  /// tax profile; a profile stores nothing for a false answer, so false
  /// reads "not recorded" and the model asks. [index] defaults to the
  /// shipped cards. Pass the time as [now] so a test can pin it.
  static String brief({
    required Entity entity,
    required DateTime now,
    bool taxResident = false,
    bool usPerson = false,
    KnowledgeIndex? index,
  }) {
    final country = entity.countryCode.toUpperCase();
    final jurisdiction = TaxJurisdiction.fromCountryCode(country);
    final period = TaxSummaryService.currentPeriodFor(entity, now: now);
    final perimeter = jurisdiction == null
        ? null
        : guidancePerimeterFor(jurisdiction);
    final guidance = buildGuidanceBlock(
      entity: entity,
      rulesVersion: rulesVersionFor(entity, period.startYear),
    );
    final cards = (index ?? KnowledgeIndex.shipped).cardsFor(
      country: country,
      taxYear: period.startYear,
      entityKind: entity.kind,
    );
    final countryCards = <KnowledgeCard>[
      for (final card in cards)
        if (card.countryCode == country) card,
    ];
    final universalCards = <KnowledgeCard>[
      for (final card in cards)
        if (card.isUniversal) card,
    ];

    final reserved = perimeter?.signpostOnlyTopics
        .map((topic) => topic.title)
        .join('; ');
    final lines = <String>[
      _entityLine(entity, country),
      _taxYearLine(period),
      _jurisdictionLine(guidance, country),
      _sectionsLine(jurisdiction),
      _profileLine(country, taxResident: taxResident, usPerson: usPerson),
      _perimeterLine(country, reserved),
      _signpostLine(guidance),
      'Disclaimer key: ${guidance['disclaimerKey'] ?? 'none'}.',
      ..._indirectTaxLines(country, now),
      ..._cardLines('Cards for $country', countryCards),
      ..._cardLines('Universal cards', universalCards),
    ];
    return lines.join('\n');
  }

  /// The system messages that open every model call: the static rules, then
  /// the entity brief (docs/money-guide.md, section 7.1). The static part
  /// comes first so the longest prefix is shared and cached.
  static List<Map<String, Object?>> systemMessages(String brief) => [
    {'role': 'system', 'content': staticRules},
    {'role': 'system', 'content': brief},
  ];
}

String _entityLine(Entity entity, String country) =>
    'Entity: ${_kindLabel(entity.kind)} in $country, base currency '
    '${entity.baseCurrencyCode}, time zone ${entity.timeZone}.';

String _taxYearLine(
  ({int startYear, String label, DateTime start, DateTime lastDay}) period,
) =>
    'Tax year now: ${period.label}, ${_isoDate(period.start)} to '
    '${_isoDate(period.lastDay)}.';

String _profileLine(
  String country, {
  required bool taxResident,
  required bool usPerson,
}) =>
    'Profile: tax resident of $country ${_recorded(taxResident)}; '
    'US person ${_recorded(usPerson)}.';

String _perimeterLine(String country, String? reserved) => reserved == null
    ? 'Perimeter: general guidance only. No tax rules for $country beyond '
          'this brief.'
    : 'Perimeter: tax illustration. Reserved, so explain in general and '
          'signpost: $reserved.';

String _signpostLine(Map<String, Object?> guidance) {
  final professional =
      guidance['professional'] ?? 'a qualified local tax professional';
  return 'Signpost to: $professional.';
}

String _kindLabel(EntityKind kind) => switch (kind) {
  EntityKind.individual => 'individual',
  EntityKind.soleTrader => 'sole trader',
  EntityKind.company => 'company',
};

String _recorded(bool answer) => answer ? 'yes' : 'not recorded';

String _isoDate(DateTime date) => date.toIso8601String().split('T').first;

String _jurisdictionLine(Map<String, Object?> guidance, String country) {
  final state = guidance['jurisdictionState'];
  final rules = guidance['rulesVersion'];
  if (state == 'universal') {
    return 'Jurisdiction: universal, no rule pack for $country.';
  }
  return 'Jurisdiction: $state${rules == null ? '' : ', rules $rules'}.';
}

/// The state of each section: `full` only for a reviewed pack's full
/// section, `preview` for a preview pack or a partial section, `universal`
/// when the pack does not compute the section (docs/money-guide.md,
/// section 7.3).
String _sectionsLine(TaxJurisdiction? jurisdiction) {
  if (jurisdiction == null) {
    return 'Sections: every section universal.';
  }
  final manifest = TaxRules.forJurisdiction(jurisdiction).manifest;
  final states = <String>[
    for (final section in TaxSection.values)
      '${_sectionLabels[section]} ${_sectionState(manifest, section)}',
  ];
  return 'Sections: ${states.join('; ')}.';
}

String _sectionState(TaxPackManifest manifest, TaxSection section) =>
    switch (manifest.coverageOf(section)) {
      TaxSectionCoverage.full =>
        manifest.maturity == TaxPackMaturity.reviewed ? 'full' : 'preview',
      TaxSectionCoverage.partial => 'preview',
      TaxSectionCoverage.signpostOnly ||
      TaxSectionCoverage.notBuilt => 'universal',
      TaxSectionCoverage.notApplicable => 'not applicable',
    };

const Map<TaxSection, String> _sectionLabels = {
  TaxSection.personalReturn: 'personal income tax',
  TaxSection.selfEmployment: 'self-employment',
  TaxSection.companyReturn: 'company tax',
  TaxSection.indirectTax: 'VAT or sales tax',
  TaxSection.capitalGains: 'capital gains',
  TaxSection.digitalAssets: 'digital assets',
  TaxSection.filingCalendar: 'filing calendar',
  TaxSection.payroll: 'payroll',
};

/// For a country without a pack: the tax authority and the indirect-tax
/// rates in force at [now], each with its source grade, the only country
/// figures the guide may state there (docs/money-guide.md, section 7.3).
List<String> _indirectTaxLines(String country, DateTime now) {
  if (TaxJurisdiction.fromCountryCode(country) != null) {
    return const [];
  }
  final info = Countries.byCode(country);
  if (info == null) {
    return const [];
  }
  final today = DateTime.utc(now.year, now.month, now.day);
  final indirectTax = info.indirectTax;
  final rates = <String>[
    if (indirectTax != null)
      for (final rate in indirectTax.rates)
        if (!rate.from.isAfter(today) &&
            (rate.to == null || rate.to!.isAfter(today)))
          _rateText(rate, info.sources[rate.source].grade),
  ];
  final name = indirectTax?.localName ?? indirectTax?.kind.name;
  return [
    if (info.authority case final authority?)
      'Tax authority: ${authority.name}.',
    if (rates.isNotEmpty) 'Indirect tax now: $name ${rates.join(', ')}.',
  ];
}

String _rateText(IndirectTaxRate rate, SourceGrade grade) =>
    '${rate.label} ${_percent(rate.ratePerMillion)} (grade ${grade.name})';

/// [perMillion] as a percentage without trailing zeros: 160000 is `16%`.
String _percent(int perMillion) {
  final whole = perMillion ~/ 10000;
  final fraction = (perMillion % 10000).toString().padLeft(4, '0');
  final trimmed = fraction.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.isEmpty ? '$whole%' : '$whole.$trimmed%';
}

List<String> _cardLines(String heading, List<KnowledgeCard> cards) => [
  if (cards.isEmpty)
    '$heading: none.'
  else ...[
    '$heading (id: title):',
    for (final card in cards) '- ${card.id}: ${card.title}',
  ],
];
