/// The live Money guide eval (docs/money-guide.md, section 8.3).
///
/// It asks every golden question three times of the real model through the
/// real `AgentService`, grades each run with the deterministic grader, and
/// writes a cost and pass-rate report under `test/money_guide/eval_reports/`
/// (gitignored). It costs money, so `dart_test.yaml` skips the `live_eval`
/// tag unless it is asked for by name.
///
/// Run it from `openbudget_server/`, with the key filled by Monosecret:
///
/// ```bash
/// msr --reason "Money guide eval" dart test --run-skipped -t live_eval test/money_guide/live_eval_test.dart
/// ```
///
/// The key comes only from the `OPENCODE_ZEN_API_KEY` environment variable.
/// It goes to the provider's `Authorization` header and nowhere else. The run
/// logs question ids, pass or fail, token counts and cost, and never the key
/// or any message content. The report holds the same and nothing more.
@Tags(['live_eval'])
library;

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openbudget_server/src/agent/agent_provider_resolver.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';
import 'eval/eval_fixtures.dart';
import 'eval/eval_report.dart';
import 'eval/eval_runner.dart';
import 'eval/eval_suite.dart';

/// The environment variable that carries the provider key.
const String _keyVariable = 'OPENCODE_ZEN_API_KEY';

/// How many times each question runs (docs/money-guide.md, section 8.3).
const int _runsPerQuestion = 3;

void main() {
  withServerpod('Given the Money guide eval against the live model', (
    sessionBuilder,
    endpoints,
  ) {
    test(
      'then every golden question is asked and graded, and a report is written',
      () async {
        final apiKey = Platform.environment[_keyVariable]?.trim();
        if (apiKey == null || apiKey.isEmpty) {
          fail(
            'Set $_keyVariable, for example with Monosecret: '
            'msr --reason "Money guide eval" dart test --run-skipped '
            '-t live_eval test/money_guide/live_eval_test.dart',
          );
        }

        final fixtures = loadFixtures();
        final goldenFiles = loadGoldenFiles();
        final transport = RecordingClient(http.Client());
        final harness = await EvalHarness.start(
          sessionBuilder: sessionBuilder,
          endpoints: endpoints,
          fixtures: fixtures,
          transport: transport,
          baseUrl: AgentProviderResolver.zenEndpoint.replaceFirst(
            '/chat/completions',
            '',
          ),
          model: AgentProviderResolver.zenModel,
          apiKey: apiKey,
        );
        addTearDown(() {
          harness.close();
          transport.close();
        });

        final outcomes = await runEvalSuite(
          harness: harness,
          goldenFiles: goldenFiles,
          runsPerQuestion: _runsPerQuestion,
          onRun: _logRun,
        );

        final generatedAt = DateTime.now().toUtc();
        final report = renderReport(
          countries: outcomes,
          model: AgentProviderResolver.zenModel,
          runsPerQuestion: _runsPerQuestion,
          generatedAt: generatedAt,
        );
        final file = writeReport(report, generatedAt: generatedAt);

        _log('[live_eval] report written to ${file.path}');
        for (final country in outcomes) {
          _log(
            '[live_eval] ${country.country}: '
            '${country.passedQuestions}/${country.questions.length} questions '
            'passed, median cost ${country.medianCostMicroUsd} micro-USD',
          );
        }

        // The run only fails when it could not measure anything. Whether a
        // country meets the thresholds is the report's verdict, so a prompt
        // under tuning still produces a report.
        expect(
          outcomes.expand((country) => country.questions).expand((q) => q.runs),
          isNotEmpty,
        );
      },
      timeout: const Timeout(Duration(minutes: 45)),
    );
  });
}

/// Logs one run: the question id, pass or fail, the failed gate names, token
/// counts and cost. Nothing the user or the model wrote.
void _logRun(GradedRun graded, int index) {
  final run = graded.run;
  final gates = {for (final failure in graded.failures) failure.gate.name};
  _log(
    '[live_eval] ${run.questionId} run ${index + 1}/$_runsPerQuestion '
    '${graded.passed ? 'pass' : 'FAIL ${gates.join(',')}'} '
    'calls=${run.modelCalls} prompt=${run.promptTokens} '
    'cached=${run.cachedTokens} completion=${run.completionTokens} '
    'cost=${run.costMicroUsd}micro-USD',
  );
}

/// Writes one line to the test output. The eval's progress is the point of
/// running it, so it prints rather than hiding behind a reporter.
void _log(String line) {
  // ignore: avoid_print, the live run's progress is meant to be read.
  print(line);
}
