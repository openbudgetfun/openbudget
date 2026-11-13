// Generates lib/src/constants/currencies.dart, the currency vocabulary every
// amount in OpenBudget is stored in.
//
// data/iso4217.json is the source of truth: every active entry of ISO 4217
// List One that has a published minor unit, plus BTC. The codes the standard
// publishes without one are recorded there as excluded, because an amount
// cannot be written in them. Each listed entry carries the display name, the
// published minor unit and a symbol; the file records where all three came
// from.
//
//   cd openbudget_core && dart run tool/generate_currencies.dart
//   cd openbudget_core && dart run tool/generate_currencies.dart --check
import 'dart:convert';
import 'dart:io';

/// Where the generated file is written, relative to the package root.
const _outputPath = 'lib/src/constants/currencies.dart';

/// Where the source data lives, relative to the package root.
const _dataPath = 'data/iso4217.json';

/// One currency as the source data describes it.
class CurrencyEntry {
  const CurrencyEntry({
    required this.code,
    required this.name,
    required this.displayName,
    required this.exponent,
    required this.symbol,
  });

  final String code;

  /// The ISO 4217 name.
  final String name;

  /// The name the app shows, which is [name] unless OpenBudget renamed it.
  final String displayName;

  /// The published minor unit.
  final int exponent;

  final String symbol;
}

/// The provenance recorded alongside the list.
class CurrencySource {
  const CurrencySource({
    required this.publisher,
    required this.document,
    required this.url,
    required this.publishedOn,
    required this.excluded,
    required this.symbolSource,
  });

  final String publisher;
  final String document;
  final String url;
  final String publishedOn;

  /// ISO codes left out because the standard publishes no minor unit for them.
  final List<String> excluded;

  /// Where the symbols came from, as the data records it.
  final String symbolSource;
}

Future<void> main(List<String> arguments) async {
  final check = arguments.contains('--check');
  final data = File(_dataPath);
  if (!data.existsSync()) {
    stderr.writeln(
      'Cannot read $_dataPath. Run this from the openbudget_core directory.',
    );
    exitCode = 1;
    return;
  }

  final parsed = _parse(data.readAsStringSync());
  final (source, currencies) = parsed;
  final rendered = await _format(render(source, currencies));
  final output = File(_outputPath);

  if (check) {
    if (!output.existsSync() || output.readAsStringSync() != rendered) {
      stderr.writeln(
        '$_outputPath is stale. Run: dart run tool/generate_currencies.dart',
      );
      exitCode = 1;
    }
    return;
  }

  output
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(rendered);
  stdout.writeln(
    'Wrote ${currencies.length} currencies to $_outputPath '
    'from ${source.document}',
  );
}

/// Reads and validates the source data.
(CurrencySource, List<CurrencyEntry>) _parse(String source) {
  final json = jsonDecode(source);
  if (json is! Map<String, Object?>) {
    throw const FormatException('$_dataPath must hold a JSON object.');
  }

  final sourceJson = _object(json, 'source');
  final currenciesJson = json['currencies'];
  if (currenciesJson is! List<Object?>) {
    throw const FormatException('"currencies" must be a list.');
  }

  final entries = <CurrencyEntry>[];
  final codes = <String>{};
  for (final raw in currenciesJson) {
    if (raw is! Map<String, Object?>) {
      throw const FormatException('Every currency must be an object.');
    }
    final code = _string(raw, 'code');
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code)) {
      throw FormatException('"$code" is not a three-letter uppercase code.');
    }
    if (!codes.add(code)) {
      throw FormatException('"$code" appears more than once.');
    }
    final name = _string(raw, 'name');
    final symbol = _string(raw, 'symbol');
    final displayName = raw['displayName'] == null
        ? name
        : _string(raw, 'displayName');
    final exponent = raw['exponent'];
    if (exponent is! int || exponent < 0 || exponent > 8) {
      throw FormatException(
        '"$code" needs a published exponent, got $exponent',
      );
    }
    entries.add(
      CurrencyEntry(
        code: code,
        name: name,
        displayName: displayName,
        exponent: exponent,
        symbol: symbol,
      ),
    );
  }
  if (entries.isEmpty) {
    throw const FormatException('"currencies" is empty.');
  }

  final excludedJson = json['excluded'];
  if (excludedJson is! Map<String, Object?>) {
    throw const FormatException('"excluded" must be an object.');
  }
  final excludedCodes = excludedJson['codes'];
  if (excludedCodes is! List<Object?> || excludedCodes.isEmpty) {
    throw const FormatException('"excluded.codes" must be a non-empty list.');
  }
  final excluded = <String>[];
  for (final value in excludedCodes) {
    if (value is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
      throw FormatException('"$value" is not a three-letter uppercase code.');
    }
    if (codes.contains(value)) {
      throw FormatException('"$value" is both excluded and listed.');
    }
    excluded.add(value);
  }

  return (
    CurrencySource(
      publisher: _string(sourceJson, 'publisher'),
      document: _string(sourceJson, 'document'),
      url: _string(sourceJson, 'url'),
      publishedOn: _string(sourceJson, 'publishedOn'),
      excluded: excluded,
      symbolSource: _string(_object(json, 'symbolSource'), 'document'),
    ),
    entries,
  );
}

