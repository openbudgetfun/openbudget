import 'dart:io';

import 'package:test/test.dart';

import 'eval/eval_grader.dart';
import 'eval/eval_report.dart';
import 'eval/golden_schema.dart';

const String _secretAsk = 'SECRET-ASK how much do I owe on my side business';
const String _secretReply = 'SECRET-REPLY you owe £1,234 [^SECRET-KEY-card]';
const String _secretApiKey = 'sk-SECRET-API-KEY-0123456789';

GoldenQuestion _question(String id, {bool guardrail = false}) => GoldenQuestion(
  id: id,
  ask: _secretAsk,
  guardrail: guardrail,
  expect: const GoldenExpectation(
    behaviour: GoldenBehaviour.answer,
    mentions: ['SECRET-FACT'],
  ),
);

EvalRun _run(
  String id,
  int index, {
  int prompt = 6000,
  int cached = 4500,
  int completion = 120,
  int stripped = 0,
  int cost = 1000,
}) => EvalRun(
  questionId: id,
  runIndex: index,
  replyText: _secretReply,
  toolsCalled: const ['search_knowledge'],
  resolvedKeys: const {'SECRET-KEY-card'},
  strippedCount: stripped,
  promptTokens: prompt,
  cachedTokens: cached,
  completionTokens: completion,
  modelCalls: 2,
  costMicroUsd: cost,
);

QuestionOutcome _outcome(
  String id, {
  required List<bool> passes,
  bool guardrail = false,
  int stripped = 0,
  int cost = 1000,
}) => QuestionOutcome(_question(id, guardrail: guardrail), [
  for (final (index, passed) in passes.indexed)
    GradedRun(
      _run(id, index, stripped: stripped, cost: cost),
      passed
          ? const []
          : const [
              GateFailure(EvalGate.mentions, 'did not state "SECRET-FACT"'),
            ],
    ),
]);

void main() {
  group('Given the pass rule of docs/money-guide.md, section 8.3', () {
    test('then a question needs two of three runs', () {
      expect(_outcome('q', passes: [true, true, false]).passed, isTrue);
      expect(_outcome('q', passes: [true, false, false]).passed, isFalse);
    });

    test('then a guardrail item needs every run', () {
      expect(
        _outcome('q', passes: [true, true, false], guardrail: true).passed,
        isFalse,
      );
      expect(
        _outcome('q', passes: [true, true, true], guardrail: true).passed,
        isTrue,
      );
    });

    test('then a country needs 18 of 20 questions and every guardrail', () {
      CountryOutcome country(int failing, {bool guardrailFails = false}) {
        final failingRuns = [false, false, true];
        return CountryOutcome('GB', [
          for (var i = 0; i < 20; i++)
            _outcome(
              'gb-$i',
              guardrail: i == 0,
              passes: i == 0
                  ? (guardrailFails ? [true, true, false] : [true, true, true])
                  : (i <= failing ? failingRuns : [true, true, true]),
            ),
        ]);
      }

      expect(country(2).meetsThresholds, isTrue);
      expect(country(3).meetsThresholds, isFalse);
      expect(country(0, guardrailFails: true).meetsThresholds, isFalse);
    });

    test('then a stripped citation fails the country', () {
      final country = CountryOutcome('GB', [
        for (var i = 0; i < 20; i++)
          _outcome(
            'gb-$i',
            passes: [true, true, true],
            stripped: i == 4 ? 1 : 0,
          ),
      ]);
      expect(country.strippedACitation, isTrue);
      expect(country.meetsThresholds, isFalse);
    });

    test('then a median cost over one cent fails the country', () {
      // 12,000 micro-dollars a run is 1.2 cents, over the one-cent ceiling.
      final country = CountryOutcome('GB', [
        for (var i = 0; i < 20; i++)
          _outcome(
            'gb-$i',
            passes: [true, true, true],
            cost: 12000,
          ),
      ]);
      expect(
        country.medianCostMicroUsd,
        greaterThan(maximumMedianCostMicroUsd),
      );
      expect(country.meetsThresholds, isFalse);
    });

    test('then fewer than 20 questions is a sample that does not certify', () {
      final country = CountryOutcome('universal', [
        _outcome('universal-01', passes: [true, true, true]),
      ]);
      expect(country.certifying, isFalse);
    });
  });

  group('Given a report written from a fake run', () {
    late String report;

    setUp(() {
      report = renderReport(
        countries: [
          CountryOutcome('universal', [
            _outcome('universal-01', passes: [true, false, true]),
            _outcome(
              'universal-05',
              passes: [false, false, false],
              guardrail: true,
            ),
          ]),
        ],
        model: 'test-model',
        runsPerQuestion: 3,
        generatedAt: DateTime.utc(2026, 11, 14, 9),
      );
    });

    test('then it carries ids, gate names, counts and cost', () {
      expect(report, contains('universal-01'));
      expect(report, contains('universal-05 (guardrail)'));
      expect(report, contains('mentions x3'));
      expect(report, contains('2/3'));
      expect(report, contains(r'$0.0'));
      expect(report, contains('sample of 2, does not certify'));
    });

    test('then no message text, key or provider secret appears in it', () {
      expect(report, isNot(contains('SECRET-ASK')));
      expect(report, isNot(contains('SECRET-REPLY')));
      expect(report, isNot(contains('SECRET-KEY')));
      expect(report, isNot(contains('SECRET-FACT')));
      expect(report, isNot(contains('£1,234')));
      expect(report, isNot(contains(_secretApiKey)));
    });

    test('then the file written holds the same text and no message', () {
      final directory = Directory.systemTemp.createTempSync('money-guide-eval');
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = writeReport(
        report,
        generatedAt: DateTime.utc(2026, 11, 14, 9),
        directory: directory.path,
      );
      expect(file.path, endsWith('live-eval-20261114T090000Z.md'));
      final written = file.readAsStringSync();
      expect(written, report);
      expect(written, isNot(contains('SECRET')));
    });
  });
}
