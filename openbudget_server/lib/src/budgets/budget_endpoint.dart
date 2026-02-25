import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for budget operations.
///
/// All methods require authentication.
class BudgetEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new budget for the authenticated user.
  Future<Budget> create(
    Session session,
    String name,
    String currencyCode,
  ) async {
    return BudgetService.create(
      session,
      name: name,
      currencyCode: currencyCode,
    );
  }

  /// Lists all budgets for the authenticated user.
  Future<List<Budget>> list(Session session) async {
    return BudgetService.listForUser(session);
  }

  /// Gets a single budget by ID, verifying ownership.
  Future<Budget> get(Session session, UuidValue budgetId) async {
    return BudgetService.getById(session, budgetId: budgetId);
  }

  /// Updates a budget by ID, verifying ownership.
  Future<Budget> update(
    Session session,
    UuidValue budgetId, {
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    bool? clearDisplayCurrencyCode,
  }) async {
    return BudgetService.update(
      session,
      budgetId: budgetId,
      name: name,
      currencyCode: currencyCode,
      displayCurrencyCode: displayCurrencyCode,
      clearDisplayCurrencyCode: clearDisplayCurrencyCode ?? false,
    );
  }

  /// Deletes a budget by ID, verifying ownership.
  Future<Budget> delete(Session session, UuidValue budgetId) async {
    return BudgetService.delete(session, budgetId: budgetId);
  }

  /// Exports all budget data as a JSON string for data portability.
  Future<String> exportData(Session session, UuidValue budgetId) async {
    return BudgetService.exportData(session, budgetId: budgetId);
  }
}
