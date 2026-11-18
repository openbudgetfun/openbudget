import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Explicit authority for a server job to act for one persisted entity owner.
///
/// Endpoints never accept this type over the wire. Only server-owned work,
/// such as the hourly recurring poster, creates one by reading the entity's
/// stored `ownerId`. It carries no session state, so concurrent jobs for two
/// owners cannot leak authority into each other.
final class SystemEntityOwner {
  const SystemEntityOwner._({
    required this.entityId,
    required this.ownerId,
  });

  /// The entity whose persisted owner is trusted.
  final UuidValue entityId;

  /// The owner read from the persisted entity row.
  final UuidValue ownerId;
}

/// The single ownership boundary for entity-scoped data.
abstract final class EntityAccess {
  /// Requires an authenticated UUID user.
  static UuidValue userId(Session session) {
    final id = session.authenticated?.userIdentifier;
    if (id == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(id);
  }

  /// Reads the persisted owner that a server job may act for.
  ///
  /// This is the narrow seam between an unauthenticated [FutureCallSession]
  /// and [requireOwned]. It reads the row instead of accepting an owner id from
  /// a caller, so an endpoint cannot choose another user's authority.
  /// Builds a [SystemEntityOwner] from an already-loaded entity, without
  /// querying it again.
  static SystemEntityOwner systemOwnerFromEntity(Entity entity) =>
      SystemEntityOwner._(
        entityId: entity.id!,
        ownerId: entity.ownerId,
      );

  static Future<SystemEntityOwner> systemOwnerFor(
    Session session,
    UuidValue entityId, {
    Transaction? transaction,
    LockMode? lockMode,
  }) async {
    final entity = await Entity.db.findById(
      session,
      entityId,
      transaction: transaction,
      lockMode: lockMode,
    );
    if (entity == null) throw NotFoundException();

    return SystemEntityOwner._(
      entityId: entity.id!,
      ownerId: entity.ownerId,
    );
  }

  /// Loads an entity only when the caller owns it.
  ///
  /// [lock] takes a row lock that lasts for the rest of the caller's
  /// transaction. [lockMode] defaults to [LockMode.forNoKeyUpdate] when [lock]
  /// is true; an explicit [lockMode] always wins.
  ///
  /// Every child insert takes PostgreSQL's `FOR KEY SHARE` on its entity row
  /// for the foreign-key check, so entity serialization needs no key lock.
  /// `FOR NO KEY UPDATE` excludes other entity writers and entity row updates
  /// but stays compatible with that check. A `FOR UPDATE` entity lock instead
  /// lets a money writer hold its account and wait for the key share while the
  /// entity holder waits for the account, which PostgreSQL reports as a 40P01
  /// deadlock. Pass [LockMode.forUpdate] only when the caller must also block
  /// new child rows, such as a base-currency change guarded by "this entity
  /// has no transaction yet".
  ///
  /// A [systemOwner] replaces the session's authenticated user for one
  /// server-owned operation. The entity id must match, and the stored owner
  /// still has to match the principal, so the ownership rule is unchanged.
  static Future<Entity> requireOwned(
    Session session,
    UuidValue entityId, {
    Transaction? transaction,
    bool lock = false,
    LockMode? lockMode,
    SystemEntityOwner? systemOwner,
  }) async {
    if (systemOwner != null && systemOwner.entityId != entityId) {
      throw ForbiddenException();
    }

    final owner = systemOwner?.ownerId ?? userId(session);
    final entity = await Entity.db.findById(
      session,
      entityId,
      transaction: transaction,
      lockMode: lockMode ?? (lock ? LockMode.forNoKeyUpdate : null),
    );
    if (entity == null) throw NotFoundException();
    if (entity.ownerId != owner) throw ForbiddenException();
    return entity;
  }
}
