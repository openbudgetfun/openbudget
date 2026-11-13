import 'dart:async';

import 'package:openbudget_test_utils/openbudget_test_utils.dart';

/// Shared bootstrap for every Patrol integration test file.
///
/// Installs the network-deny guard so an un-faked provider can never open a
/// socket to the real Serverpod server. Un-guarded, such a request hangs until
/// the harness cancels it and the failure is reported after the test already
/// completed ("SocketException: Connection attempt cancelled" against
/// `api.openbudget.app`); with the guard it throws immediately and is
/// attributed to the test that caused it.
Future<void> testExecutable(FutureOr<void> Function() testBody) async {
  installNetworkDenyGuard();
  await testBody();
}
