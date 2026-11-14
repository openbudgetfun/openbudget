import 'eval_grader.dart';
import 'eval_report.dart';
import 'eval_runner.dart';
import 'golden_schema.dart';

/// The provider failures in a row after which a suite stops, so a bad key
/// or an outage does not spend a whole timeout.
const int maxConsecutiveProviderErrors = 3;

/// Thrown when a suite stops because the provider keeps failing.
final class EvalAborted implements Exception {
  const EvalAborted(this.questionId);

  /// The question being asked when the suite stopped.
  final String questionId;

  @override
  String toString() =>
      'The provider failed $maxConsecutiveProviderErrors runs in a row at '
      '$questionId, so the eval stopped. Check the key and the provider '
      'status.';
}

/// Asks every question of [goldenFiles] [runsPerQuestion] times through
/// [harness], grades each run, and returns the outcomes per file.
///
/// The offline test and the live test share this loop, so the loop the live
/// run depends on is exercised in CI. [beforeRun] lets a caller prepare the
/// transport for a run; [onRun] reports each graded run.
Future<List<CountryOutcome>> runEvalSuite({
  required EvalHarness harness,
  required Map<String, GoldenFile> goldenFiles,
  required int runsPerQuestion,
  Future<void> Function(GoldenQuestion question, int runIndex)? beforeRun,
  void Function(GradedRun graded, int runIndex)? onRun,
}) async {
  final outcomes = <CountryOutcome>[];
  var consecutiveProviderErrors = 0;
  for (final file in goldenFiles.values) {
    final grader = EvalGrader(
      countryCode: harness.fixtures[file.fixture]!.countryCode,
    );
    final questions = <QuestionOutcome>[];
    for (final question in file.questions) {
      final runs = <GradedRun>[];
      for (var index = 0; index < runsPerQuestion; index++) {
        await beforeRun?.call(question, index);
        final run = await harness.runQuestion(file, question, runIndex: index);
        final graded = GradedRun(run, grader.grade(question, run));
        runs.add(graded);
        onRun?.call(graded, index);

        consecutiveProviderErrors = run.error == null
            ? 0
            : consecutiveProviderErrors + 1;
        if (consecutiveProviderErrors >= maxConsecutiveProviderErrors) {
          throw EvalAborted(question.id);
        }
      }
      questions.add(QuestionOutcome(question, runs));
    }
    outcomes.add(CountryOutcome(file.country, questions));
  }
  return outcomes;
}
