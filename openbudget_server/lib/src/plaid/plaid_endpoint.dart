import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/plaid/plaid_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for Plaid-linked account integration.
class PlaidEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a short-lived link token for starting Plaid Link in the client.
  Future<String> createLinkToken(Session session, UuidValue budgetId) async {
    return PlaidService.createLinkToken(session, budgetId: budgetId);
  }

  /// Exchanges a public token and imports linked bank accounts into OpenBudget.
  Future<List<Account>> exchangePublicToken(
    Session session,
    UuidValue budgetId,
    String publicToken,
  ) async {
    return PlaidService.exchangePublicTokenAndImportAccounts(
      session,
      budgetId: budgetId,
      publicToken: publicToken,
    );
  }

  /// Refreshes an existing Plaid item connection and updates imported accounts.
  Future<List<Account>> syncConnection(
    Session session,
    UuidValue budgetId,
    UuidValue connectionId,
  ) async {
    return PlaidService.syncConnection(
      session,
      budgetId: budgetId,
      connectionId: connectionId,
    );
  }
}
