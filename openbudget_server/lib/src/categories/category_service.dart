import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Owns category lifecycle within one entity's envelope plan.
///
/// Every read and write crosses [EntityAccess], so a category is visible only
/// to the owner of its entity. Categories are appended to the end of the
/// entity's list and reordered only by supplying the complete list.
abstract final class CategoryService {
  static final _log = ObLogger('CategoryService');

  /// Creates a category at the end of the entity's list.
  static Future<Category> create(
    Session session, {
    required UuidValue entityId,
    required String name,
  }) async {
    final categoryName = _requireName(name);

    _log.info('Creating category name=$categoryName entity=$entityId');

    final category = await session.db.transaction((tx) async {
      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lock: true,
        ),
      );
      final sortOrder = await _nextSortOrder(session, entity.id!, tx);

      return Category.db.insertRow(
        session,
        Category(
          entityId: entity.id!,
          name: categoryName,
          sortOrder: sortOrder,
        ),
        transaction: tx,
      );
    });

    await _notify(session, category.entityId);
    return category;
  }

  /// Lists every category of an entity, hidden ones included.
  static Future<List<Category>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    return Category.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.sortOrder, t.id],
    );
  }

  /// Loads one category after checking that the caller owns its entity.
  static Future<Category> getById(
    Session session, {
    required UuidValue categoryId,
  }) async {
    final category = await Category.db.findById(session, categoryId);
    if (category == null) {
      throw NotFoundException(message: 'Category not found');
    }

    await EntityAccess.requireOwned(session, category.entityId);
    return category;
  }

  /// Renames or hides one category without changing its position.
  static Future<Category> update(
    Session session, {
    required UuidValue categoryId,
    String? name,
    bool? isHidden,
  }) async {
    _log.info('Updating category id=$categoryId');

    final updated = await session.db.transaction((tx) async {
      final discovered = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Category not found');
      }

      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );

      final category = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (category == null) {
        throw NotFoundException(message: 'Category not found');
      }
      if (category.entityId != discovered.entityId) {
        throw ValidationException(
          message: 'The category changed concurrently; retry the update',
        );
      }

      return Category.db.updateRow(
        session,
        category.copyWith(
          name: name == null ? null : _requireName(name),
          isHidden: isHidden,
          updatedAt: _now(),
        ),
        transaction: tx,
      );
    });

    await _notify(session, updated.entityId);
    return updated;
  }

  /// Rewrites the entity's category order from an exact list of its ids.
  static Future<List<Category>> reorder(
    Session session, {
    required UuidValue entityId,
    required List<UuidValue> categoryIds,
  }) async {
    _requireNoDuplicates(categoryIds);

    final categories = await session.db.transaction((tx) async {
      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lock: true,
        ),
      );

      final owned = await Category.db.find(
        session,
        where: (t) => t.entityId.equals(entityId),
        orderByList: (t) => [t.id],
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      _requireExactSet(categoryIds, owned);

      final byId = {for (final category in owned) category.id!: category};
      final now = _now();
      final updated = <Category>[];

      for (var index = 0; index < categoryIds.length; index++) {
        updated.add(
          await Category.db.updateRow(
            session,
            byId[categoryIds[index]]!.copyWith(
              sortOrder: index,
              updatedAt: now,
            ),
            transaction: tx,
          ),
        );
      }

      return updated;
    });

    await _notify(session, entityId);
    return categories;
  }

  /// Deletes an empty category.
  ///
  /// A category with any envelope, hidden ones included, is rejected rather
  /// than cascading, because deleting it would silently remove plan history.
  static Future<void> delete(
    Session session, {
    required UuidValue categoryId,
  }) async {
    _log.info('Deleting category id=$categoryId');

    final entityId = await session.db.transaction((tx) async {
      final discovered = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Category not found');
      }

      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lock: true,
        ),
      );

      final category = await Category.db.findById(
        session,
        categoryId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (category == null) {
        throw NotFoundException(message: 'Category not found');
      }
      if (category.entityId != discovered.entityId) {
        throw ValidationException(
          message: 'The category changed concurrently; retry the delete',
        );
      }

      final envelopeCount = await Envelope.db.count(
        session,
        where: (t) => t.categoryId.equals(categoryId),
        transaction: tx,
      );
      if (envelopeCount > 0) {
        throw ValidationException(
          message: 'A category with envelopes cannot be deleted',
        );
      }

      await Category.db.deleteRow(session, category, transaction: tx);
      return category.entityId;
    });

    await _notify(session, entityId);
  }

  static Future<int> _nextSortOrder(
    Session session,
    UuidValue entityId,
    Transaction tx,
  ) async {
    final last = await Category.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderBy: (t) => t.sortOrder.desc(),
      transaction: tx,
    );

    return (last?.sortOrder ?? -1) + 1;
  }

  static String _requireName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      throw ValidationException(message: 'Name is required');
    }

    return name;
  }

  static void _requireNoDuplicates(List<UuidValue> categoryIds) {
    if (categoryIds.toSet().length != categoryIds.length) {
      throw ValidationException(
        message: 'reorder rejects duplicate category ids',
      );
    }
  }

  static void _requireExactSet(
    List<UuidValue> requested,
    List<Category> owned,
  ) {
    final requestedSet = requested.toSet();
    final ownedSet = {for (final category in owned) category.id!};

    if (requestedSet.length != ownedSet.length ||
        !requestedSet.containsAll(ownedSet)) {
      throw ValidationException(
        message: 'reorder needs every category of the entity exactly once',
      );
    }
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects category changes',
      );
    }

    return entity;
  }

  static DateTime _now() => DateTime.now().toUtc();

  static Future<void> _notify(Session session, UuidValue entityId) =>
      EntityRealtimeNotifier.notify(session, entityId, ChangeScope.plan);
}
