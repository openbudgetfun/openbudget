import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for transaction operations.
///
/// Every method requires authentication and delegates to
/// [TransactionService], which owns ownership checks and the write boundary.
class TransactionEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates a transaction header and its lines.
  Future<TransactionView> create(Session session, TransactionInput input) =>
      TransactionService.create(session, input);

  /// Loads one owned transaction with its lines and transfer peer.
  Future<TransactionView> get(
    Session session,
    UuidValue transactionId,
  ) => TransactionService.get(session, transactionId);

  /// Lists one keyset page of an owned entity's transactions.
  Future<TransactionPage> list(Session session, TransactionQuery query) =>
      TransactionService.list(session, query);

  /// Replaces a transaction and its lines.
  Future<TransactionView> update(
    Session session,
    UuidValue transactionId,
    TransactionInput input,
  ) => TransactionService.update(session, transactionId, input);

  /// Deletes a transaction, both legs of a transfer, and their balances.
  Future<void> delete(Session session, UuidValue transactionId) =>
      TransactionService.delete(session, transactionId);

  /// Sets one status on a page of owned transactions.
  ///
  /// `reconciled` is rejected here; clearing a reconciled row unlocks it.
  Future<int> setStatus(
    Session session,
    List<UuidValue> transactionIds,
    TransactionStatus status,
  ) => TransactionService.setStatus(session, transactionIds, status);

  /// Sets or clears one flag on a page of owned transactions.
  Future<int> setFlag(
    Session session,
    List<UuidValue> transactionIds,
    TransactionFlag? flag,
  ) => TransactionService.setFlag(session, transactionIds, flag);

  /// Creates both legs of a transfer and their link.
  Future<List<TransactionView>> createTransfer(
    Session session,
    TransferInput input,
  ) => TransactionService.createTransfer(session, input);

  /// Replaces both legs of an existing transfer.
  Future<List<TransactionView>> updateTransfer(
    Session session,
    UuidValue transferId,
    TransferInput input,
  ) => TransactionService.updateTransfer(session, transferId, input);

  /// Reconciles one owned transactions account against a statement balance.
  Future<ReconcileResult> reconcile(
    Session session,
    UuidValue accountId,
    DateTime statementDate,
    int statementBalanceMinor,
    // The documented reconcile signature keeps createAdjustment positional.
    // ignore: avoid_positional_boolean_parameters
    bool createAdjustment,
  ) => TransactionService.reconcile(
    session,
    accountId,
    statementDate,
    statementBalanceMinor,
    createAdjustment,
  );

  /// Imports rows into one owned transactions account idempotently.
  ///
  /// `externalId` dedupes the file, so retrying the same rows inserts only
  /// the new ones. Row-level validation failures come back with their
  /// 0-based index in [ImportResult.errors].
  Future<ImportResult> importRows(
    Session session,
    UuidValue accountId,
    List<ImportRow> rows,
  ) => TransactionService.importRows(session, accountId, rows);

  /// Finds same-account, same-amount transactions within three days.
  Future<List<TransactionView>> findDuplicates(
    Session session,
    UuidValue accountId,
    DateTime date,
    int amountMinor,
  ) => TransactionService.findDuplicates(session, accountId, date, amountMinor);
}
