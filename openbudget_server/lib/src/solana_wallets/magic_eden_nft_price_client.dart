import 'dart:convert';
import 'dart:io';

/// Normalized NFT quote returned from marketplace fallback pricing.
class NftMarketPriceQuote {
  const NftMarketPriceQuote({
    required this.mint,
    required this.usdPrice,
    required this.solPrice,
    required this.source,
    required this.confidence,
    this.collectionSymbol,
  });

  final String mint;
  final double usdPrice;
  final double solPrice;
  final String source;
  final String confidence;
  final String? collectionSymbol;
}

/// Magic Eden API client used as fallback for NFT valuation.
class MagicEdenNftPriceClient {
  static final RegExp _base58Mint = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
  static final Uri _baseUri = Uri.parse('https://api-mainnet.magiceden.dev');
  static const _lamportsPerSol = 1000000000.0;
  static const _defaultActivitiesLimit = 25;

  /// Fetches USD NFT quotes keyed by mint address.
  ///
  /// Fallback order for each mint:
  /// 1. Current listing price
  /// 2. Most recent sale price (buyNow / acceptBid)
  /// 3. Collection floor price
  static Future<Map<String, NftMarketPriceQuote>> fetchUsdQuotes({
    required Iterable<String> mintAddresses,
    required double? solUsdPrice,
    int maxMints = 100,
    void Function(String warning)? onWarning,
    HttpClient? httpClient,
  }) async {
    final cleanedMints = mintAddresses
        .map((mint) => mint.trim())
        .where((mint) => mint.isNotEmpty && _base58Mint.hasMatch(mint))
        .toSet()
        .toList(growable: false);
    if (cleanedMints.isEmpty) return const {};

    final solUsd = solUsdPrice;
    if (solUsd == null || !solUsd.isFinite || solUsd <= 0) {
      onWarning?.call(
        'Skipping NFT marketplace fallback pricing because SOL/USD price is unavailable.',
      );
      return const {};
    }

    final client = httpClient ?? HttpClient();
    final shouldClose = httpClient == null;
    final quotes = <String, NftMarketPriceQuote>{};
    final collectionFloorCache = <String, double?>{};

    try {
      for (final mint in cleanedMints.take(maxMints)) {
        final quote = await _fetchMintQuote(
          client,
          mint,
          solUsdPrice: solUsd,
          onWarning: onWarning,
          collectionFloorCache: collectionFloorCache,
        );
        if (quote != null) {
          quotes[mint] = quote;
        }
      }
    } finally {
      if (shouldClose) {
        client.close();
      }
    }

    return quotes;
  }

  static Future<NftMarketPriceQuote?> _fetchMintQuote(
    HttpClient client,
    String mint, {
    required double solUsdPrice,
    required Map<String, double?> collectionFloorCache,
    void Function(String warning)? onWarning,
  }) async {
    final token = await _requestJsonMap(
      client,
      _baseUri.resolve('/v2/tokens/$mint'),
      onWarning: onWarning,
      errorPrefix: 'Magic Eden token endpoint failed for $mint',
    );

    final collection = token == null ? null : parseCollectionSymbol(token);
    final listingSol = token == null ? null : parseListingPriceSol(token);
    if (listingSol != null && listingSol > 0) {
      return _quoteFromSol(
        mint: mint,
        solPrice: listingSol,
        solUsdPrice: solUsdPrice,
        source: 'magiceden_listing',
        confidence: 'high',
        collectionSymbol: collection,
      );
    }

    final activities = await _requestJsonList(
      client,
      _baseUri.resolve(
        '/v2/tokens/$mint/activities?offset=0&limit=$_defaultActivitiesLimit',
      ),
      onWarning: onWarning,
      errorPrefix: 'Magic Eden activities endpoint failed for $mint',
    );

    final recentSaleSol = activities == null
        ? null
        : parseRecentSalePriceSol(activities);
    if (recentSaleSol != null && recentSaleSol > 0) {
      return _quoteFromSol(
        mint: mint,
        solPrice: recentSaleSol,
        solUsdPrice: solUsdPrice,
        source: 'magiceden_last_sale',
        confidence: 'medium',
        collectionSymbol: collection,
      );
    }

    if (collection != null) {
      final cachedFloor = collectionFloorCache[collection];
      final floorSol =
          cachedFloor ??
          await _fetchCollectionFloorSol(
            client,
            collection,
            onWarning: onWarning,
          );
      collectionFloorCache[collection] = floorSol;
      if (floorSol != null && floorSol > 0) {
        return _quoteFromSol(
          mint: mint,
          solPrice: floorSol,
          solUsdPrice: solUsdPrice,
          source: 'magiceden_collection_floor',
          confidence: 'low',
          collectionSymbol: collection,
        );
      }
    }

    return null;
  }

