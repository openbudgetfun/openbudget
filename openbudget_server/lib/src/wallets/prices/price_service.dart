import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/wallets/prices/coingecko_price_client.dart';
import 'package:openbudget_server/src/wallets/prices/defillama_price_client.dart';
import 'package:serverpod/serverpod.dart';

/// A resolved price and where it came from.
class ResolvedPrice {
  const ResolvedPrice({required this.price, required this.isCached});

  final AssetPrice price;

  /// Whether the row was already in the `AssetPrice` cache rather than
  /// fetched during this call. Cached prices are older evidence, so callers
  /// record them with a lower quality.
  final bool isCached;
}

class PriceService {
  static Map<String, String> _passwords = const {};
  static Map<String, String> _environment = const {};
  static HttpClient? _httpClient;
  static DateTime Function() _clock = () => DateTime.now().toUtc();

  static const Duration cacheLifetime = Duration(minutes: 15);
  static const double defiLlamaConfidenceThreshold =
      DefiLlamaPriceClient.confidenceThreshold;

  static void configure({
    Map<String, String>? passwords,
    Map<String, String>? environment,
    HttpClient? httpClient,
    DateTime Function()? clock,
  }) {
    if (passwords != null) _passwords = passwords;
    if (environment != null) _environment = environment;
    if (httpClient != null) _httpClient = httpClient;
    if (clock != null) _clock = clock;
  }

  static void resetForTests() {
    _passwords = const {};
    _environment = const {};
    _httpClient = null;
    _clock = () => DateTime.now().toUtc();
  }

  static Future<Map<(WalletNetwork, String), AssetPrice?>> resolve(
    Session session,
    Iterable<Object> keys, {
    Map<String, String>? passwords,
    Map<String, String>? environment,
    HttpClient? httpClient,
    DateTime? now,
  }) async {
    final detailed = await resolveDetailed(
      session,
      keys,
      passwords: passwords,
      environment: environment,
      httpClient: httpClient,
      now: now,
    );
    return {
      for (final entry in detailed.entries) entry.key: entry.value?.price,
    };
  }

