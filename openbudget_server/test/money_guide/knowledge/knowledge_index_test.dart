import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_index.dart';
import 'package:test/test.dart';

KnowledgeCard _card(
  String id, {
  String countryCode = 'GB',
  String title = 'A test card',
  List<String> keywords = const ['taxes'],
  List<EntityKind> entityKinds = const [],
  List<int> taxYears = const [],
  String body = 'A body about taxes.',
}) => KnowledgeCard(
  id: id,
  countryCode: countryCode,
  title: title,
  topics: const ['test'],
  entityKinds: entityKinds,
  taxYears: taxYears,
  grade: TaxEvidenceGrade.primary,
  verifiedOn: DateTime.utc(2026, 11, 13),
  recheckBy: DateTime.utc(2027, 4, 6),
  perimeter: KnowledgePerimeter.general,
  needsEvidence: false,
  announced: false,
  keywords: keywords,
  sources: [
    KnowledgeCardSource(
      title: 'Test authority',
      url: Uri.https('www.gov.uk', '/test'),
      grade: TaxEvidenceGrade.primary,
    ),
  ],
  body: body,
);

Set<String> _ids(List<KnowledgeSearchResult> results) =>
    results.map((result) => result.card.id).toSet();

int _descending(double a, double b) => b.compareTo(a);

void main() {
  group('filters', () {
    final index = KnowledgeIndex([
      _card('gb-individual', keywords: const ['taxes', 'trading']),
      _card(
        'us-company',
        countryCode: 'US',
        keywords: const ['taxes', 'payroll'],
        entityKinds: const [EntityKind.company],
      ),
      _card(
        'universal-scoped',
        countryCode: universalCountryCode,
        taxYears: const [2026, 2027],
      ),
      _card(
        'universal-older',
        countryCode: universalCountryCode,
        taxYears: const [2025],
      ),
      _card('universal-timeless', countryCode: universalCountryCode),
    ]);

    test('the country filter keeps the requested country and universal', () {
      final results = index.search(country: 'GB', query: 'taxes');
      expect(_ids(results), {
        'gb-individual',
        'universal-scoped',
        'universal-older',
        'universal-timeless',
      });
      expect(_ids(results), isNot(contains('us-company')));
    });

    test('the year filter keeps cards with no years or the year', () {
      expect(
        _ids(index.search(taxYear: 2026, query: 'taxes')),
        {
          'gb-individual',
          'us-company',
          'universal-scoped',
          'universal-timeless',
        },
      );
      expect(
        _ids(index.search(taxYear: 2025, query: 'taxes')),
        {
          'gb-individual',
          'us-company',
          'universal-older',
          'universal-timeless',
        },
      );
    });

    test('the kind filter keeps cards with no kinds or the kind', () {
      expect(
        _ids(
          index.search(
            entityKind: EntityKind.soleTrader,
            query: 'taxes',
            limit: 10,
          ),
        ),
        {
          'gb-individual',
          'universal-scoped',
          'universal-older',
          'universal-timeless',
        },
      );
      expect(
        _ids(
          index.search(
            entityKind: EntityKind.company,
            query: 'taxes',
            limit: 10,
          ),
        ),
        {
          'gb-individual',
          'us-company',
          'universal-scoped',
          'universal-older',
          'universal-timeless',
        },
      );
    });

    test('the filters combine', () {
      expect(
        _ids(
          index.search(
            country: 'GB',
            taxYear: 2026,
            entityKind: EntityKind.individual,
            query: 'taxes',
            limit: 10,
          ),
        ),
        {'gb-individual', 'universal-scoped', 'universal-timeless'},
      );
    });

    test('results are capped at the limit', () {
      expect(index.search(query: 'taxes'), hasLength(defaultSearchLimit));
      expect(index.search(query: 'taxes', limit: 10), hasLength(5));
      expect(index.search(query: 'taxes', limit: 1), hasLength(1));
    });
  });

  group('ranking on the shipped samples', () {
    final index = KnowledgeIndex(knowledgeCards);

    String firstId(String query) => index.search(query: query).first.card.id;

    test('a sinking fund query ranks the sinking funds card first', () {
      expect(
        firstId('sinking fund annual bills spread the cost'),
        'universal-budgeting-sinking-funds',
      );
    });

    test('an emergency savings query ranks the emergency fund card first', () {
      expect(
        firstId('emergency savings buffer three months'),
        'universal-money-emergency-fund',
      );
    });

    test('an AER query ranks the AER card first', () {
      expect(
        firstId('AER annual equivalent rate compound interest'),
        'universal-money-what-aer-means',
      );
    });

    test('a zero-based query ranks the envelopes card first', () {
      expect(
        firstId('zero-based envelopes assign income'),
        'universal-budgeting-zero-based-envelopes',
      );
    });

    test('a crypto reporting query ranks the CARF card first', () {
      expect(
        firstId('crypto tax reporting OECD automatic exchange'),
        'universal-crypto-crypto-tax-reporting',
      );
    });

    test('results come back best first', () {
      final results = index.search(query: 'sinking fund annual bills');
      final scores = results.map((result) => result.score).toList();
      final sorted = List<double>.from(scores)..sort(_descending);
      expect(scores, orderedEquals(sorted));
    });

    test('the year filter applies to the shipped corpus', () {
      expect(
        _ids(
          index.search(
            taxYear: 2026,
            query: 'crypto tax reporting OECD automatic exchange',
          ),
        ),
        contains('universal-crypto-crypto-tax-reporting'),
      );
      expect(
        index.search(
          taxYear: 2030,
          query: 'crypto tax reporting OECD automatic exchange',
        ),
        isEmpty,
      );
    });

    test('a query nothing in the corpus matches returns no results', () {
      expect(index.search(query: 'quantum xylophone zzzblorpf'), isEmpty);
      expect(index.search(query: '   '), isEmpty);
      expect(index.search(query: ''), isEmpty);
    });
  });

  group('accent folding and the suffix rule', () {
    test('a folded keyword matches an accented query', () {
      final index = KnowledgeIndex([
        _card(
          'de-grundfreibetrag',
          countryCode: 'DE',
          keywords: const ['Grundfreibetrag', 'für Arbeiter'],
          body: 'Der Grundfreibetrag bleibt gleich.',
        ),
      ]);
      expect(index.search(query: 'GRUNDFREIBETRAG'), hasLength(1));
      expect(index.search(query: 'fûr'), hasLength(1));
    });

    test('a plural query matches a singular keyword', () {
      final index = KnowledgeIndex([
        _card('gb-rates', keywords: const ['interest rate']),
        _card('universal-budget', keywords: const ['budgeting']),
      ]);
      expect(
        _ids(index.search(query: 'interest rates')),
        {'gb-rates'},
      );
      expect(
        _ids(index.search(query: 'budgets')),
        {'universal-budget'},
      );
    });
  });
}
