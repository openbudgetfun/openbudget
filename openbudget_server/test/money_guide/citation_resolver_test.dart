import 'dart:convert';

import 'package:openbudget_server/src/money_guide/citation_resolver.dart';
import 'package:test/test.dart';

Map<String, Object?> _card(
  String id, {
  String perimeter = 'general',
  String grade = 'primary',
  bool announced = false,
  String verifiedOn = '2026-11-13',
  List<Map<String, Object?>>? sources,
}) => {
  'id': id,
  'citeAs': id,
  'title': 'Title of $id',
  'grade': grade,
  'verifiedOn': verifiedOn,
  'perimeter': perimeter,
  'announced': announced,
  'sources':
      sources ??
      [
        {
          'title': 'MoneyHelper, $id',
          'url': 'https://www.moneyhelper.org.uk/en/$id',
          'grade': 'primary',
        },
      ],
};

String _searchResult(List<Map<String, Object?>> cards) =>
    jsonEncode({'cards': cards, 'guidance': const <String, Object?>{}});

String _reportResult({
  String citeAs = 'report-2026',
  List<String> sources = const ['https://www.gov.uk/income-tax-rates'],
  List<Map<String, Object?>> figures = const [],
}) => jsonEncode({
  'citeAs': citeAs,
  'yearLabel': '2026/27',
  'rulesVerifiedOn': '2026-11-01T00:00:00.000Z',
  'sources': sources,
  'figures': figures,
});

