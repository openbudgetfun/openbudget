import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// API surface for transaction operations.
///
/// All methods require authentication.
class TransactionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a new transaction within a budget.
  Future<Transaction> create(
    Session session,
    String description,
    int amountCents,
    String currencyCode,
    UuidValue budgetId,
    DateTime transactionDate, {
    UuidValue? envelopeId,
    UuidValue? payeeId,
    String? memo,
  }) async {
    final transaction = await TransactionService.create(
      session,
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      transactionDate: transactionDate,
      envelopeId: envelopeId,
      payeeId: payeeId,
      memo: memo,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }

  /// Lists all transactions for a budget.
  Future<List<Transaction>> list(Session session, UuidValue budgetId) async => TransactionService.listForBudget(session, budgetId: budgetId);

  /// Lists transactions for a budget within a specific month.
  Future<List<Transaction>> listByMonth(
    Session session,
    UuidValue budgetId,
    int year,
    int month,
  ) async => TransactionService.listForBudgetMonth(
      session,
      budgetId: budgetId,
      year: year,
      month: month,
    );

  /// Gets a single transaction by ID.
  Future<Transaction> get(Session session, UuidValue transactionId) async => TransactionService.getById(session, transactionId: transactionId);

  /// Updates a transaction by ID.
  Future<Transaction> update(
    Session session,
    UuidValue transactionId, {
    String? description,
    int? amountCents,
    UuidValue? envelopeId,
    UuidValue? payeeId,
    DateTime? transactionDate,
    String? memo,
    String? flagColor,
  }) async {
    final transaction = await TransactionService.update(
      session,
      transactionId: transactionId,
      description: description,
      amountCents: amountCents,
      envelopeId: envelopeId,
      payeeId: payeeId,
      transactionDate: transactionDate,
      memo: memo,
      flagColor: flagColor,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }

  /// Sets or clears the flag color on a transaction.
  Future<Transaction> setFlag(
    Session session,
    UuidValue transactionId, {
    String? flagColor,
  }) async {
    final transaction = await TransactionService.setFlag(
      session,
      transactionId: transactionId,
      flagColor: flagColor,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }

  /// Creates a transfer between two accounts.
  Future<List<Transaction>> transfer(
    Session session,
    String description,
    int amountCents,
    String currencyCode,
    UuidValue budgetId,
    UuidValue fromAccountId,
    UuidValue toAccountId,
    DateTime transactionDate,
  ) async {
    final transactions = await TransactionService.createTransfer(
      session,
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      transactionDate: transactionDate,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return transactions;
  }

  /// Lists transactions for a specific account.
  Future<List<Transaction>> listByAccount(
    Session session,
    UuidValue accountId,
    UuidValue budgetId,
  ) async => TransactionService.listForAccount(
      session,
      accountId: accountId,
      budgetId: budgetId,
    );

  /// Toggles the cleared status of a transaction.
  Future<Transaction> toggleCleared(
    Session session,
    UuidValue transactionId,
  ) async {
    final transaction = await TransactionService.toggleCleared(
      session,
      transactionId: transactionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }

  /// Reconciles all cleared transactions for an account.
  Future<int> reconcileAccount(
    Session session,
    UuidValue accountId,
    UuidValue budgetId,
  ) async {
    final reconciledCount = await TransactionService.reconcileAccount(
      session,
      accountId: accountId,
      budgetId: budgetId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return reconciledCount;
  }

  /// Reconciles an account with a statement balance.
  ///
  /// If the cleared balance differs from the statement balance, creates an
  /// adjustment transaction. Returns [reconciledCount, adjustmentCents].
  Future<List<int>> reconcileWithBalance(
    Session session,
    UuidValue accountId,
    UuidValue budgetId,
    int statementBalanceCents,
  ) async {
    final result = await TransactionService.reconcileWithBalance(
      session,
      accountId: accountId,
      budgetId: budgetId,
      statementBalanceCents: statementBalanceCents,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return result;
  }

  /// Calculates the "Age of Money" for a budget.
  ///
  /// Returns the average days between income and spending, or null if
  /// there is insufficient data.
  Future<int?> ageOfMoney(Session session, UuidValue budgetId) async => TransactionService.ageOfMoney(session, budgetId: budgetId);

  /// Creates a split transaction with multiple envelope assignments.
  Future<List<Transaction>> createSplit(
    Session session,
    String description,
    int totalAmountCents,
    String currencyCode,
    UuidValue budgetId,
    DateTime transactionDate,
    List<SplitItem> splits, {
    UuidValue? payeeId,
    UuidValue? accountId,
  }) async {
    final transactions = await TransactionService.createSplit(
      session,
      description: description,
      totalAmountCents: totalAmountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      transactionDate: transactionDate,
      splits: splits,
      payeeId: payeeId,
      accountId: accountId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return transactions;
  }

  /// Lists the sub-transactions (splits) for a parent transaction.
  Future<List<Transaction>> listSplits(
    Session session,
    UuidValue parentTransactionId,
  ) async => TransactionService.listSplits(
      session,
      parentTransactionId: parentTransactionId,
    );

  /// Bulk creates transactions from imported data.
  ///
  /// Returns the count of successfully created transactions.
  Future<int> bulkImport(
    Session session,
    UuidValue budgetId,
    String currencyCode,
    List<ImportRow> rows, {
    UuidValue? accountId,
  }) async {
    final importedCount = await TransactionService.bulkCreate(
      session,
      budgetId: budgetId,
      currencyCode: currencyCode,
      rows: rows,
      accountId: accountId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return importedCount;
  }

  /// Finds potential duplicate transactions with the same amount near a date.
  Future<List<Transaction>> findDuplicates(
    Session session,
    UuidValue budgetId,
    int amountCents,
    DateTime transactionDate,
  ) async => TransactionService.findDuplicates(
      session,
      budgetId: budgetId,
      amountCents: amountCents,
      transactionDate: transactionDate,
    );

  /// Deletes a transaction by ID.
  Future<Transaction> delete(Session session, UuidValue transactionId) async {
    final transaction = await TransactionService.delete(
      session,
      transactionId: transactionId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }
}
