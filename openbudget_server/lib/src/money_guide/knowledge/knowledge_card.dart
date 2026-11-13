import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:yaml/yaml.dart';

/// The country code a card carries when it is not about one pack country
/// (docs/money-guide.md, section 4.1).
const String universalCountryCode = 'universal';

/// The most words a card body may carry (docs/money-guide.md, section 4.1).
const int maxCardBodyWords = 300;

/// The most characters a card id may carry (docs/money-guide.md, section 4.1).
const int maxCardIdLength = 48;

/// The wording a card never uses, as `(shown, pattern)` pairs.
///
/// Ported from `.claude/skills/tax-planning-guardrails/references/
/// test-vectors.md` ("Wording lint cases") and docs/money-guide.md section 3:
/// guidance, not advice. Patterns match case-insensitively; `\b` is a word
/// boundary, and `guarantee` is unbounded so `guaranteed` matches too.
const List<(String, String)> forbiddenCardWording = <(String, String)>[
  ('you should', r'\byou should\b'),
  ('you must', r'\byou must\b'),
  ('we recommend', r'\bwe recommend\b'),
  ('best', r'\bbest\b'),
  ('optimal', r'\boptimal\b'),
  ('guarantee', r'\bguarantee'),
  ('loophole', r'\bloophole\b'),
  ('Sie sollten', r'\bSie sollten\b'),
  ('wir empfehlen', r'\bwir empfehlen\b'),
  ('Handlungsempfehlung', 'Handlungsempfehlung'),
];

/// Verbs a card title must not start with, from the same wording lint as
/// [forbiddenCardWording]. Matched case-insensitively before a space, so a
/// title may still open with a noun such as "PAYE thresholds".
const List<String> forbiddenTitleStarts = <String>[
  'use',
  'claim',
  'pay',
  'take',
  'harvest',
  'shelter',
  'itemize',
  'maximize',
  'einzahlen',
  'nutzen',
  'ausschöpfen',
  'beantragen',
  'bilden',
];

final List<(String, RegExp)> _forbiddenWording = <(String, RegExp)>[
  for (final (shown, pattern) in forbiddenCardWording)
    (shown, RegExp(pattern, caseSensitive: false)),
];

/// Where a card may speak (docs/money-guide.md, section 4.1).
enum KnowledgePerimeter {
  /// Budgeting and money basics.
  general,

  /// What the law allows and what the figures show.
  taxIllustration,

  /// Explain in general, then point to a professional; never apply to the
  /// user's case.
  signpostOnly,
}

/// One authority page a card cites.
final class KnowledgeCardSource {
  const KnowledgeCardSource({
    required this.title,
    required this.url,
    required this.grade,
  });

  final String title;

  /// The authority page, `https://host/path` only, so the generator can
  /// write it as a `const` [Uri].
  final Uri url;

  final TaxEvidenceGrade grade;
}

/// One knowledge card of the Money guide
/// (docs/money-guide.md, section 4.1).
///
/// Cards are Markdown files with YAML front matter under
/// `openbudget_server/knowledge/`; `tool/generate_knowledge.dart` validates
/// them and writes them as constants. The body keeps its
/// `{{figure:id}}` and `{{taxYear}}` placeholders; they resolve per tax year
/// at read time with [resolveCardBody].
final class KnowledgeCard {
  const KnowledgeCard({
    required this.id,
    required this.countryCode,
    required this.title,
    required this.topics,
    required this.entityKinds,
    required this.taxYears,
    required this.grade,
    required this.verifiedOn,
    required this.recheckBy,
    required this.perimeter,
    required this.needsEvidence,
    required this.announced,
    required this.keywords,
    required this.sources,
    required this.body,
    this.skill,
  });

  /// Lower-case kebab case, prefixed by the ISO country code or
  /// `universal-`, unique and stable. Doubles as the citation key.
  final String id;

  /// An ISO 3166-1 alpha-2 code of a pack country, or [universalCountryCode].
  final String countryCode;

  final String title;

  final List<String> topics;

  /// The kinds of entity the card applies to; empty means every kind.
  final List<EntityKind> entityKinds;

  /// The tax years, by start year, the card speaks about; empty means the
  /// card is not tied to a year.
  final List<int> taxYears;

  final TaxEvidenceGrade grade;

  /// When the card was last checked against [sources].
  final DateTime verifiedOn;

  /// The last day the card is trusted without a re-check; feeds the weekly
  /// freshness workflow (docs/tax-jurisdictions.md, section 7).
  final DateTime recheckBy;

