import 'dart:collection';

import 'package:openbudget_core/src/countries/country_data.g.dart';
import 'package:openbudget_core/src/time/civil_date.dart';

/// Reference facts about one ISO 3166-1 country.
///
/// These are the static tables behind entity creation (docs/
/// tax-jurisdictions.md, section 8). The source of truth is one JSON file per
/// country in `openbudget_core/data/countries/`, inlined as constants in
/// `country_data.g.dart`; [CountryInfo.fromJson] is the file schema, so the
/// generator, the schema test and this library cannot drift apart.
///
/// Tax-year and indirect-tax fields are null until the research tasks fill
/// them; consumers must fall back to their hand-kept defaults meanwhile.
final class CountryInfo {
  const CountryInfo({
    required this.code,
    required this.name,
    required this.servable,
    required this.currencies,
    required this.timeZones,
    this.individualTaxYear,
    this.companyYearEndDefault,
    this.indirectTax,
    this.authority,
    this.sources = const [],
    this.verifiedOn,
    this.recheckBy,
    this.caveats = const [],
  });

  /// Parses one `data/countries/<CC>.json` file, strictly.
  ///
  /// Throws [ArgumentError] naming the offending key when the value violates
  /// the schema — including a repeated caveat, the same source listed twice
  /// or an unknown tax-year calendar, each error naming the country — so bad
  /// reference data fails loudly instead of quietly producing a default
  /// nobody asked for.
  factory CountryInfo.fromJson(Object? json) {
    final map = _object(json, 'country');
    for (final key in map.keys) {
      if (!_keys.contains(key)) {
        throw ArgumentError('unknown country key "$key"');
      }
    }
    final code = _code(_present(map, 'code'), 'code');
    final sources = _list(_present(map, 'sources'), SourceInfo.fromJson);
    final caveats = _stringList(_present(map, 'caveats'), 'caveats');
    _rejectDuplicates(code, sources, caveats);
    return CountryInfo(
      code: code,
      name: _nonEmptyString(_present(map, 'name'), 'name'),
      servable: _boolean(_present(map, 'servable'), 'servable'),
      currencies: _currencyList(_present(map, 'currencies')),
      timeZones: _zoneList(_present(map, 'timeZones')),
      individualTaxYear: _optional(
        map,
        'individualTaxYear',
        (
          value,
        ) => IndividualTaxYear.fromJson(value, country: code),
      ),
      companyYearEndDefault: _optional(
        map,
        'companyYearEndDefault',
        _yearEnd,
      ),
      indirectTax: _optional(map, 'indirectTax', IndirectTaxInfo.fromJson),
      authority: _optional(map, 'authority', TaxAuthorityInfo.fromJson),
      sources: sources,
      verifiedOn: _optionalDate(map, 'verifiedOn'),
      recheckBy: _optionalDate(map, 'recheckBy'),
      caveats: caveats,
    );
  }

  /// The ISO 3166-1 alpha-2 code, such as `GB`.
  final String code;

  /// The English name, verbatim from the IANA `iso3166.tab` table.
  final String name;

  /// Whether OpenBudget serves this country at all.
  ///
  /// False hides the country from every picker and blocks entity creation.
  /// The current list of excluded countries is the placeholder for open
  /// question Q1, kept in `data/servable_exclusions.json`.
  final bool servable;

  /// The current ISO 4217 currency codes; the first is the default.
  ///
  /// Empty only for territories with no economy of their own, such as
  /// Antarctica.
  final List<String> currencies;

  /// The IANA time zones, most common first.
  ///
  /// Empty only for territories no zone covers, such as Bouvet Island.
  final List<String> timeZones;

  /// When an individual's tax year starts, or null until research fills it.
  final IndividualTaxYear? individualTaxYear;

  /// A company's default financial year end, or null until research fills it.
  final ({int month, int day})? companyYearEndDefault;

  /// The indirect-tax system, or null until research fills it.
  final IndirectTaxInfo? indirectTax;

  /// The tax authority, or null until research fills it.
  final TaxAuthorityInfo? authority;

  /// Where the mechanical facts above come from, with grades and dates.
  final List<SourceInfo> sources;

  /// When the research fields were last verified, or null before research.
  final DateTime? verifiedOn;

  /// When the research fields are due for a re-check, or null before research.
  final DateTime? recheckBy;

  /// Caveats shown next to the data on screen.
  final List<String> caveats;

  /// The default currency code for a new entity, such as `GBP`.
  String get defaultCurrency => currencies.first;

