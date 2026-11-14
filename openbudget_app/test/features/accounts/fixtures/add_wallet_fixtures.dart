import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../support/fake_endpoint_client.dart';

/// The EIP-55 example address, valid on every EVM network.
const String fixtureEvmAddress = '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed';

/// The BIP 84 test vector's account key: a native SegWit Bitcoin HD wallet.
const String fixtureZpub =
    'zpub6rFR7y4Q2AijBEqTUquhVz398htDFrtymD9xYYfG1m4wAcvPhXNfE3EfH1r1ADqtfSdVCToUG868RvUUkgDKf31mGDtKsAYz2oz2AGutZYs';

/// A bare `xpub`, whose script type still has to be probed.
const String fixtureXpub =
    'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';

/// The BIP 39 test mnemonic: twelve words that must never reach a server.
const String fixtureRecoveryPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

/// A well-known Solana address (the system program's neighbour used across
/// the repo's tests).
const String fixtureSolanaAddress = '11111111111111111111111111111111';

const String fixtureEntityId = '00000000-0000-0000-0000-000000000001';

final DateTime fixtureNow = DateTime.utc(2026, 11, 14, 9);

/// Every mainnet the server could be set up to read.
final List<WalletNetwork> allMainnets = [
  for (final network in WalletNetwork.values)
    if (!network.isTestnet) network,
];

/// The seven EVM networks, in catalogue order.
final List<WalletNetwork> evmNetworks = [
  for (final network in WalletNetwork.values)
    if (network.family == ChainFamily.evm) network,
];

/// A preview row for [network]: [valueMinor] priced dollars, [unpriced]
/// holdings with no price, or [error].
WalletPreviewNetwork previewRow(
  WalletNetwork network, {
  int? valueMinor,
  int unpriced = 0,
  String? error,
}) => WalletPreviewNetwork(
  network: network,
  holdingCount: (valueMinor == null ? 0 : 1) + unpriced,
  pricedHoldingCount: valueMinor == null ? 0 : 1,
  valueMinor: valueMinor,
  valueCurrencyCode: valueMinor == null ? null : 'USD',
  readError: error,
);

/// A preview of [address] with one row per network in [rows].
WalletPreview previewOf(
  List<WalletPreviewNetwork> rows, {
  String address = fixtureEvmAddress,
  List<String> warnings = const [],
}) => WalletPreview(
  network: rows.first.network,
  address: address.toLowerCase(),
  networks: rows,
  warnings: warnings,
);

/// Ethereum $1,240, Base $310 and Arbitrum One with nothing on it.
WalletPreview ethereumBaseArbitrumPreview() => previewOf([
  previewRow(WalletNetwork.ethereumMainnet, valueMinor: 124000),
  previewRow(WalletNetwork.baseMainnet, valueMinor: 31000),
  previewRow(WalletNetwork.arbitrumOne),
]);

/// A connected wallet, as the server returns it after the first read.
Wallet fixtureWallet({
  WalletNetwork network = WalletNetwork.ethereumMainnet,
  String address = fixtureEvmAddress,
  SyncStatus syncStatus = SyncStatus.synced,
  String? lastSyncError,
  List<WalletNetwork>? scanNetworks,
}) => Wallet(
  id: UuidValue.fromString('00000000-0000-0000-0000-0000000000a1'),
  entityId: UuidValue.fromString(fixtureEntityId),
  accountId: UuidValue.fromString('00000000-0000-0000-0000-0000000000b1'),
  network: network,
  address: address,
  scanNetworks: scanNetworks,
  syncStatus: syncStatus,
  lastSyncError: lastSyncError,
  createdAt: fixtureNow,
  updatedAt: fixtureNow,
);

/// What a sync of [readNetworks] returns.
WalletSyncResult fixtureSyncResult({
  required List<WalletNetwork> readNetworks,
  List<WalletNetwork> failedNetworks = const [],
}) => WalletSyncResult(
  walletId: UuidValue.fromString('00000000-0000-0000-0000-0000000000a1'),
  insertedTransactions: 0,
  updatedTransactions: 0,
  holdingCount: 0,
  pricedHoldingCount: 0,
  cachedHoldingCount: 0,
  unpricedHoldingCount: 0,
  nftHoldingCount: 0,
  pricedNftHoldingCount: 0,
  cachedNftHoldingCount: 0,
  unpricedNftHoldingCount: 0,
  readNetworks: readNetworks,
  failedNetworks: failedNetworks,
  syncedAt: fixtureNow,
  warnings: const [],
);

/// A fake server for the add-a-wallet flow. Every wallet call the flow makes
/// is answered here, so a test can also assert which ones were not made.
class AddWalletServer {
  AddWalletServer({
    List<WalletNetwork>? supported,
    this.preview,
    this.connectResult,
  }) : supported = supported ?? allMainnets {
    client
      ..handle('wallet', 'supportedNetworks', (_) => this.supported)
      ..handle('wallet', 'preview', (_) async {
        final answer = preview;
        if (answer == null) throw StateError('No preview was set up.');
        return answer();
      })
      ..handle('wallet', 'connect', (args) async {
        final answer = connectResult;
        if (answer == null) throw StateError('No connect was set up.');
        return answer(args);
      });
  }

  final FakeEndpointClient client = FakeEndpointClient();
  final List<WalletNetwork> supported;

  /// Answers `wallet.preview`.
  Future<WalletPreview> Function()? preview;

  /// Answers `wallet.connect` from the call's arguments.
  Future<Wallet> Function(Map<String, dynamic> args)? connectResult;

  /// The wallet calls that did the work, in order. `supportedNetworks` is a
  /// read the screen makes on its own, so it is left out.
  List<String> get workCalls => [
    for (final call in client.calls)
      if (call.endpoint == 'wallet' && call.method != 'supportedNetworks')
        call.method,
  ];

  EndpointCall get lastConnect => client.callsTo('wallet', 'connect').last;
}
