import 'package:openbudget_server/src/accounts/account_service.dart';
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
  }) async {
    return AccountService.create(
      session,
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      onBudget: onBudget,
      sortOrder: sortOrder,
    );
  }

  /// Lists all accounts for a budget.
  Future<List<Account>> list(Session session, UuidValue budgetId) async {
    return AccountService.listForBudget(session, budgetId: budgetId);
  }

  /// Gets a single account by ID.
  Future<Account> get(Session session, UuidValue accountId) async {
    return AccountService.getById(session, accountId: accountId);
  }

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
    return AccountService.update(
      session,
      accountId: accountId,
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: isClosed,
    );
  }

  /// Deletes an account by ID.
  Future<Account> delete(Session session, UuidValue accountId) async {
    return AccountService.delete(session, accountId: accountId);
  }
}
