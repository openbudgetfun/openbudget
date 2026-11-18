import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:test/test.dart';

KnowledgeCard _card({
  String id = 'universal-test-card',
  String countryCode = universalCountryCode,
  String title = 'A test card about a rule',
  List<String> topics = const ['budgeting'],
  List<EntityKind> entityKinds = const [],
  List<int> taxYears = const [],
  TaxEvidenceGrade grade = TaxEvidenceGrade.primary,
  List<String> keywords = const ['test keyword'],
  List<KnowledgeCardSource>? sources,
  String body = 'A short body with the rule and its source.',
  String? skill,
}) => KnowledgeCard(
  id: id,
  countryCode: countryCode,
  title: title,
  topics: topics,
  entityKinds: entityKinds,
  taxYears: taxYears,
  grade: grade,
  verifiedOn: DateTime.utc(2026, 11, 13),
  recheckBy: DateTime.utc(2027, 4, 6),
  perimeter: KnowledgePerimeter.general,
  needsEvidence: false,
  announced: false,
  keywords: keywords,
  sources:
      sources ??
      [
        KnowledgeCardSource(
          title: 'Test authority',
          url: Uri.https('www.gov.uk', '/test'),
          grade: TaxEvidenceGrade.primary,
        ),
      ],
  body: body,
  skill: skill,
);

/// A valid GB card file's text with [id] and optional front matter
/// substitutions.
String _markdown(String id, {Map<String, String> replace = const {}}) {
  var frontMatter =
      '''
id: $id
country: GB
title: How a rule works
topics: [crypto]
entityKinds: [individual]
taxYears: []
grade: primary
verifiedOn: 2026-11-13
recheckBy: 2027-04-06
perimeter: general
needsEvidence: false
announced: false
keywords: [crypto]
sources:
  - title: HMRC
    url: https://www.gov.uk/x
    grade: primary
''';
  for (final MapEntry(key: from, value: to) in replace.entries) {
    frontMatter = frontMatter.replaceFirst(from, to);
  }
  return '---\n$frontMatter---\n\nBody text.\n';
}

