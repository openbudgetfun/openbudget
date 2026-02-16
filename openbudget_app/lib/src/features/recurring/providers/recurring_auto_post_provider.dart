import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_auto_post_provider.g.dart';

/// Fetches the count of due recurring transactions for a budget.
@riverpod
Future<int> recurringDueCount(Ref ref, String budgetId) async {
  final client = ref.watch(serverpodClientProvider);
  return client.recurringTransaction.countDue(
    // UuidValue is experimental in the uuid package.
    // ignore: experimental_member_use
    UuidValue.fromString(budgetId),
  );
}

/// Posts all due recurring transactions and returns the count posted.
@Riverpod(keepAlive: true)
class RecurringAutoPostActions extends _$RecurringAutoPostActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<int> postDue({required String budgetId}) async {
    state = const AsyncValue.loading();
    try {
      final client = ref.read(serverpodClientProvider);
      final count = await client.recurringTransaction.postDue(
        // UuidValue is experimental in the uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
      );

      // Invalidate relevant providers to refresh data.
      ref
        ..invalidate(recurringDueCountProvider(budgetId))
        ..invalidate(recurringListProvider(budgetId))
        ..invalidate(transactionListProvider(budgetId))
        ..invalidate(budgetSummaryProvider(budgetId))
        ..invalidate(budgetMonthlySummaryProvider(budgetId));

      if (ref.mounted) {
        state = const AsyncValue.data(null);
      }
      return count;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
