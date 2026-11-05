/// The decoded state of one on-chain subscription delegation.
class SolanaSubscriptionSnapshot {
  const SolanaSubscriptionSnapshot({
    required this.subscriptionAddress,
    required this.planAddress,
    required this.subscriberAddress,
    required this.planActive,
    required this.subscriptionActive,
    required this.amountBaseUnits,
    required this.periodSeconds,
  });

  final String subscriptionAddress;
  final String planAddress;
  final String subscriberAddress;
  final bool planActive;
  final bool subscriptionActive;
  final int amountBaseUnits;
  final int periodSeconds;
}

/// The on-chain operations the billing service needs.
///
/// Tests provide a fake implementation so no test touches a live RPC.
abstract interface class SolanaBillingChain {
  /// Fetches and decodes the subscription delegation at [subscriptionAddress].
  Future<SolanaSubscriptionSnapshot?> fetchSubscription(
    String subscriptionAddress,
  );

  /// Charges one subscription period and waits for confirmation.
  Future<void> transferSubscription({
    required String subscriptionAddress,
    required String planAddress,
    required String subscriberAddress,
    required String mintAddress,
    required int amountBaseUnits,
  });
}
