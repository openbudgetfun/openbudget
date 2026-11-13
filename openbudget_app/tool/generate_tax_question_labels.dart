// Generates lib/src/features/tax/tax_question_labels.g.dart, the resolver
// that turns the `AppLocalizations` keys the tax rule packs name in their
// profile questions into the localized text.
//
// Every pack declares its profile questions as data in openbudget_core
// (`profileQuestions`), and each label, help text and choice option is an
// `AppLocalizations` key such as `taxQGbScottishTaxpayer`. Dart cannot look
// a getter up by name at run time, so this tool reads the declared keys
// from the packs and writes one `switch` that maps each key to its getter.
// It fails when a declared key has no string in lib/l10n/app_en.arb, so a
// pack cannot name text that does not exist.
//
//   cd openbudget_app && dart run tool/generate_tax_question_labels.dart
//   cd openbudget_app && dart run tool/generate_tax_question_labels.dart --check
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';

/// Where the generated file is written, relative to the package root.
const _outputPath = 'lib/src/features/tax/tax_question_labels.g.dart';

/// The template ARB file, relative to the package root.
const _arbPath = 'lib/l10n/app_en.arb';

Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final arb = File(_arbPath);
  if (!arb.existsSync()) {
    stderr.writeln(
      'Cannot read $_arbPath. Run this from the openbudget_app directory.',
    );
    exitCode = 1;
    return;
  }

  final keys = declaredQuestionKeys();
  final missing = missingArbKeys(
    keys,
    jsonDecode(arb.readAsStringSync()) as Map<String, Object?>,
  );
  if (missing.isNotEmpty) {
    stderr.writeln(
      'These keys are named by a tax profile question but have no plain '
      'string in $_arbPath:\n  ${missing.join('\n  ')}',
    );
    exitCode = 1;
    return;
  }

  final rendered = await _format(render(keys));
  final output = File(_outputPath);

  if (check) {
    if (!output.existsSync() || output.readAsStringSync() != rendered) {
      stderr.writeln(
        '$_outputPath is stale. Run: '
        'dart run tool/generate_tax_question_labels.dart',
      );
      exitCode = 1;
    }
    return;
  }

  output
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(rendered);
  stdout.writeln('Wrote ${keys.length} tax question labels to $_outputPath');
}

/// Every `AppLocalizations` key the packs' questions name, in the order the
/// packs declare them, once each.
List<String> declaredQuestionKeys() {
  final keys = <String>{};
  for (final jurisdiction in TaxJurisdiction.values) {
    final pack = TaxRules.forJurisdiction(jurisdiction);
    for (final kind in EntityKind.values) {
      for (final question in pack.profileQuestions(kind)) {
        keys.addAll(arbKeysOf(question));
      }
    }
  }
  return keys.toList();
}

/// The keys [question] names: its label, its help, each choice option, the
/// "none" choice, and the two halves of a month-and-day question.
List<String> arbKeysOf(TaxProfileQuestion question) => [
  question.labelKey,
  ?question.helpKey,
  if (question is TaxChoiceQuestion) ...[
    for (final option in question.options) option.labelKey,
    ?question.noneLabelKey,
  ],
  if (question is TaxMonthDayQuestion) ...[
    question.monthLabelKey,
    question.dayLabelKey,
  ],
];

/// The [keys] that [arb] does not hold as a plain string. A key with
/// placeholders is a method, not a getter, so it cannot be resolved here.
List<String> missingArbKeys(List<String> keys, Map<String, Object?> arb) => [
  for (final key in keys)
    if (arb[key] is! String || arb['@$key'] != null) key,
];

/// The generated Dart source for [keys].
String render(List<String> keys) {
  final cases = [for (final key in keys) "    '$key' => l10n.$key,"];
  final names = [for (final key in keys) "  '$key',"];
  return '''
// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: dart run tool/generate_tax_question_labels.dart

import 'package:openbudget_app/l10n/generated/app_localizations.dart';

/// The localized text of the `AppLocalizations` [key] a tax profile
/// question names.
///
/// Throws [ArgumentError] for a key no pack declares, which the contract
/// test in `tax_question_labels_test.dart` rules out for every declared one.
String taxQuestionLabel(AppLocalizations l10n, String key) => switch (key) {
${cases.join('\n')}
    _ => throw ArgumentError.value(key, 'key', 'Not a tax question label'),
  };

/// Every key [taxQuestionLabel] resolves.
const taxQuestionLabelKeys = <String>[
${names.join('\n')}
];
''';
}

/// Formats [source] as the repository's format gate would format the file.
Future<String> _format(String source) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'format',
    '--stdin-name',
    _outputPath,
  ]);
  process.stdin.write(source);
  await process.stdin.close();
  final (formatted, errors, code) = await (
    process.stdout.transform(systemEncoding.decoder).join(),
    process.stderr.transform(systemEncoding.decoder).join(),
    process.exitCode,
  ).wait;
  if (code != 0) {
    throw StateError('dart format failed: $errors');
  }
  return formatted;
}
