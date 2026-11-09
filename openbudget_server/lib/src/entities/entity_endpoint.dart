import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Entity lifecycle for the signed-in owner.
class EntityEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates an entity with country fiscal defaults.
  Future<Entity> create(
    Session session,
    String name,
    EntityKind kind,
    String countryCode,
    String baseCurrencyCode,
    String timeZone, {
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    UuidValue? linkedPersonalEntityId,
  }) => EntityService.create(
    session,
    name,
    kind,
    countryCode,
    baseCurrencyCode,
    timeZone,
    fiscalYearEndMonth: fiscalYearEndMonth,
    fiscalYearEndDay: fiscalYearEndDay,
    linkedPersonalEntityId: linkedPersonalEntityId,
  );

  /// Lists entities owned by the caller.
  Future<List<Entity>> list(Session session, {bool? includeArchived}) =>
      EntityService.list(session, includeArchived: includeArchived ?? false);

  /// Loads one owned entity.
  Future<Entity> get(Session session, UuidValue entityId) =>
      EntityAccess.requireOwned(session, entityId);

  /// Updates mutable entity properties.
  Future<Entity> update(
    Session session,
    UuidValue entityId, {
    String? name,
    String? baseCurrencyCode,
    String? timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    UuidValue? linkedPersonalEntityId,
    bool? clearLinkedPersonalEntity,
    int? sortOrder,
  }) => EntityService.update(
    session,
    entityId,
    name: name,
    baseCurrencyCode: baseCurrencyCode,
    timeZone: timeZone,
    fiscalYearEndMonth: fiscalYearEndMonth,
    fiscalYearEndDay: fiscalYearEndDay,
    includeInNetWorth: includeInNetWorth,
    linkedPersonalEntityId: linkedPersonalEntityId,
    clearLinkedPersonalEntity: clearLinkedPersonalEntity ?? false,
    sortOrder: sortOrder,
  );

  /// Hides an entity from active lists.
  Future<Entity> archive(Session session, UuidValue entityId) =>
      EntityService.setArchived(session, entityId, archived: true);

  /// Restores an entity to active lists.
  Future<Entity> unarchive(Session session, UuidValue entityId) =>
      EntityService.setArchived(session, entityId, archived: false);

  /// Requires an exact name confirmation for every entity, including ledger mode.
  Future<void> delete(
    Session session,
    UuidValue entityId,
    String confirmName,
  ) => EntityService.delete(session, entityId, confirmName);
}
