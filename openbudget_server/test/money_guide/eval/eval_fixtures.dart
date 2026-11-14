import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';

import 'golden_schema.dart';
import 'strict_yaml.dart';

/// Where the eval's data lives, relative to `openbudget_server/`.
const String evalRoot = 'test/money_guide';

/// A seeded entity every golden question of a file is asked against
/// (`fixtures/entities.yaml`).
final class EvalFixture {
  const EvalFixture({
    required this.id,
    required this.kind,
    required this.countryCode,
    required this.currencyCode,
    required this.timeZone,
  });

  factory EvalFixture.fromYaml(String id, Object? value, String path) {
    final raw = asStringMap(value, path);
    checkKeys(
      raw,
      path,
      required: {'kind', 'country', 'currency', 'timeZone'},
    );
    final kindName = asString(raw['kind'], '$path.kind');
    final kind = EntityKind.values
        .where((value) => value.name == kindName)
        .firstOrNull;
    if (kind == null) {
      throw EvalFormatException(
        '$path.kind',
        'must be one of ${EntityKind.values.map((v) => v.name).join(', ')}',
      );
    }
    return EvalFixture(
      id: id,
      kind: kind,
      countryCode: asString(raw['country'], '$path.country'),
      currencyCode: asString(raw['currency'], '$path.currency'),
      timeZone: asString(raw['timeZone'], '$path.timeZone'),
    );
  }

  final String id;
  final EntityKind kind;
  final String countryCode;
  final String currencyCode;
  final String timeZone;
}

/// Reads `fixtures/entities.yaml`.
Map<String, EvalFixture> parseFixtures(String source, {String? name}) {
  final label = name ?? 'entities.yaml';
  final root = parseYamlMap(source, name: label);
  checkKeys(root, label, required: {'fixtures'});
  final fixtures = asStringMap(root['fixtures'], '$label.fixtures');
  return {
    for (final entry in fixtures.entries)
      entry.key: EvalFixture.fromYaml(
        entry.key,
        entry.value,
        '$label.fixtures.${entry.key}',
      ),
  };
}

/// One step of a recorded model turn.
sealed class RecordedStep {
  const RecordedStep({
    this.promptTokens,
    this.cachedTokens,
    this.completionTokens,
  });

  /// Token counts the recording reports for this model call; defaults fill
  /// the gaps.
  final int? promptTokens;
  final int? cachedTokens;
  final int? completionTokens;
}

/// The model asks for a tool.
final class RecordedToolCall extends RecordedStep {
  const RecordedToolCall({
    required this.name,
    required this.arguments,
    super.promptTokens,
    super.cachedTokens,
    super.completionTokens,
  });

  final String name;

  /// Arguments as the model sent them. The string `{{entityId}}` stands for
  /// the fixture entity's id.
  final Map<String, Object?> arguments;
}

/// The model answers in text.
final class RecordedReply extends RecordedStep {
  const RecordedReply({
    required this.text,
    super.promptTokens,
    super.cachedTokens,
    super.completionTokens,
  });

  final String text;
}

/// A recorded model turn and the verdict the grader must reach on it
/// (`fixtures/recordings/*.yaml`).
final class EvalRecording {
  const EvalRecording({
    required this.id,
    required this.question,
    required this.passes,
    required this.failedGates,
    required this.steps,
  });

  factory EvalRecording.parse(String source, {required String name}) {
    final root = parseYamlMap(source, name: name);
    checkKeys(
      root,
      name,
      required: {'id', 'question', 'expect', 'steps'},
      optional: {'note'},
    );
    final expect = asStringMap(root['expect'], '$name.expect');
    checkKeys(
      expect,
      '$name.expect',
      required: {'verdict'},
      optional: {'failedGates'},
    );
    final verdict = asString(expect['verdict'], '$name.expect.verdict');
    if (verdict != 'pass' && verdict != 'fail') {
      throw EvalFormatException(
        '$name.expect.verdict',
        'must be pass or fail',
      );
    }
    final failedGates = asStringList(
      expect['failedGates'],
      '$name.expect.failedGates',
    );
    if ((verdict == 'fail') != failedGates.isNotEmpty) {
      throw EvalFormatException(
        '$name.expect',
        'a failing recording lists failedGates; a passing one lists none',
      );
    }
    final steps = [
      for (final (index, raw) in asMapList(
        root['steps'],
        '$name.steps',
      ).indexed)
        _parseStep(raw, '$name.steps[$index]'),
    ];
    if (steps.isEmpty) {
      throw EvalFormatException('$name.steps', 'must not be empty');
    }
    return EvalRecording(
      id: asString(root['id'], '$name.id'),
      question: asString(root['question'], '$name.question'),
      passes: verdict == 'pass',
      failedGates: failedGates.toSet(),
      steps: steps,
    );
  }

  final String id;

  /// The golden question this turn answers.
  final String question;

  /// Whether the grader must pass this turn.
  final bool passes;

  /// The gates that must fail, by name, when [passes] is false.
  final Set<String> failedGates;

  final List<RecordedStep> steps;
}

RecordedStep _parseStep(Map<String, Object?> raw, String path) {
  final isTool = raw.containsKey('tool');
  checkKeys(
    raw,
    path,
    required: {if (isTool) 'tool' else 'say'},
    optional: {if (isTool) 'arguments', 'prompt', 'cached', 'completion'},
  );
  final prompt = raw['prompt'] == null
      ? null
      : asInt(raw['prompt'], '$path.prompt');
  final cached = raw['cached'] == null
      ? null
      : asInt(raw['cached'], '$path.cached');
  final completion = raw['completion'] == null
      ? null
      : asInt(raw['completion'], '$path.completion');
  if (isTool) {
    return RecordedToolCall(
      name: asString(raw['tool'], '$path.tool'),
      arguments: asStringMap(
        raw['arguments'] ?? const <String, Object?>{},
        '$path.arguments',
      ),
      promptTokens: prompt,
      cachedTokens: cached,
      completionTokens: completion,
    );
  }
  return RecordedReply(
    text: asString(raw['say'], '$path.say'),
    promptTokens: prompt,
    cachedTokens: cached,
    completionTokens: completion,
  );
}

/// Every golden file under `golden/`, by file name.
Map<String, GoldenFile> loadGoldenFiles({String root = evalRoot}) => {
  for (final file in _yamlFiles('$root/golden'))
    _basename(file): GoldenFile.parse(
      file.readAsStringSync(),
      name: _basename(file),
    ),
};

/// The seeded fixture entities of `fixtures/entities.yaml`.
Map<String, EvalFixture> loadFixtures({String root = evalRoot}) =>
    parseFixtures(
      File('$root/fixtures/entities.yaml').readAsStringSync(),
    );

/// Every recorded turn under `fixtures/recordings/`.
List<EvalRecording> loadRecordings({String root = evalRoot}) => [
  for (final file in _yamlFiles('$root/fixtures/recordings'))
    EvalRecording.parse(file.readAsStringSync(), name: _basename(file)),
];

List<File> _yamlFiles(String directory) =>
    Directory(directory)
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.yaml'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

String _basename(File file) => file.uri.pathSegments.last;
