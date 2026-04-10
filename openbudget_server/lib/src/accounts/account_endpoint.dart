import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for account operations.
///
/// All methods require authentication.
class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new account within a budget.
  Future<Account> create(
    Session session,
    String name,
    String accountType,
    int balanceCents,
    String currencyCode,
    UuidValue budgetId, {
    required bool onBudget,
    required int sortOrder,
    UuidValue? institutionId,
  }) async {
    final account = await AccountService.create(
      session,
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      onBudget: onBudget,
      sortOrder: sortOrder,
      institutionId: institutionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(account.budgetId);
    return account;
  }

  /// Lists all accounts for a budget.
  Future<List<Account>> list(Session session, UuidValue budgetId) async =>
      AccountService.listForBudget(session, budgetId: budgetId);

  /// Lists creator-owned reusable accounts that can be added to another budget.
  Future<List<Account>> listMine(
    Session session, {
    UuidValue? excludeBudgetId,
  }) async =>
      AccountService.listMine(session, excludeBudgetId: excludeBudgetId);

  /// Adds one of the creator's existing accounts to another owned budget.
  Future<Account> addMineToBudget(
    Session session,
    UuidValue sourceAccountId,
    UuidValue budgetId,
  ) async {
    final account = await AccountService.addMineToBudget(
      session,
      sourceAccountId: sourceAccountId,
      budgetId: budgetId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(account.budgetId);
    return account;
  }

  /// Gets a single account by ID.
  Future<Account> get(Session session, UuidValue accountId) async =>
      AccountService.getById(session, accountId: accountId);

  /// Updates an account by ID.
  Future<Account> update(
    Session session,
    UuidValue accountId, {
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) async {
    final account = await AccountService.update(
      session,
      accountId: accountId,
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: isClosed,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(account.budgetId);
    return account;
  }

  /// Deletes an account by ID.
  Future<Account> delete(Session session, UuidValue accountId) async {
    final account = await AccountService.delete(session, accountId: accountId);
    BudgetRealtimeNotifier.notifyBudgetChanged(account.budgetId);
    return account;
  }
}
