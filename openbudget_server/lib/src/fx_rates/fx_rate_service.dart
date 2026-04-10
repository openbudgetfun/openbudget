import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

const _currencyApiDefaultBaseUrl = 'https://api.currencyapi.com/v3';
const _currencyApiKeyName = 'currencyApiKey';
const _currencyApiBaseUrlName = 'currencyApiBaseUrl';

class FxProviderResult {
  const FxProviderResult({required this.fetchedAt, required this.rates});

  final DateTime fetchedAt;
  final Map<String, double> rates;
}

abstract class FxRateProviderClient {
  String get providerName;

  Future<FxProviderResult> fetchLatest({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  });
}

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
    final upstreamUri = _buildCurrencyApiUri(
      apiKey: apiKey,
      baseCurrencyCode: baseCurrencyCode,
      currencies: currencies,
      baseUrl: baseUrl,
    );

    final httpClient = HttpClient();
    try {
      final request = await httpClient.getUrl(upstreamUri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ValidationException(
          'FX provider request failed (status=${response.statusCode})',
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw ValidationException('FX provider returned invalid payload');
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        throw ValidationException('FX provider payload missing data map');
      }

      final meta = decoded['meta'];
      final fetchedAt = _parseFetchedAt(meta);

      final rates = <String, double>{baseCurrencyCode: 1.0};
      for (final entry in data.entries) {
        final code = entry.key;
        final valueWrapper = entry.value;
        if (valueWrapper is! Map<String, dynamic>) continue;
        final rawValue = valueWrapper['value'];
        double? parsed;
        if (rawValue is num) {
          parsed = rawValue.toDouble();
        } else if (rawValue is String) {
          parsed = double.tryParse(rawValue);
        }
        if (parsed == null) continue;
        rates[code] = parsed;
      }

      if (rates.length <= 1) {
        throw ValidationException('FX provider returned no usable rates');
      }

      return FxProviderResult(fetchedAt: fetchedAt, rates: rates);
    } finally {
      httpClient.close(force: true);
    }
  }

  DateTime _parseFetchedAt(Object? meta) {
    if (meta is! Map<String, dynamic>) return DateTime.now().toUtc();
    final raw = meta['last_updated_at'];
    if (raw is! String) return DateTime.now().toUtc();
    return DateTime.tryParse(raw)?.toUtc() ?? DateTime.now().toUtc();
  }

  Uri _buildCurrencyApiUri({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  }) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? '${baseUrl}latest'
        : '$baseUrl/latest';

    final uri = Uri.parse(normalizedBaseUrl);
    return uri.replace(
      queryParameters: {
        'apikey': apiKey,
        'base_currency': baseCurrencyCode,
        'currencies': currencies.join(','),
      },
    );
  }
}

/// Persists FX snapshots and serves latest rates for display-currency conversion.
class FxRateService {
  static final _log = ObLogger('FxRateService');

  static const _providerName = 'currencyapi';
  static const _baseCurrencyCode = 'USD';

  static Duration _refreshInterval = const Duration(minutes: 10);
  static Timer? _refreshTimer;
  static bool _refreshInFlight = false;

  static FxRateProviderClient _providerClient = CurrencyApiProviderClient();
  static String? _configuredApiKey;
  static String _configuredBaseUrl = _currencyApiDefaultBaseUrl;

  static void configure({
    required String? apiKey,
    required String? baseUrl,
    Duration refreshInterval = const Duration(minutes: 10),
    FxRateProviderClient? providerClient,
  }) {
    final trimmedApiKey = apiKey?.trim();
    _configuredApiKey = (trimmedApiKey?.isEmpty ?? true) ? null : trimmedApiKey;
    _configuredBaseUrl = (baseUrl == null || baseUrl.trim().isEmpty)
        ? _currencyApiDefaultBaseUrl
        : baseUrl.trim();
    _refreshInterval = refreshInterval;
    if (providerClient != null) {
      _providerClient = providerClient;
    }
  }

