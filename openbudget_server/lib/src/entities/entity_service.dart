import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/settings/user_settings_service.dart';
import 'package:serverpod/serverpod.dart';

/// Owns entity lifecycle and immutable tenancy boundaries.
abstract final class EntityService {
  static void _validate(String name, String zone, int month, int day) {
    if (name.trim().isEmpty) {
      throw ValidationException(message: 'Name is required');
    }
    EntityClock.location(zone);
    final date = DateTime.utc(2000, month, day);
    if (date.month != month || date.day != day) {
      throw ValidationException(message: 'Invalid fiscal year end');
    }
  }

  static Future<void> _validateLink(
    Session session,
    UuidValue? linkedId,
    Transaction tx,
  ) async {
    if (linkedId == null) return;
    final linked = await EntityAccess.requireOwned(
      session,
      linkedId,
      transaction: tx,
    );
    if (linked.kind != EntityKind.individual) {
      throw ValidationException(
        message: 'Link must refer to a personal entity',
      );
    }
  }

  /// Creates the entity and its initial user preferences atomically.
  static Future<Entity> create(
    Session session,
    String name,
    EntityKind kind,
    String countryCode,
    String baseCurrencyCode,
    String timeZone, {
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    UuidValue? linkedPersonalEntityId,
  }) async {
    final country = countryCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      throw ValidationException(message: 'Country must be an ISO alpha-2 code');
    }
    final currency = requireSupportedCurrency(baseCurrencyCode);
    final defaults = defaultFiscalYearEnd(country, kind);
    final month = fiscalYearEndMonth ?? defaults.month;
    final day = fiscalYearEndDay ?? defaults.day;
    _validate(name, timeZone, month, day);
    final entity = await session.db.transaction((tx) async {
      await _validateLink(session, linkedPersonalEntityId, tx);
      final created = await Entity.db.insertRow(
        session,
        Entity(
          ownerId: EntityAccess.userId(session),
          name: name.trim(),
          kind: kind,
          countryCode: country,
          baseCurrencyCode: currency,
          timeZone: timeZone,
          fiscalYearEndMonth: month,
          fiscalYearEndDay: day,
          includeInNetWorth: kind != EntityKind.company,
          linkedPersonalEntityId: linkedPersonalEntityId,
        ),
        transaction: tx,
      );
      await UserSettingsService.get(session, transaction: tx);
      return created;
    });
    await EntityRealtimeNotifier.notify(
      session,
      entity.id!,
      ChangeScope.entity,
    );
    return entity;
  }

  /// Lists only the caller's entities in display order.
  static Future<List<Entity>> list(
    Session session, {
    bool includeArchived = false,
  }) => Entity.db.find(
    session,
    where: (t) =>
        t.ownerId.equals(EntityAccess.userId(session)) &
        (includeArchived ? Constant.bool(true) : t.archivedAt.equals(null)),
    orderByList: (t) => [t.sortOrder, t.id],
  );

  /// Updates mutable fields while serializing with money writers.
  static Future<Entity> update(
    Session session,
    UuidValue entityId, {
    String? name,
    String? baseCurrencyCode,
    String? timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
    bool? includeInNetWorth,
    UuidValue? linkedPersonalEntityId,
    bool clearLinkedPersonalEntity = false,
    int? sortOrder,
  }) async {
    final result = await session.db.transaction((tx) async {
      final old = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      );
      final currency = baseCurrencyCode == null
          ? old.baseCurrencyCode
          : requireSupportedCurrency(baseCurrencyCode);
      if (currency != old.baseCurrencyCode) {
        final count = await session.db.unsafeQuery(
          'SELECT 1 FROM "transaction" WHERE "entityId" = @entityId LIMIT 1',
          parameters: QueryParameters.named({'entityId': entityId}),
          transaction: tx,
        );
        if (count.isNotEmpty) {
          throw ValidationException(
            message: 'Base currency is fixed after the first transaction',
          );
        }
      }
      await _validateLink(session, linkedPersonalEntityId, tx);
      final changed = old.copyWith(
        name: name?.trim() ?? old.name,
        baseCurrencyCode: currency,
        timeZone: timeZone ?? old.timeZone,
        fiscalYearEndMonth: fiscalYearEndMonth ?? old.fiscalYearEndMonth,
        fiscalYearEndDay: fiscalYearEndDay ?? old.fiscalYearEndDay,
        includeInNetWorth: includeInNetWorth ?? old.includeInNetWorth,
        linkedPersonalEntityId: clearLinkedPersonalEntity
            ? null
            : linkedPersonalEntityId ?? old.linkedPersonalEntityId,
        sortOrder: sortOrder ?? old.sortOrder,
        updatedAt: DateTime.now().toUtc(),
      );
      _validate(
        changed.name,
        changed.timeZone,
        changed.fiscalYearEndMonth,
        changed.fiscalYearEndDay,
      );
      return Entity.db.updateRow(session, changed, transaction: tx);
    });
    await EntityRealtimeNotifier.notify(session, entityId, ChangeScope.entity);
    return result;
  }

  /// Archives or restores an owned entity.
  static Future<Entity> setArchived(
    Session session,
    UuidValue entityId, {
    required bool archived,
  }) async {
    final result = await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      );
      return Entity.db.updateRow(
        session,
        entity.copyWith(
          archivedAt: archived ? DateTime.now().toUtc() : null,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
    });
    await EntityRealtimeNotifier.notify(session, entityId, ChangeScope.entity);
    return result;
  }

  /// Deletes the ownership tree only after exact name confirmation.
  static Future<void> delete(
    Session session,
    UuidValue entityId,
    String confirmName,
  ) async {
    await session.db.transaction((tx) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      );
      if (confirmName != entity.name) {
        throw ValidationException(
          message: 'Type the exact entity name to confirm deletion',
        );
      }
      await Entity.db.deleteRow(session, entity, transaction: tx);
    });
    await EntityRealtimeNotifier.notify(session, entityId, ChangeScope.entity);
  }
}
