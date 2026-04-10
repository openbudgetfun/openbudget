import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class CreateBudget extends _$CreateBudget {
  @override
  AsyncValue<String?> build() => const AsyncValue.data(null);

  Future<String> create({
    required String name,
    required CurrencyCode currency,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);

    try {
      final budget = await client.budget.create(name, currency.code);
      if (!ref.mounted) return '';

      final budgetId = budget.id?.toString() ?? '';
      state = AsyncValue.data(budgetId);
      ref.invalidate(budgetListProvider);
      return budgetId;
    } on Exception catch (e, st) {
      if (!ref.mounted) return '';
      state = AsyncValue.error(e, st);
      return '';
    }
  }
}
