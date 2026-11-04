import 'package:openbudget_server/src/billing/solana_billing_chain.dart';

/// An in-memory Solana subscriptions chain for tests.
class FakeSolanaBillingChain implements SolanaBillingChain {
  FakeSolanaBillingChain({
    Map<String, SolanaSubscriptionSnapshot>? subscriptions,
    this.transferError,
  }) : subscriptions = subscriptions ?? {};

  final Map<String, SolanaSubscriptionSnapshot> subscriptions;
  final List<SolanaTransferCall> transfers = [];
  Exception? transferError;
  int fetchCount = 0;

  @override
  Future<SolanaSubscriptionSnapshot?> fetchSubscription(
    String subscriptionAddress,
  ) async {
    fetchCount += 1;
    return subscriptions[subscriptionAddress];
  }

  @override
  Future<void> transferSubscription({
    required String subscriptionAddress,
    required String planAddress,
    required String subscriberAddress,
    required String mintAddress,
    required int amountBaseUnits,
  }) async {
    transfers.add(
      SolanaTransferCall(
        subscriptionAddress: subscriptionAddress,
        planAddress: planAddress,
        subscriberAddress: subscriberAddress,
        mintAddress: mintAddress,
        amountBaseUnits: amountBaseUnits,
      ),
    );
    final error = transferError;
    if (error != null) throw error;
  }
}

class SolanaTransferCall {
  const SolanaTransferCall({
    required this.subscriptionAddress,
    required this.planAddress,
    required this.subscriberAddress,
    required this.mintAddress,
    required this.amountBaseUnits,
  });

  final String subscriptionAddress;
  final String planAddress;
  final String subscriberAddress;
  final String mintAddress;
  final int amountBaseUnits;
}
