// Generates lib/src/countries/country_data.g.dart from the dataset in
// data/countries/, one file per ISO 3166-1 country.
//
// The JSON files are the source of truth (docs/tax-jurisdictions.md, 8.2);
// this tool only validates them against the CountryInfo schema and inlines
// them as `const` Dart so core logic reads them offline. CI runs `--check`
// and fails when the committed Dart has drifted from the dataset.
//
//   dart run tool/generate_country_data.dart          # write the constants
//   dart run tool/generate_country_data.dart --check  # fail if stale
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/src/countries/country_info.dart';

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final dir = Directory('data/countries');
  if (!dir.existsSync()) {
    _fail('no data/countries directory; run from openbudget_core');
  }

  final files = dir.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.endsWith('.json');
  }).toList()..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    _fail('data/countries holds no JSON files');
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Regenerate with: dart run tool/generate_country_data.dart')
    ..writeln('//')
    ..writeln('// Source of truth: data/countries/<CC>.json, one file per')
    ..writeln(
      '// ISO 3166-1 country, built by tool/bootstrap_country_data.dart.',
    )
    ..writeln();

  var count = 0;
  for (final file in files) {
    final name = file.uri.pathSegments.last;
    final code = name.substring(0, name.length - '.json'.length);
    final Object? json;
    try {
      json = jsonDecode(file.readAsStringSync());
    } on FormatException catch (error) {
      _fail('$name is not valid JSON: ${error.message}');
    }
    final country = CountryInfo.fromJson(json);
    if (country.code != code) {
      _fail('$name holds code ${country.code}');
    }
    if (count == 0) {
      buffer
        ..writeln('/// The country dataset as JSON-shaped data, keyed by')
        ..writeln('/// ISO 3166-1 alpha-2 code, in code order.')
        ..writeln('const Map<String, Map<String, Object?>> countryData = {');
    }
    _writeEntry(buffer, code, json, 1);
    count++;
  }
  if (count == 0) {
    _fail('no country files could be read');
  }
  buffer.writeln('};');

  const outputPath = 'lib/src/countries/country_data.g.dart';
  final output = buffer.toString();
  final existing = File(outputPath);
  if (checkOnly) {
    if (!existing.existsSync() || existing.readAsStringSync() != output) {
      _fail(
        '$outputPath is out of date with data/countries/. '
        'Run `dart run tool/generate_country_data.dart` and commit.',
      );
    }
    stdout.writeln('country_data.g.dart is up to date ($count countries).');
    return;
  }
  existing.writeAsStringSync(output);
  stdout.writeln('Generated $outputPath with $count countries.');
}

/// Writes one `'<CC>': { ... }` entry, nested JSON values and all.
void _writeEntry(
  StringBuffer buffer,
  String code,
  Object? json,
  int indent,
) {
  final pad = '  ' * indent;
  buffer.write('$pad${_literal(code)}: ');
  _writeValue(buffer, json, indent);
  buffer.writeln(',');
}

void _writeValue(StringBuffer buffer, Object? value, int indent) {
  switch (value) {
    case final Map<String, Object?> map when map.isNotEmpty:
      buffer.writeln('{');
      final pad = '  ' * (indent + 1);
      for (final entry in map.entries) {
        buffer.write('$pad${_literal(entry.key)}: ');
        _writeValue(buffer, entry.value, indent + 1);
        buffer.writeln(',');
      }
      buffer.write('${'  ' * indent}}');
    case final List<Object?> list when list.isNotEmpty:
      buffer.writeln('[');
      final pad = '  ' * (indent + 1);
      for (final entry in list) {
        buffer.write(pad);
        _writeValue(buffer, entry, indent + 1);
        buffer.writeln(',');
      }
      buffer.write('${'  ' * indent}]');
    case Map<String, Object?>():
      buffer.write('{}');
    case List<Object?>():
      buffer.write('[]');
    case String():
      buffer.write(_literal(value));
    case int():
    case double():
    case bool():
      buffer.write(value.toString());
    case null:
      buffer.write('null');
    default:
      _fail('unexpected JSON value of type ${value.runtimeType}');
  }
}

/// A Dart string literal for a JSON string.
String _literal(String value) =>
    '"${value.replaceAll(r'\', r'\\').replaceAll('"', r'\"').replaceAll(r'$', r'\$')}"';

Never _fail(String message) {
  stderr.writeln('generate_country_data: $message');
  exit(2);
}
