import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_actions_provider.g.dart';

/// Every transaction write goes through `transaction.*` and relies on
/// `EntityChangedEvent` for refreshes; the local invalidations keep tests
/// and offline flows correct too. The server computes base amounts, FX
/// sources and balances; the app never converts.
@Riverpod(keepAlive: true)
class TransactionActions extends _$TransactionActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Creates a transaction from one input. [input.lines] may be empty for a
  /// single-line transaction; the server builds the line.
  Future<TransactionView> create({
    required TransactionInput input,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final view = await client.transaction.create(input);
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
      return view;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Replaces a transaction and its lines. A reconciled transaction rejects
  /// money edits; the server enforces this.
  Future<TransactionView> update({
    required String transactionId,
    required TransactionInput input,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final view = await client.transaction.update(
        UuidValue.fromString(transactionId),
        input,
      );
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
      return view;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Deletes a transaction, or both legs when it is part of a transfer.
  Future<void> delete({
    required String transactionId,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.transaction.delete(UuidValue.fromString(transactionId));
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Bulk status change. `reconciled` cannot be set here; clearing a
  /// reconciled transaction unlocks it.
  Future<int> setStatus({
    required List<String> transactionIds,
    required TransactionStatus status,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final count = await client.transaction.setStatus(
      transactionIds.map(UuidValue.fromString).toList(),
      status,
    );
    if (ref.mounted) ref.invalidate(transactionPagesProvider(entityId));
    return count;
  }

  Future<int> setFlag({
    required List<String> transactionIds,
    required String entityId,
    TransactionFlag? flag,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final count = await client.transaction.setFlag(
      transactionIds.map(UuidValue.fromString).toList(),
      flag,
    );
    if (ref.mounted) ref.invalidate(transactionPagesProvider(entityId));
    return count;
  }

  Future<void> bulkDelete({
    required List<String> transactionIds,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      for (final id in transactionIds) {
        await client.transaction.delete(UuidValue.fromString(id));
      }
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Creates both legs of a transfer and their link.
  Future<List<TransactionView>> createTransfer({
    required TransferInput input,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final legs = await client.transaction.createTransfer(input);
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
      return legs;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Replaces both legs of an existing transfer.
  Future<List<TransactionView>> updateTransfer({
    required String transferId,
    required TransferInput input,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final legs = await client.transaction.updateTransfer(
        UuidValue.fromString(transferId),
        input,
      );
      if (ref.mounted) {
        ref.invalidate(transactionPagesProvider(entityId));
        state = const AsyncValue.data(null);
      }
      return legs;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Reconciles an account against a statement balance. With
  /// [createAdjustment] the difference becomes a cleared adjustment
  /// transaction dated [statementDate].
  Future<ReconcileResult> reconcile({
    required String accountId,
    required DateTime statementDate,
    required int statementBalanceMinor,
    required bool createAdjustment,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.transaction.reconcile(
      UuidValue.fromString(accountId),
      statementDate,
      statementBalanceMinor,
      createAdjustment,
    );
  }

  /// Imports rows into one account idempotently.
  Future<ImportResult> importRows({
    required String accountId,
    required List<ImportRow> rows,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.transaction.importRows(
      UuidValue.fromString(accountId),
      rows,
    );
  }

  /// Same account, same amount, date within ±3 days.
  Future<List<TransactionView>> findDuplicates({
    required String accountId,
    required DateTime date,
    required int amountMinor,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.transaction.findDuplicates(
      UuidValue.fromString(accountId),
      date,
      amountMinor,
    );
  }
}
