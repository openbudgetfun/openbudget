import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_billing_api.g.dart';

/// The billing calls the Plus screen needs.
///
/// A narrow interface keeps every provider testable with a fake instead of a
/// live Serverpod client, while production wraps the generated endpoint.
abstract interface class PlusBillingApi {
  Future<Entitlement?> getEntitlement();

  Future<String> createStripeCheckout(String successUrl, String cancelUrl);

  Future<String> createStripePortal(String returnUrl);

  Future<SolanaPlanView> getSolanaPlan();

  Future<String> solanaSubscriptionChallenge();

  Future<Entitlement> confirmSolanaSubscription(
    String subscriberAddress,
    String message,
    String signatureBase58,
  );
}

/// [PlusBillingApi] backed by the generated Serverpod billing endpoint.
class ServerpodPlusBillingApi implements PlusBillingApi {
  const ServerpodPlusBillingApi(this._endpoint);

  final EndpointBilling _endpoint;

  @override
  Future<Entitlement?> getEntitlement() => _endpoint.getEntitlement();

  @override
  Future<String> createStripeCheckout(
    String successUrl,
    String cancelUrl,
  ) => _endpoint.createStripeCheckout(successUrl, cancelUrl);

  @override
  Future<String> createStripePortal(String returnUrl) =>
      _endpoint.createStripePortal(returnUrl);

  @override
  Future<SolanaPlanView> getSolanaPlan() => _endpoint.getSolanaPlan();

  @override
  Future<String> solanaSubscriptionChallenge() =>
      _endpoint.solanaSubscriptionChallenge();

  @override
  Future<Entitlement> confirmSolanaSubscription(
    String subscriberAddress,
    String message,
    String signatureBase58,
  ) => _endpoint.confirmSolanaSubscription(
    subscriberAddress,
    message,
    signatureBase58,
  );
}

/// The billing calls used by the Plus feature.
@Riverpod(keepAlive: true)
PlusBillingApi plusBillingApi(Ref ref) =>
    ServerpodPlusBillingApi(ref.watch(serverpodClientProvider).billing);
