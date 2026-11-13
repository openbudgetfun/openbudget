import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/common/confidence.dart';
import 'package:openbudget_server/src/generated/wallets/price_quality.dart';
import 'package:openbudget_server/src/generated/wallets/price_source.dart';
import 'package:openbudget_server/src/wallets/jupiter_price_client.dart';
import 'package:openbudget_server/src/wallets/magic_eden_nft_price_client.dart';
import 'package:openbudget_server/src/wallets/solana_transaction_interpreter.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:serverpod/serverpod.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';

/// Helius-backed Solana provider for the read-only wallet sync.
///
/// Every network call happens here, before the service takes a database lock.
/// A failure throws [WalletProviderException] so the last committed holdings
/// and valuation stay untouched.
final class SolanaWalletProvider implements WalletProvider {
  SolanaWalletProvider({
    required this.helius,
    this.httpClient,
    this.clock = DateTime.now,
  });

  /// Builds a provider from the server's configured Helius key.
  factory SolanaWalletProvider.fromSession(
    Session session,
    WalletNetwork network,
  ) {
    final apiKey = heliusApiKeyFrom(
      passwords: session.passwords,
      environment: Platform.environment,
    );
    if (apiKey == null) {
      throw const WalletProviderException(
        'Missing Helius API key. Set HELIUS_API_KEY or passwords.heliusApiKey.',
      );
    }
    return SolanaWalletProvider(
      helius: createHelius(
        HeliusConfig(
          apiKey: apiKey,
          cluster: network == WalletNetwork.solanaDevnet
              ? HeliusCluster.devnet
              : HeliusCluster.mainnet,
        ),
      ),
    );
  }

  static const _historyPageSize = 100;
  static const _maxHistoryPages = 10;
  static const _wrappedSolMint = 'So11111111111111111111111111111111111111112';
  static const _nativeAssetId = 'native';
  static const _priceCurrency = 'USD';

  final HeliusClient helius;
  final HttpClient? httpClient;
  final DateTime Function() clock;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    // Solana reads its one network; a family provider that covers several
    // networks, such as the future EVM provider, takes them from the request.
    final network = request.networks.single;
    final address = request.address;
    final untilSignature = request.untilSignature;
    final warnings = <String>[];
    final historyFuture = _fetchHistory(
      address: address,
      untilSignature: untilSignature,
    );
    final balancesFuture = helius.wallet.getBalances(
      GetBalancesRequest(address: address),
    );
    final assetsFuture = helius.das.getAssetsByOwner(
      GetAssetsByOwnerRequest(ownerAddress: address, limit: 1000),
    );

    final history = await historyFuture;
    final balances = await balancesFuture;
    final assets = await assetsFuture;
    final assetsById = {for (final asset in assets.items) asset.id: asset};

    if (assets.total > assets.items.length) {
      warnings.add(
        'Helius returned ${assets.items.length} of ${assets.total} assets; '
        'metadata for the remainder is missing.',
      );
    }

    final jupiterPrices = await JupiterPriceClient.fetchUsdPrices(
      mintAddresses: {
        ...balances.tokens.map((token) => token.mint),
        _wrappedSolMint,
      },
      onWarning: warnings.add,
      httpClient: httpClient,
    );

    final nftMints = assets.items
        .where(_isLikelyNft)
        .map((asset) => asset.id)
        .toSet();
    final nftQuotes = await MagicEdenNftPriceClient.fetchUsdQuotes(
      mintAddresses: nftMints,
      solUsdPrice: jupiterPrices[_wrappedSolMint],
      onWarning: warnings.add,
      maxMints: 150,
      httpClient: httpClient,
    );

    final holdings = _buildHoldings(
      network: network,
      balances: balances,
      assetsById: assetsById,
      allAssets: assets.items,
      jupiterPrices: jupiterPrices,
      nftQuotes: nftQuotes,
      warnings: warnings,
    );