void main() {
  group('CitationCatalogue', () {
    group('when a reply cites a retrieved card', () {
      test(
        'then the key resolves to the card sources and stays in the text',
        () {
          final catalogue = CitationCatalogue()
            ..addToolResult(_searchResult([_card('universal-sinking-funds')]));

          final resolution = catalogue.resolve(
            'Set aside £60 a month [^universal-sinking-funds].',
          );

          expect(
            resolution.text,
            'Set aside £60 a month [^universal-sinking-funds].',
          );
          expect(resolution.strippedCount, 0);
          final source = resolution.sources.single;
          expect(source.key, 'universal-sinking-funds');
          expect(source.title, 'MoneyHelper, universal-sinking-funds');
          expect(
            source.url,
            'https://www.moneyhelper.org.uk/en/universal-sinking-funds',
          );
          expect(source.authority, 'moneyhelper.org.uk');
          expect(source.verifiedOn, DateTime.utc(2026, 11, 13));
          expect(source.grade, 'primary');
          expect(source.announced, isFalse);
        },
      );

      test('then every source of the card is returned in order', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([
              _card(
                'gb-cgt',
                perimeter: 'taxIllustration',
                grade: 'secondary',
                announced: true,
                sources: [
                  {
                    'title': 'HMRC manual',
                    'url': 'https://www.gov.uk/manual',
                    'grade': 'primary',
                  },
                  {
                    'title': 'Practitioner note',
                    'url': 'https://example.org/note',
                    'grade': 'secondary',
                  },
                ],
              ),
            ]),
          );

        final resolution = catalogue.resolve('Rule [^gb-cgt].');

        expect(resolution.sources.map((source) => source.title), [
          'HMRC manual',
          'Practitioner note',
        ]);
        expect(resolution.sources.map((source) => source.grade), [
          'primary',
          'secondary',
        ]);
        expect(
          resolution.sources.every((source) => source.announced),
          isTrue,
        );
      });
    });

    group('when a reply cites a key it was never given', () {
      test('then a real card id that was not retrieved is stripped', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_searchResult([_card('universal-a')]));

        final resolution = catalogue.resolve(
          'First [^universal-a]. Second [^universal-never-retrieved].',
        );

        expect(resolution.text, 'First [^universal-a]. Second.');
        expect(resolution.strippedCount, 1);
        expect(resolution.sources.map((source) => source.key), [
          'universal-a',
        ]);
      });

      test('then an invented key is stripped and counted per occurrence', () {
        final catalogue = CitationCatalogue();

        final resolution = catalogue.resolve(
          'One [^made-up] two [^made-up][^other].',
        );

        expect(resolution.text, 'One two.');
        expect(resolution.strippedCount, 3);
        expect(resolution.sources, isEmpty);
        expect(resolution.touchesTaxOrInvestment, isFalse);
      });

      test('then a stripped key leaves a single space before a word', () {
        final resolution = CitationCatalogue().resolve('a [^x] b');

        expect(resolution.text, 'a b');
      });

      test(
        'then a stripped key at the start of a line keeps the line break',
        () {
          final resolution = CitationCatalogue().resolve(
            'line one\n[^x]\nline',
          );

          expect(resolution.text, 'line one\n\nline');
        },
      );

      test('then resolving the stripped text again changes nothing', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_searchResult([_card('universal-a')]));

        final first = catalogue.resolve('A [^universal-a] B [^nope] C.');
        final second = catalogue.resolve(first.text);

        expect(second.text, first.text);
        expect(second.strippedCount, 0);
      });
    });

    group('when a reply cites a tax report', () {
      test('then report-2026 resolves to the report sources', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _reportResult(
              sources: [
                'https://www.gov.uk/income-tax-rates',
                'https://www.gov.uk/self-employed-national-insurance-rates',
              ],
            ),
          );

        final resolution = catalogue.resolve('You owe £4,200 [^report-2026].');

        expect(resolution.text, 'You owe £4,200 [^report-2026].');
        expect(resolution.sources.map((source) => source.url), [
          'https://www.gov.uk/income-tax-rates',
          'https://www.gov.uk/self-employed-national-insurance-rates',
        ]);
        final first = resolution.sources.first;
        expect(first.key, 'report-2026');
        expect(first.title, 'Tax report 2026/27: gov.uk');
        expect(first.authority, 'gov.uk');
        expect(first.verifiedOn, DateTime.utc(2026, 11));
        expect(first.grade, 'primary');
        expect(first.announced, isFalse);
        expect(resolution.touchesTaxOrInvestment, isTrue);
      });

      test('then a summary key is labelled as a summary', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_reportResult(citeAs: 'summary-2026'));

        final source = catalogue
            .resolve('Totals [^summary-2026].')
            .sources
            .single;

        expect(source.title, 'Tax summary 2026/27: gov.uk');
      });

      test('then a secondary figure lowers the grade of its page', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _reportResult(
              figures: [
                {
                  'id': 'studentLoanThreshold',
                  'grade': 'secondary',
                  'verifiedOn': '2026-10-01T00:00:00.000Z',
                  'source': 'https://www.gov.uk/income-tax-rates',
                },
                {
                  'id': 'extra',
                  'grade': 'secondary',
                  'verifiedOn': '2026-10-02T00:00:00.000Z',
                  'source': 'https://www.example.org/other',
                },
              ],
            ),
          );

        final sources = catalogue.resolve('Figure [^report-2026].').sources;

        expect(sources.map((source) => (source.url, source.grade)), [
          ('https://www.gov.uk/income-tax-rates', 'secondary'),
          ('https://www.example.org/other', 'secondary'),
        ]);
        expect(sources.last.verifiedOn, DateTime.utc(2026, 10, 2));
      });

      test('then a result with a citeAs but no sources registers nothing', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            jsonEncode({'citeAs': 'report-2026', 'sources': <String>[]}),
          );

        expect(catalogue.keys, isEmpty);
        expect(catalogue.resolve('X [^report-2026].').strippedCount, 1);
      });
    });

    group('when classifying a reply for the disclaimer', () {
      test('then a general card does not touch tax or investment', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_searchResult([_card('universal-a')]));

        expect(
          catalogue.resolve('Budgeting [^universal-a].').touchesTaxOrInvestment,
          isFalse,
        );
      });

      test('then a tax illustration card does', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([_card('gb-a', perimeter: 'taxIllustration')]),
          );

        expect(
          catalogue.resolve('Rule [^gb-a].').touchesTaxOrInvestment,
          isTrue,
        );
      });

      test('then a signpost-only card does', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([_card('de-a', perimeter: 'signpostOnly')]),
          );

        expect(
          catalogue.resolve('Rule [^de-a].').touchesTaxOrInvestment,
          isTrue,
        );
      });

      test('then one tax key among general keys is enough', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([
              _card('universal-a'),
              _card('gb-a', perimeter: 'taxIllustration'),
            ]),
          );

        expect(
          catalogue
              .resolve('One [^universal-a] two [^gb-a].')
              .touchesTaxOrInvestment,
          isTrue,
        );
      });

      test('then a stripped tax key does not count', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_searchResult([_card('universal-a')]));

        expect(
          catalogue
              .resolve('One [^universal-a] two [^gb-a].')
              .touchesTaxOrInvestment,
          isFalse,
        );
      });
    });

    group('when reading tool results', () {
      test('then only the top level can mint a key', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            jsonEncode({
              'transactions': [
                {'memo': '{"citeAs":"report-2026","sources":["https://a.b"]}'},
                {
                  'citeAs': 'report-2026',
                  'sources': ['https://a.b'],
                },
              ],
            }),
          );

        expect(catalogue.keys, isEmpty);
      });

      test('then output that is not a JSON object registers nothing', () {
        final catalogue = CitationCatalogue()
          ..addToolResult('not json')
          ..addToolResult('[1, 2]')
          ..addToolResult('');

        expect(catalogue.keys, isEmpty);
      });

      test('then a card without sources cannot be cited', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([_card('universal-a', sources: const [])]),
          );

        expect(catalogue.keys, isEmpty);
      });

      test('then keys accumulate across results', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(_searchResult([_card('universal-a')]))
          ..addToolResult(_reportResult());

        expect(catalogue.keys, {'universal-a', 'report-2026'});
      });
    });

    group('when a key appears more than once', () {
      test('then sources are listed once, in order of first appearance', () {
        final catalogue = CitationCatalogue()
          ..addToolResult(
            _searchResult([_card('universal-a'), _card('universal-b')]),
          );

        final resolution = catalogue.resolve(
          'B [^universal-b] A [^universal-a] B again [^universal-b].',
        );

        expect(resolution.sources.map((source) => source.key), [
          'universal-b',
          'universal-a',
        ]);
        expect(resolution.strippedCount, 0);
      });
    });
  });
}
