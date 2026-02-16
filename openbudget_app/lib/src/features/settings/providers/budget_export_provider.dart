import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_export_provider.g.dart';

@Riverpod(keepAlive: true)
class BudgetExport extends _$BudgetExport {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<String> exportBudget(String budgetId) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final json = await client.budget.exportData(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
      );
      if (ref.mounted) {
        state = const AsyncValue.data(null);
      }
      return json;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
