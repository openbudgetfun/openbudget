import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
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
    final budget = await BudgetService.create(
      session,
      name: name,
      currencyCode: currencyCode,
    );
    final createdBudgetId = budget.id;
    if (createdBudgetId != null) {
      BudgetRealtimeNotifier.notifyBudgetChanged(createdBudgetId);
    }
    return budget;
  }

  /// Lists all budgets for the authenticated user.
  Future<List<Budget>> list(Session session) async => BudgetService.listForUser(session);

  /// Gets a single budget by ID, verifying ownership.
  Future<Budget> get(Session session, UuidValue budgetId) async => BudgetService.getById(session, budgetId: budgetId);

  /// Updates a budget by ID, verifying ownership.
  Future<Budget> update(
    Session session,
    UuidValue budgetId, {
    String? name,
    String? currencyCode,
    String? displayCurrencyCode,
    bool? clearDisplayCurrencyCode,
  }) async {
    final budget = await BudgetService.update(
      session,
      budgetId: budgetId,
      name: name,
      currencyCode: currencyCode,
      displayCurrencyCode: displayCurrencyCode,
      clearDisplayCurrencyCode: clearDisplayCurrencyCode ?? false,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return budget;
  }

  /// Deletes a budget by ID, verifying ownership.
  Future<Budget> delete(Session session, UuidValue budgetId) async {
    final budget = await BudgetService.delete(session, budgetId: budgetId);
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return budget;
  }

  /// Exports all budget data as a JSON string for data portability.
  Future<String> exportData(Session session, UuidValue budgetId) async => BudgetService.exportData(session, budgetId: budgetId);
}
