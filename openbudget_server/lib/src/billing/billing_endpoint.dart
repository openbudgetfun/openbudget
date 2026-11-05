import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/solana_billing_service.dart';
import 'package:openbudget_server/src/billing/stripe_client.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Subscription state for the signed-in user.
class BillingEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  final _stripeClient = StripeClient();

  /// Returns the entitlement that currently grants OpenBudget Plus, or null
  /// when the user is on the free plan.
  Future<Entitlement?> getEntitlement(Session session) =>
      EntitlementService.activeForCurrentUser(session);

  /// Creates a Stripe Checkout session and returns its hosted URL.
  Future<String> createStripeCheckout(
    Session session,
    String successUrl,
    String cancelUrl,
  ) async {
    final userId = _requireUserId(session);
    final secretKey = BillingSecrets.require(
      session,
      BillingSecretKeys.stripeSecretKey,
    );
    final priceId = BillingSecrets.require(
      session,
      BillingSecretKeys.stripePriceId,
    );
    final customer = await StripeCustomer.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    return _stripeClient.createCheckoutSession(
      secretKey: secretKey,
      priceId: priceId,
      userId: userId.uuid,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      customerId: customer?.customerId,
    );
  }

  /// Creates a Stripe billing portal session and returns its hosted URL.
  Future<String> createStripePortal(
    Session session,
    String returnUrl,
  ) async {
    final userId = _requireUserId(session);
    final secretKey = BillingSecrets.require(
      session,
      BillingSecretKeys.stripeSecretKey,
    );
    final customer = await StripeCustomer.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (customer == null) {
      throw NotFoundException('No Stripe customer for this user');
    }
    return _stripeClient.createPortalSession(
      secretKey: secretKey,
      customerId: customer.customerId,
      returnUrl: returnUrl,
    );
  }

  /// Returns the Solana plan terms the app needs to subscribe on chain.
  Future<SolanaPlanView> getSolanaPlan(Session session) async =>
      SolanaBillingService.planView(session);

  /// Returns a one-time message the subscriber signs with their wallet.
  Future<String> solanaSubscriptionChallenge(Session session) =>
      SolanaBillingService.fromSession(
        session,
      ).createChallenge(session, _requireUserId(session));

  /// Verifies the signed challenge and records the on-chain subscription.
  Future<Entitlement> confirmSolanaSubscription(
    Session session,
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) => SolanaBillingService.fromSession(session).confirmSubscription(
    session,
    userId: _requireUserId(session),
    subscriberAddress: subscriberAddress,
    message: message,
    signatureBase58: signatureBase58,
  );

  UuidValue _requireUserId(Session session) {
    final identifier = session.authenticated?.userIdentifier;
    if (identifier == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(identifier);
  }
}
