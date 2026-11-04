import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Subscription state for the signed-in user.
class BillingEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the entitlement that currently grants OpenBudget Plus, or null
  /// when the user is on the free plan.
  Future<Entitlement?> getEntitlement(Session session) =>
      EntitlementService.activeForCurrentUser(session);
}