    return WalletProviderSnapshot(
      readNetworks: [network],
      holdings: holdings,
      transactions: history,
      newestSignature: history.isEmpty ? null : history.first.signature,
      warnings: warnings,
    );
  }

  Future<List<WalletProviderTransaction>> _fetchHistory({
    required String address,
    String? untilSignature,
  }) async {
    final bySignature = <String, WalletProviderTransaction>{};
    String? before;
    var pages = 0;

    while (true) {
      final page = await helius.wallet.getHistory(
        GetHistoryRequest(
          address: address,
          until: untilSignature,
          before: before,
          limit: _historyPageSize,
        ),
      );
      for (final transaction in page) {
        bySignature.putIfAbsent(
          transaction.signature,
          () => _parseTransaction(transaction, address),
        );
      }

      if (page.length < _historyPageSize) break;
      pages += 1;
      if (pages >= _maxHistoryPages) {
        final probe = await helius.wallet.getHistory(
          GetHistoryRequest(
            address: address,
            until: untilSignature,
            before: page.last.signature,
            limit: _historyPageSize,
          ),
        );
        if (probe.isNotEmpty) {
          throw const WalletProviderException(
            'Wallet history has more transactions than one sync can page '
            'safely; no cursor was advanced.',
          );
        }
        break;
      }
      before = page.last.signature;
    }

    return bySignature.values.toList(growable: false);
  }

  WalletProviderTransaction _parseTransaction(
    EnhancedTransaction tx,
    String walletAddress,
  ) {
    final programs =
        tx.instructions
            .map((instruction) => instruction.programId)
            .toSet()
            .toList()
          ..sort();
    final interpretation = SolanaTransactionInterpreter.interpret(
      transaction: tx,
      walletAddress: walletAddress,
    );
    final movements = <WalletProviderMovement>[];
    for (final transfer in tx.tokenTransfers) {
      final mint = transfer.mint?.trim();
      if (mint == null || mint.isEmpty) continue;
      if (transfer.tokenAmount < 0) {
        throw WalletProviderException(
          'Provider returned a negative token amount for $mint.',
        );
      }
      movements.add(
        WalletProviderMovement(
          mint: mint,
          fromAccount: transfer.fromUserAccount,
          toAccount: transfer.toUserAccount,
          amountRaw: BigInt.from(transfer.tokenAmount),
        ),
      );
    }

    return WalletProviderTransaction(
      signature: tx.signature,
      slot: tx.slot,
      occurredAt: tx.timestamp == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              tx.timestamp! * 1000,
              isUtc: true,
            ),
      description: interpretation.description,
      txType: tx.type,
      source: tx.source,
      interpretationConfidence: _confidence(interpretation.confidence),
      programsJson: programs.isEmpty ? null : jsonEncode(programs),
      nativeTransfersJson: tx.nativeTransfers.isEmpty
          ? null
          : jsonEncode(
              tx.nativeTransfers.map((item) => item.toJson()).toList(),
            ),
      tokenTransfersJson: tx.tokenTransfers.isEmpty
          ? null
          : jsonEncode(tx.tokenTransfers.map((item) => item.toJson()).toList()),
      rawJson: jsonEncode(tx.toJson()),
      movements: movements,
    );
  }

  List<WalletProviderHolding> _buildHoldings({
    required WalletNetwork network,
    required WalletBalances balances,
    required Map<String, HeliusAsset> assetsById,
    required List<HeliusAsset> allAssets,
    required Map<String, double> jupiterPrices,
    required Map<String, NftMarketPriceQuote> nftQuotes,
    required List<String> warnings,
  }) {
    if (balances.nativeBalance < 0) {
      throw const WalletProviderException(
        'Provider returned a negative native balance.',
      );
    }

    final now = clock().toUtc();
    final holdings = <WalletProviderHolding>[];
    final seen = <String>{};

    holdings.add(
      WalletProviderHolding(
        network: network,
        assetId: _nativeAssetId,
        symbol: 'SOL',
        name: 'Solana',
        decimals: 9,
        quantityRaw: BigInt.from(balances.nativeBalance),
        isNft: false,
        metadataJson: jsonEncode({'interface': 'FungibleToken'}),
        prices: _priceCandidates(
          assetId: _nativeAssetId,
          quantityRaw: BigInt.from(balances.nativeBalance),
          decimals: 9,
          asset: null,
          jupiterPrice: jupiterPrices[_wrappedSolMint],
          nftQuote: null,
          now: now,
          warnings: warnings,
        ),
      ),
    );
    seen.add(_nativeAssetId);

    for (final token in balances.tokens) {
      if (token.amount < 0) {
        throw WalletProviderException(
          'Provider returned a negative balance for ${token.mint}.',
        );
      }
      if (token.decimals < 0 || token.decimals > 36) {
        throw WalletProviderException(
          'Provider returned invalid decimals for ${token.mint}.',
        );
      }
      if (token.amount == 0) continue;
      if (!seen.add(token.mint)) continue;

      final asset = assetsById[token.mint];
      final isNft = _isLikelyNft(asset);
      holdings.add(
        WalletProviderHolding(
          network: network,
          assetId: token.mint,
          symbol:
              _trimToNull(asset?.content?.metadata?.symbol) ??
              _shortAddress(token.mint),
          name: _trimToNull(asset?.content?.metadata?.name),
          tokenProgram: _trimToNull(asset?.tokenInfo?.tokenProgram),
          decimals: token.decimals,
          quantityRaw: BigInt.from(token.amount),
          isNft: isNft,
          metadataJson: _metadataJson(asset, nftQuotes[token.mint]),
          prices: _priceCandidates(
            assetId: token.mint,
            quantityRaw: BigInt.from(token.amount),
            decimals: token.decimals,
            asset: asset,
            jupiterPrice: jupiterPrices[token.mint],
            nftQuote: nftQuotes[token.mint],
            now: now,
            warnings: warnings,
          ),
        ),
      );
    }

    for (final asset in allAssets) {
      if (!_isLikelyNft(asset)) continue;
      if (!seen.add(asset.id)) continue;
      final decimals = asset.tokenInfo?.decimals ?? 0;
      if (decimals < 0 || decimals > 36) {
        throw WalletProviderException(
          'Provider returned invalid decimals for ${asset.id}.',
        );
      }
      holdings.add(
        WalletProviderHolding(
          network: network,
          assetId: asset.id,
          symbol: _trimToNull(asset.content?.metadata?.symbol),
          name: _trimToNull(asset.content?.metadata?.name),
          tokenProgram: _trimToNull(asset.tokenInfo?.tokenProgram),
          decimals: decimals,
          quantityRaw: BigInt.one,
          isNft: true,
          metadataJson: _metadataJson(asset, nftQuotes[asset.id]),
          prices: _priceCandidates(
            assetId: asset.id,
            quantityRaw: BigInt.one,
            decimals: decimals,
            asset: asset,
            jupiterPrice: null,
            nftQuote: nftQuotes[asset.id],
            now: now,
            warnings: warnings,
          ),
        ),
      );
    }

    return holdings;
  }

  List<WalletProviderPrice> _priceCandidates({
    required String assetId,
    required BigInt quantityRaw,
    required int decimals,
    required HeliusAsset? asset,
    required double? jupiterPrice,
    required NftMarketPriceQuote? nftQuote,
    required DateTime now,
    required List<String> warnings,
  }) {
    final prices = <WalletProviderPrice>[];
    final info = asset?.tokenInfo?.priceInfo;
    if (info != null) {
      final currency = (info.currency ?? _priceCurrency).trim().toUpperCase();
      if (currency != _priceCurrency) {
        warnings.add(
          'Ignoring $currency price for $assetId; wallets value in '
          '$_priceCurrency only.',
        );
      } else {
        final perToken = _decimalFromProviderPrice(
          info.pricePerToken,
          assetId: assetId,
          warnings: warnings,
        );
        if (perToken != null) {
          prices.add(
            WalletProviderPrice(
              unitPrice: perToken,
              currencyCode: _priceCurrency,
              source: PriceSource.helius,
              quality: PriceQuality.live,
              confidence: Confidence.high,
              asOf: now,
            ),
          );
        } else {
          final total = _decimalFromProviderPrice(
            info.totalPrice,
            assetId: assetId,
            warnings: warnings,
          );
          if (total != null && quantityRaw > BigInt.zero) {
            prices.add(
              WalletProviderPrice(
                totalPrice: total,
                currencyCode: _priceCurrency,
                source: PriceSource.helius,
                quality: PriceQuality.derived,
                confidence: Confidence.medium,
                asOf: now,
              ),
            );
          }
        }
      }
    }

    final jupiter = _decimalFromProviderPrice(
      jupiterPrice,
      assetId: assetId,
      warnings: warnings,
    );
    if (jupiter != null) {
      prices.add(
        WalletProviderPrice(
          unitPrice: jupiter,
          currencyCode: _priceCurrency,
          source: PriceSource.jupiter,
          quality: PriceQuality.live,
          confidence: Confidence.high,
          asOf: now,
        ),
      );
    }

    if (nftQuote != null) {
      final nftPrice = _decimalFromProviderPrice(
        nftQuote.usdPrice,
        assetId: assetId,
        warnings: warnings,
      );
      if (nftPrice != null) {
        prices.add(
          WalletProviderPrice(
            unitPrice: nftPrice,
            currencyCode: _priceCurrency,
            source: PriceSource.magicEden,
            quality: PriceQuality.live,
            confidence: _quoteConfidence(nftQuote.confidence),
            asOf: now,
            collectionSymbol: nftQuote.collectionSymbol,
            solPrice: nftQuote.solPrice,
          ),
        );
      }
    }

    return prices;
  }

  ExactDecimal? _decimalFromProviderPrice(
    double? price, {
    required String assetId,
    required List<String> warnings,
  }) {
    if (price == null) return null;
    final exact = ExactDecimal.fromDouble(price);
    if (exact == null) {
      warnings.add('Ignoring invalid provider price for $assetId.');
    }
    return exact;
  }

  String? _metadataJson(HeliusAsset? asset, NftMarketPriceQuote? quote) {
    final metadata = <String, Object?>{
      'interface': asset?.interface_,
      'symbol': asset?.content?.metadata?.symbol,
      'name': asset?.content?.metadata?.name,
    };
    final collection = quote?.collectionSymbol;
    if (collection != null && collection.isNotEmpty) {
      metadata['collectionSymbol'] = collection;
    }
    if (quote != null) metadata['marketSolPrice'] = quote.solPrice;
    metadata.removeWhere((key, value) => value == null);
    return metadata.isEmpty ? null : jsonEncode(metadata);
  }

  static bool _isLikelyNft(HeliusAsset? asset) {
    if (asset == null) return false;
    final interfaceName = asset.interface_?.toLowerCase() ?? '';
    if (interfaceName.contains('nft')) return true;
    return asset.tokenInfo?.decimals == 0 && asset.tokenInfo?.supply == 1;
  }

  static Confidence _confidence(String confidence) =>
      switch (confidence.toLowerCase()) {
        'high' => Confidence.high,
        'medium' => Confidence.medium,
        _ => Confidence.low,
      };

  static Confidence _quoteConfidence(String confidence) =>
      switch (confidence.toLowerCase()) {
        'high' => Confidence.high,
        'medium' => Confidence.medium,
        _ => Confidence.low,
      };

  /// Whether a Helius key is configured: passwords first, then the
  /// `HELIUS_API_KEY` environment fallback. A missing key turns Solana off.
  static bool hasSecret(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) => heliusApiKeyFrom(passwords: passwords, environment: environment) != null;

  /// The configured key: passwords first, then the environment fallback.
  /// Pure in both maps so support reporting and tests never touch the real
  /// environment.
  static String? heliusApiKeyFrom({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) {
    final fromPassword = _trimToNull(passwords['heliusApiKey']);
    if (fromPassword != null) return fromPassword;
    return _trimToNull(environment['HELIUS_API_KEY']);
  }

  static String? _trimToNull(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _shortAddress(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }
}
