import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Business logic for managing recurring transactions within a budget.
///
/// All methods verify budget ownership before operating.
class RecurringTransactionService {
  /// Creates a recurring transaction, verifying budget ownership.
  static Future<RecurringTransaction> create(
    Session session, {
    required String description,
    required int amountCents,
    required String currencyCode,
    required UuidValue budgetId,
    required String frequency,
    required DateTime nextOccurrence,
    UuidValue? envelopeId,
    UuidValue? accountId,
    UuidValue? payeeId,
    DateTime? endDate,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final recurring = RecurringTransaction(
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      frequency: frequency,
      nextOccurrence: nextOccurrence,
      endDate: endDate,
      isActive: true,
      envelopeId: envelopeId,
      accountId: accountId,
      payeeId: payeeId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return RecurringTransaction.db.insertRow(session, recurring);
  }

  /// Lists all recurring transactions for a budget.
  static Future<List<RecurringTransaction>> listForBudget(
    Session session, {
    required UuidValue budgetId,
    bool? activeOnly,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    if (activeOnly ?? false) {
      return RecurringTransaction.db.find(
        session,
        where: (t) => t.budgetId.equals(budgetId) & t.isActive.equals(true),
        orderBy: (t) => t.nextOccurrence,
      );
    }

    return RecurringTransaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.nextOccurrence,
    );
  }

  /// Gets a recurring transaction by ID, verifying ownership.
  static Future<RecurringTransaction> getById(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    final recurring = await RecurringTransaction.db.findById(
      session,
      recurringTransactionId,
    );
    if (recurring == null) {
      throw NotFoundException('Recurring transaction not found');
    }

    await BudgetService.getById(session, budgetId: recurring.budgetId);
    return recurring;
  }

  /// Updates a recurring transaction.
  static Future<RecurringTransaction> update(
    Session session, {
    required UuidValue recurringTransactionId,
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
    final recurring = await getById(
      session,
      recurringTransactionId: recurringTransactionId,
    );

    final updated = recurring.copyWith(
      description: description ?? recurring.description,
      amountCents: amountCents ?? recurring.amountCents,
      envelopeId: envelopeId ?? recurring.envelopeId,
      accountId: accountId ?? recurring.accountId,
      payeeId: payeeId ?? recurring.payeeId,
      frequency: frequency ?? recurring.frequency,
      nextOccurrence: nextOccurrence ?? recurring.nextOccurrence,
      endDate: endDate ?? recurring.endDate,
      isActive: isActive ?? recurring.isActive,
      updatedAt: DateTime.now(),
    );
    return RecurringTransaction.db.updateRow(session, updated);
  }

  /// Deletes a recurring transaction.
  static Future<RecurringTransaction> delete(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    final recurring = await getById(
      session,
      recurringTransactionId: recurringTransactionId,
    );
    return RecurringTransaction.db.deleteRow(session, recurring);
  }

  /// Posts all due recurring transactions for a budget.
  ///
  /// Finds active recurring transactions where `nextOccurrence <= now`,
  /// creates actual transactions for each, advances `nextOccurrence`, and
  /// deactivates any that have passed their `endDate`.
  ///
  /// Returns the number of transactions created.
  static Future<int> postDue(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final now = DateTime.now();
    final dueRecurrings = await RecurringTransaction.db.find(
      session,
      where: (r) =>
          r.budgetId.equals(budgetId) &
          r.isActive.equals(true) &
          (r.nextOccurrence <= now),
      orderBy: (r) => r.nextOccurrence,
    );

    var count = 0;

    for (final recurring in dueRecurrings) {
      // Create the actual transaction from the recurring template.
      final transaction = Transaction(
        description: recurring.description,
        amountCents: recurring.amountCents,
        currencyCode: recurring.currencyCode,
        budgetId: recurring.budgetId,
        envelopeId: recurring.envelopeId,
        accountId: recurring.accountId,
        payeeId: recurring.payeeId,
        transactionDate: recurring.nextOccurrence,
        createdAt: DateTime.now(),
      );
      await Transaction.db.insertRow(session, transaction);
      count++;

      // Advance to next occurrence.
      final nextDate = calculateNextOccurrence(
        recurring.frequency,
        recurring.nextOccurrence,
      );

      // Deactivate if past endDate.
      final shouldDeactivate =
          recurring.endDate != null && nextDate.isAfter(recurring.endDate!);

      final updated = recurring.copyWith(
        nextOccurrence: nextDate,
        isActive: !shouldDeactivate,
        updatedAt: DateTime.now(),
      );
      await RecurringTransaction.db.updateRow(session, updated);
    }

    return count;
  }

  /// Skips the next occurrence of a recurring transaction by advancing
  /// `nextOccurrence` without creating a transaction.
  ///
  /// Returns the updated recurring transaction with the new next date.
  /// If the next date would be past `endDate`, the recurring is deactivated.
  static Future<RecurringTransaction> skipOccurrence(
    Session session, {
    required UuidValue recurringTransactionId,
  }) async {
    final recurring = await getById(
      session,
      recurringTransactionId: recurringTransactionId,
    );

    final nextDate = calculateNextOccurrence(
      recurring.frequency,
      recurring.nextOccurrence,
    );

    final shouldDeactivate =
        recurring.endDate != null && nextDate.isAfter(recurring.endDate!);

    final updated = recurring.copyWith(
      nextOccurrence: nextDate,
      isActive: !shouldDeactivate,
      updatedAt: DateTime.now(),
    );
    return RecurringTransaction.db.updateRow(session, updated);
  }

  /// Counts active recurring transactions that are due (nextOccurrence <= now).
  static Future<int> countDue(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final now = DateTime.now();
    final count = await RecurringTransaction.db.count(
      session,
      where: (r) =>
          r.budgetId.equals(budgetId) &
          r.isActive.equals(true) &
          (r.nextOccurrence <= now),
    );
    return count;
  }

  /// Calculates the next occurrence based on frequency and current date.
  static DateTime calculateNextOccurrence(String frequency, DateTime current) {
    return switch (frequency) {
      'daily' => current.add(const Duration(days: 1)),
      'weekly' => current.add(const Duration(days: 7)),
      'biweekly' => current.add(const Duration(days: 14)),
      'monthly' => DateTime(current.year, current.month + 1, current.day),
      'yearly' => DateTime(current.year + 1, current.month, current.day),
      _ => current.add(const Duration(days: 30)),
    };
  }
}
