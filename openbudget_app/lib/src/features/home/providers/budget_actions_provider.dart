import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class BudgetActions extends _$BudgetActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> deleteBudget({required String budgetId}) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      await client.budget.delete(UuidValue.fromString(budgetId));
      if (ref.mounted) {
        ref.invalidate(budgetListProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
