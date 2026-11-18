import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// How far guidance may go on one topic in one country.
enum GuidanceBoundary {
  /// Explain the rule and compute the user's own figures: a tax
  /// illustration. Never pick products or tell the user what to do.
  taxIllustration,

  /// Explain the general rule and point to a professional. Compute nothing
  /// for the user's own case.
  signpostOnly,
}

/// One topic a country's rules reserve to licensed professionals, and how
/// OpenBudget treats it.
///
/// From the `tax-planning-guardrails` skill's regulatory-boundary
/// reference; the design rules are inference pending review by counsel in
/// each jurisdiction.
@immutable
final class GuidanceReservedTopic {
  const GuidanceReservedTopic({
    required this.id,
    required this.title,
    required this.boundary,
    required this.note,
  });

  /// Stable identifier, prefixed by country: `gb.targeted-support`.
  final String id;

  /// The reserved activity in one line.
  final String title;

  /// How OpenBudget answers questions on this topic.
  final GuidanceBoundary boundary;

  /// Why the topic is reserved, citing the rule that reserves it.
  final String note;
}

/// The regulatory perimeter of one country: what guidance may say, which
/// topics it must not cross, who it signposts to, and which disclaimer
/// travels with it (money-guide section 7.4, rule 5).
@immutable
final class GuidancePerimeter {
  const GuidancePerimeter({
    required this.jurisdiction,
    required this.disclaimerKey,
    required this.scopeStatement,
    required this.professional,
    required this.reservedTopics,
  });

  final TaxJurisdiction jurisdiction;

  /// The key of this country's disclaimer: `gb`, `us`, `de` or `ng`.
  final String disclaimerKey;

  /// The plain sentence stating what the guide does and does not do.
  final String scopeStatement;

  /// Who the guide signposts to, phrased for a sentence: "an authorised
  /// financial adviser or MoneyHelper".
  final String professional;

  /// Topics this country reserves, each with the boundary it gets.
  final List<GuidanceReservedTopic> reservedTopics;

  /// The reserved topic with [id], or null when the perimeter does not
  /// name it.
  GuidanceReservedTopic? topic(String id) {
    for (final reserved in reservedTopics) {
      if (reserved.id == id) {
        return reserved;
      }
    }
    return null;
  }

  /// Every topic this perimeter treats as signpost-only.
  Iterable<GuidanceReservedTopic> get signpostOnlyTopics => reservedTopics
      .where((topic) => topic.boundary == GuidanceBoundary.signpostOnly);
}

/// The perimeter of [jurisdiction], or null when no pack serves it.
GuidancePerimeter? guidancePerimeterFor(TaxJurisdiction jurisdiction) =>
    _perimeters[jurisdiction];

final Map<TaxJurisdiction, GuidancePerimeter> _perimeters = Map.unmodifiable({
  TaxJurisdiction.gb: gbPerimeter,
  TaxJurisdiction.us: usPerimeter,
  TaxJurisdiction.de: dePerimeter,
  TaxJurisdiction.ng: ngPerimeter,
});

/// United Kingdom: tax illustrations are not themselves regulated, but
/// personal recommendations on investments and pensions are, and the FCA
/// targeted support regime (COBS 9B, in force 6 April 2026) covers
/// suggestions to groups of customers with common characteristics.
const gbPerimeter = GuidancePerimeter(
  jurisdiction: TaxJurisdiction.gb,
  disclaimerKey: 'gb',
  scopeStatement:
      'I can show what the rules allow and what your figures show; I cannot '
      'choose investment, pension or ISA products, or decide for you.',
  professional: 'an authorised financial adviser or MoneyHelper',
  reservedTopics: [
    GuidanceReservedTopic(
      id: 'gb.investment-recommendation',
      title: 'Personal recommendations on investments and pensions',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'Recommending a specific investment, ISA product, fund, pension '
          'provider, transfer or withdrawal rate is regulated advice; say '
          'what the law allows instead and signpost.',
    ),
    GuidanceReservedTopic(
      id: 'gb.targeted-support',
      title: 'Statements about what "people like you" do',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'Suggestions aimed at groups of customers with common '
          'characteristics are the FCA targeted support activity (COBS 9B, '
          'in force 6 April 2026) and need a permission OpenBudget does not '
          'hold.',
    ),
  ],
);

/// United States: keep output impersonal in kind — same inputs, same
/// output, rule-based — and never select securities, allocation or timing.
const usPerimeter = GuidancePerimeter(
  jurisdiction: TaxJurisdiction.us,
  disclaimerKey: 'us',
  scopeStatement:
      'I can show what the rules allow and what your figures show; I cannot '
      'pick securities, allocations or timing, or decide for you.',
  professional: 'a tax professional such as a CPA, enrolled agent or attorney',
  reservedTopics: [
    GuidanceReservedTopic(
      id: 'us.investment-selection',
      title: 'Security selection, allocation and trade timing',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'Individualised buy, sell or hold advice, including tax-loss '
          'harvesting on named securities, risks crossing into investment '
          'advice; describe the rule and the recorded net gains instead.',
    ),
  ],
);

/// Germany: general information, calculators and standardised workflows are
/// the safe zone; Einzelfall advice (Steuerberatung) is reserved under
/// StBerG §5.
const dePerimeter = GuidancePerimeter(
  jurisdiction: TaxJurisdiction.de,
  disclaimerKey: 'de',
  scopeStatement:
      'Ich kann zeigen, was die Gesetze erlauben und was Ihre erfassten '
      'Zahlen ergeben; keine Steuerberatung im Einzelfall und keine '
      'Entscheidung für Sie.',
  professional: 'ein Steuerberater oder ein Lohnsteuerhilfeverein',
  reservedTopics: [
    GuidanceReservedTopic(
      id: 'de.individual-case-advice',
      title: 'Einzelfallbezogene Steuerberatung',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'Handlungsempfehlungen für den Einzelfall sind unter StBerG §5 '
          'vorbehalten; allgemeine Information, Rechner und Standardabläufe '
          'bleiben erlaubt.',
    ),
    GuidanceReservedTopic(
      id: 'de.gmbh-owner-structures',
      title: 'GmbH, Holding und Gehalt-versus-Ausschüttung',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'Vergleiche von Geschäftsführergehalt und Ausschüttung, '
          'Gesellschaftsstrukturen und Beteiligungen sind signpost-only; '
          'unter Markt liegende Gehälter riskieren eine verdeckte '
          'Gewinnausschüttung.',
    ),
  ],
);

/// Nigeria: no regulatory source was found, so the strictest of the other
/// perimeters applies and every answer signposts a registered practitioner.
const ngPerimeter = GuidancePerimeter(
  jurisdiction: TaxJurisdiction.ng,
  disclaimerKey: 'ng',
  scopeStatement:
      'I can show what the rules allow and what your figures show; I cannot '
      'choose products or decide for you.',
  professional: 'a registered tax practitioner',
  reservedTopics: [
    GuidanceReservedTopic(
      id: 'ng.strictest-perimeter',
      title: 'Investment and product selection',
      boundary: GuidanceBoundary.signpostOnly,
      note:
          'No source on the regulation of tax or investment advice in '
          'Nigeria was found, so the strictest perimeter applies: no '
          'product, provider or investment selection.',
    ),
  ],
);
