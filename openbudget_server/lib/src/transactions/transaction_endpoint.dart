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
  }) async {
    return TransactionService.update(
      session,
      transactionId: transactionId,
      description: description,
      amountCents: amountCents,
      envelopeId: envelopeId,
      payeeId: payeeId,
      transactionDate: transactionDate,
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

  /// Deletes a transaction by ID.
  Future<Transaction> delete(Session session, UuidValue transactionId) async {
    return TransactionService.delete(session, transactionId: transactionId);
  }
}
