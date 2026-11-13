import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

/// A deterministic billing backend for Patrol flows.
///
/// The Playwright-style fake keeps paid states out of the real server so the
/// E2E test can assert the plan card without a database.
class FakePlusBillingBackend implements PlusBillingApi {
  FakePlusBillingBackend({this.entitlement});

  Entitlement? entitlement;
  int entitlementReads = 0;

  @override
  Future<Entitlement?> getEntitlement() async {
    entitlementReads++;
    return entitlement;
  }

  @override
  Future<String> createStripeCheckout(
    String successUrl,
    String cancelUrl,
  ) async => 'https://checkout.stripe.test/session';

  @override
  Future<String> createStripePortal(String returnUrl) async =>
      'https://billing.stripe.test/session';

  @override
  Future<SolanaPlanView> getSolanaPlan() async => SolanaPlanView(
    planAddress: '11111111111111111111111111111112',
    programAddress: 'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
    usdcMint: '11111111111111111111111111111113',
    amountBaseUnits: 20000000,
    periodSeconds: 2592000,
  );

  @override
  Future<String> solanaSubscriptionChallenge() async =>
      'OpenBudget Plus subscription test';

  @override
  Future<Entitlement> confirmSolanaSubscription(
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) async => entitlement!;
}
