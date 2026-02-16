import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_transactions_provider.g.dart';

@riverpod
Future<List<Transaction>> accountTransactions(
  Ref ref,
  String budgetId,
  String accountId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final accountUuid = UuidValue.fromString(accountId);
  // UuidValue.fromString is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  return client.transaction.listByAccount(accountUuid, budgetUuid);
}

@riverpod
class AccountTransactionActions extends _$AccountTransactionActions {
  @override
  FutureOr<void> build() {}

  Future<Transaction> toggleCleared({
    required String transactionId,
    required String budgetId,
    required String accountId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final txnUuid = UuidValue.fromString(transactionId);
    final result = await client.transaction.toggleCleared(txnUuid);
    ref
      ..invalidate(accountTransactionsProvider(budgetId, accountId))
      ..invalidate(accountListProvider(budgetId));
    return result;
  }

  Future<int> reconcileAccount({
    required String accountId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final accountUuid = UuidValue.fromString(accountId);
    // UuidValue.fromString is experimental in uuid package.
    // ignore: experimental_member_use
    final budgetUuid = UuidValue.fromString(budgetId);
    final count = await client.transaction.reconcileAccount(
      accountUuid,
      budgetUuid,
    );
    ref
      ..invalidate(accountTransactionsProvider(budgetId, accountId))
      ..invalidate(accountListProvider(budgetId));
    return count;
  }

  Future<List<int>> reconcileWithBalance({
    required String accountId,
    required String budgetId,
    required int statementBalanceCents,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final accountUuid = UuidValue.fromString(accountId);
    // UuidValue.fromString is experimental in uuid package.
    // ignore: experimental_member_use
    final budgetUuid = UuidValue.fromString(budgetId);
    final result = await client.transaction.reconcileWithBalance(
      accountUuid,
      budgetUuid,
      statementBalanceCents,
    );
    ref
      ..invalidate(accountTransactionsProvider(budgetId, accountId))
      ..invalidate(accountListProvider(budgetId));
    return result;
  }
}
