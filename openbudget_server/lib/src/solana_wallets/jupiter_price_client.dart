import 'dart:convert';
import 'dart:io';

/// Lightweight Jupiter price API client used as a fallback for missing DAS
/// token prices.
class JupiterPriceClient {
  static final _baseUri = Uri.parse('https://lite-api.jup.ag/price/v3');
  static final _base58Mint = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
  static const _batchSize = 100;

  /// Fetches token prices in USD keyed by mint address.
  static Future<Map<String, double>> fetchUsdPrices({
    required Iterable<String> mintAddresses,
    void Function(String warning)? onWarning,
    HttpClient? httpClient,
  }) async {
    final cleanedMints = mintAddresses
        .map((mint) => mint.trim())
        .where((mint) => mint.isNotEmpty && _base58Mint.hasMatch(mint))
        .toSet()
        .toList(growable: false);
    if (cleanedMints.isEmpty) return const {};

    final client = httpClient ?? HttpClient();
    final shouldClose = httpClient == null;
    final prices = <String, double>{};

    try {
      for (var index = 0; index < cleanedMints.length; index += _batchSize) {
        final next = index + _batchSize;
        final batch = cleanedMints.sublist(
          index,
          next > cleanedMints.length ? cleanedMints.length : next,
        );
        final uri = _baseUri.replace(queryParameters: {'ids': batch.join(',')});
        final request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');

        final response = await request.close();
        final body = await response.transform(utf8.decoder).join();
        if (response.statusCode < 200 || response.statusCode > 299) {
          onWarning?.call(
            'Jupiter price API returned HTTP ${response.statusCode}.',
          );
          continue;
        }

        final decoded = jsonDecode(body);
        if (decoded is! Map<String, dynamic>) {
          onWarning?.call('Jupiter price API returned an unexpected payload.');
          continue;
        }
        prices.addAll(parseUsdPriceResponse(decoded));
      }
    } on SocketException {
      onWarning?.call('Jupiter price API request failed due to network error.');
    } on HttpException {
      onWarning?.call('Jupiter price API request failed due to HTTP error.');
    } on FormatException {
      onWarning?.call('Jupiter price API response could not be parsed.');
    } finally {
      if (shouldClose) {
        client.close();
      }
    }

    return prices;
  }

  /// Parses Jupiter price response variants into mint => USD map.
  static Map<String, double> parseUsdPriceResponse(Map<String, dynamic> json) {
    final container = json['data'];
    final data = container is Map<String, dynamic> ? container : json;
    final prices = <String, double>{};

    for (final entry in data.entries) {
      final mint = entry.key.trim();
      if (mint.isEmpty) continue;

      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final price =
            _coerceDouble(value['price']) ??
            _coerceDouble(value['usdPrice']) ??
            _coerceDouble(value['pricePerToken']);
        if (price != null && price.isFinite && price > 0) {
          prices[mint] = price;
        }
        continue;
      }

      final scalarPrice = _coerceDouble(value);
      if (scalarPrice != null && scalarPrice.isFinite && scalarPrice > 0) {
        prices[mint] = scalarPrice;
      }
    }

    return prices;
  }

  static double? _coerceDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
