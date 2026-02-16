import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing categories within a budget.
///
/// All methods verify budget ownership before operating on categories.
class CategoryService {
  /// Creates a category within a budget, verifying ownership.
  static Future<Category> create(
    Session session, {
    required String name,
    required UuidValue budgetId,
    required int sortOrder,
  }) async {
    // Verify the user owns this budget.
    await BudgetService.getById(session, budgetId: budgetId);

    final category = Category(
      name: name,
      budgetId: budgetId,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
    return Category.db.insertRow(session, category);
  }

  /// Lists all categories for a budget, verifying ownership.
  static Future<List<Category>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return Category.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
    );
  }

  /// Fetches a single category, verifying budget ownership.
  static Future<Category> getById(
    Session session, {
    required UuidValue categoryId,
  }) async {
    final category = await Category.db.findById(session, categoryId);
    if (category == null) {
      throw NotFoundException('Category not found');
    }

    // Verify the user owns the parent budget.
    await BudgetService.getById(session, budgetId: category.budgetId);
    return category;
  }

  /// Updates a category, verifying budget ownership.
  static Future<Category> update(
    Session session, {
    required UuidValue categoryId,
    String? name,
    int? sortOrder,
  }) async {
    final category = await getById(session, categoryId: categoryId);

    final updated = category.copyWith(
      name: name ?? category.name,
      sortOrder: sortOrder ?? category.sortOrder,
    );
    return Category.db.updateRow(session, updated);
  }

  /// Batch-updates sort order for multiple categories in a single budget.
  static Future<List<Category>> reorder(
    Session session, {
    required UuidValue budgetId,
    required List<UuidValue> categoryIds,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final results = <Category>[];
    for (var i = 0; i < categoryIds.length; i++) {
      final category = await Category.db.findById(session, categoryIds[i]);
      if (category == null) continue;
      final updated = category.copyWith(sortOrder: i);
      results.add(await Category.db.updateRow(session, updated));
    }
    return results;
  }

  /// Deletes a category, verifying budget ownership.
  static Future<Category> delete(
    Session session, {
    required UuidValue categoryId,
  }) async {
    final category = await getById(session, categoryId: categoryId);
    return Category.db.deleteRow(session, category);
  }
}
