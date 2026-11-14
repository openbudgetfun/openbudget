import 'dart:async';

import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import 'test_data.dart';

/// One call the app made to the faked wallet server.
typedef FakeWalletCall = ({String method, Map<String, dynamic> args});

/// A faked Serverpod client for the add-a-wallet Patrol flow.
///
/// It answers the three wallet calls the flow makes (`supportedNetworks`,
/// `preview` and `connect`) from fixtures and records every call, so a test
/// can assert both what the app sent and what it never sent. `connect` waits
/// on [firstRead], so a test can hold the first read open and look at the
/// "Reading…" state before it lets the wallet in.
///
/// Any other endpoint call throws, which keeps the flow honest about what it
/// touches.
class FakeWalletServer extends Client {
  FakeWalletServer() : super('http://localhost/');

  final List<FakeWalletCall> calls = [];

  /// Completes the first read. Complete it to let `connect` answer.
  Completer<void> firstRead = Completer<void>()..complete();

  /// What `connect` answers, from its arguments.
  Wallet Function(Map<String, dynamic> args) connectResult = (args) =>
      WalletFlowData.connected(
        network: args['network']! as WalletNetwork,
        scanNetworks: args['scanNetworks'] as List<WalletNetwork>?,
      );

  List<FakeWalletCall> callsTo(String method) => [
    for (final call in calls)
      if (call.method == method) call,
  ];

  /// The wallet calls that did the work, leaving out `supportedNetworks`,
  /// which the screen reads on its own.
  List<String> get workCalls => [
    for (final call in calls)
      if (call.method != 'supportedNetworks') call.method,
  ];

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    if (endpoint != 'wallet') {
      throw StateError('Unexpected endpoint call $endpoint.$method');
    }
    calls.add((method: method, args: args));
    final answer = switch (method) {
      'supportedNetworks' => [
        for (final network in WalletNetwork.values)
          if (!network.isTestnet) network,
      ],
      'preview' => WalletFlowData.evmPreview(),
      'connect' => await _connect(args),
      _ => throw StateError('Unexpected wallet call $method'),
    };
    return answer as T;
  }

  Future<Wallet> _connect(Map<String, dynamic> args) async {
    await firstRead.future;
    return connectResult(args);
  }
}
