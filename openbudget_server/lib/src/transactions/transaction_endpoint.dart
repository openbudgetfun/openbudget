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
    return TransactionService.create(
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
  }

  /// Lists all transactions for a budget.
  Future<List<Transaction>> list(Session session, UuidValue budgetId) async {
    return TransactionService.listForBudget(session, budgetId: budgetId);
  }

  /// Lists transactions for a budget within a specific month.
  Future<List<Transaction>> listByMonth(
    Session session,
    UuidValue budgetId,
    int year,
    int month,
  ) async {
    return TransactionService.listForBudgetMonth(
      session,
      budgetId: budgetId,
      year: year,
      month: month,
    );
  }

  /// Gets a single transaction by ID.
  Future<Transaction> get(Session session, UuidValue transactionId) async {
    return TransactionService.getById(session, transactionId: transactionId);
  }

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
  }) async {
    return TransactionService.update(
      session,
      transactionId: transactionId,
      description: description,
      amountCents: amountCents,
      envelopeId: envelopeId,
      payeeId: payeeId,
      transactionDate: transactionDate,
      memo: memo,
    );
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
    return TransactionService.createTransfer(
      session,
      description: description,
      amountCents: amountCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      transactionDate: transactionDate,
    );
  }

  /// Lists transactions for a specific account.
  Future<List<Transaction>> listByAccount(
    Session session,
    UuidValue accountId,
    UuidValue budgetId,
  ) async {
    return TransactionService.listForAccount(
      session,
      accountId: accountId,
      budgetId: budgetId,
    );
  }

  /// Toggles the cleared status of a transaction.
  Future<Transaction> toggleCleared(
    Session session,
    UuidValue transactionId,
  ) async {
    return TransactionService.toggleCleared(
      session,
      transactionId: transactionId,
    );
  }

  /// Reconciles all cleared transactions for an account.
  Future<int> reconcileAccount(
    Session session,
    UuidValue accountId,
    UuidValue budgetId,
  ) async {
    return TransactionService.reconcileAccount(
      session,
      accountId: accountId,
      budgetId: budgetId,
    );
  }

  /// Calculates the "Age of Money" for a budget.
  ///
  /// Returns the average days between income and spending, or null if
  /// there is insufficient data.
  Future<int?> ageOfMoney(Session session, UuidValue budgetId) async {
    return TransactionService.ageOfMoney(session, budgetId: budgetId);
  }

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
    return TransactionService.createSplit(
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
  }

  /// Lists the sub-transactions (splits) for a parent transaction.
  Future<List<Transaction>> listSplits(
    Session session,
    UuidValue parentTransactionId,
  ) async {
    return TransactionService.listSplits(
      session,
      parentTransactionId: parentTransactionId,
    );
  }

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
    return TransactionService.bulkCreate(
      session,
      budgetId: budgetId,
      currencyCode: currencyCode,
      rows: rows,
      accountId: accountId,
    );
  }

  /// Finds potential duplicate transactions with the same amount near a date.
  Future<List<Transaction>> findDuplicates(
    Session session,
    UuidValue budgetId,
    int amountCents,
    DateTime transactionDate,
  ) async {
    return TransactionService.findDuplicates(
      session,
      budgetId: budgetId,
      amountCents: amountCents,
      transactionDate: transactionDate,
    );
  }

  /// Deletes a transaction by ID.
  Future<Transaction> delete(Session session, UuidValue transactionId) async {
    return TransactionService.delete(session, transactionId: transactionId);
  }
}
