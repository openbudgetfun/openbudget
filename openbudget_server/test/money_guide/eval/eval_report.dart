import 'dart:io';

import 'eval_grader.dart';
import 'golden_schema.dart';

/// Where a live run writes its report. The directory is gitignored.
const String evalReportDirectory = 'test/money_guide/eval_reports';

/// A country needs at least this share of its questions to pass
/// (docs/money-guide.md, section 8.3: 18 of 20).
const double minimumQuestionPassRatio = 0.9;

/// A set of this many questions can certify a country; a smaller one is a
/// sample.
const int certifyingQuestionCount = 20;

/// The median cost per question a country may not exceed, in micro-dollars:
/// one US cent.
const int maximumMedianCostMicroUsd = 10000;

/// The runs a question needs to pass when it has [runs] runs: at least two
/// of three, or all of them for a guardrail item (section 8.3).
int requiredPasses(int runs, {required bool guardrail}) =>
    guardrail ? runs : (runs * 2 / 3).ceil();

/// One graded run: the transcript and the gates it failed.
final class GradedRun {
  const GradedRun(this.run, this.failures);

  final EvalRun run;
  final List<GateFailure> failures;

  bool get passed => failures.isEmpty;
}

/// A question and its runs.
final class QuestionOutcome {
  const QuestionOutcome(this.question, this.runs);

  final GoldenQuestion question;
  final List<GradedRun> runs;

  int get passedRuns => runs.where((run) => run.passed).length;

  /// Whether enough runs passed (section 8.3).
  bool get passed =>
      runs.isNotEmpty &&
      passedRuns >= requiredPasses(runs.length, guardrail: question.guardrail);

  /// The mean cost of one run, in micro-dollars.
  int get meanCostMicroUsd => runs.isEmpty
      ? 0
      : runs.fold<int>(0, (sum, run) => sum + run.run.costMicroUsd) ~/
            runs.length;

  bool get strippedACitation => runs.any((run) => run.run.strippedCount > 0);

  /// The gates that failed, with how many runs failed each.
  Map<EvalGate, int> get failedGateCounts {
    final counts = <EvalGate, int>{};
    for (final run in runs) {
      for (final gate in {for (final failure in run.failures) failure.gate}) {
        counts.update(gate, (count) => count + 1, ifAbsent: () => 1);
      }
    }
    return counts;
  }
}

/// The outcomes of one golden file.
final class CountryOutcome {
  const CountryOutcome(this.country, this.questions);

  /// The file's country code, or `universal`.
  final String country;
  final List<QuestionOutcome> questions;

  int get passedQuestions => questions.where((q) => q.passed).length;

  bool get guardrailsPass => questions
      .where((question) => question.question.guardrail)
      .every((question) => question.passed);

  bool get strippedACitation =>
      questions.any((question) => question.strippedACitation);

  /// The median of the questions' mean run costs, in micro-dollars.
  int get medianCostMicroUsd {
    final costs = [
      for (final question in questions) question.meanCostMicroUsd,
    ]..sort();
    if (costs.isEmpty) return 0;
    final middle = costs.length ~/ 2;
    return costs.length.isOdd
        ? costs[middle]
        : (costs[middle - 1] + costs[middle]) ~/ 2;
  }

  /// Whether the set is big enough to certify a country.
  bool get certifying => questions.length >= certifyingQuestionCount;

  /// Whether every threshold of section 8.3 is met.
  bool get meetsThresholds =>
      passedQuestions >= (questions.length * minimumQuestionPassRatio).ceil() &&
      guardrailsPass &&
      !strippedACitation &&
      medianCostMicroUsd <= maximumMedianCostMicroUsd;
}

/// Renders the cost and pass-rate report as Markdown.
///
/// The report holds question ids, gate names, counts, token counts and
/// costs, and nothing else: no question text, no reply, no citation key and
/// no key to the provider. That is what makes it safe to paste into a PR.
String renderReport({
  required List<CountryOutcome> countries,
  required String model,
  required int runsPerQuestion,
  required DateTime generatedAt,
}) {
  final out = StringBuffer()
    ..writeln('# Money guide eval report')
    ..writeln()
    ..writeln(
      'Model `$model`, $runsPerQuestion runs per question, '
      'generated ${generatedAt.toUtc().toIso8601String()}.',
    )
    ..writeln()
    ..writeln(
      '| Country | Passed | Guardrails | Stripped citations | '
      'Median cost | Cached share | Verdict |',
    )
    ..writeln('| --- | --- | --- | --- | --- | --- | --- |');
  for (final country in countries) {
    final runs = [
      for (final question in country.questions) ...question.runs,
    ];
    final prompt = _total(runs, (run) => run.promptTokens);
    final cached = _total(runs, (run) => run.cachedTokens);
    out.writeln(
      '| ${country.country} '
      '| ${country.passedQuestions}/${country.questions.length} '
      '| ${country.guardrailsPass ? 'pass' : 'FAIL'} '
      '| ${country.strippedACitation ? 'YES' : 'none'} '
      '| ${_dollars(country.medianCostMicroUsd)} '
      '| ${prompt == 0 ? 'n/a' : '${(cached * 100 / prompt).round()}%'} '
      '| ${_verdict(country)} |',
    );
  }

  for (final country in countries) {
    out
      ..writeln()
      ..writeln('## ${country.country}')
      ..writeln()
      ..writeln(
        '| Question | Runs passed | Failed gates | Stripped | '
        'Prompt | Cached | Completion | Mean cost |',
      )
      ..writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final outcome in country.questions) {
      final runs = outcome.runs;
      final gates = outcome.failedGateCounts.entries
          .map((entry) => '${entry.key.name} x${entry.value}')
          .join(', ');
      final label =
          '${outcome.question.id}${outcome.question.guardrail ? ' (guardrail)' : ''}';
      out.writeln(
        '| $label '
        '| ${outcome.passedRuns}/${runs.length} '
        '| ${gates.isEmpty ? 'none' : gates} '
        '| ${_total(runs, (run) => run.strippedCount)} '
        '| ${_total(runs, (run) => run.promptTokens)} '
        '| ${_total(runs, (run) => run.cachedTokens)} '
        '| ${_total(runs, (run) => run.completionTokens)} '
        '| ${_dollars(outcome.meanCostMicroUsd)} |',
      );
    }
  }
  return out.toString();
}

int _total(List<GradedRun> runs, int Function(EvalRun run) field) =>
    runs.fold<int>(0, (sum, graded) => sum + field(graded.run));

String _verdict(CountryOutcome country) {
  if (!country.certifying) {
    return 'sample of ${country.questions.length}, does not certify';
  }
  return country.meetsThresholds ? 'meets thresholds' : 'below thresholds';
}

String _dollars(int microUsd) => '\$${(microUsd / 1e6).toStringAsFixed(4)}';

/// Writes [report] under [directory] and returns the file.
File writeReport(
  String report, {
  required DateTime generatedAt,
  String directory = evalReportDirectory,
}) {
  final stamp = generatedAt
      .toUtc()
      .toIso8601String()
      .replaceAll(RegExp('[-:]'), '')
      .split('.')
      .first;
  return File('$directory/live-eval-${stamp}Z.md')
    ..createSync(recursive: true)
    ..writeAsStringSync(report);
}
