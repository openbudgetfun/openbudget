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
    String? memo,
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
      memo: memo,
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
    String? memo,
  }) async {
    final transaction = await getById(session, transactionId: transactionId);

    final updated = transaction.copyWith(
      description: description ?? transaction.description,
      amountCents: amountCents ?? transaction.amountCents,
      envelopeId: envelopeId ?? transaction.envelopeId,
      payeeId: payeeId ?? transaction.payeeId,
      transactionDate: transactionDate ?? transaction.transactionDate,
      memo: memo ?? transaction.memo,
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

  /// Reconciles an account with a statement balance.
  ///
  /// Computes the cleared balance (sum of all cleared & unreconciled
  /// transactions plus previously reconciled transactions). If it differs
  /// from [statementBalanceCents], an adjustment transaction is created.
  /// All cleared transactions are then marked reconciled.
  ///
  /// Returns a list containing: [reconciledCount, adjustmentCents].
  static Future<List<int>> reconcileWithBalance(
    Session session, {
    required UuidValue accountId,
    required UuidValue budgetId,
    required int statementBalanceCents,
  }) async {
    final budget = await BudgetService.getById(session, budgetId: budgetId);

    // Sum all transactions for this account to get the current balance.
    final allTransactions = await Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId) & t.accountId.equals(accountId),
    );

    // Cleared balance = sum of all reconciled + cleared transactions.
    var clearedBalanceCents = 0;
    for (final txn in allTransactions) {
      if (txn.reconciled || txn.cleared) {
        clearedBalanceCents += txn.amountCents;
      }
    }

    final adjustmentCents = statementBalanceCents - clearedBalanceCents;

    // Create adjustment transaction if needed.
    if (adjustmentCents != 0) {
      final adjustment = Transaction(
        budgetId: budgetId,
        accountId: accountId,
        amountCents: adjustmentCents,
        currencyCode: budget.currencyCode,
        description: 'Reconciliation adjustment',
        transactionDate: DateTime.now(),
        cleared: true,
        reconciled: true,
        createdAt: DateTime.now(),
      );
      await Transaction.db.insertRow(session, adjustment);
    }

    // Mark all cleared transactions as reconciled.
    final count = await reconcileAccount(
      session,
      accountId: accountId,
      budgetId: budgetId,
    );

    return [count, adjustmentCents];
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

  /// Creates a split transaction: a parent with multiple sub-transactions.
  ///
  /// The parent holds the total amount (no envelope). Each split has its own
  /// envelope and amount. The sum of split amounts must equal the parent.
  static Future<List<Transaction>> createSplit(
    Session session, {
    required String description,
    required int totalAmountCents,
    required String currencyCode,
    required UuidValue budgetId,
    required DateTime transactionDate,
    required List<SplitItem> splits,
    UuidValue? payeeId,
    UuidValue? accountId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    // Validate split amounts sum to total.
    final splitSum = splits.fold<int>(0, (sum, s) => sum + s.amountCents.abs());
    if (splitSum != totalAmountCents.abs()) {
      throw ValidationException(
        'Split amounts must equal total: $splitSum != ${totalAmountCents.abs()}',
      );
    }

    // Create parent transaction (no envelope).
    final parent = Transaction(
      description: description,
      amountCents: totalAmountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      payeeId: payeeId,
      accountId: accountId,
      transactionDate: transactionDate,
      createdAt: DateTime.now(),
    );
    final savedParent = await Transaction.db.insertRow(session, parent);

    final results = <Transaction>[savedParent];

    // Create child split transactions.
    for (final split in splits) {
      final child = Transaction(
        description: split.memo ?? description,
        amountCents: totalAmountCents.isNegative
            ? -split.amountCents.abs()
            : split.amountCents.abs(),
        currencyCode: currencyCode,
        budgetId: budgetId,
        envelopeId: split.envelopeId,
        payeeId: payeeId,
        accountId: accountId,
        parentTransactionId: savedParent.id,
        transactionDate: transactionDate,
        createdAt: DateTime.now(),
      );
      final saved = await Transaction.db.insertRow(session, child);
      results.add(saved);
    }

    return results;
  }

  /// Lists the sub-transactions (splits) for a parent transaction.
  static Future<List<Transaction>> listSplits(
    Session session, {
    required UuidValue parentTransactionId,
  }) async {
    final parent = await getById(session, transactionId: parentTransactionId);
    return Transaction.db.find(
      session,
      where: (t) => t.parentTransactionId.equals(parent.id),
      orderBy: (t) => t.createdAt,
    );
  }

  /// Bulk creates transactions from import data.
  ///
  /// All transactions are created within a single budget, verified once.
  /// Returns the count of successfully created transactions.
  static Future<int> bulkCreate(
    Session session, {
    required UuidValue budgetId,
    required String currencyCode,
    required List<ImportRow> rows,
    UuidValue? accountId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    var count = 0;
    for (final row in rows) {
      final transaction = Transaction(
        description: row.description,
        amountCents: row.amountCents,
        currencyCode: currencyCode,
        budgetId: budgetId,
        accountId: accountId,
        transactionDate: row.transactionDate,
        createdAt: DateTime.now(),
      );
      await Transaction.db.insertRow(session, transaction);
      count++;
    }

    return count;
  }

  /// Finds potential duplicate transactions for a given amount and date.
  ///
  /// Matches transactions with the same absolute amount within ±1 day
  /// of the given date. Returns up to 5 potential duplicates.
  static Future<List<Transaction>> findDuplicates(
    Session session, {
    required UuidValue budgetId,
    required int amountCents,
    required DateTime transactionDate,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final dayBefore = transactionDate.subtract(const Duration(days: 1));
    final dayAfter = transactionDate.add(const Duration(days: 1));

    return Transaction.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.amountCents.equals(amountCents) &
          (t.transactionDate >= dayBefore) &
          (t.transactionDate <= dayAfter),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
      limit: 5,
    );
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
