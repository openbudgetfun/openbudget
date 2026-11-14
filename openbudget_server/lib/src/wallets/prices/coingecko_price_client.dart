import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';

class CoinGeckoPriceClient {
  static const int chunkSize = 515;
  static const String proHost = 'https://pro-api.coingecko.com';
  static const String demoHost = 'https://api.coingecko.com';
  static const String apiVersion = '/api/v3';

  static String? coingeckoProApiKeyFrom({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) =>
      _trimToNull(passwords['coingeckoProApiKey']) ??
      _trimToNull(environment['COINGECKO_PRO_API_KEY']);

  static String? coingeckoDemoApiKeyFrom({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) =>
      _trimToNull(passwords['coingeckoDemoApiKey']) ??
      _trimToNull(environment['COINGECKO_DEMO_API_KEY']);

  static bool hasSecret(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) =>
      coingeckoProApiKeyFrom(passwords: passwords, environment: environment) !=
          null ||
      coingeckoDemoApiKeyFrom(passwords: passwords, environment: environment) !=
          null;

  static bool hasProKey(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) =>
      coingeckoProApiKeyFrom(passwords: passwords, environment: environment) !=
      null;

  static String? _trimToNull(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static Uri baseUri({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) {
    final pro = coingeckoProApiKeyFrom(
      passwords: passwords,
      environment: environment,
    );
    final host = pro != null ? proHost : demoHost;
    return Uri.parse('$host$apiVersion');
  }

  static String? headerName({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) {
    final pro = coingeckoProApiKeyFrom(
      passwords: passwords,
      environment: environment,
    );
    if (pro != null) return 'x-cg-pro-api-key';
    final demo = coingeckoDemoApiKeyFrom(
      passwords: passwords,
      environment: environment,
    );
    if (demo != null) return 'x-cg-demo-api-key';
    return null;
  }

  static String? apiKey({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) {
    final pro = coingeckoProApiKeyFrom(
      passwords: passwords,
      environment: environment,
    );
    if (pro != null) return pro;
    return coingeckoDemoApiKeyFrom(
      passwords: passwords,
      environment: environment,
    );
  }

  static Future<Map<String, double>> fetchSimplePrices({
    required Iterable<String> ids,
    String vsCurrency = 'usd',
    Map<String, String> passwords = const {},
    Map<String, String> environment = const {},
    HttpClient? httpClient,
    void Function(String warning)? onWarning,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) async {
    final cleaned = ids
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const {};

    final client = httpClient ?? HttpClient();
    final shouldClose = httpClient == null;
    final prices = <String, double>{};
    try {
      for (var i = 0; i < cleaned.length; i += chunkSize) {
        final end = (i + chunkSize > cleaned.length)
            ? cleaned.length
            : i + chunkSize;
        final batch = cleaned.sublist(i, end);
        final uri = baseUri(passwords: passwords, environment: environment)
            .replace(
              path: '$apiVersion/simple/price',
              queryParameters: {
                'ids': batch.join(','),
                'vs_currencies': vsCurrency,
              },
            );
        final decoded = await _requestJson(
          client,
          uri,
          passwords: passwords,
          environment: environment,
          onWarning: onWarning,
          errorPrefix: 'CoinGecko simple/price',
          counter:
              counter ??
              requestCounter ??
              vendorRequestCounter ??
              vendorCounter,
        );
        if (decoded is Map<String, dynamic>) {
          prices.addAll(
            parseSimplePriceResponse(decoded, vsCurrency: vsCurrency),
          );
        }
      }
    } finally {
      if (shouldClose) client.close();
    }
    return prices;
  }

  static Future<Map<String, double>> fetchPrices({
    required Iterable<String> ids,
    String vsCurrency = 'usd',
    Map<String, String> passwords = const {},
    Map<String, String> environment = const {},
    HttpClient? httpClient,
    void Function(String warning)? onWarning,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) => fetchSimplePrices(
    ids: ids,
    vsCurrency: vsCurrency,
    passwords: passwords,
    environment: environment,
    httpClient: httpClient,
    onWarning: onWarning,
    counter: counter,
    requestCounter: requestCounter,
    vendorRequestCounter: vendorRequestCounter,
    vendorCounter: vendorCounter,
  );

  static Future<Map<String, double>> fetchTokenPrices({
    required String platform,
    required Iterable<String> contractAddresses,
    String vsCurrency = 'usd',
    Map<String, String> passwords = const {},
    Map<String, String> environment = const {},
    HttpClient? httpClient,
    void Function(String warning)? onWarning,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) async {
    final cleaned = contractAddresses
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (cleaned.isEmpty) return const {};

    final client = httpClient ?? HttpClient();
    final shouldClose = httpClient == null;
    final prices = <String, double>{};
    try {
      for (var i = 0; i < cleaned.length; i += chunkSize) {
        final end = (i + chunkSize > cleaned.length)
            ? cleaned.length
            : i + chunkSize;
        final batch = cleaned.sublist(i, end);
        final uri = baseUri(passwords: passwords, environment: environment)
            .replace(
              path: '$apiVersion/simple/token_price/$platform',
              queryParameters: {
                'contract_addresses': batch.join(','),
                'vs_currencies': vsCurrency,
              },
            );
        final decoded = await _requestJson(
          client,
          uri,
          passwords: passwords,
          environment: environment,
          onWarning: onWarning,
          errorPrefix: 'CoinGecko simple/token_price',
          counter:
              counter ??
              requestCounter ??
              vendorRequestCounter ??
              vendorCounter,
        );
        if (decoded is Map<String, dynamic>) {
          prices.addAll(
            parseTokenPriceResponse(decoded, vsCurrency: vsCurrency),
          );
        }
      }
    } finally {
      if (shouldClose) client.close();
    }
    return prices;
  }

  static Map<String, double> parseSimplePriceResponse(
    Map<String, dynamic> json, {
    String vsCurrency = 'usd',
  }) {
    final prices = <String, double>{};
    for (final entry in json.entries) {
      final id = entry.key.trim();
      if (id.isEmpty) continue;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final price = _coerceDouble(
          value[vsCurrency] ?? value[vsCurrency.toLowerCase()],
        );
        if (price != null && price.isFinite && price > 0) prices[id] = price;
      }
    }
    return prices;
  }

  static Map<String, double> parseTokenPriceResponse(
    Map<String, dynamic> json, {
    String vsCurrency = 'usd',
  }) {
    final prices = <String, double>{};
    for (final entry in json.entries) {
      final contract = entry.key.trim().toLowerCase();
      if (contract.isEmpty) continue;
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        final price = _coerceDouble(
          value[vsCurrency] ?? value[vsCurrency.toLowerCase()],
        );
        if (price != null && price.isFinite && price > 0) {
          prices[contract] = price;
        }
      }
    }
    return prices;
  }

  static Future<dynamic> _requestJson(
    HttpClient client,
    Uri uri, {
    required Map<String, String> passwords,
    required Map<String, String> environment,
    required String errorPrefix,
    void Function(String warning)? onWarning,
    WalletVendorRequestCounter? counter,
  }) async {
    counter?.record('coingecko');
    final current = WalletVendorRequestCounter.current;
    if (current != null && !identical(current, counter)) {
      current.record('coingecko');
    }

    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'openbudget/wallets');
      final name = headerName(passwords: passwords, environment: environment);
      final key = apiKey(passwords: passwords, environment: environment);
      if (name != null && key != null) request.headers.set(name, key);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode > 299) {
        onWarning?.call('$errorPrefix returned HTTP ${response.statusCode}.');
        return null;
      }
      return jsonDecode(body);
    } on SocketException {
      onWarning?.call('$errorPrefix request failed due to network error.');
      return null;
    } on HttpException {
      onWarning?.call('$errorPrefix request failed due to HTTP error.');
      return null;
    } on TimeoutException {
      onWarning?.call('$errorPrefix request timed out.');
      return null;
    } on FormatException {
      onWarning?.call('$errorPrefix response could not be parsed.');
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