  /// The default IANA time zone for a new entity.
  ///
  /// [DateTime.utc]-style `UTC` for territories no zone covers.
  String get defaultTimeZone => timeZones.isEmpty ? 'UTC' : timeZones.first;

  /// The time zones offered for a new entity, default first.
  List<String> get timeZoneChoices =>
      timeZones.isEmpty ? const ['UTC'] : timeZones;

  /// The canonical JSON shape of a `data/countries/<CC>.json` file.
  Map<String, Object?> toJsonObject() => {
    'code': code,
    'name': name,
    'servable': servable,
    'currencies': List<String>.of(currencies),
    'timeZones': List<String>.of(timeZones),
    'individualTaxYear': individualTaxYear?.toJsonObject(),
    'companyYearEndDefault': companyYearEndDefault == null
        ? null
        : {
            'month': companyYearEndDefault!.month,
            'day': companyYearEndDefault!.day,
          },
    'indirectTax': indirectTax?.toJsonObject(),
    'authority': authority?.toJsonObject(),
    'sources': [for (final source in sources) source.toJsonObject()],
    'verifiedOn': _civilDateString(verifiedOn),
    'recheckBy': _civilDateString(recheckBy),
    'caveats': List<String>.of(caveats),
  };

  /// The schema keys, in file order.
  static const Set<String> _keys = {
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
  };
}

/// When an individual's tax year starts (docs/tax-jurisdictions.md, 8.3).
final class IndividualTaxYear {
  const IndividualTaxYear({
    required this.startMonth,
    required this.startDay,
    required this.calendar,
  });

  factory IndividualTaxYear.fromJson(Object? json, {String? country}) {
    final map = _object(json, 'individualTaxYear');
    return IndividualTaxYear(
      startMonth: _month(_present(map, 'startMonth')),
      startDay: _day(_present(map, 'startDay')),
      calendar: TaxYearCalendar.fromJsonName(
        _nonEmptyString(_present(map, 'calendar'), 'calendar'),
        country: country,
      ),
    );
  }

  /// The month (1–12) a tax year starts in.
  final int startMonth;

  /// The day of [startMonth] a tax year starts on.
  final int startDay;

  /// The calendar the year follows, [TaxYearCalendar.gregorian] for almost
  /// every country.
  final TaxYearCalendar calendar;

  Map<String, Object?> toJsonObject() => {
    'startMonth': startMonth,
    'startDay': startDay,
    'calendar': calendar.jsonName,
  };
}

/// The calendar an individual tax year follows.
///
/// Every JSON name is a CLDR calendar identifier (UTS #35) except
/// [bikramSambat]: Nepal's calendar has no CLDR identifier, so it carries the
/// schema's own `bikram-sambat` spelling. [TaxYearCalendar.fromJsonName]
/// rejects anything else, so a typo or an unresearched calendar fails the
/// generator, CI and the tests instead of silently parsing as text.
enum TaxYearCalendar {
  gregorian('gregorian'),
  buddhist('buddhist'),
  chinese('chinese'),
  coptic('coptic'),
  dangi('dangi'),
  ethiopic('ethiopic'),
  hebrew('hebrew'),
  indian('indian'),
  islamic('islamic'),
  islamicCivil('islamic-civil'),
  islamicRgsa('islamic-rgsa'),
  islamicTbla('islamic-tbla'),
  islamicUmalqura('islamic-umalqura'),
  japanese('japanese'),
  persian('persian'),
  roc('roc'),

  /// Nepal's calendar; CLDR defines no identifier for it.
  bikramSambat('bikram-sambat');

  const TaxYearCalendar(this.jsonName);

  /// The identifier used in `data/countries/<CC>.json`.
  final String jsonName;

  /// Parses a `calendar` value, rejecting unknown spellings. When [country]
  /// is given — the ISO code of the file being parsed — the error names it.
  static TaxYearCalendar fromJsonName(String name, {String? country}) =>
      switch (name) {
        'gregorian' => gregorian,
        'buddhist' => buddhist,
        'chinese' => chinese,
        'coptic' => coptic,
        'dangi' => dangi,
        'ethiopic' => ethiopic,
        'hebrew' => hebrew,
        'indian' => indian,
        'islamic' => islamic,
        'islamic-civil' => islamicCivil,
        'islamic-rgsa' => islamicRgsa,
        'islamic-tbla' => islamicTbla,
        'islamic-umalqura' => islamicUmalqura,
        'japanese' => japanese,
        'persian' => persian,
        'roc' => roc,
        'bikram-sambat' => bikramSambat,
        _ => throw ArgumentError(
          '${country ?? 'country'}: unknown tax-year calendar "$name"',
        ),
      };
}

