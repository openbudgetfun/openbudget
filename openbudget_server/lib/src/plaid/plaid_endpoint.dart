import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/plaid/plaid_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for Plaid-linked account integration.
class PlaidEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a short-lived link token for starting Plaid Link in the client.
  Future<String> createLinkToken(Session session, UuidValue budgetId) async => PlaidService.createLinkToken(session, budgetId: budgetId);

  /// Exchanges a public token and imports linked bank accounts into OpenBudget.
  Future<List<Account>> exchangePublicToken(
    Session session,
    UuidValue budgetId,
    String publicToken,
  ) async {
    final accounts = await PlaidService.exchangePublicTokenAndImportAccounts(
      session,
      budgetId: budgetId,
      publicToken: publicToken,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return accounts;
  }

  /// Refreshes an existing Plaid item connection and updates imported accounts.
  Future<List<Account>> syncConnection(
    Session session,
    UuidValue budgetId,
    UuidValue connectionId,
  ) async {
    final accounts = await PlaidService.syncConnection(
      session,
      budgetId: budgetId,
      connectionId: connectionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return accounts;
  }

  /// Creates a Plaid sandbox item and imports accounts without client-side Link.
  Future<List<Account>> importSandboxAccounts(
    Session session,
    UuidValue budgetId, {
    String? plaidInstitutionId,
  }) async {
    final accounts = await PlaidService.importSandboxAccounts(
      session,
      budgetId: budgetId,
      plaidInstitutionId: plaidInstitutionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return accounts;
  }
}
