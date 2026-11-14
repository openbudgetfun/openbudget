import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_card.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:test/test.dart';

import 'eval/eval_fixtures.dart';
import 'eval/golden_schema.dart';
import 'eval/strict_yaml.dart';

/// Keys the tax tools cite: `report-2026`, `summary-2026`, `crypto-2026`.
final RegExp _taxToolKey = RegExp(r'^(report|summary|crypto)-\d{4}$');

void main() {
  final toolNames = {
    for (final tool in const AgentToolRegistry().definitions(canPropose: true))
      (tool['function']! as Map<String, Object?>)['name']! as String,
  };
  final cardIds = {for (final card in knowledgeCards) card.id};
  final fixtures = loadFixtures();
  final goldenFiles = loadGoldenFiles();

  group('Given the golden files under test/money_guide/golden/', () {
    test('then there is at least one', () {
      expect(goldenFiles, isNotEmpty);
    });

    for (final MapEntry(key: fileName, value: file) in goldenFiles.entries) {
      group('when $fileName is read', () {
        final stem = fileName.replaceAll(RegExp(r'\.yaml$'), '');

        test('then its name is its country in lower case', () {
          expect(file.country.toLowerCase(), stem);
        });

        test('then the country is universal or a known country', () {
          expect(
            file.country == universalCountryCode ||
                Countries.byCode(file.country) != null,
            isTrue,
            reason: 'unknown country ${file.country}',
          );
        });

        test('then its fixture exists and matches its country', () {
          final fixture = fixtures[file.fixture];
          expect(fixture, isNotNull, reason: 'no fixture ${file.fixture}');
          if (file.country != universalCountryCode) {
            expect(fixture!.countryCode, file.country);
          }
        });

        test('then question ids are unique and start with the file stem', () {
          final ids = [for (final question in file.questions) question.id];
          expect(ids.toSet(), hasLength(ids.length));
          for (final id in ids) {
            expect(id, startsWith('$stem-'));
          }
        });

        test('then every tool it expects exists', () {
          for (final question in file.questions) {
            for (final tool in question.expect.tools) {
              expect(
                toolNames,
                contains(tool),
                reason: '${question.id} expects unknown tool $tool',
              );
            }
          }
        });

        test('then every key it cites is a card or a tax tool result', () {
          for (final question in file.questions) {
            for (final key in question.expect.cites) {
              expect(
                cardIds.contains(key) || _taxToolKey.hasMatch(key),
                isTrue,
                reason: '${question.id} cites unknown key $key',
              );
            }
          }
        });

        test('then a refusal states no facts', () {
          for (final question in file.questions) {
            if (question.expect.behaviour == GoldenBehaviour.refuse) {
              expect(
                question.expect.mentions,
                isEmpty,
                reason: '${question.id} is a refusal, so it states no facts',
              );
            }
          }
        });
      });
    }
  });

  group('Given a golden file that breaks the schema', () {
    const valid = '''
country: universal
fixture: gb_individual
questions:
  - id: universal-01
    ask: What is a sinking fund?
    expect:
      behaviour: answer
''';

    String? failureOf(String source) {
      try {
        GoldenFile.parse(source, name: 'bad.yaml');
      } on EvalFormatException catch (error) {
        return error.toString();
      }
      return null;
    }

    test('then the valid example parses', () {
      final file = GoldenFile.parse(valid, name: 'ok.yaml');
      expect(file.questions.single.expect.behaviour, GoldenBehaviour.answer);
      expect(file.questions.single.guardrail, isFalse);
    });

    test('then an unknown top-level key is rejected', () {
      expect(failureOf('$valid\nextra: 1\n'), contains('unknown key "extra"'));
    });

    test('then an unknown question key is rejected', () {
      expect(
        failureOf(valid.replaceFirst('    ask:', '    asks: x\n    ask:')),
        contains('unknown key "asks"'),
      );
    });

    test('then an unknown expectation key is rejected', () {
      expect(
        failureOf('$valid      cite: [x]\n'),
        contains('questions[0].expect: unknown key "cite"'),
      );
    });

    test('then a missing question is rejected', () {
      expect(
        failureOf(valid.replaceFirst('    ask: What is a sinking fund?\n', '')),
        contains('missing required key "ask"'),
      );
    });

    test('then a missing fixture is rejected', () {
      expect(
        failureOf(valid.replaceFirst('fixture: gb_individual\n', '')),
        contains('missing required key "fixture"'),
      );
    });

    test('then an unknown behaviour is rejected', () {
      expect(
        failureOf(valid.replaceFirst('behaviour: answer', 'behaviour: shrug')),
        contains('behaviour: must be one of'),
      );
    });

    test('then a list of the wrong type is rejected', () {
      expect(
        failureOf('$valid      tools: search_knowledge\n'),
        contains('questions[0].expect.tools: expected a list'),
      );
    });

    test('then a bad question id is rejected', () {
      expect(
        failureOf(valid.replaceFirst('universal-01', 'Universal 01')),
        contains('lower-case kebab case'),
      );
    });

    test('then an empty question list is rejected', () {
      expect(
        failureOf('country: universal\nfixture: x\nquestions: []\n'),
        contains('must not be empty'),
      );
    });

    test('then text that is not YAML is rejected', () {
      expect(failureOf('questions: [unclosed'), contains('not valid YAML'));
    });
  });
}
