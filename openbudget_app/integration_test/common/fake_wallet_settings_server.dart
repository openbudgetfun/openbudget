import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import 'fake_wallet_server.dart';
import 'test_data.dart';

/// A faked Serverpod client for the wallet settings Patrol flow.
///
/// It behaves like the server for what the settings touch: the networks a
/// wallet reads decide which holdings it has, so removing a chain drops its
/// holdings and the valuation with them, and adding one reads it at once. It
/// records every call, so a test can assert what the app sent.
///
/// Any other endpoint call throws, which keeps the flow honest about what it
/// touches.
class FakeWalletSettingsServer extends Client {
  FakeWalletSettingsServer() : super('http://localhost/');

  final List<FakeWalletCall> calls = [];

  /// The account's name, which `account.update` changes.
  String accountName = WalletSettingsFlowData.accountName;

  /// The networks the wallet reads now.
  List<WalletNetwork> scan = [
    WalletNetwork.ethereumMainnet,
    WalletNetwork.baseMainnet,
  ];

  /// What each chain holds, in dollars' minor units.
  final Map<WalletNetwork, int> valueByNetwork = {
    WalletNetwork.ethereumMainnet: WalletSettingsFlowData.ethereumMinor,
    WalletNetwork.baseMainnet: WalletSettingsFlowData.baseMinor,
    WalletNetwork.arbitrumOne: WalletSettingsFlowData.arbitrumMinor,
  };

  /// The valuation of the wallet: every chain it reads.
  int get totalMinor =>
      scan.fold(0, (sum, chain) => sum + (valueByNetwork[chain] ?? 0));

  List<FakeWalletCall> callsTo(String method) => [
    for (final call in calls)
      if (call.method == method) call,
  ];

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    calls.add((method: '$endpoint.$method', args: args));
    final answer = switch ('$endpoint.$method') {
      'account.get' => WalletSettingsFlowData.account(
        name: accountName,
        balanceMinor: totalMinor,
      ),
      'account.update' => _rename(args),
      'wallet.getForAccount' => WalletSettingsFlowData.wallet(scan),
      'wallet.supportedNetworks' => [
        for (final network in WalletNetwork.values)
          if (!network.isTestnet) network,
      ],
      'wallet.listHoldings' => WalletSettingsFlowData.holdings(
        scan,
        valueByNetwork,
      ),
      'wallet.listNetworkStates' => WalletSettingsFlowData.states(scan),
      'wallet.preview' => WalletSettingsFlowData.preview(valueByNetwork),
      'wallet.setScanNetworks' => _setScanNetworks(args),
      _ => throw StateError('Unexpected call $endpoint.$method'),
    };
    return answer as T;
  }

  Account _rename(Map<String, dynamic> args) {
    accountName = args['name']! as String;
    return WalletSettingsFlowData.account(
      name: accountName,
      balanceMinor: totalMinor,
    );
  }

  Wallet _setScanNetworks(Map<String, dynamic> args) {
    scan = [...args['networks']! as List<WalletNetwork>];
    return WalletSettingsFlowData.wallet(scan);
  }
}