  final KnowledgePerimeter perimeter;

  /// The relief needs proof, so the guide asks for the evidence and not
  /// only the number.
  final bool needsEvidence;

  /// The card describes a rule that is not yet law; never used in
  /// arithmetic.
  final bool announced;

  /// The synonyms and local terms retrieval matches on.
  final List<String> keywords;

  final List<KnowledgeCardSource> sources;

  /// The developer reference the card distils, so a reviewer can trace it.
  final String? skill;

  final String body;

  /// Whether the card is not about one pack country.
  bool get isUniversal => countryCode == universalCountryCode;

  /// The key a reply cites the card with
  /// (docs/money-guide.md, section 6).
  String get citeAs => id;
}

/// Thrown when a card file, field or figure placeholder breaks the format
/// of docs/money-guide.md, section 4.1.
final class KnowledgeFormatException implements Exception {
  KnowledgeFormatException(this.message, {this.cardId, this.path});

  final String message;

  /// The card id, when it is known.
  final String? cardId;

  /// The card file, when the card came from a file.
  final String? path;

  @override
  String toString() {
    final where = <String>[
      ?path,
      if (cardId case final cardId?) 'card $cardId',
    ];
    return where.isEmpty
        ? 'knowledge card: $message'
        : '${where.join(': ')}: $message';
  }
}

/// One broken format rule, naming the card.
final class KnowledgeCardIssue {
  const KnowledgeCardIssue(this.cardId, this.rule);

  final String cardId;
  final String rule;

  @override
  String toString() => 'card $cardId: $rule';
}

/// Parses one card file's text into a [KnowledgeCard].
///
/// Throws [KnowledgeFormatException] with the [path] and, once the id is
/// readable, the card id when a field breaks the format.
KnowledgeCard parseKnowledgeCardMarkdown(
  String contents, {
  required String path,
}) {
  final lines = const LineSplitter().convert(contents.trim());
  if (lines.isEmpty || lines.first != '---') {
    throw KnowledgeFormatException(
      'a card file starts with a --- front matter block',
      path: path,
    );
  }
  final close = lines.indexWhere((line) => line == '---', 1);
  if (close < 0) {
    throw KnowledgeFormatException(
      'the front matter block is not closed with a --- line',
      path: path,
    );
  }
  final frontMatterText = lines.sublist(1, close).join('\n');
  final body = lines.sublist(close + 1).join('\n').trim();

  final Object? frontMatter;
  try {
    frontMatter = loadYaml(frontMatterText);
  } on YamlException catch (error) {
    throw KnowledgeFormatException(
      'the front matter is not valid YAML: ${error.message}',
      path: path,
    );
  }
  if (frontMatter is! YamlMap) {
    throw KnowledgeFormatException(
      'the front matter must be a YAML mapping',
      path: path,
    );
  }

  return _FrontMatterReader(frontMatter, path: path).read(body);
}