  /// Resolves prices like [resolve], keeping whether each one was cached.
  static Future<Map<(WalletNetwork, String), ResolvedPrice?>> resolveDetailed(
    Session session,
    Iterable<Object> keys, {
    Map<String, String>? passwords,
    Map<String, String>? environment,
    HttpClient? httpClient,
    DateTime? now,
  }) async {
    // An explicit value wins, then a test override from [configure], then the
    // session's own secrets and the process environment. Without the last
    // step the hourly future call runs with no CoinGecko key and silently
    // falls back to the free demo host.
    final effectivePasswords =
        passwords ?? (_passwords.isNotEmpty ? _passwords : session.passwords);
    final effectiveEnvironment =
        environment ??
        (_environment.isNotEmpty ? _environment : Platform.environment);
    final effectiveClient = httpClient ?? _httpClient;
    final effectiveNow = (now ?? _clock()).toUtc();

    final normalized = <(WalletNetwork, String)>[];
    final seen = <(WalletNetwork, String)>{};
    for (final key in keys) {
      (WalletNetwork, String)? pair;
      if (key is (WalletNetwork, String)) {
        pair = key;
      } else if (key is Map) {
        final network = key['network'] ?? key['walletNetwork'];
        final assetId = key['assetId'] ?? key['asset_id'];
        if (network is WalletNetwork && assetId is String) {
          pair = (network, assetId);
        }
      }
      if (pair == null) continue;
      final trimmed = (pair.$1, pair.$2.trim());
      if (trimmed.$2.isEmpty) continue;
      if (seen.add(trimmed)) normalized.add(trimmed);
    }
    if (normalized.isEmpty) return {};

    // Read cache rows.
    final cacheRows = await AssetPrice.db.find(
      session,
      where: (t) =>
          t.network.inSet(normalized.map((k) => k.$1).toSet()) &
          t.assetId.inSet(normalized.map((k) => k.$2).toSet()),
    );
    final cacheByKey = <(WalletNetwork, String), AssetPrice>{
      for (final row in cacheRows) (row.network, row.assetId): row,
    };

    final result = <(WalletNetwork, String), ResolvedPrice?>{};
    final misses = <(WalletNetwork, String)>[];
    for (final key in normalized) {
      final cached = cacheByKey[key];
      if (cached != null && !cached.expiresAt.toUtc().isBefore(effectiveNow)) {
        result[key] = ResolvedPrice(price: cached, isCached: true);
      } else {
        result[key] = null;
        misses.add(key);
      }
    }
    if (misses.isEmpty) return result;

    final toWrite = <AssetPrice>[];

    // CoinGecko pass.
    final nativeIds = <String>{};
    final tokensByPlatform = <String, Set<String>>{};
    for (final key in misses) {
      final network = key.$1;
      final assetId = key.$2;
      if (assetId == 'native') {
        final id = network.coingeckoId;
        if (id != null) nativeIds.add(id);
      } else {
        final platform = network.coingeckoPlatform;
        if (platform != null) {
          tokensByPlatform.putIfAbsent(platform, () => {}).add(assetId);
        }
      }
    }

    final nativePrices = nativeIds.isEmpty
        ? const <String, double>{}
        : await CoinGeckoPriceClient.fetchSimplePrices(
            ids: nativeIds,
            passwords: effectivePasswords,
            environment: effectiveEnvironment,
            httpClient: effectiveClient,
          );

    final tokenPricesByPlatform = <String, Map<String, double>>{};
    for (final entry in tokensByPlatform.entries) {
      tokenPricesByPlatform[entry.key] =
          await CoinGeckoPriceClient.fetchTokenPrices(
            platform: entry.key,
            contractAddresses: entry.value,
            passwords: effectivePasswords,
            environment: effectiveEnvironment,
            httpClient: effectiveClient,
          );
    }

    final stillMissing = <(WalletNetwork, String)>[];
    for (final key in misses) {
      final network = key.$1;
      final assetId = key.$2;
      double? price;
      if (assetId == 'native') {
        final id = network.coingeckoId;
        if (id != null) price = nativePrices[id];
      } else {
        final platform = network.coingeckoPlatform;
        if (platform != null) {
          price = tokenPricesByPlatform[platform]?[assetId.toLowerCase()];
        }
      }
      if (price != null && price > 0) {
        final row = AssetPrice(
          network: network,
          assetId: assetId,
          currencyCode: 'USD',
          unitPrice: price.toString(),
          source: PriceSource.coingecko,
          fetchedAt: effectiveNow,
          expiresAt: effectiveNow.add(cacheLifetime),
        );
        result[key] = ResolvedPrice(price: row, isCached: false);
        toWrite.add(row);
      } else {
        stillMissing.add(key);
      }
    }

    // DefiLlama pass.
    if (stillMissing.isNotEmpty) {
      final dlKeys = <String>{};
      final dlKeyToOriginal = <String, (WalletNetwork, String)>{};
      for (final key in stillMissing) {
        final network = key.$1;
        final assetId = key.$2;
        String? dlKey;
        if (assetId == 'native' && network.coingeckoId != null) {
          dlKey = 'coingecko:${network.coingeckoId}';
        } else if (network.defillamaChain != null) {
          dlKey = '${network.defillamaChain}:$assetId';
        }
        if (dlKey != null) {
          dlKeys.add(dlKey);
          dlKeyToOriginal[dlKey] = key;
        }
      }

      final dlPrices = dlKeys.isEmpty
          ? const <String, DefiLlamaPrice>{}
          : await DefiLlamaPriceClient.fetchPrices(
              coins: dlKeys,
              httpClient: effectiveClient,
            );

      for (final entry in dlPrices.entries) {
        final original = dlKeyToOriginal[entry.key];
        if (original == null) continue;
        if (entry.value.confidence < defiLlamaConfidenceThreshold) continue;
        final price = entry.value.price;
        if (price <= 0) continue;
        final row = AssetPrice(
          network: original.$1,
          assetId: original.$2,
          symbol: entry.value.symbol,
          currencyCode: 'USD',
          unitPrice: price.toString(),
          source: PriceSource.defillama,
          fetchedAt: effectiveNow,
          expiresAt: effectiveNow.add(cacheLifetime),
        );
        result[original] = ResolvedPrice(price: row, isCached: false);
        toWrite.add(row);
      }
    }

    // Write cache.
    for (final row in toWrite) {
      await AssetPrice.db.upsertRow(
        session,
        row,
        conflictColumns: (t) => [t.network, t.assetId],
        updateColumns: (t) => [
          t.symbol,
          t.currencyCode,
          t.unitPrice,
          t.source,
          t.fetchedAt,
          t.expiresAt,
        ],
      );
    }

    return result;
  }

  // Aliases.
  static Future<Map<(WalletNetwork, String), AssetPrice?>> resolvePrices(
    Session session,
    Iterable<Object> keys, {
    Map<String, String>? passwords,
    Map<String, String>? environment,
    HttpClient? httpClient,
    DateTime? now,
  }) => resolve(
    session,
    keys,
    passwords: passwords,
    environment: environment,
    httpClient: httpClient,
    now: now,
  );

  static Future<Map<(WalletNetwork, String), AssetPrice?>> fetchPrices(
    Session session,
    Iterable<Object> keys, {
    Map<String, String>? passwords,
    Map<String, String>? environment,
    HttpClient? httpClient,
    DateTime? now,
  }) => resolve(
    session,
    keys,
    passwords: passwords,
    environment: environment,
    httpClient: httpClient,
    now: now,
  );
}
