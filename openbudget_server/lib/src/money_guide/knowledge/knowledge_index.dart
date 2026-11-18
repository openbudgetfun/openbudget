import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';

/// The weight of a title match (docs/money-guide.md, section 5.2).
const int titleMatchWeight = 3;

/// The weight of a keyword match (docs/money-guide.md, section 5.2).
const int keywordMatchWeight = 2;

/// The weight of a body match (docs/money-guide.md, section 5.2).
const int bodyMatchWeight = 1;

/// How many cards one search returns (docs/money-guide.md, section 5.2).
const int defaultSearchLimit = 4;

/// A result must score at least this share of the query's full
/// inverse-document-frequency weight to be returned.
const double defaultMinimumScoreRatio = 0.3;

/// The BM25 saturation parameter.
const double _k1 = 1.5;

/// The BM25 length-normalisation parameter.
const double _b = 0.75;

/// One search hit: a card and its BM25 score.
final class KnowledgeSearchResult {
  const KnowledgeSearchResult({required this.card, required this.score});

  final KnowledgeCard card;
  final double score;
}

/// The BM25 lexical index over the knowledge cards
/// (docs/money-guide.md, section 5.2).
///
/// Filters cut the corpus to the requested country and the universal set,
/// then to the cards whose listed tax years contain the requested year and
/// whose listed entity kinds contain the entity's kind, before scoring.
/// Build once at startup and reuse: construction tokenises every card.
final class KnowledgeIndex {
  KnowledgeIndex(List<KnowledgeCard> cards) {
    for (final card in cards) {
      final counts = _weightedTermCounts(card);
      _documents.add(_IndexedCard(card, counts));
      for (final term in counts.keys) {
        _documentFrequency.update(
          term,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    final totalLength = _documents.fold<int>(
      0,
      (sum, document) => sum + document.length,
    );
    _averageLength = _documents.isEmpty ? 1 : totalLength / _documents.length;
  }

  final List<_IndexedCard> _documents = <_IndexedCard>[];
  final Map<String, int> _documentFrequency = <String, int>{};
  double _averageLength = 1;

  /// The cards matching [country], [taxYear] and [entityKind], ranked by
  /// BM25 against [query], best first, at most [limit] of them, each above
  /// the minimum score.
  ///
  /// The country filter keeps the requested country's cards and the
  /// universal ones; null means no filter. A null [taxYear] or null
  /// [entityKind] also means no filter. An empty result means no card
  /// cleared the minimum score.
  List<KnowledgeSearchResult> search({
    required String query,
    String? country,
    int? taxYear,
    EntityKind? entityKind,
    int limit = defaultSearchLimit,
    double minimumScoreRatio = defaultMinimumScoreRatio,
  }) {
    final queryTokens = _tokenize(query);
    if (queryTokens.isEmpty) {
      return const [];
    }
    final termWeights = <String, double>{
      for (final term in queryTokens.toSet())
        if (_documentFrequency.containsKey(term))
          term: _inverseDocumentFrequency(term),
    };
    final fullWeight = termWeights.values.fold<double>(
      0,
      (sum, idf) => sum + idf,
    );
    if (fullWeight <= 0) {
      return const [];
    }
    final minimum = minimumScoreRatio * fullWeight;

    final hits = <KnowledgeSearchResult>[];
    for (final document in _documents) {
      if (!_matchesFilters(document.card, country, taxYear, entityKind)) {
        continue;
      }
      final score = _score(document, termWeights);
      if (score >= minimum) {
        hits.add(KnowledgeSearchResult(card: document.card, score: score));
      }
    }
    hits.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.card.id.compareTo(b.card.id);
    });
    return hits.take(math.max(0, limit)).toList();
  }

  /// Every card matching [country], [taxYear] and [entityKind], with the
  /// same filters as [search], in id order.
  ///
  /// The entity brief lists these so the model can read a card by id
  /// (docs/money-guide.md, section 5.1).
  List<KnowledgeCard> cardsFor({
    String? country,
    int? taxYear,
    EntityKind? entityKind,
  }) => [
    for (final document in _documents)
      if (_matchesFilters(document.card, country, taxYear, entityKind))
        document.card,
  ]..sort((a, b) => a.id.compareTo(b.id));

  double _inverseDocumentFrequency(String term) {
    final df = _documentFrequency[term] ?? 0;
    return math.log(1 + (_documents.length - df + 0.5) / (df + 0.5));
  }

  double _score(_IndexedCard document, Map<String, double> termWeights) {
    final normaliser = _k1 * (1 - _b + _b * document.length / _averageLength);
    var score = 0.0;
    for (final MapEntry(key: term, value: idf) in termWeights.entries) {
      final tf = document.termCounts[term];
      if (tf == null) {
        continue;
      }
      score += idf * tf * (_k1 + 1) / (tf + normaliser);
    }
    return score;
  }

  /// Every shipped card, built once on first use
  /// (docs/money-guide.md, section 4.2).
  static final KnowledgeIndex shipped = KnowledgeIndex(knowledgeCards);
}

/// One card's weighted term counts and total weighted length.
final class _IndexedCard {
  const _IndexedCard(this.card, this.termCounts);

  final KnowledgeCard card;
  final Map<String, int> termCounts;

