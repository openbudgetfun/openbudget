import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/money_guide/guidance_block.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_index.dart';

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

  final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
  final pack = jurisdiction == null
      ? null
      : TaxRules.forJurisdiction(jurisdiction);

  int year;
  if (taxYearArg != null) {
    year = taxYearArg;
  } else if (pack != null) {
    year = pack.taxYearFor(EntityClock.today(entity)).startYear;
  } else {
    final country = Countries.byCode(entity.countryCode);
    final individualTaxYear = entity.kind == EntityKind.company
        ? null
        : country?.individualTaxYear;
    if (individualTaxYear != null) {
      year = _yearContaining(DateTime.now().toUtc(), individualTaxYear);
    } else {
      year = DateTime.now().toUtc().year;
    }
  }

  // Cards read by id are not subject to the BM25 filters, so a card listed
  // in the entity brief can always be opened.
  final collected = <String, KnowledgeCard>{};
  for (final id in ids.take(4)) {
    for (final card in knowledgeCards) {
      if (card.id == id) {
        collected[id] = card;
      }
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
    if (crossBorder) 'crossBorder': true,
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
  try {
    return pack.ruleSet(year).versionFor(jurisdiction);
  } on Object catch (_) {
    return null;
  }
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

int _yearContaining(DateTime now, IndividualTaxYear taxYear) {
  // Reuse TaxSummaryService logic indirectly by approximating: if now is before
  // the tax year start in [now.year], use [now.year]-1.
  final startThisYear = DateTime.utc(
    now.year,
    taxYear.startMonth,
    taxYear.startDay,
  );
  return now.isBefore(startThisYear) ? now.year - 1 : now.year;
}
