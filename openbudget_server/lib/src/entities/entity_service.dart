import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
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
        // An entity write lock is FOR NO KEY UPDATE, which still admits a
        // child insert's foreign-key key-share check. Upgrade it before the
        // count so a transaction create either commits first and is counted,
        // or waits until this change commits.
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        final count = await session.db.unsafeQuery(
          'SELECT 1 FROM "transaction" WHERE "entityId" = @entityId LIMIT 1',
          parameters: QueryParameters.named({
            'entityId': entityId.toString(),
          }),
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

  /// Exports every record of an owned entity as one portable JSON document.
  ///
  /// Amounts are minor units in the row's own currency: transactions carry
  /// the account currency plus the stored base amount, allocations are in
  /// base currency. Lines travel with their transaction so the document can
  /// be re-imported through the ordinary write path.
  static Future<String> exportData(Session session, UuidValue entityId) async {
    final entity = await EntityAccess.requireOwned(session, entityId);

    final accounts = await Account.db.find(
      session,
      where: (a) => a.entityId.equals(entityId),
      orderBy: (a) => a.sortOrder,
    );
    final categories = await Category.db.find(
      session,
      where: (c) => c.entityId.equals(entityId),
      orderBy: (c) => c.sortOrder,
    );
    final envelopes = await Envelope.db.find(
      session,
      where: (e) => e.entityId.equals(entityId),
      orderBy: (e) => e.categoryId,
    );
    final transactions = await model.Transaction.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderBy: (t) => t.date,
    );
    final transactionIds = transactions
        .where((t) => t.id != null)
        .map((t) => t.id!)
        .toSet();
    final lines = transactionIds.isEmpty
        ? <TransactionLine>[]
        : await TransactionLine.db.find(
            session,
            where: (l) => l.transactionId.inSet(transactionIds),
            orderByList: (l) => [l.transactionId, l.sortOrder],
          );
    final linesByTransaction = <UuidValue, List<TransactionLine>>{};
    for (final line in lines) {
      linesByTransaction.putIfAbsent(line.transactionId, () => []).add(line);
    }
    final payees = await Payee.db.find(
      session,
      where: (p) => p.entityId.equals(entityId),
      orderBy: (p) => p.name,
    );
    final recurring = await RecurringTransaction.db.find(
      session,
      where: (r) => r.entityId.equals(entityId),
      orderBy: (r) => r.nextDate,
    );
    final allocations = await MonthlyAllocation.db.find(
      session,
      where: (a) => a.entityId.equals(entityId),
      orderByList: (a) => [a.month, a.envelopeId],
    );

    final export = <String, dynamic>{
      'exportVersion': 2,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'entity': {
        'id': entity.id?.toString(),
        'name': entity.name,
        'kind': entity.kind.name,
        'countryCode': entity.countryCode,
        'baseCurrencyCode': entity.baseCurrencyCode,
        'timeZone': entity.timeZone,
        'fiscalYearEndMonth': entity.fiscalYearEndMonth,
        'fiscalYearEndDay': entity.fiscalYearEndDay,
        'createdAt': entity.createdAt.toIso8601String(),
      },
      'categories': [
        for (final c in categories)
          {
            'id': c.id?.toString(),
            'name': c.name,
            'sortOrder': c.sortOrder,
            'isHidden': c.isHidden,
          },
      ],
      'envelopes': [
        for (final e in envelopes)
          {
            'id': e.id?.toString(),
            'name': e.name,
            'categoryId': e.categoryId.toString(),
            'note': e.note,
            'taxCategoryCode': e.taxCategoryCode,
            'isHidden': e.isHidden,
          },
      ],
      'accounts': [
        for (final a in accounts)
          {
            'id': a.id?.toString(),
            'name': a.name,
            'kind': a.kind.name,
            'currencyCode': a.currencyCode,
            'balanceSource': a.balanceSource.name,
            'balanceMinor': a.balanceMinor,
            'onBudget': a.onBudget,
            'closedAt': a.closedAt?.toIso8601String(),
          },
      ],
      'transactions': [
        for (final t in transactions)
          {
            'id': t.id?.toString(),
            'accountId': t.accountId.toString(),
            'date': t.date.toIso8601String(),
            'amountMinor': t.amountMinor,
            'baseAmountMinor': t.baseAmountMinor,
            'fxRate': t.fxRate,
            'fxRateDate': t.fxRateDate.toIso8601String(),
            'fxRateSource': t.fxRateSource.name,
            'kind': t.kind.name,
            'status': t.status.name,
            'description': t.description,
            'memo': t.memo,
            'payeeId': t.payeeId?.toString(),
            'lines': [
              for (final TransactionLine line
                  in linesByTransaction[t.id!] ?? const <TransactionLine>[])
                {
                  'amountMinor': line.amountMinor,
                  'baseAmountMinor': line.baseAmountMinor,
                  'envelopeId': line.envelopeId?.toString(),
                  'ledgerAccountId': line.ledgerAccountId?.toString(),
                  'taxCategoryCode': line.taxCategoryCode,
                  'businessUsePercent': line.businessUsePercent,
                  'salesTaxMinor': line.salesTaxMinor,
                  'memo': line.memo,
                  'sortOrder': line.sortOrder,
                },
            ],
          },
      ],
      'payees': [
        for (final p in payees) {'id': p.id?.toString(), 'name': p.name},
      ],
      'recurringTransactions': [
        for (final r in recurring)
          {
            'id': r.id?.toString(),
            'accountId': r.accountId.toString(),
            'description': r.description,
            'amountMinor': r.amountMinor,
            'frequency': r.frequency.name,
            'nextDate': r.nextDate.toIso8601String(),
            'endDate': r.endDate?.toIso8601String(),
            'isActive': r.isActive,
          },
      ],
      'monthlyAllocations': [
        for (final a in allocations)
          {
            'envelopeId': a.envelopeId.toString(),
            'month': a.month,
            'allocatedMinor': a.allocatedMinor,
          },
      ],
    };

    return jsonEncode(export);
  }
}
