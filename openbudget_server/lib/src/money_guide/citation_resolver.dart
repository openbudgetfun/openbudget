import 'dart:convert';

/// One source behind a citation key, as it is stored with the message and
/// shown in the app's sources sheet (docs/money-guide.md, section 6).
final class CitationSource {
  const CitationSource({
    required this.key,
    required this.title,
    required this.url,
    required this.authority,
    required this.grade,
    required this.announced,
    this.verifiedOn,
  });

  /// The key the model wrote as `[^key]`.
  final String key;

  final String title;
  final String url;

  /// The host that publishes the source, without a leading `www.`.
  final String authority;

  /// When the source was last checked, as a date-only UTC value.
  final DateTime? verifiedOn;

  /// `primary`, `secondary` or `inferred`.
  final String grade;

  /// True when the source describes a rule that is not yet law.
  final bool announced;
}

/// The outcome of resolving the citation keys in one reply.
final class CitationResolution {
  const CitationResolution({
    required this.text,
    required this.sources,
    required this.strippedCount,
    required this.touchesTaxOrInvestment,
  });

  /// The reply with every key that could not be resolved removed. Resolved
  /// keys stay in place for the app to turn into chips.
  final String text;

  /// The sources of the resolved keys, in order of first appearance, each
  /// key's sources together.
  final List<CitationSource> sources;

  /// How many unresolved keys were removed. Log the count, never the keys.
  final int strippedCount;

  /// Whether a resolved key is a tax card, a tax tool result or anything
  /// else that makes the country's disclaimer apply.
  final bool touchesTaxOrInvestment;
}

/// The keys a conversation's tool results make citable, and the pass that
/// resolves a reply against them (docs/money-guide.md, section 6).
///
/// A key resolves only when a tool result in the conversation carried it:
/// a knowledge card's `citeAs`, or the top-level `citeAs` of a tax tool
/// result such as `report-2026`. A real card id the model never retrieved is
/// unknown, exactly like a key it invented.
///
/// The catalogue is pure. The caller feeds it every stored tool result and
/// each new one as it arrives, so resolution reads what was stored and does
/// not depend on how the prompt was compacted.
final class CitationCatalogue {
  final Map<String, _CitableKey> _keys = {};

  static final RegExp _marker = RegExp(
    r'[ \t]*\[\^([A-Za-z0-9][A-Za-z0-9_-]*)\]',
  );

  /// The keys that can currently be cited.
  Set<String> get keys => Set.unmodifiable(_keys.keys);

  /// Registers the keys that [toolOutput], a tool result's JSON, carries.
  ///
  /// Only the top level counts, so text a user typed into a memo can never
  /// mint a key. Output that is not a JSON object registers nothing.
  void addToolResult(String toolOutput) {
    final Object? decoded;
    try {
      decoded = jsonDecode(toolOutput);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, Object?>) return;

    final cards = decoded['cards'];
    if (cards is List<Object?>) {
      for (final card in cards) {
        if (card is Map<String, Object?>) _addCard(card);
      }
    }
    _addReport(decoded);
  }

  /// Removes every key of [text] that is not in the catalogue, and returns
  /// the sources of the keys that remain.
  CitationResolution resolve(String text) {
    final resolvedKeys = <String>[];
    var stripped = 0;

    final cleaned = text.replaceAllMapped(_marker, (match) {
      final key = match.group(1)!;
      if (!_keys.containsKey(key)) {
        stripped++;
        return _gapAfterStrippedMarker(match);
      }
      if (!resolvedKeys.contains(key)) resolvedKeys.add(key);
      return match.group(0)!;
    });

    return CitationResolution(
      text: cleaned,
      sources: [for (final key in resolvedKeys) ..._keys[key]!.sources],
      strippedCount: stripped,
      touchesTaxOrInvestment: resolvedKeys.any(
        (key) => _keys[key]!.touchesTaxOrInvestment,
      ),
    );
  }

  /// What replaces a stripped marker and the spaces before it: nothing, so
  /// `claim [^x].` becomes `claim.`, or one space when a word follows, so
  /// `a [^x] b` does not become `ab`.
  static String _gapAfterStrippedMarker(Match match) {
    final hadSpaceBefore = match.group(0)!.startsWith(RegExp('[ \t]'));
    if (!hadSpaceBefore) return '';
    final end = match.end;
    if (end >= match.input.length) return '';
    return _isWordCharacter(match.input.codeUnitAt(end)) ? ' ' : '';
  }

  static bool _isWordCharacter(int codeUnit) =>
      (codeUnit >= 0x30 && codeUnit <= 0x39) ||
      (codeUnit >= 0x41 && codeUnit <= 0x5A) ||
      (codeUnit >= 0x61 && codeUnit <= 0x7A) ||
      codeUnit > 0x7F;