/// Validates [cards] against the format rules of docs/money-guide.md,
/// section 4.1, including that every `{{figure:id}}` placeholder exists in
/// the country pack for each listed tax year.
///
/// Returns one [KnowledgeCardIssue] per broken rule; an empty list means
/// every card is valid.
List<KnowledgeCardIssue> validateKnowledgeCards(List<KnowledgeCard> cards) {
  final errors = <KnowledgeCardIssue>[];
  final seenIds = <String>{};
  for (final card in cards) {
    void fail(String rule) => errors.add(KnowledgeCardIssue(card.id, rule));

    final prefix = card.isUniversal
        ? 'universal-'
        : '${card.countryCode.toLowerCase()}-';
    if (card.id.length > maxCardIdLength) {
      fail('the id is longer than $maxCardIdLength characters');
    }
    if (!_cardIdPattern.hasMatch(card.id)) {
      fail('the id is not lower-case kebab case');
    }
    if (!card.id.startsWith(prefix)) {
      fail('an id for country ${card.countryCode} starts with "$prefix"');
    }
    if (!seenIds.add(card.id)) {
      fail('the id is used twice');
    }

    if (card.countryCode != universalCountryCode &&
        TaxJurisdiction.fromCountryCode(card.countryCode) == null) {
      fail('country must be a pack country or "$universalCountryCode"');
    }
    if (card.recheckBy.isBefore(card.verifiedOn)) {
      fail('recheckBy is before verifiedOn');
    }
    if (card.topics.isEmpty) {
      fail('the card needs at least one topic');
    }
    if (card.keywords.isEmpty) {
      fail('the card needs at least one keyword');
    }

    if (card.sources.isEmpty) {
      fail('the card needs at least one source');
    }
    for (final source in card.sources) {
      if (source.url.scheme != 'https' ||
          source.url.host.isEmpty ||
          source.url.path.isEmpty) {
        fail('source "${source.title}" is not an https://host/path URL');
      }
      if (source.url.query.isNotEmpty || source.url.fragment.isNotEmpty) {
        fail(
          'source "${source.title}" carries a query or fragment; '
          'cite the page without one',
        );
      }
    }

    final words = countWords(card.body);
    if (words > maxCardBodyWords) {
      fail('the body is $words words; at most $maxCardBodyWords');
    }

    for (final (shown, pattern) in _forbiddenWording) {
      if (pattern.hasMatch(card.title)) {
        fail('the title uses the forbidden wording "$shown"');
      }
      if (pattern.hasMatch(card.body)) {
        fail('the body uses the forbidden wording "$shown"');
      }
    }
    for (final verb in forbiddenTitleStarts) {
      if (card.title.toLowerCase().startsWith('$verb ')) {
        fail('the title starts with the imperative "$verb"');
      }
    }

    if (card.grade != TaxEvidenceGrade.primary &&
        !RegExp(card.grade.name).hasMatch(card.body)) {
      fail('a ${card.grade.name} card must say so in its body');
    }

    if (card.isUniversal) {
      if (card.body.contains('{{')) {
        fail(
          'a universal card writes facts out with their source; '
          'it carries no figure or taxYear placeholder',
        );
      }
      continue;
    }

    for (final match in _placeholderPattern.allMatches(card.body)) {
      final token = match.group(1)!;
      final figureId = _figureTokenPattern.firstMatch(token)?.group(1);
      if (token != 'taxYear' && figureId == null) {
        fail('unknown placeholder {$token}');
        continue;
      }
      if (figureId == null) {
        continue;
      }
      final jurisdiction = TaxJurisdiction.fromCountryCode(card.countryCode);
      if (jurisdiction == null) {
        continue;
      }
      final pack = TaxRules.forJurisdiction(jurisdiction);
      for (final year in card.taxYears) {
        if (!pack.supportedStartYears.contains(year)) {
          fail(
            'tax year $year is not in the ${card.countryCode} pack '
            '(known years: ${pack.supportedStartYears.join(', ')})',
          );
          continue;
        }
        if (!pack.ruleSet(year).figures.containsKey(figureId)) {
          fail(
            'figure $figureId is not in the ${card.countryCode} pack '
            'for the year starting $year',
          );
        }
      }
    }
  }
  return errors;
}

/// Resolves a card's `{{figure:id}}` and `{{taxYear}}` placeholders for the
/// tax year starting in [startYear], from the country pack's named figures
/// (docs/money-guide.md, section 4.1).
///
/// A universal card carries no placeholders, so its body comes back
/// unchanged. Throws [KnowledgeFormatException] when the year is not in the
/// pack or the pack holds no figure of that id for the year.
String resolveCardBody(KnowledgeCard card, int startYear) {
  if (card.isUniversal) {
    return card.body;
  }
  final jurisdiction = TaxJurisdiction.fromCountryCode(card.countryCode);
  if (jurisdiction == null) {
    throw KnowledgeFormatException(
      'country ${card.countryCode} has no pack',
      cardId: card.id,
    );
  }
  final pack = TaxRules.forJurisdiction(jurisdiction);
  if (!pack.supportedStartYears.contains(startYear)) {
    throw KnowledgeFormatException(
      'no ${jurisdiction.countryCode} rules for the year starting $startYear',
      cardId: card.id,
    );
  }
  final figures = pack.ruleSet(startYear).figures;
  final yearLabel = pack.taxYear(startYear).label;
  return card.body.replaceAllMapped(_placeholderPattern, (match) {
    final token = match.group(1)!;
    if (token == 'taxYear') {
      return yearLabel;
    }
    final figureId = _figureTokenPattern.firstMatch(token)?.group(1);
    if (figureId == null) {
      throw KnowledgeFormatException(
        'unknown placeholder {$token}',
        cardId: card.id,
      );
    }
    final figure = figures[figureId];
    if (figure == null) {
      throw KnowledgeFormatException(
        'figure $figureId is not in the ${jurisdiction.countryCode} pack '
        'for the year starting $startYear',
        cardId: card.id,
      );
    }
    return _formatFigure(figure, jurisdiction);
  });
}

/// Counts whitespace-separated words in [text].
int countWords(String text) {
  final trimmed = text.trim();
  return trimmed.isEmpty ? 0 : trimmed.split(_whitespacePattern).length;
}

