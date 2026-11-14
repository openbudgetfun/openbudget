import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/money_guide/guidance_block.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_index.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';

/// Runs the `search_knowledge` tool for [entity] and returns its result as a
/// map (docs/money-guide.md, section 5.3).
Map<String, Object?> searchKnowledgeResult({
  required Entity entity,
  required Map<String, Object?> args,
}) {
  final query = _optionalString(args, 'query') ?? '';
  final ids = _stringList(args, 'ids');
  final countryArg = _optionalString(args, 'country');
  final taxYearArg = _optionalInt(args, 'taxYear');

  final entityCountry = entity.countryCode.toUpperCase();
  final requestedCountry = (countryArg ?? entity.countryCode).toUpperCase();
  final crossBorder = requestedCountry != entityCountry;

  int year;
  if (taxYearArg != null) {
    year = taxYearArg;
  } else {
    // The clock seam is the only way to honour a pinned now in search_knowledge.
    // ignore: invalid_use_of_visible_for_testing_member
    final now = TaxSummaryService.clock();
    year = TaxSummaryService.startYearFor(entity, now: now);
  }

  // Cards read by id are not subject to the BM25 filters, so a card listed
  // in the entity brief can always be opened.
  final collected = <String, KnowledgeCard>{};
  for (final id in ids.take(4)) {
    final card = _knowledgeCardsById[id];
    if (card != null) {
      collected[id] = card;
    }
  }

  if (query.trim().isNotEmpty) {
    final hits = KnowledgeIndex.shipped.search(
      query: query,
      country: requestedCountry,
      taxYear: year,
      entityKind: entity.kind,
    );
    for (final hit in hits) {
      collected.putIfAbsent(hit.card.id, () => hit.card);
      if (collected.length >= 4) break;
    }
  }

  final cards = <Map<String, Object?>>[];
  for (final card in collected.values.take(4)) {
    cards.add(_cardJson(card, year));
  }

  final block = buildGuidanceBlock(
    entity: entity,
    rulesVersion: _rulesVersionFor(entity, year),
    crossBorder: crossBorder,
  );

  return {
    'cards': cards,
    'guidance': block,
  };
}

Map<String, Object?> _cardJson(KnowledgeCard card, int year) {
  final body = card.isUniversal ? card.body : resolveCardBody(card, year);
  return {
    'id': card.id,
    'citeAs': card.citeAs,
    'title': card.title,
    'grade': card.grade.name,
    'verifiedOn': card.verifiedOn.toIso8601String().split('T').first,
    'perimeter': card.perimeter.name,
    'needsEvidence': card.needsEvidence,
    'announced': card.announced,
    'body': body,
    'sources': [
      for (final source in card.sources)
        {
          'title': source.title,
          'url': source.url.toString(),
          'grade': source.grade.name,
        },
    ],
  };
}

String? _rulesVersionFor(Entity entity, int year) {
  final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
  if (jurisdiction == null) return null;
  final pack = TaxRules.forJurisdiction(jurisdiction);
  if (!pack.supportedStartYears.contains(year)) return null;
  return pack.ruleSet(year).versionFor(jurisdiction);
}

String? _optionalString(Map<String, Object?> args, String key) {
  final value = args[key];
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return null;
}

int? _optionalInt(Map<String, Object?> args, String key) {
  final value = args[key];
  if (value == null) return null;
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  return null;
}

List<String> _stringList(Map<String, Object?> args, String key) {
  final value = args[key];
  if (value == null) return const [];
  if (value is List) {
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const [];
}

final Map<String, KnowledgeCard> _knowledgeCardsById = <String, KnowledgeCard>{
  for (final card in knowledgeCards) card.id: card,
};
