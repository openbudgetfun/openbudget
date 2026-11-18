import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

CryptoBreakdownRow _row(
  String key,
  int valueMinor,
  int shareBasisPoints, {
  List<WalletNetwork> networks = const [],
  String? symbol,
  String? name,
  String? assetId,
  bool isOther = false,
  int holdingCount = 1,
}) => CryptoBreakdownRow(
  key: key,
  networks: networks,
  symbol: symbol,
  name: name,
  assetId: assetId,
  isOther: isOther,
  holdingCount: holdingCount,
  valueMinor: valueMinor,
  shareBasisPoints: shareBasisPoints,
);

/// What the server answers for an entity with two wallets, in GBP: £200.00
/// across Ethereum, Solana and Base, or the same money by asset.
CryptoBreakdownView cryptoBreakdownView(
  CryptoBreakdownGrouping grouping, {
  int walletCount = 2,
  bool isComplete = true,
  List<String> missingCurrencyCodes = const [],
  bool hasStaleRates = false,
  List<CryptoBreakdownRow>? rows,
}) {
  final resolved =
      rows ??
      switch (grouping) {
        CryptoBreakdownGrouping.byChain => [
          _row(
            'ethereumMainnet',
            10000,
            5000,
            networks: [WalletNetwork.ethereumMainnet],
            holdingCount: 4,
          ),
          _row(
            'solanaMainnet',
            7000,
            3500,
            networks: [WalletNetwork.solanaMainnet],
            holdingCount: 2,
          ),
          _row(
            'baseMainnet',
            3000,
            1500,
            networks: [WalletNetwork.baseMainnet],
          ),
        ],
        CryptoBreakdownGrouping.byAsset => [
          _row(
            'asset:USDC',
            8000,
            4000,
            networks: [
              WalletNetwork.ethereumMainnet,
              WalletNetwork.baseMainnet,
              WalletNetwork.solanaMainnet,
            ],
            symbol: 'USDC',
            name: 'USD Coin',
            holdingCount: 3,
          ),
          _row(
            'asset:ETH',
            6000,
            3000,
            networks: [
              WalletNetwork.ethereumMainnet,
              WalletNetwork.baseMainnet,
            ],
            symbol: 'ETH',
            holdingCount: 2,
          ),
          _row(
            'asset:SOL',
            4000,
            2000,
            networks: [WalletNetwork.solanaMainnet],
            symbol: 'SOL',
          ),
          _row(
            'other',
            2000,
            1000,
            networks: [WalletNetwork.baseMainnet],
            isOther: true,
            holdingCount: 3,
          ),
        ],
      };
  return CryptoBreakdownView(
    currencyCode: 'GBP',
    asOf: DateTime.utc(2026, 9, 5),
    grouping: grouping,
    totalMinor: resolved.fold(0, (sum, row) => sum + row.valueMinor),
    walletCount: walletCount,
    isComplete: isComplete,
    missingCurrencyCodes: missingCurrencyCodes,
    hasStaleRates: hasStaleRates,
    rows: resolved,
  );
}

/// The answer for an entity with no wallets: the section stays hidden.
CryptoBreakdownView noWalletsBreakdown(CryptoBreakdownGrouping grouping) =>
    cryptoBreakdownView(grouping, walletCount: 0, rows: const []);