  int get length => termCounts.values.fold(0, (sum, count) => sum + count);
}

/// Title ×3, keywords ×2, body ×1 (docs/money-guide.md, section 5.2).
Map<String, int> _weightedTermCounts(KnowledgeCard card) {
  final counts = <String, int>{};
  void count(String text, int weight) {
    for (final token in _tokenize(text)) {
      counts.update(token, (count) => count + weight, ifAbsent: () => weight);
    }
  }

  count(card.title, titleMatchWeight);
  for (final keyword in card.keywords) {
    count(keyword, keywordMatchWeight);
  }
  count(card.body, bodyMatchWeight);
  return counts;
}

bool _matchesFilters(
  KnowledgeCard card,
  String? country,
  int? taxYear,
  EntityKind? entityKind,
) {
  if (country != null && card.countryCode != country && !card.isUniversal) {
    return false;
  }
  if (taxYear != null &&
      card.taxYears.isNotEmpty &&
      !card.taxYears.contains(taxYear)) {
    return false;
  }
  if (entityKind != null &&
      card.entityKinds.isNotEmpty &&
      !card.entityKinds.contains(entityKind)) {
    return false;
  }
  return true;
}

final RegExp _tokenPattern = RegExp('[a-z0-9]+');

/// Tokenises text the way the index stores it and queries read it:
/// lower-case, accent-folded Unicode letters and digits, with the small
/// English suffix rule of docs/money-guide.md, section 5.2. There is no
/// stemming library, so both sides of a match go through this function.
List<String> _tokenize(String text) => <String>[
  for (final match in _tokenPattern.allMatches(
    _foldAccents(text.toLowerCase()),
  ))
    _stem(match.group(0)!),
];

const Map<String, String> _accentFolds = <String, String>{
  'à': 'a',
  'á': 'a',
  'â': 'a',
  'ã': 'a',
  'ä': 'a',
  'å': 'a',
  'ā': 'a',
  'ă': 'a',
  'ą': 'a',
  'æ': 'ae',
  'ç': 'c',
  'ć': 'c',
  'ĉ': 'c',
  'č': 'c',
  'ď': 'd',
  'ð': 'd',
  'đ': 'd',
  'è': 'e',
  'é': 'e',
  'ê': 'e',
  'ë': 'e',
  'ē': 'e',
  'ĕ': 'e',
  'ė': 'e',
  'ę': 'e',
  'ě': 'e',
  'ĝ': 'g',
  'ğ': 'g',
  'ġ': 'g',
  'ģ': 'g',
  'ĥ': 'h',
  'ì': 'i',
  'í': 'i',
  'î': 'i',
  'ï': 'i',
  'ĩ': 'i',
  'ī': 'i',
  'ĭ': 'i',
  'į': 'i',
  'ı': 'i',
  'ĵ': 'j',
  'ķ': 'k',
  'ĺ': 'l',
  'ļ': 'l',
  'ł': 'l',
  'ñ': 'n',
  'ń': 'n',
  'ņ': 'n',
  'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ŏ': 'o',
  'ő': 'o',
  'œ': 'oe',
  'ŕ': 'r',
  'ř': 'r',
  'ß': 'ss',
  'ś': 's',
  'ŝ': 's',
  'ş': 's',
  'š': 's',
  'ţ': 't',
  'ť': 't',
  'þ': 'th',
  'ù': 'u',
  'ú': 'u',
  'û': 'u',
  'ü': 'u',
  'ũ': 'u',
  'ū': 'u',
  'ŭ': 'u',
  'ů': 'u',
  'ű': 'u',
  'ų': 'u',
  'ŵ': 'w',
  'ý': 'y',
  'ÿ': 'y',
  'ŷ': 'y',
  'ź': 'z',
  'ż': 'z',
  'ž': 'z',
};

final RegExp _nonAsciiPattern = RegExp('[^\u0000-\u007F]');

String _foldAccents(String text) => text.splitMapJoin(
  _nonAsciiPattern,
  onMatch: (match) => _accentFolds[match.group(0)] ?? ' ',
);

/// Plural and -ing/-ed suffix rule; a word keeps at least three characters.
String _stem(String word) {
  var stemmed = word;
  if (stemmed.length >= 5 && stemmed.endsWith('sses')) {
    stemmed = stemmed.substring(0, stemmed.length - 2);
  } else if (stemmed.length >= 5 && stemmed.endsWith('ies')) {
    stemmed = '${stemmed.substring(0, stemmed.length - 3)}y';
  } else if (stemmed.length >= 5 &&
      stemmed.endsWith('es') &&
      _esPluralPreceders.contains(stemmed[stemmed.length - 3])) {
    stemmed = stemmed.substring(0, stemmed.length - 2);
  } else if (stemmed.length >= 4 &&
      stemmed.endsWith('s') &&
      !stemmed.endsWith('ss') &&
      !stemmed.endsWith('us') &&
      !stemmed.endsWith('is')) {
    stemmed = stemmed.substring(0, stemmed.length - 1);
  }
  if (stemmed.length >= 6 && stemmed.endsWith('ing')) {
    stemmed = _dropDoubledConsonant(stemmed.substring(0, stemmed.length - 3));
  } else if (stemmed.length >= 5 && stemmed.endsWith('ed')) {
    stemmed = _dropDoubledConsonant(stemmed.substring(0, stemmed.length - 2));
  }
  return stemmed;
}

/// The characters before a real `es` plural: taxes, boxes, matches, washes.
const Set<String> _esPluralPreceders = {'x', 'z', 's', 'h'};

/// `planned` stems to `plann`, which folds back to `plan`; `ll`, `ss`,
/// `ff` and `zz` are not doubled consonants from a suffix.
String _dropDoubledConsonant(String stem) {
  if (stem.length >= 2) {
    final secondToLast = stem[stem.length - 2];
    final last = stem[stem.length - 1];
    const keep = {'l', 's', 'f', 'z'};
    if (secondToLast == last && !keep.contains(last)) {
      return stem.substring(0, stem.length - 1);
    }
  }
  return stem;
}
