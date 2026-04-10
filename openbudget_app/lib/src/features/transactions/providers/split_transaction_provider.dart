import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'split_transaction_provider.g.dart';

@riverpod
Future<List<Transaction>> splitTransactions(
  Ref ref,
  String parentTransactionId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final parentUuid = UuidValue.fromString(parentTransactionId);
  return client.transaction.listSplits(parentUuid);
}

@Riverpod(keepAlive: true)
class SplitTransactionActions extends _$SplitTransactionActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<List<Transaction>> createSplit({
    required String description,
    required int totalAmountCents,
    required String currencyCode,
    required String budgetId,
    required DateTime date,
    required List<SplitItem> splits,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final result = await client.transaction.createSplit(
        description,
        totalAmountCents,
        currencyCode,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        date,
        splits,
      );

      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return result;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