  void _addCard(Map<String, Object?> card) {
    final key = card['citeAs'];
    if (key is! String || key.isEmpty) return;

    final verifiedOn = _parseDate(card['verifiedOn']);
    final announced = card['announced'] == true;
    final sources = <CitationSource>[];
    final rawSources = card['sources'];
    if (rawSources is List<Object?>) {
      for (final raw in rawSources) {
        if (raw is! Map<String, Object?>) continue;
        final url = raw['url'];
        if (url is! String || url.isEmpty) continue;
        final title = raw['title'];
        sources.add(
          CitationSource(
            key: key,
            title: title is String && title.isNotEmpty ? title : url,
            url: url,
            authority: _authorityOf(url),
            verifiedOn: verifiedOn,
            grade:
                _gradeOf(raw['grade']) ?? _gradeOf(card['grade']) ?? 'primary',
            announced: announced,
          ),
        );
      }
    }
    // A card with no source behind it has nothing to show, so it cannot be
    // cited.
    if (sources.isEmpty) return;

    final perimeter = card['perimeter'];
    _keys[key] = _CitableKey(
      sources: sources,
      touchesTaxOrInvestment: perimeter != 'general',
    );
  }

  /// A tax report or summary names itself with `citeAs` and lists the
  /// authority pages it used in `sources`.
  void _addReport(Map<String, Object?> result) {
    final key = result['citeAs'];
    if (key is! String || key.isEmpty) return;
    final rawSources = result['sources'];
    if (rawSources is! List<Object?>) return;

    final verifiedOn = _parseDate(result['rulesVerifiedOn']);
    final label = _reportLabel(key, result);
    final byUrl = <String, CitationSource>{};
    for (final raw in rawSources) {
      if (raw is! String || raw.isEmpty) continue;
      final authority = _authorityOf(raw);
      byUrl[raw] = CitationSource(
        key: key,
        title: '$label: $authority',
        url: raw,
        authority: authority,
        verifiedOn: verifiedOn,
        grade: 'primary',
        announced: false,
      );
    }

    // A figure the report quotes from a weaker source lowers the grade of
    // that page, so the sources sheet never shows a secondary figure as
    // primary.
    final figures = result['figures'];
    if (figures is List<Object?>) {
      for (final raw in figures) {
        if (raw is! Map<String, Object?>) continue;
        final url = raw['source'];
        final grade = _gradeOf(raw['grade']);
        if (url is! String || url.isEmpty || grade == null) continue;
        final existing = byUrl[url];
        if (existing == null) {
          final authority = _authorityOf(url);
          byUrl[url] = CitationSource(
            key: key,
            title: '$label: $authority',
            url: url,
            authority: authority,
            verifiedOn: _parseDate(raw['verifiedOn']) ?? verifiedOn,
            grade: grade,
            announced: false,
          );
        } else if (_gradeRank(grade) > _gradeRank(existing.grade)) {
          byUrl[url] = CitationSource(
            key: key,
            title: existing.title,
            url: url,
            authority: existing.authority,
            verifiedOn: existing.verifiedOn,
            grade: grade,
            announced: false,
          );
        }
      }
    }
    if (byUrl.isEmpty) return;

    _keys[key] = _CitableKey(
      sources: byUrl.values.toList(),
      touchesTaxOrInvestment: true,
    );
  }

  /// `Tax report 2026/27`, from the key's prefix and the result's year label.
  static String _reportLabel(String key, Map<String, Object?> result) {
    final prefix = key.split('-').first;
    final kind = switch (prefix) {
      'report' => 'Tax report',
      'summary' => 'Tax summary',
      'crypto' => 'Crypto tax summary',
      _ => 'Tax figures',
    };
    final yearLabel = result['yearLabel'];
    return yearLabel is String && yearLabel.isNotEmpty
        ? '$kind $yearLabel'
        : kind;
  }

  static String _authorityOf(String url) {
    final host = Uri.tryParse(url)?.host ?? '';
    if (host.isEmpty) return url;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  static String? _gradeOf(Object? value) =>
      value is String && _grades.contains(value) ? value : null;

  static const Set<String> _grades = {'primary', 'secondary', 'inferred'};

  /// Higher is weaker.
  static int _gradeRank(String grade) => switch (grade) {
    'primary' => 0,
    'secondary' => 1,
    _ => 2,
  };
}

final class _CitableKey {
  const _CitableKey({
    required this.sources,
    required this.touchesTaxOrInvestment,
  });

  final List<CitationSource> sources;
  final bool touchesTaxOrInvestment;
}