/// The kind of indirect tax a country levies.
enum IndirectTaxKind {
  vat,
  gst,
  salesTax,
  consumptionTax,
  none;

  static IndirectTaxKind fromName(String name) => switch (name) {
    'vat' => vat,
    'gst' => gst,
    'salesTax' => salesTax,
    'consumptionTax' => consumptionTax,
    'none' => none,
    _ => throw ArgumentError('unknown indirect-tax kind "$name"'),
  };
}

/// One country's indirect-tax system (docs/tax-jurisdictions.md, 8.3).
final class IndirectTaxInfo {
  const IndirectTaxInfo({
    required this.kind,
    required this.rates,
    this.localName,
    this.registrationThreshold,
    this.returnFrequency,
    this.subdivisions = const [],
  });

  factory IndirectTaxInfo.fromJson(Object? json) {
    final map = _object(json, 'indirectTax');
    return IndirectTaxInfo(
      kind: IndirectTaxKind.fromName(
        _nonEmptyString(_present(map, 'kind'), 'kind'),
      ),
      localName: _optionalString(map['localName'], 'localName'),
      rates: _list(_present(map, 'rates'), IndirectTaxRate.fromJson),
      registrationThreshold: _optional(
        map,
        'registrationThreshold',
        IndirectTaxThreshold.fromJson,
      ),
      returnFrequency: _optionalString(
        map['returnFrequency'],
        'returnFrequency',
      ),
      subdivisions:
          _optional(
            map,
            'subdivisions',
            (value) => _list(value, IndirectTaxSubdivision.fromJson),
          ) ??
          const [],
    );
  }

  /// What kind of tax this is, such as [IndirectTaxKind.vat].
  final IndirectTaxKind kind;

  /// The tax's local name, such as `Mehrwertsteuer`.
  final String? localName;

  /// The rates, effective-dated; rates are never overwritten, only superseded.
  final List<IndirectTaxRate> rates;

  /// The registration threshold, when known.
  final IndirectTaxThreshold? registrationThreshold;

  /// The default return frequency, such as `monthly`.
  final String? returnFrequency;

  /// Subdivisions (ISO 3166-2 codes) with rates of their own.
  final List<IndirectTaxSubdivision> subdivisions;

  Map<String, Object?> toJsonObject() => {
    'kind': kind.name,
    'localName': localName,
    'rates': [for (final rate in rates) rate.toJsonObject()],
    'registrationThreshold': registrationThreshold?.toJsonObject(),
    'returnFrequency': returnFrequency,
    'subdivisions': [
      for (final subdivision in subdivisions) subdivision.toJsonObject(),
    ],
  };
}

/// One effective-dated indirect-tax rate.
final class IndirectTaxRate {
  const IndirectTaxRate({
    required this.label,
    required this.ratePerMillion,
    required this.from,
    required this.source,
    this.to,
    this.appliesTo,
  });

  factory IndirectTaxRate.fromJson(Object? json) {
    final map = _object(json, 'rate');
    return IndirectTaxRate(
      label: _nonEmptyString(_present(map, 'label'), 'label'),
      ratePerMillion: _ratePerMillion(_present(map, 'ratePerMillion')),
      from: _civilDate(_present(map, 'from'), 'from'),
      to: _optionalDate(map, 'to'),
      appliesTo: _optionalString(map['appliesTo'], 'appliesTo'),
      source: _sourceIndex(_present(map, 'source')),
    );
  }

  /// What the rate applies to, such as `standard`.
  final String label;

  /// The exact rate in millionths of the taxed amount: 1% is `10000`, so
  /// Québec's 9.975% QST is `99750` with no value rounded away.
  final int ratePerMillion;

  /// The first day the rate applies.
  final DateTime from;

  /// The day after the last day the rate applied, or null while current.
  final DateTime? to;

  /// What scope the rate covers when it is not the general base, such as
  /// `food and medicines`.
  final String? appliesTo;

  /// The index of the entry in the country's `sources` list.
  final int source;

  Map<String, Object?> toJsonObject() => {
    'label': label,
    'ratePerMillion': ratePerMillion,
    'from': _civilDateString(from),
    'to': to == null ? null : _civilDateString(to),
    'appliesTo': appliesTo,
    'source': source,
  };
}

/// The turnover above which a business must register.
final class IndirectTaxThreshold {
  const IndirectTaxThreshold({
    required this.amountMinor,
    required this.currency,
    required this.period,
    required this.source,
  });

