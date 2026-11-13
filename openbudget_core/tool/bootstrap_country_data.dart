// Builds the country dataset in data/countries/ from public reference data.
//
// Every ISO 3166-1 code in the IANA tz `iso3166.tab` gets one JSON file with
// the mechanical fields only: the English name, the current currencies, the
// IANA time zones, and the `servable` flag from the placeholder exclusions in
// data/servable_exclusions.json. Tax-year and indirect-tax fields stay null
// until the research tasks fill them (docs/tax-jurisdictions.md, U3 to U5).
//
// Sources, fetched over the network on every run so the version is explicit:
//   - IANA tz database `iso3166.tab` and `zone.tab` at a release tag [P].
//     The two .tab files are also written verbatim as test fixtures.
//   - Unicode CLDR supplemental currency data, for the territory-to-currency
//     map that ISO 4217 itself does not publish [S]. A territory's current
//     currencies (those without an end date) are kept, newest first, so the
//     first entry is the default.
//
//   dart run tool/bootstrap_country_data.dart
//   dart run tool/bootstrap_country_data.dart --tz-version 2026f
//
// Hand-kept inputs live beside the output: data/timezone_defaults.json picks
// the default zone of every multi-zone country, and data/servable_exclusions.json
// carries the placeholder sanctions list behind Q1.
import 'dart:convert';
import 'dart:io';

/// The IANA tz database release this dataset was last built from.
const String _defaultTzVersion = '2026f';

/// The Unicode CLDR release used for the territory-to-currency map.
const String _defaultCldrRelease = 'release-46';

String _tzUrl(String file, String version) =>
    'https://raw.githubusercontent.com/eggert/tz/$version/$file';

String _cldrUrl(String release) =>
    'https://raw.githubusercontent.com/unicode-org/cldr-json/$release/'
    'cldr-json/cldr-core/supplemental/currencyData.json';

/// The schema key order of a country file, from docs/tax-jurisdictions.md 8.3.
const List<String> _keys = [
  'code',
  'name',
  'servable',
  'currencies',
  'timeZones',
  'individualTaxYear',
  'companyYearEndDefault',
  'indirectTax',
  'authority',
  'sources',
  'verifiedOn',
  'recheckBy',
  'caveats',
];

Future<void> main(List<String> args) async {
  final tzVersion = _option(args, '--tz-version') ?? _defaultTzVersion;
  final cldrRelease = _option(args, '--cldr-release') ?? _defaultCldrRelease;
  final retrievedOn = DateTime.now().toUtc();
  final retrieved =
      '${retrievedOn.year.toString().padLeft(4, '0')}-'
      '${retrievedOn.month.toString().padLeft(2, '0')}-'
      '${retrievedOn.day.toString().padLeft(2, '0')}';

  final isoTab = await _fetch(_tzUrl('iso3166.tab', tzVersion));
  final zoneTab = await _fetch(_tzUrl('zone.tab', tzVersion));
  final cldrJson = await _fetch(_cldrUrl(cldrRelease));

  final names = _parseIso3166Tab(isoTab);
  final zonesByCountry = _parseZoneTab(zoneTab);
  final currencyByCountry = _parseCldrCurrencies(cldrJson);

  final defaults = _readJson(File('data/timezone_defaults.json'));
  final exclusions = _readJson(File('data/servable_exclusions.json'));
  final excluded = <String, String>{};
  for (final entry in exclusions['excluded']! as List<Object?>) {
    final item = entry! as Map<String, Object?>;
    excluded[item['code']! as String] = item['reason']! as String;
  }

  final unknownExclusions = excluded.keys.toSet()..removeAll(names.keys);
  if (unknownExclusions.isNotEmpty) {
    _fail(
      'data/servable_exclusions.json lists non-ISO codes: '
      '${unknownExclusions.join(', ')}',
    );
  }

  final outDir = Directory('data/countries')..createSync(recursive: true);
  for (final stale in outDir.listSync()) {
    if (stale is File && stale.path.endsWith('.json')) {
      stale.deleteSync();
    }
  }

  // The verbatim IANA files double as schema-test fixtures.
  File('data/iso3166.tab').writeAsStringSync(isoTab);
  File('data/zone.tab').writeAsStringSync(zoneTab);

  var written = 0;
  var excludedCount = 0;
  for (final code in names.keys.toList()..sort()) {
    final zoneOverride =
        (defaults['countries'] as Map<String, Object?>?)?[code]
            as Map<String, Object?>?;
    final timeZones = _timeZones(
      code: code,
      zoneZones: zonesByCountry[code] ?? const [],
      override: zoneOverride,
    );
    final currencies = currencyByCountry[code] ?? const [];
    if (currencies.isEmpty) {
      stderr.writeln(
        'note: $code has no current currency in CLDR '
        '(${names[code]}), writing an empty list',
      );
    }
    final isExcluded = excluded.containsKey(code);
    if (isExcluded) {
      excludedCount++;
    }
    final country = <String, Object?>{
      'code': code,
      'name': names[code],
      'servable': !isExcluded,
      'currencies': currencies,
      'timeZones': timeZones,
      'individualTaxYear': null,
      'companyYearEndDefault': null,
      'indirectTax': null,
      'authority': null,
      'sources': [
        {
          'title':
              'IANA Time Zone Database $tzVersion: iso3166.tab '
              '(country codes and English names)',
          'url': _tzUrl('iso3166.tab', tzVersion),
          'grade': 'primary',
          'retrievedOn': retrieved,
        },
        {
          'title':
              'IANA Time Zone Database $tzVersion: zone.tab '
              '(country time zones)',
          'url': _tzUrl('zone.tab', tzVersion),
          'grade': 'primary',
          'retrievedOn': retrieved,
        },
        {
          'title':
              'Unicode CLDR ($cldrRelease): supplemental currency data '
              '(territory-to-currency map)',
          'url': _cldrUrl(cldrRelease),
          'grade': 'secondary',
          'retrievedOn': retrieved,
        },
      ],
      'verifiedOn': null,
      'recheckBy': null,
      'caveats': [
        if (isExcluded)
          'Not served: ${excluded[code]} — see data/servable_exclusions.json.',
      ],
    };
    File(
      'data/countries/$code.json',
    ).writeAsStringSync(_prettyJson(_order(country)));
    written++;
  }

  stdout.writeln(
    'wrote $written country files from tzdata $tzVersion and '
    'CLDR $cldrRelease; $excludedCount excluded from service '
    '(${excluded.keys.toList()..sort()})',
  );
}

