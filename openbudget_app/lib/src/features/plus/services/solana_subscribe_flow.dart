import 'package:flutter/widgets.dart';

/// Why a Solana subscription did not finish.
enum SolanaSubscribeFailure {
  /// This build or platform cannot reach a Solana wallet.
  walletUnavailable,

  /// The person dismissed the wallet picker or declined the connection.
  walletRejected,

  /// The connection or transaction failed after the wallet was chosen.
  failed,
}

/// A Solana wallet flow that could not complete.
class SolanaSubscribeException implements Exception {
  const SolanaSubscribeException(this.failure, [this.cause]);

  final SolanaSubscribeFailure failure;
  final Object? cause;

  @override
  String toString() {
    final reason = cause == null ? '' : ': $cause';
    return 'SolanaSubscribeException(${failure.name}$reason)';
  }
}

/// Connects a Solana wallet, subscribes to the on-chain plan, and proves
/// wallet ownership to the server.
///
/// The widget tests replace this with a fake, so no test touches a wallet.
// ignore: one_member_abstracts
abstract interface class SolanaSubscribeFlow {
  Future<void> subscribe({required BuildContext context});
}
