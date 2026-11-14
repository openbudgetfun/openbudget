import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../fixtures/budget_month.dart';
import '../../../support/fake_endpoint_client.dart';
import 'wallet_holdings_fixtures.dart';

/// The EIP-55 example address, valid on every EVM network.
const String settingsEvmAddress = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

final DateTime settingsNow = DateTime.utc(2026, 11, 14, 9);

/// A fake wallet server that behaves like the real one for the wallet
/// settings: the networks a wallet reads decide which holdings it has, and
/// saving a new list reads at once.
///
/// [valueByNetwork] is what each chain holds in dollars' minor units. Only
/// the chains the wallet reads show their holdings, so removing a chain
/// drops its holdings and adding one reads them.
class WalletSettingsServer {
  WalletSettingsServer({
    required List<WalletNetwork> reading,
    required this.valueByNetwork,
    this.accountName = 'Ethereum wallet (0x5a…eAed)',
    this.network = WalletNetwork.ethereumMainnet,
    List<WalletNetwork>? supported,
  }) : scan = [...reading],
       supported =
           supported ??
           [
             for (final candidate in WalletNetwork.values)
               if (!candidate.isTestnet) candidate,
           ] {
    client
      ..handle('account', 'get', (_) => account())
      ..handle('account', 'update', (args) {
        accountName = args['name']! as String;
        return account();
      })
      ..handle('wallet', 'getForAccount', (_) => wallet())
      ..handle('wallet', 'supportedNetworks', (_) => this.supported)
      ..handle('wallet', 'listHoldings', (_) => holdings())
      ..handle('wallet', 'listNetworkStates', (_) => states())
      ..handle('wallet', 'preview', (_) async {
        previewCalls++;
        final error = previewError;
        if (error != null) throw error;
        return previewAnswer ?? _emptyPreview();
      })
      ..handle('wallet', 'setScanNetworks', (args) async {
        final next = args['networks']! as List<WalletNetwork>;
        final failure = setScanError;
        if (failure != null) throw failure;
        scan = [...next];
        return wallet(
          syncStatus: readFails ? SyncStatus.failed : SyncStatus.synced,
        );
      })
      ..handle('wallet', 'disconnect', (_) {
        final failure = disconnectError;
        if (failure != null) throw failure;
        disconnected = true;
        return null;
      });
  }

  final FakeEndpointClient client = FakeEndpointClient();
  final WalletNetwork network;
  final Map<WalletNetwork, int> valueByNetwork;
  final List<WalletNetwork> supported;

  String accountName;
  List<WalletNetwork> scan;
  bool disconnected = false;

  /// Makes the read after a save fail on every network.
  bool readFails = false;

  /// What `wallet.preview` answers, or throws.
  WalletPreview? previewAnswer;
  Exception? previewError;
  int previewCalls = 0;
  Exception? setScanError;
  Exception? disconnectError;

  Account account() => testAccount(
    name: accountName,
    kind: AccountKind.crypto,
    currencyCode: 'USD',
    balanceMinor: totalMinor,
    onBudget: false,
    balanceSource: AccountBalanceSource.valuations,
  );

  /// What the wallet's valuation is: every read chain's value.
  int get totalMinor =>
      scan.fold(0, (sum, n) => sum + (valueByNetwork[n] ?? 0));

  Wallet wallet({SyncStatus syncStatus = SyncStatus.synced}) => Wallet(
    id: UuidValue.fromString(fixtureWalletId),
    entityId: UuidValue.fromString(fixtureEntityId),
    accountId: UuidValue.fromString(fixtureAccountId),
    network: network,
    address: settingsEvmAddress,
    scanNetworks: network.family == ChainFamily.evm ? [...scan] : null,
    syncStatus: syncStatus,
    createdAt: settingsNow,
    updatedAt: settingsNow,
  );

  List<WalletHolding> holdings() => [
    for (final (index, chain) in scan.indexed)
      if ((valueByNetwork[chain] ?? 0) > 0)
        fixtureHolding(
          network: chain,
          id: '00000000-0000-0000-0000-0000000000${(0xe0 + index).toRadixString(16)}',
          symbol: 'ETH',
          name: 'Ether',
          valueMinor: valueByNetwork[chain],
        ),
  ];

  List<WalletNetworkState> states() => [
    for (final chain in scan)
      fixtureNetworkState(chain, lastReadAt: settingsNow),
  ];

  WalletPreview _emptyPreview() => WalletPreview(
    network: network,
    address: settingsEvmAddress.toLowerCase(),
    networks: [
      for (final chain in supported)
        if (chain.family == ChainFamily.evm) settingsPreviewRow(chain),
    ],
    warnings: const [],
  );

  /// The wallet calls that did the work, in order.
  List<String> get workCalls => [
    for (final call in client.calls)
      if (call.endpoint == 'wallet' &&
          const {
            'setScanNetworks',
            'preview',
            'disconnect',
          }.contains(call.method))
        call.method,
  ];
}

/// A preview row for [network]: [valueMinor] priced dollars, or nothing.
WalletPreviewNetwork settingsPreviewRow(
  WalletNetwork network, {
  int? valueMinor,
}) => WalletPreviewNetwork(
  network: network,
  holdingCount: valueMinor == null ? 0 : 1,
  pricedHoldingCount: valueMinor == null ? 0 : 1,
  valueMinor: valueMinor,
  valueCurrencyCode: valueMinor == null ? null : 'USD',
);
