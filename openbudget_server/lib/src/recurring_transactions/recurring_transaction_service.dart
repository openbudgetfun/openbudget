import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// Owns recurring schedules within one entity.
///
/// A schedule is a future fact, not a transaction: every write crosses
/// [EntityAccess], and every posted occurrence goes through
/// [TransactionWriter] with the schedule's stable occurrence id. The writer
/// therefore stores the real FX rate, line, payee and rule semantics, and a
/// failed occurrence leaves neither a transaction nor an advanced schedule.
abstract final class RecurringTransactionService {
  static final _log = ObLogger('RecurringTransactionService');

  /// The most occurrences one schedule catches up in one call.
  ///
  /// A daily schedule that has been due for years behind a restored backup is
  /// worked down across hourly runs instead of holding one database
  /// transaction open indefinitely. Every run stops at this documented bound.
  static const maxOccurrencesPerRun = 100;

  /// Creates a schedule for a transactions-sourced account.
  static Future<RecurringTransaction> create(
    Session session, {
    required UuidValue accountId,
    required String description,
    required int amountMinor,
    required RecurrenceFrequency frequency,
    required DateTime nextDate,
    UuidValue? payeeId,
    UuidValue? envelopeId,
    String? memo,
    DateTime? endDate,
  }) async {
    final scheduleDescription = _requireDescription(description);
    _requireAmount(amountMinor);
    final scheduleDate = _requireCivilDate(nextDate, 'nextDate');
    final requestedEnd = endDate == null
        ? null
        : _requireCivilDate(endDate, 'endDate');
    final scheduleEnd = _requireEndDate(requestedEnd, scheduleDate);

    _log.info('Creating recurring transaction account=$accountId');

    final result = await session.db.transaction((tx) async {
      final discovered = await Account.db.findById(
        session,
        accountId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Account not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );
      final account = await _lockPostingAccount(
        session,
        accountId: accountId,
        entityId: entity.id!,
        transaction: tx,
      );

      await _requirePayee(
        session,
        entityId: entity.id!,
        payeeId: payeeId,
        transaction: tx,
      );
      await _requireEnvelope(
        session,
        entityId: entity.id!,
        envelopeId: envelopeId,
        transaction: tx,
      );

      final now = DateTime.now().toUtc();
      final schedule = await RecurringTransaction.db.insertRow(
        session,
        RecurringTransaction(
          entityId: entity.id!,
          accountId: account.id!,
          payeeId: payeeId,
          envelopeId: envelopeId,
          description: scheduleDescription,
          memo: _normaliseMemo(memo),
          amountMinor: amountMinor,
          frequency: frequency,
          nextDate: scheduleDate,
          endDate: scheduleEnd,
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );

      return (schedule, entity.id!);
    });

    await _notify(session, result.$2);
    return result.$1;
  }

  /// Lists every schedule of an owned entity in due-date order.
  static Future<List<RecurringTransaction>> list(
    Session session, {
    required UuidValue entityId,
  }) async {
    await EntityAccess.requireOwned(session, entityId);

    return RecurringTransaction.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.nextDate, t.id],
    );
  }

  /// Loads one schedule after checking that the caller owns its entity.
  static Future<RecurringTransaction> getById(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    final schedule = await RecurringTransaction.db.findById(
      session,
      recurringTransactionId,
    );
    if (schedule == null) {
      throw NotFoundException(message: 'Recurring transaction not found');
    }

    await EntityAccess.requireOwned(session, schedule.entityId);
    return schedule;
  }

  /// Updates the §7.1 named fields.
  ///
  /// [clearPayee], [clearEnvelope] and [clearEndDate] distinguish an omitted
  /// reference from one the user removed. A blank memo clears it, matching the
  /// app's other nullable notes.
  static Future<RecurringTransaction> update(
    Session session, {
    required UuidValue recurringTransactionId,
    UuidValue? accountId,
    String? description,
    int? amountMinor,
    RecurrenceFrequency? frequency,
    DateTime? nextDate,
    UuidValue? payeeId,
    bool clearPayee = false,
    UuidValue? envelopeId,
    bool clearEnvelope = false,
    String? memo,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isActive,
  }) async {
    if (payeeId != null && clearPayee) {
      throw ValidationException(
        message: 'A payee update cannot also clear the payee',
      );
    }

    if (envelopeId != null && clearEnvelope) {
      throw ValidationException(
        message: 'An envelope update cannot also clear the envelope',
      );
    }

    if (endDate != null && clearEndDate) {
      throw ValidationException(
        message: 'An end date update cannot also clear the end date',
      );
    }

    if (description != null) _requireDescription(description);
    if (amountMinor != null) _requireAmount(amountMinor);
    if (nextDate != null) _requireCivilDate(nextDate, 'nextDate');
    if (endDate != null) _requireCivilDate(endDate, 'endDate');

    _log.info('Updating recurring transaction id=$recurringTransactionId');

    final result = await session.db.transaction((tx) async {
      final discovered = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final nextAccountId = accountId ?? discovered.accountId;
      final accounts = await _lockAccounts(
        session,
        {discovered.accountId, nextAccountId},
        tx,
      );

      // The account lock comes before the schedule row, the same order the
      // hourly poster and TransactionWriter use. Re-read after the lock so a
      // concurrent post that advanced the date is preserved.
      final current = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
      );
      if (current == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }
      if (current.entityId != entity.id ||
          current.accountId != discovered.accountId) {
        throw ValidationException(
          message:
              'The recurring transaction changed concurrently; retry the '
              'update',
        );
      }

      final targetAccount = accounts[nextAccountId];
      if (targetAccount == null) {
        throw NotFoundException(message: 'Account not found');
      }
      _requirePostingAccount(targetAccount, entity.id!);

      await _requirePayee(
        session,
        entityId: entity.id!,
        payeeId: payeeId,
        transaction: tx,
      );
      await _requireEnvelope(
        session,
        entityId: entity.id!,
        envelopeId: envelopeId,
        transaction: tx,
      );

      final nextDescription = description == null
          ? current.description
          : _requireDescription(description);
      final nextScheduleDate = nextDate == null
          ? current.nextDate
          : _requireCivilDate(nextDate, 'nextDate');
      final nextScheduleEnd = clearEndDate
          ? null
          : endDate == null
          ? current.endDate
          : _requireCivilDate(endDate, 'endDate');
      _requireEndDate(nextScheduleEnd, nextScheduleDate);

      final nextPayeeId = clearPayee ? null : payeeId ?? current.payeeId;
      final nextEnvelopeId = clearEnvelope
          ? null
          : envelopeId ?? current.envelopeId;
      final nextMemo = memo == null ? current.memo : _normaliseMemo(memo);

      final updated = await RecurringTransaction.db.updateRow(
        session,
        current.copyWith(
          accountId: nextAccountId,
          payeeId: nextPayeeId,
          envelopeId: nextEnvelopeId,
          description: nextDescription,
          memo: nextMemo,
          amountMinor: amountMinor ?? current.amountMinor,
          frequency: frequency ?? current.frequency,
          nextDate: nextScheduleDate,
          endDate: nextScheduleEnd,
          isActive: isActive ?? current.isActive,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );

      return (updated, entity.id!);
    });

    await _notify(session, result.$2);
    return result.$1;
  }

  /// Deletes the schedule, leaving every posted transaction in place.
  ///
  /// `transaction.recurringTransactionId` is set to null by the schema's
  /// foreign key, so deleting a configuration never deletes financial facts.
  static Future<RecurringTransaction> delete(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    _log.info('Deleting recurring transaction id=$recurringTransactionId');

    final result = await session.db.transaction((tx) async {
      final discovered = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final schedule = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (schedule == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }
      if (schedule.entityId != entity.id) {
        throw ValidationException(
          message:
              'The recurring transaction changed concurrently; retry the '
              'delete',
        );
      }

      await RecurringTransaction.db.deleteRow(
        session,
        schedule,
        transaction: tx,
      );
      return (schedule, entity.id!);
    });

    await _notify(session, result.$2);
    return result.$1;
  }

  /// Advances the schedule by exactly one occurrence without posting it.
  static Future<RecurringTransaction> skipOccurrence(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    final result = await session.db.transaction((tx) async {
      final discovered = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }

      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          discovered.entityId,
          transaction: tx,
          lockMode: LockMode.forNoKeyUpdate,
        ),
      );

      final schedule = await RecurringTransaction.db.findById(
        session,
        recurringTransactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (schedule == null) {
        throw NotFoundException(message: 'Recurring transaction not found');
      }
      if (schedule.entityId != entity.id) {
        throw ValidationException(
          message:
              'The recurring transaction changed concurrently; retry the skip',
        );
      }
      if (!schedule.isActive) {
        throw ValidationException(
          message: 'An inactive recurring transaction cannot skip',
        );
      }

      final next = nextOccurrence(
        schedule.frequency,
        schedule.nextDate,
        schedule.nextDate,
      );
      final remainsActive =
          schedule.endDate == null || !next.isAfter(schedule.endDate!);

      return (
        await RecurringTransaction.db.updateRow(
          session,
          schedule.copyWith(
            nextDate: next,
            isActive: remainsActive,
            updatedAt: DateTime.now().toUtc(),
          ),
          transaction: tx,
        ),
        entity.id!,
      );
    });

    await _notify(session, result.$2);
    return result.$1;
  }

  /// Posts every due occurrence for one owned entity.
  ///
  /// Each occurrence is one transaction: the [TransactionWriter] insert and
  /// the schedule advance commit together. A domain failure rolls back only
  /// that occurrence and propagates to the caller; the schedule stays due for
  /// a later retry. Returns the number of transactions actually inserted.
  static Future<int> postDue(
    Session session, {
    required UuidValue entityId,
  }) async {
    final report = await _postDue(
      session,
      entityId: entityId,
      continueOnError: false,
    );
    return report.posted;
  }

  /// Posts due occurrences for an unauthenticated server job.
  ///
  /// The [systemOwner] carries the persisted owner read by the future call.
  /// Failures are logged and counted so one broken schedule cannot stop the
  /// rest of the sweep; every failed occurrence stays due for the next run.
  static Future<({int posted, int failed})> postDueForSystemJob(
    Session session, {
    required UuidValue entityId,
    required SystemEntityOwner systemOwner,
  }) => _postDue(
    session,
    entityId: entityId,
    systemOwner: systemOwner,
    continueOnError: true,
  );

  /// Counts active schedules with an occurrence due on the entity's today.
  ///
  /// This matches the previous per-schedule contract: a schedule that catches
  /// up several dates is still one due row, and an end date that has no
  /// remaining occurrence is not due.
  static Future<int> countDue(
    Session session, {
    required UuidValue entityId,
  }) async {
    final entity = await EntityAccess.requireOwned(session, entityId);
    final today = EntityClock.today(entity);

    final rows = await session.db.unsafeQuery(
      '''
SELECT count(*)::bigint
FROM recurring_transaction
WHERE "entityId" = @entityId::uuid
  AND "isActive"
  AND "nextDate" <= @today
  AND ("endDate" IS NULL OR "nextDate" <= "endDate")
''',
      parameters: QueryParameters.named({
        'entityId': entityId.toString(),
        'today': today,
      }),
    );

    return rows.first.first as int;
  }

  static Future<({int posted, int failed})> _postDue(
    Session session, {
    required UuidValue entityId,
    required bool continueOnError,
    SystemEntityOwner? systemOwner,
  }) async {
    final entity = _requireWritable(
      await EntityAccess.requireOwned(
        session,
        entityId,
        systemOwner: systemOwner,
      ),
    );
    final today = EntityClock.today(entity);

    final due = await RecurringTransaction.db.find(
      session,
      where: (t) =>
          t.entityId.equals(entityId) &
          t.isActive.equals(true) &
          (t.nextDate <= today),
      orderByList: (t) => [t.nextDate, t.id],
    );

    var posted = 0;
    var failed = 0;
    for (final schedule in due) {
      if (!_hasDueOccurrence(schedule, today)) continue;

      try {
        posted += await _postScheduleCatchUp(
          session,
          scheduleId: schedule.id!,
          today: today,
          systemOwner: systemOwner,
        );
      } on Object catch (error, stackTrace) {
        if (!continueOnError) rethrow;

        failed++;
        _log.severe(
          'Recurring schedule ${schedule.id} failed; it remains due',
          error,
          stackTrace,
        );
      }
    }

    return (posted: posted, failed: failed);
  }

  static Future<int> _postScheduleCatchUp(
    Session session, {
    required UuidValue scheduleId,
    required DateTime today,
    SystemEntityOwner? systemOwner,
  }) async {
    var posted = 0;
    while (posted < maxOccurrencesPerRun) {
      final schedule = await RecurringTransaction.db.findById(
        session,
        scheduleId,
      );
      if (schedule == null || !_hasDueOccurrence(schedule, today)) break;

      try {
        final inserted = await _postOneOccurrence(
          session,
          schedule: schedule,
          systemOwner: systemOwner,
        );
        if (!inserted) break;
        posted++;
      } on DatabaseUniqueViolationException catch (error) {
        if (error.constraintName != 'transaction_account_external_unique_idx') {
          rethrow;
        }

        // A concurrent poster won this stable occurrence id. Its transaction
        // also advanced the schedule, so re-read and continue from there.
        final occurrenceExternalId = _occurrenceExternalId(
          schedule,
          schedule.nextDate,
        );
        final existing = await model.Transaction.db.findFirstRow(
          session,
          where: (t) =>
              t.accountId.equals(schedule.accountId) &
              t.externalId.equals(occurrenceExternalId) &
              t.recurringTransactionId.equals(schedule.id),
        );
        final fresh = await RecurringTransaction.db.findById(
          session,
          scheduleId,
        );
        if (existing == null ||
            fresh == null ||
            !fresh.nextDate.isAfter(schedule.nextDate)) {
          throw ValidationException(
            message:
                'The recurring occurrence was posted concurrently but its '
                'schedule did not advance; retry after repairing the schedule',
          );
        }
      }
    }

    if (posted == maxOccurrencesPerRun) {
      final remaining = await RecurringTransaction.db.findById(
        session,
        scheduleId,
      );
      if (remaining != null && _hasDueOccurrence(remaining, today)) {
        _log.warning(
          'Recurring schedule $scheduleId reached the '
          '$maxOccurrencesPerRun occurrence limit; the next run continues',
        );
      }
    }

    return posted;
  }

  /// Writes one occurrence and advances the schedule in one transaction.
  static Future<bool> _postOneOccurrence(
    Session session, {
    required RecurringTransaction schedule,
    SystemEntityOwner? systemOwner,
  }) => TransactionWriter.inTransaction(session, (tx) async {
    final entity = _requireWritable(
      await EntityAccess.requireOwned(
        session,
        schedule.entityId,
        transaction: tx,
        lockMode: LockMode.forNoKeyUpdate,
        systemOwner: systemOwner,
      ),
    );

    final account = await Account.db.findById(
      session,
      schedule.accountId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    _requirePostingAccount(account, entity.id!);

    // Schedule rows come after the account lock. The poster then never
    // holds a schedule while waiting for an account, which is the inverse
    // of the merge and envelope-reassignment hierarchies.
    final current = await RecurringTransaction.db.findById(
      session,
      schedule.id!,
      transaction: tx,
    );
    if (current == null) return false;
    if (current.entityId != entity.id ||
        current.accountId != account.id ||
        !current.isActive ||
        current.nextDate != schedule.nextDate) {
      // A concurrent edit, skip or post moved the schedule while this run
      // was starting. Nothing has been written yet; re-read and let the
      // caller decide whether the new date is still due.
      return false;
    }
    if (current.endDate != null && current.nextDate.isAfter(current.endDate!)) {
      return false;
    }

    final occurrenceDate = current.nextDate;
    final occurrenceExternalId = _occurrenceExternalId(
      current,
      occurrenceDate,
    );

    await TransactionWriter.create(
      session,
      TransactionInput(
        accountId: current.accountId,
        date: occurrenceDate,
        amountMinor: current.amountMinor,
        payeeId: current.payeeId,
        description: current.description,
        memo: current.memo,
        status: TransactionStatus.uncleared,
        lines: current.envelopeId == null
            ? const []
            : [
                TransactionLineInput(
                  amountMinor: current.amountMinor,
                  envelopeId: current.envelopeId,
                ),
              ],
      ),
      transaction: tx,
      metadata: TransactionWriteMetadata(
        externalId: occurrenceExternalId,
        recurringTransactionId: current.id,
      ),
      systemOwner: systemOwner,
    );

    final next = nextOccurrence(
      current.frequency,
      current.nextDate,
      current.nextDate,
    );
    final remainsActive =
        current.endDate == null || !next.isAfter(current.endDate!);

    final updated = await RecurringTransaction.db.updateWhere(
      session,
      columnValues: (t) => [
        t.nextDate(next),
        t.isActive(remainsActive),
        t.updatedAt(DateTime.now().toUtc()),
      ],
      where: (t) =>
          t.id.equals(current.id) &
          t.nextDate.equals(current.nextDate) &
          t.updatedAt.equals(current.updatedAt) &
          t.isActive.equals(true),
      transaction: tx,
    );
    if (updated.isEmpty) {
      throw ValidationException(
        message:
            'The recurring schedule changed while posting; retry the '
            'occurrence',
      );
    }

    return true;
  });

  static Future<Account> _lockPostingAccount(
    Session session, {
    required UuidValue accountId,
    required UuidValue entityId,
    required Transaction transaction,
  }) async {
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    _requirePostingAccount(account, entityId);
    return account;
  }

  static Future<Map<UuidValue, Account>> _lockAccounts(
    Session session,
    Iterable<UuidValue> accountIds,
    Transaction transaction,
  ) async {
    final ordered = accountIds.toSet().toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    final accounts = <UuidValue, Account>{};
    for (final id in ordered) {
      final account = await Account.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (account != null) accounts[id] = account;
    }
    return accounts;
  }

  static void _requirePostingAccount(Account account, UuidValue entityId) {
    if (account.entityId != entityId) {
      throw NotFoundException(message: 'Account not found');
    }
    if (account.balanceSource != AccountBalanceSource.transactions) {
      throw ValidationException(
        message: 'Recurring transactions require a transactions account',
      );
    }
    if (account.closedAt != null) {
      throw ValidationException(
        message: 'A closed account rejects recurring transactions',
      );
    }
  }

  static Future<void> _requirePayee(
    Session session, {
    required UuidValue entityId,
    required UuidValue? payeeId,
    required Transaction transaction,
  }) async {
    if (payeeId == null) return;

    final payee = await Payee.db.findById(
      session,
      payeeId,
      transaction: transaction,
    );
    if (payee == null || payee.entityId != entityId) {
      throw NotFoundException(message: 'Payee not found');
    }
  }

  static Future<void> _requireEnvelope(
    Session session, {
    required UuidValue entityId,
    required UuidValue? envelopeId,
    required Transaction transaction,
  }) async {
    if (envelopeId == null) return;

    final envelope = await Envelope.db.findById(
      session,
      envelopeId,
      transaction: transaction,
    );
    if (envelope == null || envelope.entityId != entityId) {
      throw NotFoundException(message: 'Envelope not found');
    }
  }

  static String _occurrenceExternalId(
    RecurringTransaction schedule,
    DateTime date,
  ) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return 'recurring:${schedule.id}:${date.year}-$month-$day';
  }

  static bool _hasDueOccurrence(RecurringTransaction schedule, DateTime today) {
    if (!schedule.isActive) return false;
    if (schedule.nextDate.isAfter(today)) return false;
    final endDate = schedule.endDate;
    if (endDate != null && schedule.nextDate.isAfter(endDate)) return false;
    return true;
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects recurring changes',
      );
    }

    return entity;
  }

  static String _requireDescription(String raw) {
    final description = raw.trim();
    if (description.isEmpty) {
      throw ValidationException(message: 'Description is required');
    }

    return description;
  }

  static void _requireAmount(int amountMinor) {
    if (amountMinor == 0) {
      throw ValidationException(message: 'amountMinor must not be zero');
    }
    if (amountMinor.abs() > maxSafeMinor) {
      throw ValidationException(
        message: 'amountMinor exceeds the safe minor-unit range',
      );
    }
  }

  static DateTime _requireCivilDate(DateTime value, String field) {
    if (!isCivilDate(value) || value.year < 1900) {
      throw ValidationException(
        message: '$field must be a UTC calendar date',
      );
    }

    return value;
  }

  static DateTime? _requireEndDate(DateTime? endDate, DateTime nextDate) {
    if (endDate == null) return null;
    if (endDate.isBefore(nextDate)) {
      throw ValidationException(
        message: 'endDate cannot be before nextDate',
      );
    }

    return endDate;
  }

  static String? _normaliseMemo(String? raw) {
    final memo = raw?.trim();
    return memo == null || memo.isEmpty ? null : memo;
  }

  static Future<void> _notify(Session session, UuidValue entityId) =>
      EntityRealtimeNotifier.notify(
        session,
        entityId,
        ChangeScope.transactions,
      );
}