final RegExp _cardIdPattern = RegExp(r'^[a-z][a-z0-9]*(-[a-z0-9]+)*$');
final RegExp _placeholderPattern = RegExp(r'\{\{([^{}]*)\}\}');
final RegExp _figureTokenPattern = RegExp(r'^figure:([A-Za-z][A-Za-z0-9]*)$');
final RegExp _whitespacePattern = RegExp(r'\s+');
final RegExp _thousandsPattern = RegExp(r'\B(?=(\d{3})+(?!\d))');

String _formatFigure(TaxFigure figure, TaxJurisdiction jurisdiction) =>
    switch (figure.unit) {
      TaxFigureUnit.currencyMinor =>
        '${_currencySymbol(jurisdiction)}${_formatMajor(figure.value)}',
      TaxFigureUnit.rateBasisPoints =>
        '${_withFraction(figure.value ~/ 100, figure.value % 100)}%',
      TaxFigureUnit.percent => '${_withFraction(figure.value, 0)}%',
      TaxFigureUnit.count => '${figure.value}',
    };

/// The [TaxEvidenceGrade] called [name], or null.
TaxEvidenceGrade? _gradeNamed(String name) {
  for (final grade in TaxEvidenceGrade.values) {
    if (grade.name == name) {
      return grade;
    }
  }
  return null;
}

/// The [KnowledgePerimeter] called [name], or null.
KnowledgePerimeter? _perimeterNamed(String name) {
  for (final perimeter in KnowledgePerimeter.values) {
    if (perimeter.name == name) {
      return perimeter;
    }
  }
  return null;
}

/// The [EntityKind] called [name], or null.
EntityKind? _entityKindNamed(String name) {
  for (final kind in EntityKind.values) {
    if (kind.name == name) {
      return kind;
    }
  }
  return null;
}

String _currencySymbol(TaxJurisdiction jurisdiction) => switch (jurisdiction) {
  TaxJurisdiction.gb => '£',
  TaxJurisdiction.us => r'$',
  TaxJurisdiction.de => '€',
  TaxJurisdiction.ng => '₦',
};

/// Minor units in the currency's normal written form: 1257000 is `12,570`.
String _formatMajor(int minor) {
  final major = minor ~/ 100;
  final fraction = minor % 100;
  final grouped = major.toString().replaceAll(_thousandsPattern, ',');
  return fraction == 0
      ? grouped
      : '$grouped.${fraction.toString().padLeft(2, '0')}';
}

String _withFraction(int whole, int fraction) =>
    fraction == 0 ? '$whole' : '$whole.${fraction.toString().padLeft(2, '0')}';

/// Reads the front matter of one card file.
final class _FrontMatterReader {
  _FrontMatterReader(this._map, {required this.path});

  static const Set<String> _allowedKeys = {
    'id',
    'country',
    'title',
    'topics',
    'entityKinds',
    'taxYears',
    'grade',
    'verifiedOn',
    'recheckBy',
    'perimeter',
    'needsEvidence',
    'announced',
    'keywords',
    'skill',
    'sources',
  };

  static const List<String> _requiredKeys = <String>[
    'id',
    'country',
    'title',
    'topics',
    'entityKinds',
    'taxYears',
    'grade',
    'verifiedOn',
    'recheckBy',
    'perimeter',
    'needsEvidence',
    'announced',
    'keywords',
    'sources',
  ];

  final YamlMap _map;
  final String path;

  /// Set as soon as the id is readable, so later errors name the card.
  String? _cardId;

  KnowledgeCard read(String body) {
    final id = string('id');
    _cardId = id;
    _checkKeys();
    return KnowledgeCard(
      id: id,
      countryCode: string('country'),
      title: string('title'),
      topics: stringList('topics'),
      entityKinds: entityKindList('entityKinds'),
      taxYears: intList('taxYears'),
      grade: _grade('grade'),
      verifiedOn: date('verifiedOn'),
      recheckBy: date('recheckBy'),
      perimeter: _perimeter('perimeter'),
      needsEvidence: flag('needsEvidence'),
      announced: flag('announced'),
      keywords: stringList('keywords'),
      skill: _optionalString('skill'),
      sources: _sources(),
      body: body,
    );
  }

