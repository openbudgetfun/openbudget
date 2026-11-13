import 'dart:async';

import 'package:openbudget_test_utils/openbudget_test_utils.dart';

/// Shared bootstrap for every widget test file under `test/`.
///
/// Installs the network-deny guard so a widget test whose provider chain
/// reads the Serverpod client fails inside the test with a clear
/// `StateError` naming the endpoint, instead of leaving a cancelled socket
/// attempt that fails the suite after it completed.
Future<void> testExecutable(FutureOr<void> Function() testBody) async {
  installNetworkDenyGuard();
  await testBody();
}
