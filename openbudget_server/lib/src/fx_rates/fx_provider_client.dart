import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// Default base URL for the currencyapi.com v3 API.
const currencyApiDefaultBaseUrl = 'https://api.currencyapi.com/v3';

/// The password key holding the currency provider API key.
const currencyApiKeyName = 'currencyApiKey';

/// The password key overriding the currency provider base URL.
const currencyApiBaseUrlName = 'currencyApiBaseUrl';

/// One provider response: the provider's data time and exact rate strings.
///
/// Rates are units of the currency per 1 USD. They are already parsed at the
/// JSON boundary; nothing after this point handles a double.
class FxProviderResult {
  const FxProviderResult({required this.fetchedAt, required this.rates});

  /// When the provider produced the data.
  final DateTime fetchedAt;

  /// Exact decimal rates by ISO 4217 code.
  final Map<String, String> rates;
}

/// The provider port used by the FX service, replaceable in tests.
abstract class FxRateProviderClient {
  /// Name used in logs.
  String get providerName;

  /// Fetches the latest USD-based rates.
  Future<FxProviderResult> fetchLatest({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  });

  /// Fetches the provider's historical snapshot for one calendar date.
  ///
  /// Implementations must not substitute a newer day's rates: a missing
  /// historical day is a missing rate, never a fabricated one.
  Future<FxProviderResult> fetchHistorical({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required DateTime date,
    required String baseUrl,
  });
}

/// currencyapi.com client. JSON numbers are converted to exact decimals here
/// and nowhere else.
class CurrencyApiProviderClient implements FxRateProviderClient {
  @override
  String get providerName => 'currencyapi';

  @override
  Future<FxProviderResult> fetchLatest({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  }) async {
    final uri = currencyApiUri(
      baseUrl: baseUrl,
      path: 'latest',
      apiKey: apiKey,
      baseCurrencyCode: baseCurrencyCode,
      currencies: currencies,
    );
    return _fetch(uri);
  }

  @override
  Future<FxProviderResult> fetchHistorical({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required DateTime date,
    required String baseUrl,
  }) async {
    final uri = currencyApiUri(
      baseUrl: baseUrl,
      path: 'historical',
      apiKey: apiKey,
      baseCurrencyCode: baseCurrencyCode,
      currencies: currencies,
      date: date,
    );
    return _fetch(uri);
  }

  Future<FxProviderResult> _fetch(Uri uri) async {
    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValidationException(
          message: 'FX provider request failed (status=${response.statusCode})',
        );
      }

      return parseCurrencyApiResponse(body);
    } finally {
      httpClient.close(force: true);
    }
  }
}

/// Builds a currencyapi.com URL. Exposed for tests.
Uri currencyApiUri({
  required String baseUrl,
  required String path,
  required String apiKey,
  required String baseCurrencyCode,
  required List<String> currencies,
  DateTime? date,
}) {
  final trimmed = baseUrl.trim();
  final base = trimmed.isEmpty ? currencyApiDefaultBaseUrl : trimmed;
  final normalized = base.endsWith('/') ? '$base$path' : '$base/$path';
  final query = <String, String>{
    'apikey': apiKey,
    'base_currency': baseCurrencyCode,
    'currencies': currencies.join(','),
    if (date != null) 'date': formatProviderDate(date),
  };
  return Uri.parse(normalized).replace(queryParameters: query);
}

/// Parses a currencyapi.com response body. Exposed for tests.
FxProviderResult parseCurrencyApiResponse(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) {
    throw ValidationException(message: 'FX provider returned invalid payload');
  }

  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw ValidationException(
      message: 'FX provider payload missing data map',
    );
  }

  final meta = decoded['meta'];
  final fetchedAt = parseProviderFetchedAt(meta);
  final rates = <String, String>{'USD': '1'};

  for (final entry in data.entries) {
    final currency = CurrencyCode.tryParse(entry.key);
    if (currency == null) continue;
    if (currency.code == 'USD') {
      rates['USD'] = '1';
      continue;
    }
    final wrapper = entry.value;
    final rawValue = wrapper is Map<String, dynamic>
        ? wrapper['value']
        : wrapper;
    final parsed = parseProviderRate(rawValue);
    if (parsed == null) {
      ObLogger('FxProvider').fine(
        'Skipping unusable ${currency.code} rate from the FX provider',
      );
      continue;
    }
    rates[currency.code] = parsed;
  }

  if (rates.length <= 1) {
    throw ValidationException(message: 'FX provider returned no usable rates');
  }

  return FxProviderResult(fetchedAt: fetchedAt, rates: rates);
}

/// Converts one provider JSON value to an exact, positive decimal string.
///
/// Doubles are accepted only here, at the external JSON boundary. Zero,
/// negative, non-finite, exponent-bearing strings that cannot be expanded and
/// malformed values all return null.
String? parseProviderRate(Object? raw) {
  if (raw is int) {
    return raw > 0 ? raw.toString() : null;
  }
  if (raw is double) {
    return ExactDecimal.fromDouble(raw)?.toString();
  }
  if (raw is num) {
    return ExactDecimal.fromDouble(raw.toDouble())?.toString();
  }
  if (raw is! String) return null;

  final text = raw.trim();
  final direct = ExactDecimal.tryParse(text);
  if (direct != null) return direct.toString();

  final asDouble = double.tryParse(text);
  if (asDouble == null) return null;
  return ExactDecimal.fromDouble(asDouble)?.toString();
}

/// Parses the provider's `meta.last_updated_at`, falling back to now.
DateTime parseProviderFetchedAt(Object? meta) {
  if (meta is Map<String, dynamic>) {
    final raw = meta['last_updated_at'];
    if (raw is String) {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed.toUtc();
    }
  }
  return DateTime.now().toUtc();
}

/// `yyyy-MM-dd` for the provider's historical endpoint.
String formatProviderDate(DateTime date) {
  final utc = date.toUtc();
  final year = utc.year.toString().padLeft(4, '0');
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
