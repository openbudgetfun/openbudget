import 'package:meta/meta.dart';

/// One wording problem found in an opportunity title or explanation.
@immutable
final class WordingIssue {
  const WordingIssue({required this.field, required this.matched});

  /// `title` or `explanation`.
  final String field;

  /// The phrase or verb the linter matched.
  final String matched;

  @override
  String toString() => '$field matched "$matched"';
}

/// Phrases no opportunity title or explanation may contain: advice
/// language the tax-planning-guardrails wording rules ban (test-vectors
/// reference, "Wording lint cases").
final List<RegExp> bannedWordingPhrases = List.unmodifiable([
  RegExp(r'\byou should\b', caseSensitive: false),
  RegExp(r'\byou must\b', caseSensitive: false),
  RegExp(r'\bwe recommend\b', caseSensitive: false),
  RegExp(r'\bbest\b', caseSensitive: false),
  RegExp(r'\boptimal\b', caseSensitive: false),
  RegExp(r'\bguarantee', caseSensitive: false),
  RegExp(r'\bloophole\b', caseSensitive: false),
  RegExp(r'\bSie sollten\b', caseSensitive: false),
  RegExp(r'\bwir empfehlen\b', caseSensitive: false),
  RegExp('Handlungsempfehlung'),
]);

/// Imperative verbs a title must not start with: titles are neutral noun
/// phrases ("Pension annual allowance"), never instructions ("Use your
/// pension annual allowance"). The skill's list first, then the verbs the
/// packs' old titles used, so no imperative slips back in.
const List<String> bannedTitleVerbs = [
  // From the tax-planning-guardrails wording lint cases.
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
  // Imperatives the packs' titles have used since.
  'register',
  'file',
  'compare',
  'watch',
  'budget',
  'restore',
  'prüfen',
  'erwägen',
];

/// German infinitives that make a title imperative when they end it, as
/// German instructions do ("Basisrente bis zum Höchstbetrag einzahlen").
const List<String> bannedGermanFinalVerbs = [
  'einzahlen',
  'nutzen',
  'ausschöpfen',
  'beantragen',
  'bilden',
  'prüfen',
];

String _firstWord(String text) => text
    .trimLeft()
    .split(' ')
    .first
    .toLowerCase()
    .replaceAll(RegExp('[^0-9a-zA-Zäöüß]'), '');

String _lastWord(String text) => text
    .trimRight()
    .split(' ')
    .last
    .toLowerCase()
    .replaceAll(RegExp('[^0-9a-zA-Zäöüß]'), '');

/// Returns every wording issue in an opportunity's [title] and
/// [explanation], empty when the wording passes the lint.
List<WordingIssue> findWordingIssues({
  required String title,
  required String explanation,
}) {
  final issues = <WordingIssue>[
    for (final phrase in bannedWordingPhrases)
      if (title.contains(phrase))
        WordingIssue(field: 'title', matched: phrase.pattern),
    for (final phrase in bannedWordingPhrases)
      if (explanation.contains(phrase))
        WordingIssue(field: 'explanation', matched: phrase.pattern),
  ];
  final firstWord = _firstWord(title);
  if (bannedTitleVerbs.contains(firstWord)) {
    issues.add(
      WordingIssue(field: 'title', matched: 'imperative "$firstWord"'),
    );
  }
  final lastWord = _lastWord(title);
  if (bannedGermanFinalVerbs.contains(lastWord)) {
    issues.add(WordingIssue(field: 'title', matched: 'imperative "$lastWord"'));
  }
  return issues;
}