Map<String, Object?> _object(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! Map<String, Object?>) {
    throw FormatException('"$key" must be an object.');
  }
  return value;
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('"$key" must be a non-empty string.');
  }
  return value;
}

/// Renders the enum, member by member, in the order the data lists them.
String render(CurrencySource source, List<CurrencyEntry> currencies) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Regenerate with: dart run tool/generate_currencies.dart')
    ..writeln('//')
    ..writeln('// Currencies: ${source.document}, published by')
    ..writeln('// ${source.publisher} on ${source.publishedOn}.')
    ..writeln('// ${source.url}')
    ..writeln('//')
    ..writeln('// Symbols: ${source.symbolSource}.')
    ..writeln(
      '// A currency CLDR gives no distinct symbol keeps its code followed by a',
    )
    ..writeln(
      '// non-breaking space. The currencies OpenBudget shipped before this',
    )
    ..writeln(
      '// list keep their existing names and symbols, and BTC is not an ISO',
    )
    ..writeln('// 4217 code.')
    ..writeln('//')
    ..writeln(
      '// Not offered, because ISO 4217 publishes no minor unit for them:',
    )
    ..writeln('// ${source.excluded.join(", ")}')
    ..writeln()
    ..writeln('/// Standard currency codes supported by OpenBudget.')
    ..writeln('enum CurrencyCode {');

  for (final (index, currency) in currencies.indexed) {
    buffer.writeln('  /// ${currency.displayName}');
    final arguments = [
      "'${currency.code}'",
      _literal(currency.displayName),
      _literal(currency.symbol),
      '${currency.exponent}',
    ].join(', ');
    final end = index == currencies.length - 1 ? ';' : ',';
    buffer.writeln('  ${_memberName(currency.code)}($arguments)$end');
  }

  buffer
    ..writeln()
    ..writeln(
      '  const CurrencyCode(this.code, this.displayName, this.symbol, '
      'this.decimals);',
    )
    ..writeln()
    ..writeln('  /// ISO 4217 currency code (or crypto equivalent).')
    ..writeln('  final String code;')
    ..writeln()
    ..writeln('  /// Human-readable name.')
    ..writeln('  final String displayName;')
    ..writeln()
    ..writeln('  /// Currency symbol for display.')
    ..writeln('  final String symbol;')
    ..writeln()
    ..writeln(
      '  /// Number of decimal places used by this currency: amounts are stored in',
    )
    ..writeln(
      '  /// its minor unit, so 100 USD minor units is one dollar and 100 JPY minor',
    )
    ..writeln('  /// units is one hundred yen.')
    ..writeln('  final int decimals;')
    ..writeln()
    ..writeln(
      '  /// The currency with ISO 4217 [code], or null when OpenBudget does not',
    )
    ..writeln(
      '  /// support it. [code] is trimmed and upper-cased before matching. Callers',
    )
    ..writeln('  /// decide what an unknown code means; nothing guesses.')
    ..writeln('  static CurrencyCode? tryParse(String code) {')
    ..writeln('    final upper = code.trim().toUpperCase();')
    ..writeln('    for (final currency in values) {')
    ..writeln('      if (currency.code == upper) {')
    ..writeln('        return currency;')
    ..writeln('      }')
    ..writeln('    }')
    ..writeln('    return null;')
    ..writeln('  }')
    ..writeln('}');

  return buffer.toString();
}

/// The enum member for [code]: its lowercase form, with a trailing underscore
/// when that would collide with a Dart keyword (`TRY`).
String _memberName(String code) {
  final name = code.toLowerCase();
  return _keywords.contains(name) ? '${name}_' : name;
}

/// Dart's reserved words plus the members every enum already has.
const _keywords = {
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'index',
  'is',
  'name',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'values',
  'var',
  'void',
  'while',
  'with',
};

/// The code unit of a backslash, which a raw string literal cannot hold.
const _backslash = 0x5C;

/// Renders [value] as a Dart string literal, escaping everything outside
/// printable ASCII so invisible symbols stay visible in review.
String _literal(String value) {
  if (value.contains(r'$')) {
    if (value.contains("'") || value.codeUnits.contains(_backslash)) {
      throw FormatException('"$value" needs escaping and a raw string.');
    }
    return "r'$value'";
  }
  final buffer = StringBuffer("'");
  for (final rune in value.runes) {
    if (rune == 0x27) {
      buffer.write(r"\'");
    } else if (rune == 0x5C) {
      buffer.write(r'\\');
    } else if (rune >= 0x20 && rune <= 0x7E) {
      buffer.writeCharCode(rune);
    } else {
      buffer.write(_escape(rune));
    }
  }
  return "$buffer'";
}

/// Renders one non-ASCII code point as a Dart unicode escape.
String _escape(int rune) {
  const prefix = r'\u';
  final hex = rune.toRadixString(16).toUpperCase();
  return rune <= 0xFFFF ? '$prefix${hex.padLeft(4, '0')}' : '$prefix{$hex}';
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
