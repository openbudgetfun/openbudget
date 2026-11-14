import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';

/// One DefiLlama price result.
class DefiLlamaPrice {
  const DefiLlamaPrice({
    required this.key,
    required this.price,
    this.symbol,
    this.timestamp,
    this.confidence = 0.0,
    this.decimals,
  });

  final String key;
  final double price;
  final String? symbol;
  final int? timestamp;
  final double confidence;
  final int? decimals;

  bool get isAboveThreshold =>
      confidence >= DefiLlamaPriceClient.confidenceThreshold;
}

class DefiLlamaPriceClient {
  static const double confidenceThreshold = 0.9;
  static const String baseUrl = 'https://coins.llama.fi/prices/current';

  /// Fetches prices for the given DefiLlama coin keys (e.g. `coingecko:bitcoin`,
  /// `ethereum:0x...`). Returns a map keyed by the request key.
  static Future<Map<String, DefiLlamaPrice>> fetchPrices({
    required Iterable<String> coins,
    HttpClient? httpClient,
    void Function(String warning)? onWarning,
  }) async {
    final cleaned = coins
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const {};

    final client = httpClient ?? HttpClient();
    final shouldClose = httpClient == null;
    final prices = <String, DefiLlamaPrice>{};
    try {
      // DefiLlama accepts comma-separated keys in the path.
      final uri = Uri.parse('$baseUrl/${cleaned.join(',')}');
      final decoded = await _requestJson(client, uri, onWarning: onWarning);
      if (decoded is Map<String, dynamic>) {
        prices.addAll(parsePricesResponse(decoded));
      }
    } finally {
      if (shouldClose) client.close();
    }
    return prices;
  }

  static Map<String, DefiLlamaPrice> parsePricesResponse(
    Map<String, dynamic> json,
  ) {
    final coins = json['coins'];
    final container = coins is Map<String, dynamic> ? coins : json;
    final prices = <String, DefiLlamaPrice>{};
    for (final entry in container.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final price = _coerceDouble(value['price']);
        if (price == null || !price.isFinite) continue;
        final confidence = _coerceDouble(value['confidence']) ?? 0.0;
        prices[key] = DefiLlamaPrice(
          key: key,
          price: price,
          symbol: value['symbol'] is String ? value['symbol'] as String : null,
          timestamp: value['timestamp'] is int
              ? value['timestamp'] as int
              : int.tryParse('${value['timestamp']}'),
          confidence: confidence,
          decimals: value['decimals'] is int
              ? value['decimals'] as int
              : int.tryParse('${value['decimals']}'),
        );
      }
    }
    return prices;
  }

  /// Filters a parsed response to entries at or above the confidence threshold.
  static Map<String, DefiLlamaPrice> filterByConfidence(
    Map<String, DefiLlamaPrice> prices, {
    double threshold = confidenceThreshold,
  }) => {
    for (final entry in prices.entries)
      if (entry.value.confidence >= threshold) entry.key: entry.value,
  };

  static Future<dynamic> _requestJson(
    HttpClient client,
    Uri uri, {
    void Function(String warning)? onWarning,
  }) async {
    WalletVendorRequestCounter.current?.record('defillama');
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'openbudget/wallets');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode > 299) {
        onWarning?.call(
          'DefiLlama prices/current returned HTTP ${response.statusCode}.',
        );
        return null;
      }
      return jsonDecode(body);
    } on SocketException {
      onWarning?.call(
        'DefiLlama prices/current request failed due to network error.',
      );
      return null;
    } on HttpException {
      onWarning?.call(
        'DefiLlama prices/current request failed due to HTTP error.',
      );
      return null;
    } on TimeoutException {
      onWarning?.call('DefiLlama prices/current request timed out.');
      return null;
    } on FormatException {
      onWarning?.call('DefiLlama prices/current response could not be parsed.');
      return null;
    }
  }

  static double? _coerceDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
