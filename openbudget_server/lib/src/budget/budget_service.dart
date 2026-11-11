import 'package:meta/meta.dart';
import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Writes the stored side of the envelope plan.
///
/// Every write locks the entity row first, then the envelopes it names in
/// UUID order, then allocation rows. Envelope deletion and reassignment use
/// the same order, so a plan write and a catalogue change cannot form a lock
/// cycle. Transactions, balances and account rows are never written here.
///
/// A method that returns a view commits its own write first and then reads
/// the view through [BudgetMonthService.month]. The response is therefore one
/// coherent snapshot, and a concurrent write that commits before that read
/// may appear in it.
abstract final class BudgetService {
  /// Runs inside a write transaction after every mutation, before it commits.
  ///
  /// A rollback test uses it to fail deliberately and prove that neither rows
  /// nor change events survive the aborted transaction.
  @visibleForTesting
  static Future<void> Function()? debugBeforeCommit;

  /// Sparse upsert of one month's allocations for the named envelopes.
  ///
  /// A zero deletes that envelope's row; every other value, including a
  /// negative one, replaces the row for that envelope. Envelopes not named
  /// keep their existing allocation. Duplicate ids, foreign envelopes and
  /// unsafe amounts are rejected before the first mutation.
  static Future<BudgetMonthView> setAllocations(
    Session session, {
    required UuidValue entityId,
    required int month,
    required List<AllocationInput> allocations,
  }) async {
    BudgetValidation.requireMonth(month);
    final byEnvelope = <UuidValue, AllocationInput>{};
    for (final input in allocations) {
      BudgetValidation.requireSafeMinor(
        input.allocatedMinor,
        'allocatedMinor',
      );
      if (byEnvelope.containsKey(input.envelopeId)) {
        throw ValidationException(
          message: 'setAllocations rejects duplicate envelope ids',
        );
      }
      byEnvelope[input.envelopeId] = input;
    }

    final outcome = await session.db.transaction((transaction) async {
      final entity = await _lockWritableEntity(
        session,
        entityId,
        transaction,
      );
      await _lockEnvelopes(
        session,
        entity,
        byEnvelope.keys,
        transaction,
      );

      final now = _now();
      final deleted = <UuidValue>{};
      final rows = <MonthlyAllocation>[];
      for (final input in byEnvelope.values) {
        if (input.allocatedMinor == 0) {
          deleted.add(input.envelopeId);
          continue;
        }
        rows.add(
          MonthlyAllocation(
            entityId: _requireId(entity),
            envelopeId: input.envelopeId,
            month: month,
            allocatedMinor: input.allocatedMinor,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (deleted.isNotEmpty) {
        await MonthlyAllocation.db.deleteWhere(
          session,
          where: (t) =>
              t.entityId.equals(entity.id) &
              t.envelopeId.inSet(deleted) &
              t.month.equals(month),
          transaction: transaction,
        );
      }
      if (rows.isNotEmpty) {
        await MonthlyAllocation.db.upsert(
          session,
          rows,
          conflictColumns: (t) => [t.envelopeId, t.month],
          updateColumns: (t) => [t.allocatedMinor, t.updatedAt],
          transaction: transaction,
        );
      }

      await _debugBeforeCommit();
      return (entityId: _requireId(entity), month: month);
    });

    return _committedView(
      session,
      entityId: outcome.entityId,
      month: outcome.month,
    );
  }

  /// Moves a positive amount between two envelopes or between an envelope and
  /// Ready to Assign. A null id means Ready to Assign.
  ///
  /// Both sides change in one transaction. A side that lands on zero loses its
  /// sparse row instead of storing a zero.
  static Future<BudgetMonthView> moveMoney(
    Session session, {
    required UuidValue entityId,
    required int month,
    required UuidValue? fromEnvelopeId,
    required UuidValue? toEnvelopeId,
    required int amountMinor,
  }) async {
    BudgetValidation.requireMonth(month);
    if (amountMinor <= 0) {
      throw ValidationException(message: 'amountMinor must be positive');
    }
    BudgetValidation.requireSafeMinor(amountMinor, 'amountMinor');
    if (fromEnvelopeId == null && toEnvelopeId == null) {
      throw ValidationException(
        message: 'moveMoney needs a source or a destination envelope',
      );
    }
    if (fromEnvelopeId != null && fromEnvelopeId == toEnvelopeId) {
      throw ValidationException(
        message: 'moveMoney needs two different envelopes',
      );
    }

    final outcome = await session.db.transaction((transaction) async {
      final entity = await _lockWritableEntity(
        session,
        entityId,
        transaction,
      );
      final envelopeIds = <UuidValue>{
        ?fromEnvelopeId,
        ?toEnvelopeId,
      };
      await _lockEnvelopes(session, entity, envelopeIds, transaction);

      final existing = await MonthlyAllocation.db.find(
        session,
        where: (t) =>
            t.entityId.equals(entity.id) &
            t.envelopeId.inSet(envelopeIds) &
            t.month.equals(month),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final byEnvelope = {
        for (final row in existing) row.envelopeId: row,
      };

      final deltas = <UuidValue, int>{
        ?fromEnvelopeId: -amountMinor,
        ?toEnvelopeId: amountMinor,
      };
      final ordered = deltas.keys.toList()
        ..sort((first, second) => first.uuid.compareTo(second.uuid));
      final now = _now();

      for (final envelopeId in ordered) {
        final row = byEnvelope[envelopeId];
        final next = BudgetValidation.checkedSum(
          row?.allocatedMinor ?? 0,
          deltas[envelopeId]!,
          'Allocation for envelope $envelopeId',
        );
        if (next == 0) {
          if (row != null) {
            await MonthlyAllocation.db.deleteRow(
              session,
              row,
              transaction: transaction,
            );
          }
          continue;
        }
        if (row == null) {
          await MonthlyAllocation.db.insertRow(
            session,
            MonthlyAllocation(
              entityId: _requireId(entity),
              envelopeId: envelopeId,
              month: month,
              allocatedMinor: next,
              createdAt: now,
              updatedAt: now,
            ),
            transaction: transaction,
          );
        } else {
          await MonthlyAllocation.db.updateRow(
            session,
            row.copyWith(allocatedMinor: next, updatedAt: now),
            transaction: transaction,
          );
        }
      }

      await _debugBeforeCommit();
      return (entityId: _requireId(entity), month: month);
    });

    return _committedView(
      session,
      entityId: outcome.entityId,
      month: outcome.month,
    );
  }

  /// Replaces [toMonth]'s entire allocation set with [fromMonth]'s.
  ///
  /// Rows that exist only in the target month are deleted, not merged. A
  /// self-copy is a safe no-op that still returns the current month view.
  static Future<BudgetMonthView> copyMonth(
    Session session, {
    required UuidValue entityId,
    required int fromMonth,
    required int toMonth,
  }) async {
    BudgetValidation.requireMonth(fromMonth);
    BudgetValidation.requireMonth(toMonth);

    final outcome = await session.db.transaction((transaction) async {
      final entity = await _lockWritableEntity(
        session,
        entityId,
        transaction,
      );

      final source = await MonthlyAllocation.db.find(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(fromMonth),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
      if (fromMonth == toMonth) {
        return (entityId: _requireId(entity), month: toMonth);
      }

      for (final row in source) {
        BudgetValidation.requireSafeMinor(
          row.allocatedMinor,
          'Allocation for month $fromMonth',
        );
      }

      final target = await MonthlyAllocation.db.find(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(toMonth),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
      await _lockEnvelopes(
        session,
        entity,
        {
          for (final row in source) row.envelopeId,
          for (final row in target) row.envelopeId,
        },
        transaction,
      );

      await MonthlyAllocation.db.deleteWhere(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(toMonth),
        transaction: transaction,
      );

      final now = _now();
      final copies = <MonthlyAllocation>[
        for (final row in source)
          if (row.allocatedMinor != 0)
            MonthlyAllocation(
              entityId: _requireId(entity),
              envelopeId: row.envelopeId,
              month: toMonth,
              allocatedMinor: row.allocatedMinor,
              createdAt: now,
              updatedAt: now,
            ),
      ];
      if (copies.isNotEmpty) {
        await MonthlyAllocation.db.insert(
          session,
          copies,
          transaction: transaction,
        );
      }

      await _debugBeforeCommit();
      return (entityId: _requireId(entity), month: toMonth);
    });

    return _committedView(
      session,
      entityId: outcome.entityId,
      month: outcome.month,
    );
  }

  /// Saves the exact sparse allocation set of [month] under [name].
  ///
  /// A name collision creates another template; an existing saved plan is
  /// never overwritten or deleted.
  static Future<BudgetTemplate> saveTemplate(
    Session session, {
    required UuidValue entityId,
    required int month,
    required String name,
  }) async {
    BudgetValidation.requireMonth(month);
    final templateName = name.trim();
    if (templateName.isEmpty) {
      throw ValidationException(message: 'Template name is required');
    }

    final outcome = await session.db.transaction((transaction) async {
      final entity = await _lockWritableEntity(
        session,
        entityId,
        transaction,
      );
      final allocations = await MonthlyAllocation.db.find(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(month),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
      for (final row in allocations) {
        BudgetValidation.requireSafeMinor(
          row.allocatedMinor,
          'Allocation for month $month',
        );
      }

      final now = _now();
      final template = await BudgetTemplate.db.insertRow(
        session,
        BudgetTemplate(
          entityId: _requireId(entity),
          name: templateName,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );
      final lines = <BudgetTemplateLine>[
        for (final row in allocations)
          if (row.allocatedMinor != 0)
            BudgetTemplateLine(
              templateId: _requireId(template),
              envelopeId: row.envelopeId,
              allocatedMinor: row.allocatedMinor,
            ),
      ];
      if (lines.isNotEmpty) {
        await BudgetTemplateLine.db.insert(
          session,
          lines,
          transaction: transaction,
        );
      }

      await _debugBeforeCommit();
      return (entityId: _requireId(entity), template: template);
    });

    await _notify(session, outcome.entityId);
    return outcome.template;
  }

  /// Lists every template of an owned entity in display order.
  static Future<List<BudgetTemplate>> listTemplates(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);
    return BudgetTemplate.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.name, t.id],
    );
  }

  /// Loads one template's lines after checking ownership through its entity.
  static Future<List<BudgetTemplateLine>> getTemplateLines(
    Session session, {
    required UuidValue templateId,
  }) => session.db.transaction(
    (transaction) async {
      final template = await BudgetTemplate.db.findById(
        session,
        templateId,
        transaction: transaction,
      );
      if (template == null) {
        throw NotFoundException(message: 'Budget template not found');
      }
      await EntityAccess.requireOwned(
        session,
        template.entityId,
        transaction: transaction,
      );
      return BudgetTemplateLine.db.find(
        session,
        where: (t) => t.templateId.equals(templateId),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
    },
    settings: const TransactionSettings(
      isolationLevel: IsolationLevel.repeatableRead,
    ),
  );

  /// Replaces [month]'s entire allocation set with the template's lines.
  ///
  /// A template is a complete saved plan, so target-only rows are removed.
  /// Goals, envelopes and transaction lines are untouched; a template with no
  /// lines clears the month's allocations.
  static Future<BudgetMonthView> applyTemplate(
    Session session, {
    required UuidValue templateId,
    required int month,
  }) async {
    BudgetValidation.requireMonth(month);

    final outcome = await session.db.transaction((transaction) async {
      final discovered = await BudgetTemplate.db.findById(
        session,
        templateId,
        transaction: transaction,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Budget template not found');
      }
      final entity = await _lockWritableEntity(
        session,
        discovered.entityId,
        transaction,
      );
      final template = await BudgetTemplate.db.findById(
        session,
        templateId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (template == null) {
        throw NotFoundException(message: 'Budget template not found');
      }
      if (template.entityId != entity.id) {
        throw ValidationException(
          message: 'The template changed concurrently; retry the apply',
        );
      }

      final lines = await BudgetTemplateLine.db.find(
        session,
        where: (t) => t.templateId.equals(templateId),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
      final lineEnvelopes = <UuidValue>{};
      for (final line in lines) {
        if (!lineEnvelopes.add(line.envelopeId)) {
          throw ValidationException(
            message: 'Budget template has a duplicate envelope line',
          );
        }
        BudgetValidation.requireSafeMinor(
          line.allocatedMinor,
          'Template line allocation',
        );
      }

      final target = await MonthlyAllocation.db.find(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(month),
        orderByList: (t) => [t.envelopeId],
        transaction: transaction,
      );
      await _lockEnvelopes(
        session,
        entity,
        {...lineEnvelopes, for (final row in target) row.envelopeId},
        transaction,
      );

      await MonthlyAllocation.db.deleteWhere(
        session,
        where: (t) => t.entityId.equals(entity.id) & t.month.equals(month),
        transaction: transaction,
      );

      final now = _now();
      final rows = <MonthlyAllocation>[
        for (final line in lines)
          if (line.allocatedMinor != 0)
            MonthlyAllocation(
              entityId: _requireId(entity),
              envelopeId: line.envelopeId,
              month: month,
              allocatedMinor: line.allocatedMinor,
              createdAt: now,
              updatedAt: now,
            ),
      ];
      if (rows.isNotEmpty) {
        await MonthlyAllocation.db.insert(
          session,
          rows,
          transaction: transaction,
        );
      }

      await _debugBeforeCommit();
      return (entityId: _requireId(entity), month: month);
    });

    return _committedView(
      session,
      entityId: outcome.entityId,
      month: outcome.month,
    );
  }

  /// Deletes one template and its lines, checking ownership first.
  static Future<void> deleteTemplate(
    Session session, {
    required UuidValue templateId,
  }) async {
    final entityId = await session.db.transaction((transaction) async {
      final discovered = await BudgetTemplate.db.findById(
        session,
        templateId,
        transaction: transaction,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Budget template not found');
      }
      final entity = await _lockWritableEntity(
        session,
        discovered.entityId,
        transaction,
      );
      final template = await BudgetTemplate.db.findById(
        session,
        templateId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (template == null) {
        throw NotFoundException(message: 'Budget template not found');
      }
      if (template.entityId != entity.id) {
        throw ValidationException(
          message: 'The template changed concurrently; retry the delete',
        );
      }
      await BudgetTemplate.db.deleteRow(
        session,
        template,
        transaction: transaction,
      );
      await _debugBeforeCommit();
      return _requireId(entity);
    });

    await _notify(session, entityId);
  }

  /// Publishes the committed change, then reads the latest coherent view.
  ///
  /// The read cannot run inside the write transaction. That transaction is
  /// READ COMMITTED and serializes only the plan rows it locks, so a posting
  /// on another envelope could commit between the view's three aggregates.
  /// Reading after commit gives the response one repeatable-read snapshot
  /// instead; it may include a later committed write.
  static Future<BudgetMonthView> _committedView(
    Session session, {
    required UuidValue entityId,
    required int month,
  }) async {
    await _notify(session, entityId, month: month);
    return BudgetMonthService.month(
      session,
      entityId: entityId,
      month: month,
    );
  }

  static Future<Entity> _lockWritableEntity(
    Session session,
    UuidValue entityId,
    Transaction transaction,
  ) async {
    final entity = await EntityAccess.requireOwned(
      session,
      entityId,
      transaction: transaction,
      lock: true,
    );
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects plan changes',
      );
    }
    return entity;
  }

  static Future<Map<UuidValue, Envelope>> _lockEnvelopes(
    Session session,
    Entity entity,
    Iterable<UuidValue> envelopeIds,
    Transaction transaction,
  ) async {
    final ordered = envelopeIds.toSet().toList()
      ..sort((first, second) => first.uuid.compareTo(second.uuid));
    final locked = <UuidValue, Envelope>{};
    for (final envelopeId in ordered) {
      final envelope = await Envelope.db.findById(
        session,
        envelopeId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (envelope == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      if (envelope.entityId != entity.id) {
        throw ForbiddenException(
          message: 'Envelope belongs to another entity',
        );
      }
      locked[envelopeId] = envelope;
    }
    return locked;
  }

  static Future<void> _debugBeforeCommit() async {
    final hook = debugBeforeCommit;
    if (hook != null) await hook();
  }

  static Future<void> _notify(
    Session session,
    UuidValue entityId, {
    int? month,
  }) => EntityRealtimeNotifier.notify(
    session,
    entityId,
    ChangeScope.plan,
    month: month,
  );

  static DateTime _now() => DateTime.now().toUtc();

  static UuidValue _requireId(Object row) {
    final id = switch (row) {
      Entity(:final id) => id,
      Envelope(:final id) => id,
      BudgetTemplate(:final id) => id,
      _ => throw StateError('Row has no id: $row'),
    };
    if (id == null) throw StateError('A persisted row has no id');
    return id;
  }
}
