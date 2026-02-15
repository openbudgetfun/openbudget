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
    return CategoryService.create(
      session,
      name: name,
      budgetId: budgetId,
      sortOrder: sortOrder,
    );
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
  }) async {
    return CategoryService.update(
      session,
      categoryId: categoryId,
      name: name,
      sortOrder: sortOrder,
    );
  }

  /// Deletes a category by ID.
  Future<Category> delete(Session session, UuidValue categoryId) async {
    return CategoryService.delete(session, categoryId: categoryId);
  }
}
