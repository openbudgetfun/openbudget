import 'package:openbudget_core/src/countries/country_info.dart';

/// How a country reads on screen, and what else people call it.
///
/// [CountryInfo.name] is the IANA `iso3166.tab` name verbatim, which is
/// terse by design ("Britain (UK)", "St Lucia", "Congo (Dem. Rep.)").
/// Pickers show [displayName] instead and search [searchAliases] too.
extension CountryDisplayName on CountryInfo {
  /// The name to show a person: the IANA name with `St` spelled out and `&`
  /// as "and", or a hand-kept name where the IANA one is not what people
  /// write.
  String get displayName =>
      _displayNames[code] ??
      name.replaceFirst(RegExp('^St '), 'Saint ').replaceAll(' & ', ' and ');

  /// Other names people type to find this country, not including
  /// [displayName] or the IANA [CountryInfo.name], which pickers match too.
  List<String> get searchAliases => _aliases[code] ?? const [];
}

const Map<String, String> _displayNames = {
  'AS': 'American Samoa',
  'BL': 'Saint Barthélemy',
  'BQ': 'Caribbean Netherlands',
  'CD': 'Democratic Republic of the Congo',
  'CF': 'Central African Republic',
  'CG': 'Republic of the Congo',
  'GB': 'United Kingdom',
  'KP': 'North Korea',
  'KR': 'South Korea',
  'MF': 'Saint Martin',
  'MM': 'Myanmar',
  'PM': 'Saint Pierre and Miquelon',
  'ST': 'São Tomé and Príncipe',
  'SX': 'Sint Maarten',
  'SZ': 'Eswatini',
  'TC': 'Turks and Caicos Islands',
  'TF': 'French Southern Territories',
  'TL': 'Timor-Leste',
  'UM': 'U.S. Outlying Islands',
  'VC': 'Saint Vincent and the Grenadines',
  'VG': 'British Virgin Islands',
  'VI': 'U.S. Virgin Islands',
  'WS': 'Samoa',
};

const Map<String, List<String>> _aliases = {
  'AE': ['UAE', 'Emirates'],
  'CI': ['Ivory Coast'],
  'CV': ['Cabo Verde'],
  'CZ': ['Czechia'],
  'GB': ['UK', 'Great Britain', 'England', 'Scotland', 'Wales'],
  'MM': ['Burma'],
  'MK': ['Macedonia'],
  'NL': ['Holland'],
  'SZ': ['Swaziland'],
  'TL': ['East Timor'],
  'TR': ['Türkiye', 'Turkiye'],
  'US': ['USA', 'America', 'United States of America'],
  'VA': ['Holy See'],
};
