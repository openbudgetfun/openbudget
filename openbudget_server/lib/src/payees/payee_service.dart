import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// Owns payee lifecycle within one entity.
///
/// Every read and write crosses [EntityAccess], so a payee is visible only to
/// the owner of its entity. A payee name is unique per entity. Creation reuses
/// an existing payee with the same trimmed name, which is the same policy
/// [TransactionWriter] applies to `TransactionInput.payeeName`, so retrying a
/// create or two concurrent creates leave exactly one row.
///
/// Payee changes are transaction metadata. [merge] and [delete] move or clear
/// transaction references through [TransactionWriter.reassignPayee], never by
/// writing transaction rows here, so lines, amounts, FX, base totals, status,
/// revision, transfer links and cached balances stay exactly as they were.
abstract final class PayeeService {
  static final _log = ObLogger('PayeeService');

  /// Creates a payee, or returns the entity's payee with the same name.
  ///
  /// The insert uses `ON CONFLICT ("entityId", name) DO NOTHING` and then
  /// selects, so the unique index settles a race without a raw database error.
  static Future<Payee> create(
    Session session, {
    required String name,
    required UuidValue entityId,
  }) async {
    final payeeName = _requireName(name);

    _log.info('Creating payee name=$payeeName entity=$entityId');

    final payee = await session.db.transaction((tx) async {
      _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      await session.db.unsafeExecute(
        'INSERT INTO payee ("entityId", name, "createdAt") '
        'VALUES (@entityId::uuid, @name, now()) '
        'ON CONFLICT ("entityId", name) DO NOTHING',
        parameters: QueryParameters.named({
          'entityId': entityId.toString(),
          'name': payeeName,
        }),
        transaction: tx,
      );

      final row = await Payee.db.findFirstRow(
        session,
        where: (t) => t.entityId.equals(entityId) & t.name.equals(payeeName),
        transaction: tx,
      );
      if (row == null) {
        throw StateError('Payee upsert did not produce a row');
      }

      return row;
    });

    await _notify(session, payee.entityId);
    return payee;
  }

