import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';

/// Reads single Bitcoin addresses from Esplora servers.
///
/// Public Esplora limits are unpublished and answered with HTTP 429
/// (multichain-wallets.md 4.2), so the client paces itself at five
/// requests a second per host, honours a `Retry-After` header by waiting
/// and retrying the same host once, and fails over to the next host
/// otherwise. Every failure becomes a [WalletProviderException] with a
/// plain-words message that carries no URL and no address, so nothing
/// about a wallet reaches logs or `lastSyncError`.
final class EsploraClient {
  /// Creates a client. Tests inject [transport], [now] and [delay] so no
  /// test touches the network and no test sleeps.
  EsploraClient({
    List<Uri>? baseUrls,
    EsploraTransport? transport,
    this.minRequestInterval = defaultMinRequestInterval,
    this.maxRetryAfter = defaultMaxRetryAfter,
    DateTime Function()? now,
    Future<void> Function(Duration duration)? delay,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) : _baseUrls = _checkedBaseUrls(baseUrls),
       _transport = transport ?? _ioTransport,
       _now = now ?? DateTime.now,
       _delay = delay ?? _defaultDelay,
       _counter =
           counter ?? requestCounter ?? vendorRequestCounter ?? vendorCounter;

  /// mempool.space first, then Blockstream. Both speak the same Esplora
  /// API, and a self-hosted server later replaces the list with one URL
  /// (multichain-wallets.md 4.5).
  static const defaultBaseUrls = [
    'https://mempool.space/api',
    'https://blockstream.info/api',
  ];

  /// One request every 200 ms is five requests a second per host.
  static const defaultMinRequestInterval = Duration(milliseconds: 200);

  /// A `Retry-After` longer than this is not waited out; the client fails
  /// over instead, so one busy host cannot stall a sync.
  static const defaultMaxRetryAfter = Duration(seconds: 30);

  static const _malformedMessage =
      'The Bitcoin service sent data OpenBudget could not read. '
      'Try again later.';
  static const _rateLimitedMessage =
      'The Bitcoin service is rate limiting requests right now. '
      'Try again in a minute.';
  static const _unreachableMessage =
      'The Bitcoin service could not be reached. Try again later.';

  final List<Uri> _baseUrls;
  final EsploraTransport _transport;
  final DateTime Function() _now;
  final Future<void> Function(Duration duration) _delay;
  final WalletVendorRequestCounter? _counter;

  /// The minimum spacing between two requests to one host.
  final Duration minRequestInterval;

  /// The longest `Retry-After` the client honours on one host.
  final Duration maxRetryAfter;

  final _lastRequestAt = <Uri, DateTime>{};

  /// The hosts this client reads, in failover order.
  List<Uri> get baseUrls => List.unmodifiable(_baseUrls);

  /// Reads one address's balance facts, failing over until a host answers.
  Future<EsploraAddressSummary> fetchAddress(String address) async {
    final failures = <_EsploraFailure>[];
    for (final baseUrl in _baseUrls) {
      try {
        return await _fetchFrom(baseUrl, address);
      } on _EsploraFailure catch (failure) {
        failures.add(failure);
      }
    }
    throw _describe(failures);
  }

  Future<EsploraAddressSummary> _fetchFrom(Uri baseUrl, String address) async {
    var retriedAfter429 = false;
    while (true) {
      await _pace(baseUrl);
      _recordRequest();
      final EsploraResponse response;
      try {
        response = await _transport(_addressUrl(baseUrl, address));
      } on SocketException {
        throw const _EsploraFailure.transport();
      } on HttpException {
        throw const _EsploraFailure.transport();
      } on TimeoutException {
        throw const _EsploraFailure.transport();
      } on FormatException {
        throw const _EsploraFailure.transport();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return parseAddressBody(response.body);
      }

      if (response.statusCode == 429) {
        final wait = _retryAfterOf(response);
        // A 429 with an honourable `Retry-After` retries the same host
        // once; anything else moves straight to the next host, because
        // public hosts throttle by IP and waiting longer would only hold
        // the sync.
        if (!retriedAfter429 && wait != null) {
          retriedAfter429 = true;
          await _delay(wait);
          continue;
        }
        throw const _EsploraFailure.rateLimited();
      }
      throw _EsploraFailure.http(response.statusCode);
    }
  }

  void _recordRequest() {
    _counter?.record('esplora');
    final current = WalletVendorRequestCounter.current;
    if (current != null && !identical(current, _counter)) {
      current.record('esplora');
    }
    if (_counter == null && current == null) {
      // No counter available: nothing to record.
    }
  }

  /// Holds requests to [baseUrl] at least [minRequestInterval] apart.
  ///
  /// The clock and the wait are injected so the pace is provable without
  /// real sleeps.
  Future<void> _pace(Uri baseUrl) async {
    final last = _lastRequestAt[baseUrl];
    final moment = _now();
    var requestedAt = moment;
    if (last != null) {
      final earliest = last.add(minRequestInterval);
      if (moment.isBefore(earliest)) {
        final wait = earliest.difference(moment);
        await _delay(wait);
        requestedAt = earliest;
      }
    }
    _lastRequestAt[baseUrl] = requestedAt;
  }

  /// The `Retry-After` wait, or null when the header is absent, not a
  /// whole number of seconds, negative, or longer than [maxRetryAfter].
  /// Esplora answers in seconds; the HTTP-date form is not honoured.
  Duration? _retryAfterOf(EsploraResponse response) {
    final raw = response.retryAfter?.trim();
    if (raw == null || raw.isEmpty) return null;
    final seconds = int.tryParse(raw);
    if (seconds == null || seconds < 0) return null;
    final wait = Duration(seconds: seconds);
    if (wait > maxRetryAfter) return null;
    return wait;
  }

  /// The address endpoint on [baseUrl]. Building through `pathSegments`
  /// percent-encodes every piece, so no address can change the path.
  Uri _addressUrl(Uri baseUrl, String address) => baseUrl.replace(
    pathSegments: [
      ...baseUrl.pathSegments.where((segment) => segment.isNotEmpty),
      'address',
      address,
    ],
  );

  /// Composes one plain-words failure out of every host's outcome. A rate
  /// limit names itself; otherwise a HTTP status, which is the most
  /// specific answer any host gave, wins over a vague transport error.
  /// No message names a host, a URL or an address.
  WalletProviderException _describe(List<_EsploraFailure> failures) {
    if (failures.any((failure) => failure.isRateLimited)) {
      return const WalletProviderException(_rateLimitedMessage);
    }
    final status = failures
        .where((failure) => failure.statusCode != null)
        .firstOrNull
        ?.statusCode;
    if (status != null) {
      return WalletProviderException(
        'The Bitcoin service could not be read (HTTP $status). '
        'Try again later.',
      );
    }
    return const WalletProviderException(_unreachableMessage);
  }

  static List<Uri> _checkedBaseUrls(List<Uri>? baseUrls) {
    if (baseUrls == null) {
      return [for (final url in defaultBaseUrls) Uri.parse(url)];
    }
    if (baseUrls.isEmpty) {
      throw ArgumentError.value(baseUrls, 'baseUrls', 'must not be empty');
    }
    return List.of(baseUrls);
  }

  /// The production transport: one GET per call on a short-lived client,
  /// with a generic user agent (multichain-wallets.md 4.4).
  static Future<EsploraResponse> _ioTransport(Uri url) async {
    final client = HttpClient()..userAgent = 'OpenBudgetServer';
    try {
      final request = await client.getUrl(url);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final headers = <String, String>{};
      response.headers.forEach((name, values) {
        headers[name.toLowerCase()] = values.firstOrNull ?? '';
      });
      return EsploraResponse(
        statusCode: response.statusCode,
        headers: headers,
        body: body,
      );
    } finally {
      client.close();
    }
  }

  static Future<void> _defaultDelay(Duration duration) =>
      Future<void>.delayed(duration);

  /// Parses one address endpoint body.
  static EsploraAddressSummary parseAddressBody(String? body) {
    final Object? decoded;
    try {
      decoded = body == null ? null : jsonDecode(body);
    } on FormatException {
      throw const WalletProviderException(_malformedMessage);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const WalletProviderException(_malformedMessage);
    }
    final summary = EsploraAddressSummary(
      chainStats: _txoStats(decoded['chain_stats']),
      mempoolStats: _txoStats(decoded['mempool_stats']),
    );
    if (summary.confirmedSats.isNegative || summary.mempoolSats.isNegative) {
      throw const WalletProviderException(_malformedMessage);
    }
    return summary;
  }

  static EsploraTxoStats _txoStats(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const WalletProviderException(_malformedMessage);
    }
    return EsploraTxoStats(
      fundedSats: _sats(value['funded_txo_sum']),
      spentSats: _sats(value['spent_txo_sum']),
    );
  }

