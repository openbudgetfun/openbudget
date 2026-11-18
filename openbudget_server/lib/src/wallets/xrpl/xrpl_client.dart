import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';

/// Reads XRP Ledger accounts from public JSON-RPC servers.
///
/// The three documented public servers are tried in order; a transport
/// failure, a non-2xx response or an unparseable body fails over to the
/// next one. Every failure becomes a WalletProviderException with a
/// plain-words message that carries no URL and no address, so nothing
/// about a wallet reaches logs or `lastSyncError`.
///
/// Tests inject a transport (or an http client) so no test touches the
/// network.
final class XrplClient {
  XrplClient({
    Object? endpoints,
    Object? baseUrls,
    Object? urls,
    Object? transport,
    http.Client? httpClient,
    http.Client? client,
    this.userAgent = 'OpenBudgetServer',
  }) : _endpoints = _parseEndpoints(endpoints ?? baseUrls ?? urls),
       // Keeping the public parameter named `transport`.
       // ignore: prefer_initializing_formals
       _transport = transport,
       _httpClient = httpClient ?? client {
    if (_endpoints.isEmpty) {
      throw ArgumentError('At least one XRP Ledger endpoint is required.');
    }
  }

  /// The three documented public servers, in failover order:
  /// xrplcluster.com, then Ripple's s1 and s2.
  static const defaultEndpoints = <String>[
    'https://xrplcluster.com',
    'https://s1.ripple.com:51234',
    'https://s2.ripple.com:51234',
  ];

  static const _unreachableMessage =
      'The XRP Ledger could not be reached. Try again later.';

  final List<Uri> _endpoints;
  final Object? _transport;
  final http.Client? _httpClient;
  final String userAgent;

  /// The hosts this client reads, in failover order.
  List<Uri> get endpoints => List.unmodifiable(_endpoints);
  List<Uri> get baseUrls => endpoints;

  /// Sends one JSON-RPC [method] with [params] to the first server that
  /// answers.
  Future<Map<String, dynamic>> call(
    String method,
    Map<String, dynamic> params,
  ) async {
    final body = jsonEncode({
      'method': method,
      'params': [params],
    });
    for (final endpoint in _endpoints) {
      try {
        final response = await _post(endpoint, body);
        if (response.statusCode < 200 || response.statusCode > 299) {
          continue;
        }
        final decoded = jsonDecode(response.body ?? '');
        if (decoded is! Map<String, dynamic>) {
          continue;
        }
        final result = decoded['result'];
        if (result is! Map<String, dynamic>) {
          continue;
        }
        return result;
      } on SocketException {
        continue;
      } on HttpException {
        continue;
      } on TimeoutException {
        continue;
      } on FormatException {
        continue;
      } on Object catch (_) {
        continue;
      }
    }
    throw const WalletProviderException(_unreachableMessage);
  }

  Future<_XrplResponse> _post(Uri endpoint, String body) async {
    WalletVendorRequestCounter.current?.record('xrpl');
    // Transport injection: support both two-argument (url, body) and
    // one-argument (url) callables so tests can script responses either
    // way.
    if (_transport != null) {
      dynamic result;
      try {
        result = Function.apply(_transport as Function, [endpoint, body]);
      } on Object catch (_) {
        result = Function.apply(_transport as Function, [endpoint]);
      }
      final awaited = await result;
      return _coerceResponse(awaited);
    }

    final client = _httpClient ?? http.Client();
    final ownsClient = _httpClient == null;
    try {
      final request = http.Request('POST', endpoint);
      request.headers[HttpHeaders.contentTypeHeader] = 'application/json';
      request.headers[HttpHeaders.acceptHeader] = 'application/json';
      request.headers[HttpHeaders.userAgentHeader] = userAgent;
      request.body = body;
      final streamed = await client.send(request);
      final responseBody = await streamed.stream.bytesToString();
      return _XrplResponse(
        statusCode: streamed.statusCode,
        body: responseBody,
        headers: streamed.headers,
      );
    } finally {
      if (ownsClient) client.close();
    }
  }

  _XrplResponse _coerceResponse(Object? value) {
    if (value is _XrplResponse) return value;
    if (value is XrplResponse) return _XrplResponse.from(value);
    // Allow a plain Map to stand in for a 200 response in tests.
    if (value is Map) {
      return _XrplResponse(
        statusCode: 200,
        body: jsonEncode(value),
      );
    }
    throw const FormatException('unexpected transport result');
  }

  static List<Uri> _parseEndpoints(Object? input) {
    if (input == null) return defaultEndpoints.map(Uri.parse).toList();
    final list = input is List ? input : [input];
    final result = <Uri>[];
    for (final entry in list) {
      if (entry is Uri) {
        result.add(entry);
      } else if (entry is String) {
        result.add(Uri.parse(entry));
      }
    }
    return result;
  }
}

/// One HTTP response, reduced to what the client reads.
final class XrplResponse {
  const XrplResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String? body;
  final Map<String, String> headers;
}

final class _XrplResponse {
  const _XrplResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
  });

  factory _XrplResponse.from(XrplResponse value) => _XrplResponse(
    statusCode: value.statusCode,
    body: value.body,
    headers: value.headers,
  );

  final int statusCode;
  final String? body;
  final Map<String, String> headers;
}