  /// Lists every payee of an entity, ordered by name and then id.
  static Future<List<Payee>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    return Payee.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.name, t.id],
    );
  }

  /// Loads one payee after checking that the caller owns its entity.
  static Future<Payee> getById(
    Session session, {
    required UuidValue payeeId,
  }) async {
    final payee = await Payee.db.findById(session, payeeId);
    if (payee == null) {
      throw NotFoundException(message: 'Payee not found');
    }

    await EntityAccess.requireOwned(session, payee.entityId);
    return payee;
  }

  /// Renames one payee.
  ///
  /// A name already used by another payee of the entity rejects the update.
  /// The pre-check gives the common case a domain error, and the unique index
  /// settles a concurrent rename: the losing transaction rolls back and is
  /// reported the same way instead of leaking a database error.
  static Future<Payee> update(
    Session session, {
    required UuidValue payeeId,
    String? name,
  }) async {
    _log.info('Updating payee id=$payeeId');

    final Payee updated;
    try {
      updated = await session.db.transaction((tx) async {
        final discovered = await Payee.db.findById(
          session,
          payeeId,
          transaction: tx,
        );
        if (discovered == null) {
          throw NotFoundException(message: 'Payee not found');
        }

        _requireWritable(
          await EntityAccess.requireOwned(
            session,
            discovered.entityId,
            transaction: tx,
            lockMode: LockMode.forNoKeyUpdate,
          ),
        );

        final payee = await Payee.db.findById(
          session,
          payeeId,
          transaction: tx,
          lockMode: LockMode.forUpdate,
        );
        if (payee == null) {
          throw NotFoundException(message: 'Payee not found');
        }
        if (payee.entityId != discovered.entityId) {
          throw ValidationException(
            message: 'The payee changed concurrently; retry the update',
          );
        }

        final payeeName = name == null ? payee.name : _requireName(name);
        if (payeeName != payee.name) {
          await _rejectDuplicateName(
            session,
            entityId: payee.entityId,
            name: payeeName,
            exceptPayeeId: payee.id!,
            transaction: tx,
          );
        }

        return Payee.db.updateRow(
          session,
          payee.copyWith(name: payeeName),
          transaction: tx,
        );
      });
    } on DatabaseUniqueViolationException {
      throw ValidationException(
        message: 'A payee with this name already exists',
      );
    }

    await _notify(session, updated.entityId);
    return updated;
  }

  /// Returns the envelope used by the payee's most recent coded transaction.
  ///
  /// The lookup is one bounded query: the latest transaction by `(date, id)`
  /// wins, and a split transaction resolves to its largest absolute line, then
  /// the lowest envelope id and line id. It returns null when the payee has no
  /// transaction with an envelope, including a payee with no history at all.
  static Future<UuidValue?> lastUsedEnvelopeId(
    Session session, {
    required UuidValue payeeId,
    required UuidValue entityId,
  }) async {
    final payee = await Payee.db.findById(session, payeeId);
    if (payee == null || payee.entityId != entityId) {
      throw NotFoundException(message: 'Payee not found');
    }

    await EntityAccess.requireOwned(session, entityId);

    final rows = await session.db.unsafeQuery(
      '''
SELECT l."envelopeId"::text AS "envelopeId"
FROM "transaction" t
JOIN transaction_line l ON l."transactionId" = t.id
WHERE t."payeeId" = @payeeId::uuid
  AND t."entityId" = @entityId::uuid
  AND l."envelopeId" IS NOT NULL
ORDER BY t.date DESC, t.id DESC, abs(l."amountMinor") DESC,
  l."envelopeId" ASC, l.id ASC
LIMIT 1
''',
      parameters: QueryParameters.named({
        'payeeId': payeeId.toString(),
        'entityId': entityId.toString(),
      }),
    );

    if (rows.isEmpty) return null;

    final envelopeId = UuidValue.fromString(rows.first.first as String);
    final envelope = await Envelope.db.findById(session, envelopeId);
    if (envelope == null || envelope.entityId != entityId) {
      throw ValidationException(
        message: 'A transaction line points at an envelope of another entity',
      );
    }

    return envelopeId;
  }

  /// Merges [sourcePayeeId] into [targetPayeeId] and deletes the source.
  ///
  /// Both payees must belong to one entity. Transactions, recurring schedules
  /// and rules move in one database transaction, so a rejected merge changes
  /// nothing. A payee rule conflict is rejected rather than guessed:
  /// - different destination envelopes reject the merge;
  /// - the same envelope with a different `enabled` state rejects the merge;
  /// - identical rules collapse to the target's rule without loss.
  ///
  /// Returns the number of transaction headers whose payee moved.
  static Future<int> merge(
    Session session, {
    required UuidValue sourcePayeeId,
    required UuidValue targetPayeeId,
  }) async {
    if (sourcePayeeId == targetPayeeId) {
      throw ValidationException(message: 'A payee cannot merge into itself');
    }

    _log.info('Merging payee source=$sourcePayeeId target=$targetPayeeId');

    final outcome = await TransactionWriter.inTransaction(session, (tx) async {
      final source = await Payee.db.findById(
        session,
        sourcePayeeId,
        transaction: tx,
      );
      final target = await Payee.db.findById(
        session,
        targetPayeeId,
        transaction: tx,
      );
      if (source == null || target == null) {
        throw NotFoundException(message: 'Payee not found');
      }
      if (source.entityId != target.entityId) {
        throw ValidationException(
          message: 'Payees must belong to the same entity',
        );
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          source.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      // The entity row is locked, which serialises every payee-family write:
      // merge, delete, rename and rule changes all take it first. Re-read the
      // two payees under that lock; the writer hierarchy stays accounts then
      // rows, so a concurrent transaction write cannot deadlock with this one.
      final sourceRow = await Payee.db.findById(
        session,
        sourcePayeeId,
        transaction: tx,
      );
      final targetRow = await Payee.db.findById(
        session,
        targetPayeeId,
        transaction: tx,
      );
      if (sourceRow == null || targetRow == null) {
        throw NotFoundException(message: 'Payee not found');
      }
      if (sourceRow.entityId != entity.id || targetRow.entityId != entity.id) {
        throw ValidationException(
          message: 'A payee changed concurrently; retry the merge',
        );
      }

      await _resolveRulesForMerge(
        session,
        entity: entity,
        source: sourceRow,
        target: targetRow,
        transaction: tx,
      );
      await _moveRecurringPayees(
        session,
        entity: entity,
        source: sourceRow,
        target: targetRow,
        transaction: tx,
      );

      final changed = await TransactionWriter.reassignPayee(
        session,
        entityId: entity.id!,
        fromPayeeId: sourceRow.id!,
        toPayeeId: targetRow.id,
        transaction: tx,
      );

      await Payee.db.deleteRow(session, sourceRow, transaction: tx);
      return (entityId: entity.id!, changed: changed);
    });

    await _notify(session, outcome.entityId);
    return outcome.changed;
  }

  /// Deletes a payee and clears every reference to it.
  ///
  /// The outcome matches the schema's foreign keys: transactions and recurring
  /// schedules lose the payee, and the payee's rule disappears. Transaction
  /// references are cleared through [TransactionWriter.reassignPayee] so the
  /// rows and their change events follow the writer contract; financial facts
  /// are preserved.
  static Future<Payee> delete(
    Session session, {
    required UuidValue payeeId,
  }) async {
    _log.info('Deleting payee id=$payeeId');

    final outcome = await TransactionWriter.inTransaction(session, (tx) async {
      final discovered = await Payee.db.findById(
        session,
        payeeId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Payee not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final payee = await Payee.db.findById(
        session,
        payeeId,
        transaction: tx,
      );
      if (payee == null) {
        throw NotFoundException(message: 'Payee not found');
      }
      if (payee.entityId != entity.id) {
        throw ValidationException(
          message: 'The payee changed concurrently; retry the delete',
        );
      }

      await TransactionWriter.reassignPayee(
        session,
        entityId: entity.id!,
        fromPayeeId: payeeId,
        toPayeeId: null,
        transaction: tx,
      );
      await _clearRecurringPayees(
        session,
        entity: entity,
        payee: payee,
        transaction: tx,
      );
      await _deleteRules(
        session,
        entity: entity,
        payee: payee,
        transaction: tx,
      );

      await Payee.db.deleteRow(session, payee, transaction: tx);
      return (entityId: entity.id!, payee: payee);
    });

    await _notify(session, outcome.entityId);
    return outcome.payee;
  }

  static Future<void> _resolveRulesForMerge(
    Session session, {
    required Entity entity,
    required Payee source,
    required Payee target,
    required Transaction transaction,
  }) async {
    final rules = await TransactionRule.db.find(
      session,
      where: (t) => t.payeeId.inSet({source.id!, target.id!}),
      orderByList: (t) => [t.payeeId, t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );

    TransactionRule? sourceRule;
    TransactionRule? targetRule;
    for (final rule in rules) {
      if (rule.entityId != entity.id) {
        throw ValidationException(
          message: 'A transaction rule belongs to another entity',
        );
      }
      if (rule.payeeId == source.id) {
        sourceRule = rule;
      } else if (rule.payeeId == target.id) {
        targetRule = rule;
      }
    }

    if (sourceRule == null) return;

    if (targetRule == null) {
      await TransactionRule.db.updateRow(
        session,
        sourceRule.copyWith(payeeId: target.id),
        transaction: transaction,
      );
      return;
    }

    if (sourceRule.envelopeId != targetRule.envelopeId) {
      throw ValidationException(
        message:
            'The payees have rules for different envelopes; align them before '
            'merging',
      );
    }
    if (sourceRule.enabled != targetRule.enabled) {
      throw ValidationException(
        message:
            'The payees have rules with different enabled states; align them '
            'before merging',
      );
    }

    await TransactionRule.db.deleteRow(
      session,
      sourceRule,
      transaction: transaction,
    );
  }

  static Future<void> _moveRecurringPayees(
    Session session, {
    required Entity entity,
    required Payee source,
    required Payee target,
    required Transaction transaction,
  }) async {
    final rows = await RecurringTransaction.db.find(
      session,
      where: (t) => t.payeeId.equals(source.id),
      orderByList: (t) => [t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );

    for (final row in rows) {
      if (row.entityId != entity.id) {
        throw ValidationException(
          message: 'A recurring transaction belongs to another entity',
        );
      }
      await RecurringTransaction.db.updateRow(
        session,
        row.copyWith(payeeId: target.id),
        transaction: transaction,
      );
    }
  }

  static Future<void> _clearRecurringPayees(
    Session session, {
    required Entity entity,
    required Payee payee,
    required Transaction transaction,
  }) async {
    final rows = await RecurringTransaction.db.find(
      session,
      where: (t) => t.payeeId.equals(payee.id),
      orderByList: (t) => [t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );

    for (final row in rows) {
      if (row.entityId != entity.id) {
        throw ValidationException(
          message: 'A recurring transaction belongs to another entity',
        );
      }
      await RecurringTransaction.db.updateRow(
        session,
        row.copyWith(payeeId: null),
        transaction: transaction,
      );
    }
  }

  static Future<void> _deleteRules(
    Session session, {
    required Entity entity,
    required Payee payee,
    required Transaction transaction,
  }) async {
    final rules = await TransactionRule.db.find(
      session,
      where: (t) => t.payeeId.equals(payee.id),
      orderByList: (t) => [t.id],
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );

    for (final rule in rules) {
      if (rule.entityId != entity.id) {
        throw ValidationException(
          message: 'A transaction rule belongs to another entity',
        );
      }
      await TransactionRule.db.deleteRow(
        session,
        rule,
        transaction: transaction,
      );
    }
  }

  static Future<void> _rejectDuplicateName(
    Session session, {
    required UuidValue entityId,
    required String name,
    required UuidValue exceptPayeeId,
    required Transaction transaction,
  }) async {
    final duplicate = await Payee.db.findFirstRow(
      session,
      where: (t) =>
          t.entityId.equals(entityId) &
          t.name.equals(name) &
          t.id.notEquals(exceptPayeeId),
      transaction: transaction,
    );
    if (duplicate != null) {
      throw ValidationException(
        message: 'A payee with this name already exists',
      );
    }
  }

  static String _requireName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      throw ValidationException(message: 'Name is required');
    }

    return name;
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects payee changes',
      );
    }

    return entity;
  }

  static Future<void> _notify(Session session, UuidValue entityId) =>
      EntityRealtimeNotifier.notify(
        session,
        entityId,
        ChangeScope.transactions,
      );
}
