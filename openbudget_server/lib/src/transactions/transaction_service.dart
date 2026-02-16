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

  /// Lists transactions for a specific account.
  static Future<List<Transaction>> listForAccount(
    Session session, {
    required UuidValue accountId,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId) & t.accountId.equals(accountId),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
    );
  }

  /// Toggles the cleared status of a transaction.
  static Future<Transaction> toggleCleared(
    Session session, {
    required UuidValue transactionId,
  }) async {
    final transaction = await getById(session, transactionId: transactionId);
    final updated = transaction.copyWith(cleared: !transaction.cleared);
    return Transaction.db.updateRow(session, updated);
  }

  /// Reconciles an account by marking all cleared transactions as reconciled
  /// and returning the count of reconciled transactions.
  static Future<int> reconcileAccount(
    Session session, {
    required UuidValue accountId,
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final cleared = await Transaction.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.accountId.equals(accountId) &
          t.cleared.equals(true) &
          t.reconciled.equals(false),
    );

    for (final txn in cleared) {
      await Transaction.db.updateRow(session, txn.copyWith(reconciled: true));
    }

    return cleared.length;
  }

  /// Calculates the "Age of Money" for a budget using FIFO matching.
  ///
  /// Returns the average number of days between income receipt and spending
  /// for the most recent outflows, or null if insufficient data.
  static Future<int?> ageOfMoney(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final transactions = await Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.transactionDate,
    );

    if (transactions.isEmpty) return null;

    // Separate inflows and outflows (exclude transfers), sorted oldest first.
    final inflows = transactions
        .where((t) => t.amountCents > 0 && t.transferPairId == null)
        .toList();
    final outflows = transactions
        .where((t) => t.amountCents < 0 && t.transferPairId == null)
        .toList();

    if (inflows.isEmpty || outflows.isEmpty) return null;

    // FIFO: match each outflow cent to the oldest available inflow cent.
    final remainingCents = inflows.map((i) => i.amountCents).toList();
    var inflowIdx = 0;
    final ages = <int>[];

    for (final outflow in outflows) {
      var remaining = outflow.amountCents.abs();

      while (remaining > 0 && inflowIdx < remainingCents.length) {
        final available = remainingCents[inflowIdx];
        final consumed = remaining < available ? remaining : available;
        final ageDays = outflow.transactionDate
            .difference(inflows[inflowIdx].transactionDate)
            .inDays;

        if (ageDays >= 0) {
          ages.add(ageDays);
        }

        remaining -= consumed;
        remainingCents[inflowIdx] -= consumed;

        if (remainingCents[inflowIdx] <= 0) {
          inflowIdx++;
        }
      }
    }

    if (ages.isEmpty) return null;

    // Return average of the last 10 ages for recency.
    final recentAges = ages.length > 10 ? ages.sublist(ages.length - 10) : ages;
    final sum = recentAges.fold<int>(0, (s, a) => s + a);
    return (sum / recentAges.length).round();
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