  factory IndirectTaxThreshold.fromJson(Object? json) {
    final map = _object(json, 'registrationThreshold');
    return IndirectTaxThreshold(
      amountMinor: _amountMinor(_present(map, 'amountMinor')),
      currency: _currency(_present(map, 'currency'), 'currency'),
      period: _nonEmptyString(_present(map, 'period'), 'period'),
      source: _sourceIndex(_present(map, 'source')),
    );
  }

  /// The threshold in the currency's minor units, at its published exponent.
  final int amountMinor;

  /// The ISO 4217 code the threshold is denominated in.
  final String currency;

  /// The turnover window, such as `rolling12Months`.
  final String period;

  /// The index of the entry in the country's `sources` list.
  final int source;

  Map<String, Object?> toJsonObject() => {
    'amountMinor': amountMinor,
    'currency': currency,
    'period': period,
    'source': source,
  };
}

/// A subdivision with indirect-tax rates of its own.
final class IndirectTaxSubdivision {
  const IndirectTaxSubdivision({required this.code, required this.rates});

  factory IndirectTaxSubdivision.fromJson(Object? json) {
    final map = _object(json, 'subdivision');
    return IndirectTaxSubdivision(
      code: _subdivisionCode(_present(map, 'code')),
      rates: _list(_present(map, 'rates'), IndirectTaxRate.fromJson),
    );
  }

  /// The ISO 3166-2 code, such as `US-CA`.
  final String code;

  /// The subdivision's rates, effective-dated like the country's.
  final List<IndirectTaxRate> rates;

  Map<String, Object?> toJsonObject() => {
    'code': code,
    'rates': [for (final rate in rates) rate.toJsonObject()],
  };
}

/// A country's tax authority.
final class TaxAuthorityInfo {
  const TaxAuthorityInfo({required this.name, required this.url});

  factory TaxAuthorityInfo.fromJson(Object? json) {
    final map = _object(json, 'authority');
    return TaxAuthorityInfo(
      name: _nonEmptyString(_present(map, 'name'), 'name'),
      url: _nonEmptyString(_present(map, 'url'), 'url'),
    );
  }

  /// The authority's English name, such as `HM Revenue & Customs`.
  final String name;

  /// The authority's site, for signposting.
  final String url;

  Map<String, Object?> toJsonObject() => {'name': name, 'url': url};
}

/// How firmly a source backs a fact (docs/tax-jurisdictions.md, 5.1).
enum SourceGrade {
  primary,
  secondary,
  inferred,
  background;

  static SourceGrade fromName(String name) => switch (name) {
    'primary' => primary,
    'secondary' => secondary,
    'inferred' => inferred,
    'background' => background,
    _ => throw ArgumentError('unknown source grade "$name"'),
  };
}

/// One cited source for a country's facts.
final class SourceInfo {
  const SourceInfo({
    required this.title,
    required this.url,
    required this.grade,
    required this.retrievedOn,
  });

  factory SourceInfo.fromJson(Object? json) {
    final map = _object(json, 'source');
    return SourceInfo(
      title: _nonEmptyString(_present(map, 'title'), 'title'),
      url: _nonEmptyString(_present(map, 'url'), 'url'),
      grade: SourceGrade.fromName(
        _nonEmptyString(_present(map, 'grade'), 'grade'),
      ),
      retrievedOn: _civilDate(_present(map, 'retrievedOn'), 'retrievedOn'),
    );
  }

  /// What the source is, such as `VAT Act, section 5`.
  final String title;

  /// Where the source was retrieved from.
  final String url;

  /// How firmly the source backs a fact.
  final SourceGrade grade;

  /// The day the source was retrieved.
  final DateTime retrievedOn;

  Map<String, Object?> toJsonObject() => {
    'title': title,
    'url': url,
    'grade': grade.name,
    'retrievedOn': _civilDateString(retrievedOn),
  };
}

/// The generated country dataset, keyed by ISO 3166-1 alpha-2 code.
abstract final class Countries {
  static final List<CountryInfo> _all = UnmodifiableListView([
    for (final json in countryData.values) CountryInfo.fromJson(json),
  ]);

  static final Map<String, CountryInfo> _byCode = UnmodifiableMapView({
    for (final country in _all) country.code: country,
  });

  /// Every country, sorted by ISO code.
  static List<CountryInfo> get all => _all;

  /// The country for [code], case-insensitively, or null when unknown.
  static CountryInfo? byCode(String code) {
    if (code.length != 2) {
      return null;
    }
    return _byCode[code.toUpperCase()];
  }
}

Map<String, Object?> _object(Object? value, String what) {
  if (value is Map<String, Object?>) {
    return value;
  }
  throw ArgumentError('$what must be a JSON object');
}