  String string(String key) {
    final value = _map[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    throw _error('front matter key "$key" must be a non-empty string');
  }

  String? _optionalString(String key) =>
      _map.keys.contains(key) ? string(key) : null;

  List<String> stringList(String key) {
    final value = _map[key];
    if (value is! YamlList) {
      throw _error('front matter key "$key" must be a list');
    }
    final entries = <String>[];
    for (final item in value) {
      if (item is! String || item.trim().isEmpty) {
        throw _error('front matter key "$key" must hold non-empty strings');
      }
      entries.add(item.trim());
    }
    return entries;
  }

  List<EntityKind> entityKindList(String key) {
    final value = _map[key];
    if (value is! YamlList) {
      throw _error('front matter key "$key" must be a list');
    }
    final kinds = <EntityKind>[];
    for (final item in value) {
      if (item is! String) {
        throw _error(
          'front matter key "$key" must hold individual, soleTrader or '
          'company',
        );
      }
      final kind = _entityKindNamed(item);
      if (kind == null) {
        throw _error(
          'front matter key "$key" must hold individual, soleTrader or '
          'company',
        );
      }
      kinds.add(kind);
    }
    return kinds;
  }

  List<int> intList(String key) {
    final value = _map[key];
    if (value is! YamlList) {
      throw _error('front matter key "$key" must be a list');
    }
    final years = <int>[];
    for (final item in value) {
      if (item is! int) {
        throw _error('front matter key "$key" must hold whole years');
      }
      years.add(item);
    }
    return years;
  }

  DateTime date(String key) {
    final value = _map[key];
    if (value is DateTime) {
      return DateTime.utc(value.year, value.month, value.day);
    }
    if (value is String) {
      final parsedDate = DateTime.tryParse(value);
      if (parsedDate != null) {
        return DateTime.utc(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );
      }
    }
    throw _error('front matter key "$key" must be an ISO 8601 date');
  }

  bool flag(String key) {
    final value = _map[key];
    if (value is bool) {
      return value;
    }
    throw _error('front matter key "$key" must be true or false');
  }

  List<KnowledgeCardSource> _sources() {
    final value = _map['sources'];
    if (value is! YamlList || value.isEmpty) {
      throw _error('front matter key "sources" must hold at least one source');
    }
    final sources = <KnowledgeCardSource>[];
    for (final entry in value) {
      if (entry is! YamlMap) {
        throw _error(
          'front matter key "sources" must hold mappings with title, url '
          'and grade',
        );
      }
      final title = entry['title'];
      final url = entry['url'];
      final grade = entry['grade'];
      if (title is! String || title.trim().isEmpty) {
        throw _error('a source needs a non-empty title');
      }
      if (url is! String) {
        throw _error('source "${title.trim()}" needs a url');
      }
      final parsedUrl = Uri.tryParse(url);
      if (parsedUrl == null || parsedUrl.scheme != 'https') {
        throw _error('source "${title.trim()}" needs an https url');
      }
      if (grade is! String) {
        throw _error('source "${title.trim()}" needs a grade');
      }
      final sourceGrade = _gradeNamed(grade);
      if (sourceGrade == null) {
        throw _error(
          'source "${title.trim()}" needs a grade of primary, secondary or '
          'inferred',
        );
      }
      sources.add(
        KnowledgeCardSource(
          title: title.trim(),
          url: parsedUrl,
          grade: sourceGrade,
        ),
      );
    }
    return sources;
  }

  TaxEvidenceGrade _grade(String key) {
    final value = _map[key];
    if (value is! String) {
      throw _error('front matter key "$key" must be a grade name');
    }
    final grade = _gradeNamed(value);
    if (grade == null) {
      throw _error(
        'front matter key "$key" must be one of '
        '${TaxEvidenceGrade.values.map((g) => g.name).join(', ')}',
      );
    }
    return grade;
  }

  KnowledgePerimeter _perimeter(String key) {
    final value = _map[key];
    if (value is! String) {
      throw _error('front matter key "$key" must be a perimeter name');
    }
    final perimeter = _perimeterNamed(value);
    if (perimeter == null) {
      throw _error(
        'front matter key "$key" must be one of '
        '${KnowledgePerimeter.values.map((p) => p.name).join(', ')}',
      );
    }
    return perimeter;
  }

  void _checkKeys() {
    for (final key in _map.keys) {
      if (key is! String || !_allowedKeys.contains(key)) {
        throw _error('unknown front matter key "$key"');
      }
    }
    for (final key in _requiredKeys) {
      if (!_map.keys.contains(key)) {
        throw _error('missing front matter key "$key"');
      }
    }
  }

  KnowledgeFormatException _error(String message) =>
      KnowledgeFormatException(message, cardId: _cardId, path: path);
}