  static void resetForTests() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _refreshInFlight = false;
    _providerClient = CurrencyApiProviderClient();
    _configuredApiKey = null;
    _configuredBaseUrl = _currencyApiDefaultBaseUrl;
    _refreshInterval = const Duration(minutes: 10);
  }

  static void startBackgroundRefresh(Serverpod pod) {
    _refreshTimer?.cancel();

    // Warm immediately and then keep snapshots fresh.
    unawaited(_refreshWithInternalSession(pod, reason: 'startup'));

    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      unawaited(_refreshWithInternalSession(pod, reason: 'periodic'));
    });
  }

  static Future<void> _refreshWithInternalSession(
    Serverpod pod, {
    required String reason,
  }) async {
    final session = await pod.createSession(enableLogging: false);
    try {
      if (!_hasProviderCredentials(session)) {
        _log.warning(
          'Skipping FX $reason refresh; missing $_currencyApiKeyName in passwords.',
        );
        return;
      }
      await refreshNow(session);
    } on Exception catch (error, stackTrace) {
      _log.warning('FX $reason refresh failed: $error\n$stackTrace');
    } finally {
      await session.close();
    }
  }

  static Future<FxLatestSnapshot> latest(Session session) async {
    final now = DateTime.now().toUtc();
    final current = await _findLatestSnapshot(session);

    if (current == null) {
      if (_hasProviderCredentials(session)) {
        return refreshNow(session);
      }
      _log.warning(
        'No FX rates available yet and provider credentials are not configured; serving USD fallback snapshot.',
      );
      return _fallbackSnapshot(fetchedAt: now);
    }

    final isDueForRefresh =
        now.difference(current.fetchedAt.toUtc()) >= _refreshInterval;

    if (isDueForRefresh && _hasProviderCredentials(session)) {
      try {
        return await refreshNow(session);
      } on Exception catch (error, stackTrace) {
        _log.warning(
          'Serving stale FX snapshot after refresh failure: $error\n$stackTrace',
        );
      }
    }

    return _toLatestSnapshot(session, current, isStale: isDueForRefresh);
  }

  static Future<FxLatestSnapshot> refreshNow(Session session) async {
    if (_refreshInFlight) {
      final existing = await _findLatestSnapshot(session);
      if (existing != null) {
        return _toLatestSnapshot(session, existing, isStale: false);
      }
    }

    if (!_hasProviderCredentials(session)) {
      throw ValidationException(
        'Missing currency provider credentials ($_currencyApiKeyName).',
      );
    }

    _refreshInFlight = true;
    try {
      final apiKey = _resolveApiKey(session)!;
      final baseUrl = _resolveBaseUrl(session);
      final providerResult = await _providerClient.fetchLatest(
        apiKey: apiKey,
        baseCurrencyCode: _baseCurrencyCode,
        currencies: CurrencyCode.values.map((value) => value.code).toList(),
        baseUrl: baseUrl,
      );

      await FxRateSnapshot.db.updateWhere(
        session,
        columnValues: (table) => [table.isLatest(false)],
        where: (table) =>
            table.provider.equals(_providerName) &
            table.baseCurrencyCode.equals(_baseCurrencyCode) &
            table.isLatest.equals(true),
      );

      final snapshot = await FxRateSnapshot.db.insertRow(
        session,
        FxRateSnapshot(
          provider: _providerName,
          baseCurrencyCode: _baseCurrencyCode,
          fetchedAt: providerResult.fetchedAt,
          isLatest: true,
        ),
      );

      final snapshotId = snapshot.id;
      if (snapshotId == null) {
        throw ValidationException('Failed to persist FX snapshot id');
      }

      final entries = providerResult.rates.entries
          .map(
            (entry) => FxRateEntry(
              snapshotId: snapshotId,
              currencyCode: entry.key,
              rate: entry.value,
            ),
          )
          .toList();

      await FxRateEntry.db.insert(session, entries);

      final quotes =
          entries
              .map(
                (entry) => FxRateQuote(
                  currencyCode: entry.currencyCode,
                  rate: entry.rate,
                ),
              )
              .toList()
            ..sort((a, b) => a.currencyCode.compareTo(b.currencyCode));

      return FxLatestSnapshot(
        baseCurrencyCode: snapshot.baseCurrencyCode,
        fetchedAt: snapshot.fetchedAt,
        isStale: false,
        rates: quotes,
      );
    } finally {
      _refreshInFlight = false;
    }
  }

  static Future<FxRateSnapshot?> _findLatestSnapshot(Session session) => FxRateSnapshot.db.findFirstRow(
      session,
      where: (table) =>
          table.provider.equals(_providerName) &
          table.baseCurrencyCode.equals(_baseCurrencyCode) &
          table.isLatest.equals(true),
      orderBy: (table) => table.fetchedAt,
      orderDescending: true,
    );

  static Future<FxLatestSnapshot> _toLatestSnapshot(
    Session session,
    FxRateSnapshot snapshot, {
    required bool isStale,
  }) async {
    final snapshotId = snapshot.id;
    if (snapshotId == null) {
      throw ValidationException('FX snapshot missing id');
    }

    final entries = await FxRateEntry.db.find(
      session,
      where: (table) => table.snapshotId.equals(snapshotId),
      orderBy: (table) => table.currencyCode,
    );

    return FxLatestSnapshot(
      baseCurrencyCode: snapshot.baseCurrencyCode,
      fetchedAt: snapshot.fetchedAt,
      isStale: isStale,
      rates: entries
          .map(
            (entry) =>
                FxRateQuote(currencyCode: entry.currencyCode, rate: entry.rate),
          )
          .toList(),
    );
  }

  static bool _hasProviderCredentials(Session session) => _resolveApiKey(session) != null;

  static FxLatestSnapshot _fallbackSnapshot({required DateTime fetchedAt}) => FxLatestSnapshot(
      baseCurrencyCode: _baseCurrencyCode,
      fetchedAt: fetchedAt,
      isStale: true,
      rates: [FxRateQuote(currencyCode: _baseCurrencyCode, rate: 1)],
    );

  static String? _resolveApiKey(Session session) {
    final key =
        _configuredApiKey ?? session.serverpod.getPassword(_currencyApiKeyName);
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  static String _resolveBaseUrl(Session session) {
    final configured = _configuredBaseUrl.trim();
    if (configured.isNotEmpty) return configured;

    final fromPasswords = session.serverpod
        .getPassword(_currencyApiBaseUrlName)
        ?.trim();
    if (fromPasswords != null && fromPasswords.isNotEmpty) {
      return fromPasswords;
    }

    return _currencyApiDefaultBaseUrl;
  }
}