Object? _present(Map<String, Object?> map, String key) {
  if (!map.containsKey(key)) {
    throw ArgumentError('missing "$key"');
  }
  return map[key];
}

T? _optional<T>(
  Map<String, Object?> map,
  String key,
  T Function(Object? value) parse,
) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  return parse(value);
}

/// Rejects a source list or caveat list that repeats an entry.
void _rejectDuplicates(
  String code,
  List<SourceInfo> sources,
  List<String> caveats,
) {
  final seenSources = <String>{};
  for (final source in sources) {
    if (!seenSources.add('${source.url}\n${source.title}')) {
      throw ArgumentError(
        '$code lists the source "${source.title}" at ${source.url} '
        'more than once',
      );
    }
  }
  final seenCaveats = <String>{};
  for (final caveat in caveats) {
    if (!seenCaveats.add(caveat)) {
      throw ArgumentError('$code repeats the caveat "$caveat"');
    }
  }
}

({int month, int day}) _yearEnd(Object? value) {
  final map = _object(value, 'companyYearEndDefault');
  return (
    month: _month(_present(map, 'month')),
    day: _day(_present(map, 'day')),
  );
}

String _nonEmptyString(Object? value, String key) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw ArgumentError('"$key" must be a non-empty string');
}

String? _optionalString(Object? value, String key) {
  if (value == null) {
    return null;
  }
  return _nonEmptyString(value, key);
}

bool _boolean(Object? value, String key) {
  if (value is bool) {
    return value;
  }
  throw ArgumentError('"$key" must be true or false');
}

String _code(Object? value, String key) {
  if (value is String && RegExp(r'^[A-Z]{2}$').hasMatch(value)) {
    return value;
  }
  throw ArgumentError('"$key" must be an ISO 3166-1 alpha-2 code');
}

String _currency(Object? value, String key) {
  if (value is String && RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
    return value;
  }
  throw ArgumentError('"$key" must be an ISO 4217 code');
}

String _subdivisionCode(Object? value) {
  if (value is String && RegExp(r'^[A-Z]{2}-[A-Z0-9]{1,3}$').hasMatch(value)) {
    return value;
  }
  throw ArgumentError('"code" must be an ISO 3166-2 code');
}

List<String> _currencyList(Object? value) {
  if (value is! List<Object?>) {
    throw ArgumentError('"currencies" must be a list');
  }
  return UnmodifiableListView([
    for (final entry in value) _currency(entry, 'currencies'),
  ]);
}

List<String> _zoneList(Object? value) {
  if (value is! List<Object?>) {
    throw ArgumentError('"timeZones" must be a list');
  }
  return UnmodifiableListView([
    for (final entry in value) _nonEmptyString(entry, 'timeZones'),
  ]);
}

List<String> _stringList(Object? value, String key) {
  if (value is! List<Object?>) {
    throw ArgumentError('"$key" must be a list');
  }
  return UnmodifiableListView([
    for (final entry in value) _nonEmptyString(entry, key),
  ]);
}

List<T> _list<T>(Object? value, T Function(Object? json) parse) {
  if (value is! List<Object?>) {
    throw ArgumentError('expected a JSON array');
  }
  return UnmodifiableListView([for (final entry in value) parse(entry)]);
}

int _intIn(Object? value, String key, int low, int high) {
  if (value is int && value >= low && value <= high) {
    return value;
  }
  throw ArgumentError('"$key" must be an integer from $low to $high');
}

int _month(Object? value) => _intIn(value, 'month', 1, 12);

int _day(Object? value) => _intIn(value, 'day', 1, 31);

int _ratePerMillion(Object? value) =>
    _intIn(value, 'ratePerMillion', 0, 1000000);

int _amountMinor(Object? value) {
  if (value is int && value >= 0) {
    return value;
  }
  throw ArgumentError('"amountMinor" must be a non-negative integer');
}

int _sourceIndex(Object? value) {
  if (value is int && value >= 0) {
    return value;
  }
  throw ArgumentError('"source" must be a non-negative integer');
}

DateTime _civilDate(Object? value, String key) {
  if (value is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
    throw ArgumentError('"$key" must be a YYYY-MM-DD date');
  }
  final year = int.parse(value.substring(0, 4));
  final month = int.parse(value.substring(5, 7));
  final day = int.parse(value.substring(8, 10));
  return civilDate(year, month, day);
}

DateTime? _optionalDate(Map<String, Object?> map, String key) =>
    map[key] == null ? null : _civilDate(map[key], key);

String? _civilDateString(DateTime? value) => value == null
    ? null
    : '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';
