import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_provider.dart';

/// Pure, stateless spam/scam classifier for wallet holdings.
class WalletSpamClassifier {
  const WalletSpamClassifier();

  static const List<String> baitWords = <String>[
    'airdrop',
    'bonus',
    'claim',
    'free',
    'gift',
    'giveaway',
    'mint',
    'official',
    'prize',
    'reward',
    'support',
    'verify',
    'visit',
    'voucher',
    'winner',
  ];

  static const Set<String> impersonatedSymbols = <String>{
    'AVAX',
    'BNB',
    'BTC',
    'DAI',
    'ETH',
    'POL',
    'SOL',
    'TRX',
    'USDC',
    'USDT',
    'WBTC',
    'WETH',
    'XRP',
  };

  static String foldLookAlikes(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      buffer.write(_homoglyphs[rune] ?? String.fromCharCode(rune));
    }
    return buffer.toString();
  }

  static bool hasInvisibleCharacter(String? value) {
    if (value == null || value.isEmpty) return false;
    return value.contains(_invisible);
  }

  static bool hasLookAlike(String? value) {
    if (value == null || value.isEmpty) return false;
    return foldLookAlikes(value) != value;
  }

  static bool looksLikeUrlOrDomain(String? value) {
    if (value == null || value.isEmpty) return false;
    final lower = value.toLowerCase();
    if (lower.contains('http://') ||
        lower.contains('https://') ||
        lower.contains('www.')) {
      return true;
    }
    return RegExp(r'\.[a-z]{2,}').hasMatch(lower);
  }

  static bool containsBaitWord(String? value) {
    if (value == null || value.isEmpty) return false;
    final folded = foldLookAlikes(value).toLowerCase();
    for (final word in baitWords) {
      if (folded.contains(word)) return true;
    }
    return false;
  }

  static bool isBaitText(String? value) {
    if (value == null || value.isEmpty) return false;
    if (hasInvisibleCharacter(value)) return true;
    if (hasLookAlike(value)) return true;
    if (looksLikeUrlOrDomain(value)) return true;
    if (containsBaitWord(value)) return true;
    return false;
  }

  static bool isCanonicalAsset(
    WalletNetwork network,
    String assetId,
    String? symbol,
  ) {
    if (assetId == 'native') return true;
    final foldedSymbol = symbol == null
        ? null
        : foldLookAlikes(symbol).toUpperCase();
    for (final asset in ChainCatalog.assetsFor(network)) {
      if (asset.assetId == assetId) {
        if (foldedSymbol == null ||
            asset.symbol.toUpperCase() == foldedSymbol) {
          return true;
        }
      }
    }
    return false;
  }

  static SpamVerdict classify({
    WalletNetwork? network,
    String? assetId,
    String? symbol,
    String? name,
    PriceSource? priceSource,
    PriceQuality? priceQuality,
    int? valueMinor,
    int? walletTotalValueMinor,
    bool isNative = false,
    bool isNft = false,
    bool providerSpamFlag = false,
    WalletHolding? holding,
    WalletProviderHolding? providerHolding,
  }) {
    var resolvedNetwork = network;
    var resolvedAssetId = assetId;
    var resolvedSymbol = symbol;
    var resolvedName = name;
    var resolvedPriceSource = priceSource;
    final resolvedValueMinor = valueMinor;
    if (holding != null) {
      resolvedNetwork ??= holding.network;
      resolvedAssetId ??= holding.assetId;
      resolvedSymbol ??= holding.symbol;
      resolvedName ??= holding.name;
      resolvedPriceSource ??= holding.priceSource;
    }
    if (providerHolding != null) {
      resolvedNetwork ??= providerHolding.network;
      resolvedAssetId ??= providerHolding.assetId;
      resolvedSymbol ??= providerHolding.symbol;
      resolvedName ??= providerHolding.name;
    }
    resolvedNetwork ??= WalletNetwork.ethereumMainnet;
    resolvedAssetId ??= '';
    final resolvedValue = resolvedValueMinor ?? holding?.valueMinor;
    final native = isNative || resolvedAssetId == 'native';

    if (native) return SpamVerdict.clean;
    if (isCanonicalAsset(resolvedNetwork, resolvedAssetId, resolvedSymbol)) {
      if (!isBaitText(resolvedName) && !isBaitText(resolvedSymbol)) {
        return SpamVerdict.clean;
      }
    }

    if (isBaitText(resolvedName) || isBaitText(resolvedSymbol)) {
      return SpamVerdict.suspected;
    }

    final foldedSymbol = foldLookAlikes(resolvedSymbol ?? '').toUpperCase();
    if (impersonatedSymbols.contains(foldedSymbol)) {
      final canonicalIds = <String>{
        for (final asset in ChainCatalog.assetsFor(resolvedNetwork))
          if (asset.symbol.toUpperCase() == foldedSymbol) asset.assetId,
      };
      if (canonicalIds.isEmpty || !canonicalIds.contains(resolvedAssetId)) {
        return SpamVerdict.suspected;
      }
    }

    if (providerSpamFlag) return SpamVerdict.suspected;

    final nonCoinGecko =
        resolvedPriceSource != null &&
        resolvedPriceSource != PriceSource.coingecko;
    if (nonCoinGecko &&
        resolvedValue != null &&
        walletTotalValueMinor != null &&
        resolvedValue > 100000 &&
        walletTotalValueMinor > 0 &&
        resolvedValue * 2 > walletTotalValueMinor) {
      return SpamVerdict.suspected;
    }

    return SpamVerdict.clean;
  }

  static SpamVerdict classifyHolding(
    WalletHolding holding, {
    int? walletTotalValueMinor,
  }) => classify(
    holding: holding,
    walletTotalValueMinor: walletTotalValueMinor,
  );

  static SpamVerdict classifyProviderHolding(
    WalletProviderHolding holding, {
    int? walletTotalValueMinor,
  }) => classify(
    providerHolding: holding,
    walletTotalValueMinor: walletTotalValueMinor,
  );

  static List<WalletHolding> classifyHoldings(
    List<WalletHolding> holdings, {
    int? walletTotalValueMinor,
  }) {
    final total =
        walletTotalValueMinor ??
        holdings.fold<int>(
          0,
          (sum, holding) =>
              holding.valueMinor == null ? sum : sum + holding.valueMinor!,
        );
    return [
      for (final holding in holdings)
        if (holding.spamVerdict == SpamVerdict.hiddenByUser ||
            holding.spamVerdict == SpamVerdict.allowedByUser)
          holding
        else
          holding.copyWith(
            spamVerdict: classify(
              holding: holding,
              walletTotalValueMinor: total,
            ),
          ),
    ];
  }

  SpamVerdict call({
    WalletNetwork? network,
    String? assetId,
    String? symbol,
    String? name,
    PriceSource? priceSource,
    PriceQuality? priceQuality,
    int? valueMinor,
    int? walletTotalValueMinor,
    bool isNative = false,
    bool isNft = false,
    bool providerSpamFlag = false,
    WalletHolding? holding,
    WalletProviderHolding? providerHolding,
  }) => classify(
    network: network,
    assetId: assetId,
    symbol: symbol,
    name: name,
    priceSource: priceSource,
    priceQuality: priceQuality,
    valueMinor: valueMinor,
    walletTotalValueMinor: walletTotalValueMinor,
    isNative: isNative,
    isNft: isNft,
    providerSpamFlag: providerSpamFlag,
    holding: holding,
    providerHolding: providerHolding,
  );

  static final RegExp _invisible = RegExp(
    r'[\u200b-\u200f\u202a-\u202e\u2060\ufeff\u00ad]',
  );

  static const Map<int, String> _homoglyphs = <int, String>{
    0x0430: 'a',
    0x0435: 'e',
    0x043e: 'o',
    0x0440: 'p',
    0x0441: 'c',
    0x0445: 'x',
    0x0443: 'y',
    0x0456: 'i',
    0x0458: 'j',
    0x0455: 's',
    0x0405: 'S',
    0x0410: 'A',
    0x0412: 'B',
    0x0415: 'E',
    0x041a: 'K',
    0x041c: 'M',
    0x041d: 'H',
    0x041e: 'O',
    0x0420: 'P',
    0x0421: 'C',
    0x0422: 'T',
    0x0425: 'X',
    0x03b1: 'a',
    0x03b2: 'b',
    0x03b5: 'e',
    0x03bf: 'o',
    0x03c1: 'p',
    0x03bd: 'v',
    0x03bc: 'm',
    0x03ba: 'k',
    0x03b9: 'i',
    0x03c4: 't',
    0x03c7: 'x',
    0x03b7: 'n',
    0x03c9: 'w',
    0x0391: 'A',
    0x0392: 'B',
    0x0395: 'E',
    0x0396: 'Z',
    0x0397: 'H',
    0x0399: 'I',
    0x039a: 'K',
    0x039c: 'M',
    0x039d: 'N',
    0x039f: 'O',
    0x03a1: 'P',
    0x03a4: 'T',
    0x03a7: 'X',
  };
}
