import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart' show UuidValue;

/// One counted wallet holding: a priced holding whose spam verdict is clean
/// or allowedByUser, in the currency its price was quoted in.
class CountedHolding {
  const CountedHolding({
    required this.walletId,
    required this.network,
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.currencyCode,
    required this.valueMinor,
  });

  /// The wallet the holding belongs to.
  final UuidValue walletId;
  final WalletNetwork network;
  final String assetId;
  final String? symbol;
  final String? name;

  /// ISO 4217 code [valueMinor] is in.
  final String currencyCode;

  /// The holding's stored valuation in [currencyCode]'s minor units.
  final int valueMinor;
}

/// Converts [amountMinor] of [currencyCode] into the reporting currency, or
/// returns null when no rate is available.
typedef MinorConverter = int? Function(String currencyCode, int amountMinor);

/// What [CryptoBreakdownBuilder.build] produced.
class CryptoBreakdownResult {
  const CryptoBreakdownResult({
    required this.rows,
    required this.totalMinor,
    required this.missingCurrencyCodes,
  });

  final List<CryptoBreakdownRow> rows;
  final int totalMinor;

  /// Currencies a counted holding was priced in that had no rate; those
  /// holdings are in no row and no total.
  final List<String> missingCurrencyCodes;
}

/// Splits counted wallet holdings into chain or asset rows.
///
/// Pure and exact: no double ever touches a sum. A wallet's counted value in
/// one currency is converted once, the way net worth converts the wallet's
/// account, and that converted figure is shared out over the wallet's
/// holdings in proportion to their values (largest remainder, so not one
/// minor unit is lost or invented). Chain rows, asset rows and the total are
/// all sums of those shares, so every grouping adds up to the same total and
/// that total matches net worth's figure for the same wallets. A currency
/// with no rate is never guessed: its holdings leave every row and every
/// total, and the code is reported in
/// [CryptoBreakdownResult.missingCurrencyCodes].
///
/// By asset, natives and the catalogue's canonical tokens merge across
/// networks by ticker (all USDC is one row, ETH on Ethereum, Base, Arbitrum
/// and OP is one row); every other token stays one row per network and
/// asset. The top [topAssetCount] rows are kept and the rest become one
/// "Other" row.
abstract final class CryptoBreakdownBuilder {
  /// How many asset rows are listed before the rest become "Other".
  static const topAssetCount = 8;

  /// The key of the remainder row.
  static const otherKey = 'other';

  static CryptoBreakdownResult build({
    required Iterable<CountedHolding> holdings,
    required CryptoBreakdownGrouping grouping,
    required MinorConverter convert,
  }) {
    final shares = _convertPerWallet(holdings, convert);
    final slices = <String, _Slice>{};
    for (final share in shares.converted) {
      slices
          .putIfAbsent(
            _keyOf(share.holding, grouping),
            () => _Slice.of(share.holding, grouping),
          )
          .add(share);
    }
    final converted = [
      for (final slice in slices.values)
        if (slice.converted.sign > 0) slice,
    ]..sort(_largestFirst);

    final visible = grouping == CryptoBreakdownGrouping.byAsset
        ? converted.take(topAssetCount).toList()
        : converted;
    final rest = grouping == CryptoBreakdownGrouping.byAsset
        ? converted.skip(topAssetCount).toList()
        : const <_Slice>[];
    final entries = <_Entry>[
      for (final slice in visible) slice.toEntry(),
      if (rest.isNotEmpty) _Entry.other(rest),
    ];

    final total = entries.fold(BigInt.zero, (sum, row) => sum + row.value);
    final basisPoints = _apportion(
      BigInt.from(10000),
      entries.map((row) => row.value).toList(),
    );
    return CryptoBreakdownResult(
      rows: [
        for (final (index, entry) in entries.indexed)
          entry.toRow(basisPoints[index]),
      ],
      totalMinor: _safe(total, 'Crypto total'),
      missingCurrencyCodes: shares.missing.toList()..sort(),
    );
  }

  static String _keyOf(
    CountedHolding holding,
    CryptoBreakdownGrouping grouping,
  ) {
    if (grouping == CryptoBreakdownGrouping.byChain) {
      return holding.network.name;
    }
    final canonical = ChainCatalog.tryAsset(holding.network, holding.assetId);
    if (canonical != null) return 'asset:${canonical.symbol}';
    return '${holding.network.name}:${holding.assetId}';
  }

  static int _largestFirst(_Slice first, _Slice second) {
    final byValue = second.converted.compareTo(first.converted);
    return byValue != 0 ? byValue : first.key.compareTo(second.key);
  }

  /// Converts each wallet's value per currency once and shares the result
  /// over that wallet's holdings.
  static ({List<_Share> converted, Set<String> missing}) _convertPerWallet(
    Iterable<CountedHolding> holdings,
    MinorConverter convert,
  ) {
    final cells = <(UuidValue, String), List<CountedHolding>>{};
    for (final holding in holdings) {
      cells
          .putIfAbsent((holding.walletId, holding.currencyCode), () => [])
          .add(holding);
    }

    final converted = <_Share>[];
    final missing = <String>{};
    for (final entry in cells.entries) {
      final cell = entry.value;
      final native = cell.fold(
        BigInt.zero,
        (sum, holding) => sum + BigInt.from(holding.valueMinor),
      );
      final code = entry.key.$2;
      if (native.abs() > BigInt.from(maxSafeMinor)) {
        throw ValidationException(
          message: '$code crypto value exceeds the safe minor-unit range',
        );
      }
      final total = convert(code, native.toInt());
      if (total == null) {
        missing.add(code);
        continue;
      }
      final parts = _apportion(BigInt.from(total), [
        for (final holding in cell) BigInt.from(holding.valueMinor),
      ]);
      for (final (index, holding) in cell.indexed) {
        converted.add(_Share(holding, BigInt.from(parts[index])));
      }
    }
    return (converted: converted, missing: missing);
  }