  static BigInt _sats(Object? value) {
    if (value is int && value >= 0) return BigInt.from(value);
    if (value is String) {
      final parsed = BigInt.tryParse(value.trim());
      if (parsed != null && !parsed.isNegative) return parsed;
    }
    throw const WalletProviderException(_malformedMessage);
  }
}

/// Sends one GET and returns the response, or throws for a transport
/// failure. Tests inject a scripted stand-in.
typedef EsploraTransport = Future<EsploraResponse> Function(Uri url);

/// One HTTP response, reduced to what the client reads. Header names are
/// lower-cased. Neither the request URL nor the queried address is kept.
final class EsploraResponse {
  const EsploraResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String? body;
  final Map<String, String?> headers;

  /// The `Retry-After` header, or null.
  String? get retryAfter => headers['retry-after'];
}

/// The txo sums one Esplora stat group reports for an address.
final class EsploraTxoStats {
  const EsploraTxoStats({required this.fundedSats, required this.spentSats});

  /// Every satoshi ever paid to the address, in this stat group.
  final BigInt fundedSats;

  /// Every satoshi ever paid out of the address, in this stat group.
  final BigInt spentSats;

  /// The balance this group holds: funded minus spent.
  BigInt get balanceSats => fundedSats - spentSats;
}

/// One address's balance facts.
///
/// Esplora splits the address into a confirmed group (`chain_stats`) and
/// an unconfirmed one (`mempool_stats`); each balance is funded minus
/// spent txo sums, and the live balance is the two added.
final class EsploraAddressSummary {
  const EsploraAddressSummary({
    required this.chainStats,
    required this.mempoolStats,
  });

  final EsploraTxoStats chainStats;
  final EsploraTxoStats mempoolStats;

  /// The confirmed balance in satoshis.
  BigInt get confirmedSats => chainStats.balanceSats;

  /// The balance waiting in the mempool, in satoshis.
  BigInt get mempoolSats => mempoolStats.balanceSats;

  /// The live balance: confirmed plus mempool, in satoshis.
  BigInt get totalSats => confirmedSats + mempoolSats;
}

/// Why one host gave up. Private: the client turns these into one
/// plain-words [WalletProviderException] once every host has failed.
final class _EsploraFailure implements Exception {
  const _EsploraFailure.rateLimited() : isRateLimited = true, statusCode = null;
  const _EsploraFailure.transport() : isRateLimited = false, statusCode = null;
  const _EsploraFailure.http(this.statusCode) : isRateLimited = false;

  final bool isRateLimited;
  final int? statusCode;
}
