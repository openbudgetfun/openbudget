import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Business logic for managing transactions within a budget.
///
/// All methods verify budget ownership before operating on transactions.
class TransactionService {
  /// Creates a transaction within a budget, verifying ownership.
  static Future<Transaction> create(
    Session session, {
    required String description,
    required int amountCents,
    required String currencyCode,
    required UuidValue budgetId,
    required DateTime transactionDate,
    UuidValue? envelopeId,
    UuidValue? payeeId,
  }) async {
    // Verify the user owns this budget.
    await BudgetService.getById(session, budgetId: budgetId);

    final transaction = Transaction(
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      envelopeId: envelopeId,
      budgetId: budgetId,
      payeeId: payeeId,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );
    return Transaction.db.insertRow(session, transaction);
  }

  /// Lists all transactions for a budget, verifying ownership.
  static Future<List<Transaction>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
    );
  }

  /// Lists transactions for a budget within a specific month.
  static Future<List<Transaction>> listForBudgetMonth(
    Session session, {
    required UuidValue budgetId,
    required int year,
    required int month,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    return Transaction.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          (t.transactionDate >= start) &
          (t.transactionDate < end),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
    );
  }

  /// Fetches a single transaction, verifying budget ownership.
  static Future<Transaction> getById(
    Session session, {
    required UuidValue transactionId,
  }) async {
    final transaction = await Transaction.db.findById(session, transactionId);
    if (transaction == null) {
      throw NotFoundException('Transaction not found');
    }

    // Verify the user owns the parent budget.
    await BudgetService.getById(session, budgetId: transaction.budgetId);
    return transaction;
  }

  /// Updates a transaction, verifying budget ownership.
  static Future<Transaction> update(
    Session session, {
    required UuidValue transactionId,
    String? description,
    int? amountCents,
    UuidValue? envelopeId,
    UuidValue? payeeId,
    DateTime? transactionDate,
  }) async {
    final transaction = await getById(session, transactionId: transactionId);

    final updated = transaction.copyWith(
      description: description ?? transaction.description,
      amountCents: amountCents ?? transaction.amountCents,
      envelopeId: envelopeId ?? transaction.envelopeId,
      payeeId: payeeId ?? transaction.payeeId,
      transactionDate: transactionDate ?? transaction.transactionDate,
    );
    return Transaction.db.updateRow(session, updated);
  }

  /// Creates a transfer between two accounts within a budget.
  ///
  /// This creates two linked transactions: an outflow from the source account
  /// and an inflow to the destination account, linked by `transferPairId`.
  static Future<List<Transaction>> createTransfer(
    Session session, {
    required String description,
    required int amountCents,
    required String currencyCode,
    required UuidValue budgetId,
    required UuidValue fromAccountId,
    required UuidValue toAccountId,
    required DateTime transactionDate,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final outflow = Transaction(
      description: description,
      amountCents: -amountCents.abs(),
      currencyCode: currencyCode,
      budgetId: budgetId,
      accountId: fromAccountId,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );
    final savedOutflow = await Transaction.db.insertRow(session, outflow);

    final inflow = Transaction(
      description: description,
      amountCents: amountCents.abs(),
      currencyCode: currencyCode,
      budgetId: budgetId,
      accountId: toAccountId,
      transferPairId: savedOutflow.id,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );
    final savedInflow = await Transaction.db.insertRow(session, inflow);

    final linkedOutflow = savedOutflow.copyWith(transferPairId: savedInflow.id);
    final updatedOutflow = await Transaction.db.updateRow(
      session,
      linkedOutflow,
    );

    return [updatedOutflow, savedInflow];
  }

  /// Deletes a transaction, verifying budget ownership.
  static Future<Transaction> delete(
    Session session, {
    required UuidValue transactionId,
  }) async {
    final transaction = await getById(session, transactionId: transactionId);
    return Transaction.db.deleteRow(session, transaction);
  }
}