  /// Splits [total] into whole parts in proportion to [weights]: each part's
  /// floor first, then the leftover units to the biggest remainders (the
  /// earlier part wins a tie). The parts always add up to [total]; with no
  /// positive weight they are all zero.
  static List<int> _apportion(BigInt total, List<BigInt> weights) {
    final weightSum = weights.fold(BigInt.zero, (sum, weight) => sum + weight);
    if (weights.isEmpty || weightSum.sign <= 0 || total.sign <= 0) {
      return List.filled(weights.length, 0);
    }
    final parts = [for (final weight in weights) weight * total ~/ weightSum];
    final remainders = [
      for (final weight in weights) weight * total % weightSum,
    ];
    var left = (total - parts.fold(BigInt.zero, (sum, part) => sum + part))
        .toInt();
    final order = List.generate(weights.length, (index) => index)
      ..sort((a, b) {
        final byRemainder = remainders[b].compareTo(remainders[a]);
        return byRemainder != 0 ? byRemainder : a.compareTo(b);
      });
    final result = [for (final part in parts) part.toInt()];
    for (final index in order) {
      if (left == 0) break;
      result[index] += 1;
      left -= 1;
    }
    return result;
  }

  static int _safe(BigInt value, String context) {
    if (value.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: '$context exceeds the safe minor-unit range',
      );
    }
    return value.toInt();
  }
}

/// A finished row before its share is known.
class _Entry {
  _Entry({
    required this.key,
    required this.networks,
    required this.value,
    required this.holdingCount,
    this.symbol,
    this.name,
    this.assetId,
    this.isOther = false,
  });

  factory _Entry.other(List<_Slice> slices) => _Entry(
    key: CryptoBreakdownBuilder.otherKey,
    networks: ({for (final slice in slices) ...slice.networks}.toList()
      ..sort((a, b) => a.index.compareTo(b.index))),
    value: slices.fold(BigInt.zero, (sum, slice) => sum + slice.converted),
    holdingCount: slices.fold(0, (sum, slice) => sum + slice.holdingCount),
    isOther: true,
  );

  final String key;
  final List<WalletNetwork> networks;
  final BigInt value;
  final int holdingCount;
  final String? symbol;
  final String? name;
  final String? assetId;
  final bool isOther;

  CryptoBreakdownRow toRow(int shareBasisPoints) => CryptoBreakdownRow(
    key: key,
    networks: networks,
    symbol: symbol,
    name: name,
    assetId: assetId,
    isOther: isOther,
    holdingCount: holdingCount,
    valueMinor: CryptoBreakdownBuilder._safe(value, 'Crypto row'),
    shareBasisPoints: shareBasisPoints,
  );
}

/// One holding's share of its wallet's converted value.
class _Share {
  const _Share(this.holding, this.converted);

  final CountedHolding holding;
  final BigInt converted;
}

/// The holdings that make up one row.
class _Slice {
  _Slice({
    required this.key,
    this.symbol,
    this.name,
    this.assetId,
  });

  factory _Slice.of(CountedHolding holding, CryptoBreakdownGrouping grouping) {
    final key = CryptoBreakdownBuilder._keyOf(holding, grouping);
    if (grouping == CryptoBreakdownGrouping.byChain) {
      return _Slice(key: key);
    }
    final canonical = ChainCatalog.tryAsset(holding.network, holding.assetId);
    if (canonical != null) {
      // A native coin is named by its ticker; the chain's own name would
      // mislabel ETH on Base as "Base".
      return _Slice(
        key: key,
        symbol: canonical.symbol,
        name: canonical.isNative ? null : canonical.name,
      );
    }
    return _Slice(
      key: key,
      symbol: holding.symbol,
      name: holding.name,
      assetId: holding.assetId,
    );
  }

  final String key;
  final String? symbol;
  final String? name;
  final String? assetId;
  final Map<WalletNetwork, BigInt> byNetwork = {};
  int holdingCount = 0;
  BigInt converted = BigInt.zero;

  void add(_Share share) {
    byNetwork.update(
      share.holding.network,
      (sum) => sum + share.converted,
      ifAbsent: () => share.converted,
    );
    holdingCount += 1;
    converted += share.converted;
  }

  /// The contributing networks, the biggest contributor first.
  List<WalletNetwork> get networks => byNetwork.keys.toList()
    ..sort((a, b) {
      final byValue = byNetwork[b]!.compareTo(byNetwork[a]!);
      return byValue != 0 ? byValue : a.index.compareTo(b.index);
    });

  _Entry toEntry() => _Entry(
    key: key,
    networks: networks,
    value: converted,
    holdingCount: holdingCount,
    symbol: symbol,
    name: name,
    assetId: assetId,
  );
}
