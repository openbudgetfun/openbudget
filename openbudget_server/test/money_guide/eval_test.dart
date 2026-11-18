import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import 'eval/eval_fixtures.dart';
import 'eval/eval_grader.dart';
import 'eval/eval_replay.dart';
import 'eval/eval_report.dart';
import 'eval/eval_runner.dart';
import 'eval/eval_suite.dart';

/// The offline Money guide eval: recorded model turns replayed through the
/// real `AgentService` (the real prompt, tools and citation resolver) over a
/// mock transport, then graded by the deterministic grader of
/// docs/money-guide.md, section 8.2. It makes no network call.
void main() {
  final fixtures = loadFixtures();
  final goldenFiles = loadGoldenFiles();
  final recordings = loadRecordings();
  final questions = {
    for (final file in goldenFiles.values)
      for (final question in file.questions) question.id: (file, question),
  };

  group('Given the recordings under test/money_guide/fixtures/recordings/', () {
    test('then every recording answers a golden question', () {
      for (final recording in recordings) {
        expect(
          questions,
          contains(recording.question),
          reason: '${recording.id} answers an unknown question',
        );
      }
    });

    test('then every golden question has a recording that passes', () {
      final replayed = {
        for (final recording in recordings)
          if (recording.passes) recording.question,
      };
      expect(replayed, questions.keys.toSet());
    });

    test('then every gate that can fail has a recording that fails it', () {
      final failing = {
        for (final recording in recordings) ...recording.failedGates,
      };
      expect(
        failing,
        containsAll(
          [for (final gate in EvalGate.values) gate.name]
            ..remove(EvalGate.completed.name),
        ),
      );
    });

    test('then recording ids are unique', () {
      final ids = [for (final recording in recordings) recording.id];
      expect(ids.toSet(), hasLength(ids.length));
    });
  });

  withServerpod('Given the Money guide replayed from recordings', (
    sessionBuilder,
    endpoints,
  ) {
    late RecordingClient transport;
    late EvalHarness harness;

    setUp(() async {
      // A name that resolves to a public address, so the egress guard passes
      // without a DNS lookup.
      AgentEgressGuard.lookup = (_) async => [InternetAddress('203.0.113.10')];
      transport = RecordingClient(
        MockClient(
          (_) async => throw StateError('no network in the offline eval'),
        ),
      );
      harness = await EvalHarness.start(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
        fixtures: fixtures,
        transport: transport,
        baseUrl: 'https://api.example.test/v1',
        model: 'recorded-model',
        apiKey: 'sk-offline-test-key',
      );
    });

    tearDown(() => harness.close());

    Future<({EvalRun run, List<GateFailure> failures, ReplayTransport replay})>
    replay(EvalRecording recording) async {
      final (file, question) = questions[recording.question]!;
      final entity = await harness.entityFor(file.fixture);
      final replay = ReplayTransport(recording, entityId: entity.id.toString());
      transport.inner = replay.client;
      final run = await harness.runQuestion(file, question);
      final grader = EvalGrader(
        countryCode: fixtures[file.fixture]!.countryCode,
      );
      return (
        run: run,
        failures: grader.grade(question, run),
        replay: replay,
      );
    }

    for (final recording in recordings) {
      test(
        recording.passes
            ? 'when ${recording.id} is replayed then every gate passes'
            : 'when ${recording.id} is replayed then the grader flags '
                  '${recording.failedGates.join(', ')}',
        () async {
          final graded = await replay(recording);
          final failedGates = {
            for (final failure in graded.failures) failure.gate.name,
          };
          if (recording.passes) {
            expect(
              graded.failures,
              isEmpty,
              reason: graded.failures.join('; '),
            );
          } else {
            expect(failedGates, recording.failedGates);
          }
        },
      );
    }

    group('when a passing turn is replayed', () {
      late EvalRun run;
      late ReplayTransport replayed;

      setUp(() async {
        final recording = recordings.singleWhere(
          (recording) => recording.id == 'universal-01-pass',
        );
        final graded = await replay(recording);
        run = graded.run;
        replayed = graded.replay;
      });

      test('then the real prompt and tool definitions are sent', () {
        expect(replayed.requests, hasLength(2));
        final first = replayed.requests.first;
        expect(first, contains('You are the Money guide in OpenBudget'));
        expect(first, contains('"name":"search_knowledge"'));
        expect(first, contains('universal-budgeting-sinking-funds: '));
        expect(first, contains('£480 insurance renewal'));
      });

      test('then the tool results reach the second call', () {
        expect(replayed.requests.last, contains('"role":"tool"'));
        expect(
          replayed.requests.last,
          contains('universal-budgeting-sinking-funds'),
        );
      });

      test('then the run records tools, citations and nothing stripped', () {
        expect(run.toolsCalled, ['search_knowledge']);
        expect(run.resolvedKeys, {'universal-budgeting-sinking-funds'});
        expect(run.strippedCount, 0);
        expect(run.modelCalls, 2);
        expect(run.error, isNull);
      });

      test('then tokens and cost come from the recorded usage', () {
        expect(run.promptTokens, 13000);
        expect(run.cachedTokens, 6100);
        expect(run.completionTokens, 110);
        // Each call is priced and rounded up on its own: 1,878 for the
        // first and 361 for the second.
        expect(run.costMicroUsd, 2239);
      });
    });

    group('when the model invents a citation key', () {
      test(
        'then the run counts it as stripped and the reply drops it',
        () async {
          final graded = await replay(
            recordings.singleWhere(
              (recording) => recording.id == 'universal-01-invented-citation',
            ),
          );
          expect(graded.run.strippedCount, 1);
          expect(graded.run.replyText, isNot(contains('invented-key')));
          expect(graded.run.resolvedKeys, {
            'universal-budgeting-sinking-funds',
          });
        },
      );
    });

    group('when the whole suite runs offline', () {
      test(
        'then every passing recording is graded and the report leaks nothing',
        () async {
          final passing = {
            for (final recording in recordings)
              if (recording.passes) recording.question: recording,
          };
          final outcomes = await runEvalSuite(
            harness: harness,
            goldenFiles: goldenFiles,
            runsPerQuestion: 3,
            beforeRun: (question, runIndex) async {
              final file = goldenFiles.values.singleWhere(
                (file) => file.questions.contains(question),
              );
              final entity = await harness.entityFor(file.fixture);
              transport.inner = ReplayTransport(
                passing[question.id]!,
                entityId: entity.id.toString(),
              ).client;
            },
          );

          final universal = outcomes.single;
          expect(universal.country, 'universal');
          expect(universal.passedQuestions, universal.questions.length);
          expect(universal.guardrailsPass, isTrue);
          expect(universal.strippedACitation, isFalse);
          expect(universal.questions.every((q) => q.runs.length == 3), isTrue);

          final report = renderReport(
            countries: outcomes,
            model: 'recorded-model',
            runsPerQuestion: 3,
            generatedAt: DateTime.utc(2026, 11, 14),
          );
          expect(report, contains('universal-01'));
          expect(report, contains('6/6'));
          expect(report, contains('sample of 6, does not certify'));
          // No question and no recorded reply text reaches the report.
          for (final question in questions.values) {
            expect(report, isNot(contains(question.$2.ask)));
          }
          for (final recording in recordings) {
            for (final step in recording.steps) {
              if (step is RecordedReply) {
                expect(report, isNot(contains(step.text.split('.').first)));
              }
            }
          }
        },
      );

      test('then a provider that keeps failing stops the suite', () async {
        transport.inner = MockClient(
          (_) async => http.Response('{"error":"down"}', 500),
        );

        await expectLater(
          runEvalSuite(
            harness: harness,
            goldenFiles: goldenFiles,
            runsPerQuestion: 3,
          ),
          throwsA(isA<EvalAborted>()),
        );
        expect(transport.completions, isEmpty);
      });
    });

    group('when the recording runs out before the model answers', () {
      test(
        'then the run ends with a provider error and fails to complete',
        () async {
          final recording = recordings.singleWhere(
            (recording) => recording.id == 'universal-02-pass',
          );
          final (file, question) = questions[recording.question]!;
          final entity = await harness.entityFor(file.fixture);
          // Only the tool step: the second call finds nothing recorded.
          transport.inner = ReplayTransport(
            EvalRecording(
              id: 'truncated',
              question: recording.question,
              passes: true,
              failedGates: const {},
              steps: [recording.steps.first],
            ),
            entityId: entity.id.toString(),
          ).client;

          final run = await harness.runQuestion(file, question);

          expect(run.error, 'AgentProviderException');
          expect(
            const EvalGrader(countryCode: 'GB')
                .grade(question, run)
                .single
                .gate,
            EvalGate.completed,
          );
        },
      );
    });
  });
}
