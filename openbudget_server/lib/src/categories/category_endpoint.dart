import 'package:openbudget_server/src/categories/category_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for category operations.
///
/// All methods require authentication and delegate to [CategoryService],
/// which owns the entity boundary.
class CategoryEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a category at the end of the entity's list.
  Future<Category> create(
    Session session,
    UuidValue entityId,
    String name,
  ) => CategoryService.create(session, entityId: entityId, name: name);

  /// Lists every category of an entity, hidden ones included.
  Future<List<Category>> list(Session session, UuidValue entityId) =>
      CategoryService.list(session, entityId: entityId);

  /// Loads one category by id.
  Future<Category> get(Session session, UuidValue categoryId) =>
      CategoryService.getById(session, categoryId: categoryId);

  /// Renames or hides a category.
  Future<Category> update(
    Session session,
    UuidValue categoryId, {
    String? name,
    bool? isHidden,
  }) => CategoryService.update(
    session,
    categoryId: categoryId,
    name: name,
    isHidden: isHidden,
  );

  /// Rewrites the entity's category order from an exact id list.
  Future<List<Category>> reorder(
    Session session,
    UuidValue entityId,
    List<UuidValue> categoryIds,
  ) => CategoryService.reorder(
    session,
    entityId: entityId,
    categoryIds: categoryIds,
  );

  /// Deletes an empty category.
  Future<void> delete(Session session, UuidValue categoryId) =>
      CategoryService.delete(session, categoryId: categoryId);
}
