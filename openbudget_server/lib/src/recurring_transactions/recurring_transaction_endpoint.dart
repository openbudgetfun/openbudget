import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for recurring transaction operations.
///
/// All methods require authentication.
class RecurringTransactionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new recurring transaction.
  Future<RecurringTransaction> create(
    Session session,
    String description,
    int amountCents,
    String currencyCode,
    UuidValue budgetId,
    String frequency,
    DateTime nextOccurrence, {
    UuidValue? envelopeId,
    UuidValue? accountId,
    UuidValue? payeeId,
    DateTime? endDate,
  }) async {
    return RecurringTransactionService.create(
      session,
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      frequency: frequency,
      nextOccurrence: nextOccurrence,
      envelopeId: envelopeId,
      accountId: accountId,
      payeeId: payeeId,
      endDate: endDate,
    );
  }

  /// Lists recurring transactions for a budget.
  Future<List<RecurringTransaction>> list(
    Session session,
    UuidValue budgetId, {
    bool? activeOnly,
  }) async {
    return RecurringTransactionService.listForBudget(
      session,
      budgetId: budgetId,
      activeOnly: activeOnly,
    );
  }

  /// Gets a recurring transaction by ID.
  Future<RecurringTransaction> get(
    Session session,
    UuidValue recurringTransactionId,
  ) async {
    return RecurringTransactionService.getById(
      session,
      recurringTransactionId: recurringTransactionId,
    );
  }

  /// Updates a recurring transaction.
  Future<RecurringTransaction> update(
    Session session,
    UuidValue recurringTransactionId, {
    String? description,
    int? amountCents,
    UuidValue? envelopeId,
    UuidValue? accountId,
    UuidValue? payeeId,
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate,
    bool? isActive,
  }) async {
    return RecurringTransactionService.update(
      session,
      recurringTransactionId: recurringTransactionId,
      description: description,
      amountCents: amountCents,
      envelopeId: envelopeId,
      accountId: accountId,
      payeeId: payeeId,
      frequency: frequency,
      nextOccurrence: nextOccurrence,
      endDate: endDate,
      isActive: isActive,
    );
  }

  /// Deletes a recurring transaction.
  Future<RecurringTransaction> delete(
    Session session,
    UuidValue recurringTransactionId,
  ) async {
    return RecurringTransactionService.delete(
      session,
      recurringTransactionId: recurringTransactionId,
    );
  }

  /// Skips the next occurrence of a recurring transaction by advancing the
  /// schedule without creating a transaction.
  Future<RecurringTransaction> skipOccurrence(
    Session session,
    UuidValue recurringTransactionId,
  ) async {
    return RecurringTransactionService.skipOccurrence(
      session,
      recurringTransactionId: recurringTransactionId,
    );
  }

  /// Posts all due recurring transactions for a budget, creating actual
  /// transactions and advancing the schedule. Returns the count of created
  /// transactions.
  Future<int> postDue(Session session, UuidValue budgetId) async {
    return RecurringTransactionService.postDue(session, budgetId: budgetId);
  }

  /// Returns the count of active recurring transactions that are currently due.
  Future<int> countDue(Session session, UuidValue budgetId) async {
    return RecurringTransactionService.countDue(session, budgetId: budgetId);
  }
}
