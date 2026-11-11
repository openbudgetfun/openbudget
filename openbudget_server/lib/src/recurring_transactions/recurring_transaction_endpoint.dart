import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for recurring transaction operations.
///
/// All methods require authentication and delegate to
/// [RecurringTransactionService], which owns the entity boundary and publishes
/// committed change events.
class RecurringTransactionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a schedule for one transactions-sourced account.
  Future<RecurringTransaction> create(
    Session session,
    UuidValue accountId,
    String description,
    int amountMinor,
    RecurrenceFrequency frequency,
    DateTime nextDate, {
    UuidValue? payeeId,
    UuidValue? envelopeId,
    String? memo,
    DateTime? endDate,
  }) => RecurringTransactionService.create(
    session,
    accountId: accountId,
    description: description,
    amountMinor: amountMinor,
    frequency: frequency,
    nextDate: nextDate,
    payeeId: payeeId,
    envelopeId: envelopeId,
    memo: memo,
    endDate: endDate,
  );

  /// Lists every schedule of an owned entity in due-date order.
  Future<List<RecurringTransaction>> list(
    Session session,
    UuidValue entityId,
  ) => RecurringTransactionService.list(session, entityId: entityId);

  /// Gets one schedule by ID.
  Future<RecurringTransaction> get(
    Session session,
    UuidValue recurringTransactionId,
  ) => RecurringTransactionService.getById(
    session,
    recurringTransactionId: recurringTransactionId,
  );

  /// Updates the named fields and clear flags from the §7.1 contract.
  Future<RecurringTransaction> update(
    Session session,
    UuidValue recurringTransactionId, {
    UuidValue? accountId,
    String? description,
    int? amountMinor,
    RecurrenceFrequency? frequency,
    DateTime? nextDate,
    UuidValue? payeeId,
    bool? clearPayee,
    UuidValue? envelopeId,
    bool? clearEnvelope,
    String? memo,
    DateTime? endDate,
    bool? clearEndDate,
    bool? isActive,
  }) => RecurringTransactionService.update(
    session,
    recurringTransactionId: recurringTransactionId,
    accountId: accountId,
    description: description,
    amountMinor: amountMinor,
    frequency: frequency,
    nextDate: nextDate,
    payeeId: payeeId,
    clearPayee: clearPayee ?? false,
    envelopeId: envelopeId,
    clearEnvelope: clearEnvelope ?? false,
    memo: memo,
    endDate: endDate,
    clearEndDate: clearEndDate ?? false,
    isActive: isActive,
  );

  /// Deletes one schedule without deleting its posted transactions.
  Future<RecurringTransaction> delete(
    Session session,
    UuidValue recurringTransactionId,
  ) => RecurringTransactionService.delete(
    session,
    recurringTransactionId: recurringTransactionId,
  );

  /// Advances the schedule by one occurrence without posting it.
  Future<RecurringTransaction> skipOccurrence(
    Session session,
    UuidValue recurringTransactionId,
  ) => RecurringTransactionService.skipOccurrence(
    session,
    recurringTransactionId: recurringTransactionId,
  );

  /// Posts every due occurrence for one entity and returns the actual count.
  Future<int> postDue(Session session, UuidValue entityId) =>
      RecurringTransactionService.postDue(session, entityId: entityId);

  /// Counts active schedules that are due on the entity's local today.
  Future<int> countDue(Session session, UuidValue entityId) =>
      RecurringTransactionService.countDue(session, entityId: entityId);
}
