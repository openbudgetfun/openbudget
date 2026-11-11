import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for transaction operations.
///
/// Every method requires authentication and delegates to
/// [TransactionService], which owns ownership checks and the write boundary.
/// Reconciliation and import are separate units; this endpoint exposes only
/// the implemented modern surface and has no placeholder methods for them.
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

  /// Finds same-account, same-amount transactions within three days.
  Future<List<TransactionView>> findDuplicates(
    Session session,
    UuidValue accountId,
    DateTime date,
    int amountMinor,
  ) => TransactionService.findDuplicates(session, accountId, date, amountMinor);
}
