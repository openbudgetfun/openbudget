import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for category operations.
///
/// All methods require authentication.
class CategoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new category within a budget.
  Future<Category> create(
    Session session,
    String name,
    UuidValue budgetId,
    int sortOrder,
  ) async {
    final category = await CategoryService.create(
      session,
      name: name,
      budgetId: budgetId,
      sortOrder: sortOrder,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(category.budgetId);
    return category;
  }

  /// Lists all categories for a budget.
  Future<List<Category>> list(Session session, UuidValue budgetId) async {
    return CategoryService.listForBudget(session, budgetId: budgetId);
  }

  /// Gets a single category by ID.
  Future<Category> get(Session session, UuidValue categoryId) async {
    return CategoryService.getById(session, categoryId: categoryId);
  }

  /// Updates a category by ID.
  Future<Category> update(
    Session session,
    UuidValue categoryId, {
    String? name,
    int? sortOrder,
    bool? isHidden,
  }) async {
    final category = await CategoryService.update(
      session,
      categoryId: categoryId,
      name: name,
      sortOrder: sortOrder,
      isHidden: isHidden,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(category.budgetId);
    return category;
  }

  /// Batch-reorders categories by their new position.
  ///
  /// The [categoryIds] list defines the new sort order: the first ID gets
  /// sort order 0, the second gets 1, etc.
  Future<List<Category>> reorder(
    Session session,
    UuidValue budgetId,
    List<UuidValue> categoryIds,
  ) async {
    final categories = await CategoryService.reorder(
      session,
      budgetId: budgetId,
      categoryIds: categoryIds,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return categories;
  }

  /// Deletes a category by ID.
  Future<Category> delete(Session session, UuidValue categoryId) async {
    final category = await CategoryService.delete(
      session,
      categoryId: categoryId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(category.budgetId);
    return category;
  }
}
