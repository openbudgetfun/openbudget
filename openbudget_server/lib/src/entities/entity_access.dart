import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// The single ownership boundary for entity-scoped data.
abstract final class EntityAccess {
  /// Requires an authenticated UUID user.
  static UuidValue userId(Session session) {
    final id = session.authenticated?.userIdentifier;
    if (id == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(id);
  }

  /// Loads an entity only when the caller owns it.
  static Future<Entity> requireOwned(
    Session session,
    UuidValue entityId, {
    Transaction? transaction,
    bool lock = false,
  }) async {
    final owner = userId(session);
    final entity = await Entity.db.findById(
      session,
      entityId,
      transaction: transaction,
      lockMode: lock ? LockMode.forUpdate : null,
    );
    if (entity == null) throw NotFoundException();
    if (entity.ownerId != owner) throw ForbiddenException();
    return entity;
  }
}