  static Future<double?> _fetchCollectionFloorSol(
    HttpClient client,
    String collectionSymbol, {
    void Function(String warning)? onWarning,
  }) async {
    final stats = await _requestJsonMap(
      client,
      _baseUri.resolve('/v2/collections/$collectionSymbol/stats'),
      onWarning: onWarning,
      errorPrefix:
          'Magic Eden collection stats endpoint failed for $collectionSymbol',
    );
    if (stats == null) return null;
    return parseCollectionFloorPriceSol(stats);
  }

  static NftMarketPriceQuote? _quoteFromSol({
    required String mint,
    required double solPrice,
    required double solUsdPrice,
    required String source,
    required String confidence,
    String? collectionSymbol,
  }) {
    if (!solPrice.isFinite || solPrice <= 0) return null;
    final usd = solPrice * solUsdPrice;
    if (!usd.isFinite || usd <= 0) return null;

    return NftMarketPriceQuote(
      mint: mint,
      usdPrice: usd,
      solPrice: solPrice,
      source: source,
      confidence: confidence,
      collectionSymbol: collectionSymbol,
    );
  }

  /// Extracts listing price (in SOL) from Magic Eden token payload.
  static double? parseListingPriceSol(Map<String, dynamic> json) {
    final value = _coerceDouble(json['price']);
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  /// Extracts collection symbol from Magic Eden token payload.
  static String? parseCollectionSymbol(Map<String, dynamic> json) {
    final collection = json['collection'];
    if (collection is! String) return null;
    final normalized = collection.trim();
    return normalized.isEmpty ? null : normalized;
  }

  /// Extracts most recent sale price (in SOL) from activities payload.
  static double? parseRecentSalePriceSol(List<dynamic> activities) {
    const saleTypes = {'buynow', 'acceptbid', 'sale', 'purchase'};
    for (final activity in activities) {
      if (activity is! Map<String, dynamic>) continue;
      final type = activity['type'];
      if (type is! String) continue;
      if (!saleTypes.contains(type.toLowerCase())) continue;
      final price = _coerceDouble(activity['price']);
      if (price != null && price.isFinite && price > 0) {
        return price;
      }
    }
    return null;
  }

  /// Extracts collection floor price (in SOL) from collection stats payload.
  static double? parseCollectionFloorPriceSol(Map<String, dynamic> json) {
    final floorLamports = _coerceDouble(json['floorPrice']);
    if (floorLamports == null ||
        !floorLamports.isFinite ||
        floorLamports <= 0) {
      return null;
    }
    return floorLamports / _lamportsPerSol;
  }

  static Future<Map<String, dynamic>?> _requestJsonMap(
    HttpClient client,
    Uri uri, {
    required String errorPrefix,
    void Function(String warning)? onWarning,
  }) async {
    final payload = await _requestJson(
      client,
      uri,
      errorPrefix: errorPrefix,
      onWarning: onWarning,
    );
    return payload is Map<String, dynamic> ? payload : null;
  }

  static Future<List<dynamic>?> _requestJsonList(
    HttpClient client,
    Uri uri, {
    required String errorPrefix,
    void Function(String warning)? onWarning,
  }) async {
    final payload = await _requestJson(
      client,
      uri,
      errorPrefix: errorPrefix,
      onWarning: onWarning,
    );
    return payload is List<dynamic> ? payload : null;
  }

  static Future<dynamic> _requestJson(
    HttpClient client,
    Uri uri, {
    required String errorPrefix,
    void Function(String warning)? onWarning,
  }) async {
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.userAgentHeader, 'openbudget/solana');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode > 299) {
        onWarning?.call('$errorPrefix (HTTP ${response.statusCode}).');
        return null;
      }

      return jsonDecode(body);
    } on SocketException {
      onWarning?.call('$errorPrefix (network error).');
      return null;
    } on HttpException {
      onWarning?.call('$errorPrefix (HTTP error).');
      return null;
    } on FormatException {
      onWarning?.call('$errorPrefix (invalid JSON).');
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