/// `code → English name`, verbatim from `iso3166.tab`.
Map<String, String> _parseIso3166Tab(String text) {
  final names = <String, String>{};
  for (final line in text.split('\n')) {
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final columns = line.split('\t');
    if (columns.length != 2 || !RegExp(r'^[A-Z]{2}$').hasMatch(columns[0])) {
      _fail('unparsable iso3166.tab line: "$line"');
    }
    names[columns[0]] = columns[1];
  }
  return names;
}

/// `code → zones in file order`, from `zone.tab`.
Map<String, List<String>> _parseZoneTab(String text) {
  final zones = <String, List<String>>{};
  for (final line in text.split('\n')) {
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    final columns = line.split('\t');
    if (columns.length < 3) {
      _fail('unparsable zone.tab line: "$line"');
    }
    zones.putIfAbsent(columns[0], () => []).add(columns[2]);
  }
  return zones;
}

/// `code → current currency codes, oldest first`, from CLDR currency data.
///
/// A currency is current while its CLDR entry has no end date; non-tender
/// entries and the `XXX` placeholder are skipped, so the first entry is the
/// territory's own currency where it has one (e.g. PAB before USD for PA).
Map<String, List<String>> _parseCldrCurrencies(String json) {
  final root = jsonDecode(json) as Map<String, Object?>;
  final regions =
      ((root['supplemental'] as Map<String, Object?>?)!['currencyData']
              as Map<String, Object?>?)!['region']!
          as Map<String, Object?>;
  final currencies = <String, List<String>>{};
  regions.forEach((code, value) {
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
      return;
    }
    final entries = <String, Map<String, Object?>>{};
    for (final entry in value! as List<Object?>) {
      if (entry is! Map<String, Object?>) {
        continue;
      }
      final iso = entry.keys.single;
      final attrs = entry.values.single;
      if (attrs is Map<String, Object?>) {
        entries[iso] = attrs;
      }
    }
    final current = [
      for (final item in entries.entries)
        if (!item.value.containsKey('_to') &&
            item.value['_tender'] != 'false' &&
            item.key != 'XXX')
          (item.key, item.value['_from'] as String? ?? ''),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    final codes = [for (final entry in current) entry.$1];
    if (codes.isNotEmpty) {
      currencies[code] = codes;
    }
  });
  return currencies;
}

/// A country's `timeZones`, from zone.tab plus the hand-kept default.
List<String> _timeZones({
  required String code,
  required List<String> zoneZones,
  required Map<String, Object?>? override,
}) {
  if (override == null) {
    if (zoneZones.length > 1) {
      _fail(
        '$code spans ${zoneZones.length} zones in zone.tab but has no '
        'entry in data/timezone_defaults.json',
      );
    }
    return zoneZones;
  }
  final curated = override['timeZones'] as List<Object?>?;
  final single = override['default'] as String?;
  if (curated != null) {
    final zones = curated.cast<String>();
    final unknown = zones.toSet()..removeAll(zoneZones);
    if (unknown.isNotEmpty) {
      _fail(
        '$code lists zones missing from zone.tab: '
        '${unknown.join(', ')}',
      );
    }
    return zones;
  }
  if (single is String) {
    if (!zoneZones.contains(single)) {
      _fail('$code defaults to $single, which zone.tab does not list');
    }
    return [single, ...zoneZones.where((zone) => zone != single)];
  }
  _fail(
    '${override.keys.join(', ')} is not a timezone_defaults entry shape '
    '("default" or "timeZones") for $code',
  );
}

/// Writes a `Map` as dprint-formatted JSON: two-space indent, no escapes.
String _prettyJson(Object? value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

/// Rebuilds a country object in the schema's key order, so diffs stay stable.
Map<String, Object?> _order(Map<String, Object?> country) => {
  for (final key in _keys) key: country[key],
};

/// Reads a hand-kept JSON file, failing with its path when it is invalid.
Map<String, Object?> _readJson(File file) {
  if (!file.existsSync()) {
    _fail('missing hand-kept input ${file.path}');
  }
  final value = jsonDecode(file.readAsStringSync());
  if (value is! Map<String, Object?>) {
    _fail('${file.path} must hold a JSON object');
  }
  return value;
}

/// Fetches a URL, failing with its status when the response is not 200.
Future<String> _fetch(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      _fail('fetching $url failed with HTTP ${response.statusCode}');
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

String? _option(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index < 0) {
    return null;
  }
  if (index + 1 >= args.length) {
    _fail('$name needs a value');
  }
  return args[index + 1];
}

Never _fail(String message) {
  stderr.writeln('bootstrap_country_data: $message');
  exit(2);
}
