import 'package:flutter/widgets.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';
import 'package:openbudget_app/src/features/plus/services/solana_subscribe_flow.dart';
import 'package:openbudget_client/openbudget_client.dart';

/// Builds an entitlement for tests.
Entitlement makeEntitlement({
  EntitlementStatus status = EntitlementStatus.active,
  EntitlementSource source = EntitlementSource.stripe,
  DateTime? periodEnd,
}) => Entitlement(
  userId: UuidValue.fromString('00000000-0000-0000-0000-000000000901'),
  source: source,
  externalId: 'test-subscription',
  status: status,
  currentPeriodStart: DateTime.utc(2026),
  currentPeriodEnd: periodEnd ?? DateTime.utc(2026, 2),
);

/// A [PlusBillingApi] that records calls and returns test data.
class FakePlusBillingApi implements PlusBillingApi {
  Entitlement? entitlement;
  Exception? entitlementError;

  String checkoutUrl = 'https://checkout.stripe.test/session';
  String portalUrl = 'https://billing.stripe.test/session';
  SolanaPlanView solanaPlan = SolanaPlanView(
    planAddress: '11111111111111111111111111111112',
    programAddress: 'De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44',
    usdcMint: '11111111111111111111111111111113',
    amountBaseUnits: 10000000,
    periodSeconds: 2592000,
  );
  String challenge = 'OpenBudget Plus subscription test';
  Entitlement? confirmedEntitlement;
  Exception? checkoutError;

  int entitlementReads = 0;
  int checkoutCalls = 0;
  int portalCalls = 0;
  int planCalls = 0;
  int challengeCalls = 0;
  int confirmCalls = 0;
  String? lastSuccessUrl;
  String? lastCancelUrl;
  String? lastPortalReturnUrl;
  String? lastSubscriberAddress;
  String? lastSignatureBase58;

  @override
  Future<Entitlement?> getEntitlement() async {
    entitlementReads++;
    if (entitlementError case final error?) throw error;
    return entitlement;
  }

  @override
  Future<String> createStripeCheckout(
    String successUrl,
    String cancelUrl,
  ) async {
    checkoutCalls++;
    lastSuccessUrl = successUrl;
    lastCancelUrl = cancelUrl;
    if (checkoutError case final error?) throw error;
    return checkoutUrl;
  }

  @override
  Future<String> createStripePortal(String returnUrl) async {
    portalCalls++;
    lastPortalReturnUrl = returnUrl;
    return portalUrl;
  }

  @override
  Future<SolanaPlanView> getSolanaPlan() async {
    planCalls++;
    return solanaPlan;
  }

  @override
  Future<String> solanaSubscriptionChallenge() async {
    challengeCalls++;
    return challenge;
  }

  @override
  Future<Entitlement> confirmSolanaSubscription(
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) async {
    confirmCalls++;
    lastSubscriberAddress = subscriberAddress;
    lastSignatureBase58 = signatureBase58;
    return confirmedEntitlement ??
        makeEntitlement(source: EntitlementSource.solana);
  }
}

/// A [StorePurchases] fake with no RevenueCat calls.
class FakeStorePurchases implements StorePurchases {
  FakeStorePurchases({
    this.available = true,
    this.purchaseOutcome = StorePurchaseOutcome.purchased,
    this.restoreOutcome = StorePurchaseOutcome.purchased,
    this.management,
  });

  bool available;
  StorePurchaseOutcome purchaseOutcome;
  StorePurchaseOutcome restoreOutcome;
  Uri? management;

  int purchaseCalls = 0;
  int restoreCalls = 0;
  int managementCalls = 0;
  String? identifiedUserId;

  @override
  bool get isAvailable => available;

  @override
  Future<void> identify(String userId) async {
    identifiedUserId = userId;
  }

  @override
  Future<StorePurchaseOutcome> purchaseMonthly() async {
    purchaseCalls++;
    return purchaseOutcome;
  }

  @override
  Future<StorePurchaseOutcome> restore() async {
    restoreCalls++;
    return restoreOutcome;
  }

  @override
  Future<Uri?> managementUrl() async {
    managementCalls++;
    return management;
  }
}

/// A launcher that records URLs instead of opening a browser.
class FakePlusUrlLauncher implements PlusUrlLauncher {
  FakePlusUrlLauncher({this.result = true});

  bool result;
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return result;
  }
}

/// A Solana flow that records the call and can fail on demand.
class FakeSolanaSubscribeFlow implements SolanaSubscribeFlow {
  FakeSolanaSubscribeFlow({this.error});

  SolanaSubscribeException? error;
  int calls = 0;

  @override
  Future<void> subscribe({required BuildContext context}) async {
    calls++;
    if (error case final failure?) throw failure;
  }
}