void main() {
  group('parseKnowledgeCardMarkdown', () {
    const markdown = '''
---
id: gb-cgt-crypto-matching
country: GB
title: How disposals of the same crypto token are matched
topics: [crypto, capital-gains]
entityKinds: [individual, soleTrader]
taxYears: [2025, 2026]
grade: secondary
verifiedOn: 2026-11-13
recheckBy: 2027-04-06
perimeter: taxIllustration
needsEvidence: true
announced: false
keywords: [
  same-day rule,
  30-day rule,
  section 104 pool,
]
skill: crypto-tax/references/gb.md
sources:
  - title: HMRC Cryptoassets Manual, pooling
    url: https://www.gov.uk/hmrc-internal-manuals/cryptoassets-manual
    grade: primary
  - title: "A briefing note: pooled disposals"
    url: https://www.example-advisers.org/pooled-disposals
    grade: secondary
---

This card's figures are graded secondary, from adviser summaries.

When you dispose of a token, HMRC matches it first with tokens of the same
kind bought on the same day, then with those bought in the next 30 days.
''';

    test('reads every front matter field and trims the body', () {
      final card = parseKnowledgeCardMarkdown(markdown, path: 'gb/x.md');
      expect(card.id, 'gb-cgt-crypto-matching');
      expect(card.countryCode, 'GB');
      expect(card.title, 'How disposals of the same crypto token are matched');
      expect(card.topics, ['crypto', 'capital-gains']);
      expect(card.entityKinds, [EntityKind.individual, EntityKind.soleTrader]);
      expect(card.taxYears, [2025, 2026]);
      expect(card.grade, TaxEvidenceGrade.secondary);
      expect(card.verifiedOn, DateTime.utc(2026, 11, 13));
      expect(card.recheckBy, DateTime.utc(2027, 4, 6));
      expect(card.perimeter, KnowledgePerimeter.taxIllustration);
      expect(card.needsEvidence, isTrue);
      expect(card.announced, isFalse);
      expect(card.keywords, hasLength(3));
      expect(card.skill, 'crypto-tax/references/gb.md');
      expect(card.sources, hasLength(2));
      expect(
        card.sources.first.url,
        Uri.https('www.gov.uk', '/hmrc-internal-manuals/cryptoassets-manual'),
      );
      expect(card.sources.first.grade, TaxEvidenceGrade.primary);
      expect(card.citeAs, card.id);
      expect(card.isUniversal, isFalse);
      expect(card.body, startsWith("This card's figures are graded"));
      expect(card.body, endsWith('in the next 30 days.'));
    });

    test('rejects a file without a front matter block', () {
      expect(
        () => parseKnowledgeCardMarkdown('Just text.', path: 'x.md'),
        throwsA(
          isA<KnowledgeFormatException>().having(
            (error) => error.toString(),
            'toString',
            contains('front matter'),
          ),
        ),
      );
    });

    test('rejects an unknown front matter key and names the card', () {
      final typo = _markdown(
        'gb-typo-card',
        replace: {
          'title: How a rule works': 'titel: How a rule works',
        },
      );
      expect(
        () => parseKnowledgeCardMarkdown(typo, path: 'gb/typo.md'),
        throwsA(
          isA<KnowledgeFormatException>().having(
            (e) => e.toString(),
            'toString',
            allOf(contains('gb-typo-card'), contains('"titel"')),
          ),
        ),
      );
    });

    test('rejects an unknown entity kind', () {
      final markdown = _markdown(
        'gb-bad-kind',
        replace: {
          'entityKinds: [individual]': 'entityKinds: [trust]',
        },
      );
      expect(
        () => parseKnowledgeCardMarkdown(markdown, path: 'x.md'),
        throwsA(
          isA<KnowledgeFormatException>().having(
            (e) => e.message,
            'message',
            contains('entityKinds'),
          ),
        ),
      );
    });

    test('rejects an unknown perimeter', () {
      final markdown = _markdown(
        'gb-bad-perimeter',
        replace: {
          'perimeter: general': 'perimeter: everywhere',
        },
      );
      expect(
        () => parseKnowledgeCardMarkdown(markdown, path: 'x.md'),
        throwsA(
          isA<KnowledgeFormatException>().having(
            (e) => e.message,
            'message',
            contains('perimeter'),
          ),
        ),
      );
    });
  });

  group('validateKnowledgeCards', () {
    test('a valid card produces no issue', () {
      expect(validateKnowledgeCards([_card()]), isEmpty);
    });

    test('a card without a source fails with the card id', () {
      final card = _card(id: 'universal-no-source', sources: const []);
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.cardId, 'universal-no-source');
      expect(issues.single.rule, contains('at least one source'));
    });

    test('a duplicate id fails', () {
      final a = _card(id: 'universal-dup');
      final b = _card(id: 'universal-dup', title: 'Another card');
      final issues = validateKnowledgeCards([a, b]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('used twice'));
      expect(issues.single.cardId, 'universal-dup');
    });

    test('an unknown figure for a year fails with the figure and year', () {
      final card = _card(
        id: 'gb-cgt-unknown-figure',
        countryCode: 'GB',
        taxYears: const [2026],
        keywords: const ['capital gains', 'crypto'],
        body: 'The annual exempt amount is {{figure:noSuchFigureId}}.',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.cardId, 'gb-cgt-unknown-figure');
      expect(
        issues.single.rule,
        allOf(contains('noSuchFigureId'), contains('2026')),
      );
    });

    test('a real figure for every listed year produces no issue', () {
      final card = _card(
        id: 'gb-cgt-exempt-amount',
        countryCode: 'GB',
        taxYears: const [2025, 2026],
        keywords: const ['capital gains', 'exempt amount'],
        body: 'The annual exempt amount is {{figure:capitalGainsAnnualExemptAmount}}.',
      );
      expect(validateKnowledgeCards([card]), isEmpty);
    });

    test('a body over 300 words fails', () {
      final longBody = List.generate(
        maxCardBodyWords + 1,
        (i) => 'w$i',
      ).join(' ');
      final card = _card(id: 'universal-too-long', body: longBody);
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('at most $maxCardBodyWords'));
    });

    test('a forbidden phrase in the body fails', () {
      final card = _card(
        id: 'universal-forbidden-phrase',
        body: 'Before selling, you should check the matching rules.',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('"you should"'));
    });

    test('an imperative title fails', () {
      final card = _card(
        id: 'gb-imperative-title',
        countryCode: 'GB',
        title: 'Claim the trading allowance today',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('imperative "claim"'));
    });

    test('a title starting with a noun that begins like a verb passes', () {
      final card = _card(
        id: 'gb-paye-thresholds',
        countryCode: 'GB',
        title: 'PAYE thresholds for employers',
        keywords: const ['PAYE'],
      );
      expect(validateKnowledgeCards([card]), isEmpty);
    });

    test('a secondary card must say so in its body', () {
      final card = _card(
        id: 'universal-secondary',
        grade: TaxEvidenceGrade.secondary,
        sources: [
          KnowledgeCardSource(
            title: 'Adviser summary',
            url: Uri.https('www.example-advisers.org', '/summary'),
            grade: TaxEvidenceGrade.secondary,
          ),
        ],
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('secondary card must say so'));
    });

    test('a universal card with a figure placeholder fails', () {
      final card = _card(
        id: 'universal-with-placeholder',
        body: 'The allowance is {{figure:personalAllowance}}.',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(issues.single.rule, contains('no figure or taxYear placeholder'));
    });

    test('an unknown placeholder fails', () {
      final card = _card(
        id: 'gb-unknown-placeholder',
        countryCode: 'GB',
        keywords: const ['PAYE'],
        body: 'The rate is {{rate:basic}}.',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues.single.rule, contains('unknown placeholder {rate:basic}'));
    });

    test('a year outside the pack fails with the known years', () {
      final card = _card(
        id: 'gb-old-year',
        countryCode: 'GB',
        taxYears: const [2020],
        keywords: const ['capital gains'],
        body: 'The exempt amount is {{figure:capitalGainsAnnualExemptAmount}}.',
      );
      final issues = validateKnowledgeCards([card]);
      expect(issues, hasLength(1));
      expect(
        issues.single.rule,
        allOf(contains('2020'), contains('known years')),
      );
    });

    test('an id must be kebab case, short and prefixed by its country', () {
      final longId = 'universal-${'a' * 45}';
      expect(
        validateKnowledgeCards([_card(id: 'universal-Bad_Id')]).single.rule,
        contains('kebab'),
      );
      expect(
        validateKnowledgeCards([_card(id: 'gb-not-universal')]).single.rule,
        contains('starts with "universal-"'),
      );
      expect(
        validateKnowledgeCards([_card(id: longId)]).single.rule,
        contains('longer than $maxCardIdLength'),
      );
    });

    test('recheckBy before verifiedOn fails', () {
      final card = KnowledgeCard(
        id: 'universal-stale-dates',
        countryCode: universalCountryCode,
        title: 'Dates out of order',
        topics: const ['money'],
        entityKinds: const [],
        taxYears: const [],
        grade: TaxEvidenceGrade.primary,
        verifiedOn: DateTime.utc(2027, 4, 6),
        recheckBy: DateTime.utc(2026, 11, 13),
        perimeter: KnowledgePerimeter.general,
        needsEvidence: false,
        announced: false,
        keywords: const ['dates'],
        sources: [
          KnowledgeCardSource(
            title: 'Test',
            url: Uri.https('www.gov.uk', '/x'),
            grade: TaxEvidenceGrade.primary,
          ),
        ],
        body: 'Body.',
      );
      expect(validateKnowledgeCards([card]).single.rule, contains('recheckBy'));
    });
  });

  group('resolveCardBody', () {
    KnowledgeCard gbCard(String body) => _card(
      id: 'gb-resolve',
      countryCode: 'GB',
      taxYears: const [2026],
      keywords: const ['allowance'],
      body: body,
    );

    test('resolves a figure and the tax year label', () {
      final resolved = resolveCardBody(
        gbCard(
          'For {{taxYear}} the exempt amount is {{figure:capitalGainsAnnualExemptAmount}}.',
        ),
        2026,
      );
      expect(resolved, isNot(contains('{{')));
      expect(resolved, contains('2026/27'));
      expect(resolved, matches(RegExp(r'£[\d,]+')));
    });

    test('keeps the pack value for a known figure', () {
      final resolved = resolveCardBody(
        gbCard('The allowance is {{figure:personalAllowance}}.'),
        2025,
      );
      expect(resolved, contains('£12,570'));
    });

    test('throws with the card id for an unknown figure', () {
      expect(
        () => resolveCardBody(gbCard('{{figure:missing}}'), 2026),
        throwsA(
          isA<KnowledgeFormatException>().having(
            (error) => error.toString(),
            'toString',
            allOf(contains('gb-resolve'), contains('missing')),
          ),
        ),
      );
    });

    test('throws for a year the pack does not know', () {
      expect(
        () => resolveCardBody(gbCard('Body.'), 2030),
        throwsA(isA<KnowledgeFormatException>()),
      );
    });

    test('a universal body comes back unchanged', () {
      final card = _card(body: 'Written out, with its source.');
      expect(resolveCardBody(card, 2026), 'Written out, with its source.');
    });
  });

  group('the shipped sample cards', () {
    test('the corpus holds exactly the five universal samples', () {
      expect(knowledgeCards, hasLength(5));
      expect(knowledgeCards.map((card) => card.id).toSet(), hasLength(5));
      for (final card in knowledgeCards) {
        expect(card.isUniversal, isTrue, reason: card.id);
        expect(card.sources, isNotEmpty, reason: card.id);
        expect(
          countWords(card.body),
          lessThanOrEqualTo(maxCardBodyWords),
          reason: card.id,
        );
      }
    });

    test('the shipped cards pass every format rule', () {
      expect(validateKnowledgeCards(knowledgeCards), isEmpty);
    });

    test('every shipped card sits in its folder by topic', () {
      expect(
        knowledgeCards.map((card) => card.id),
        containsAll(<String>[
          'universal-budgeting-zero-based-envelopes',
          'universal-budgeting-sinking-funds',
          'universal-money-emergency-fund',
          'universal-money-what-aer-means',
          'universal-crypto-crypto-tax-reporting',
        ]),
      );
    });
  });
}
