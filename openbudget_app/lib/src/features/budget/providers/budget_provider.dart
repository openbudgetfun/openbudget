import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_provider.g.dart';

@riverpod
class CreateBudget extends _$CreateBudget {
  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  Future<String> create({
    required String name,
    required CurrencyCode currency,
  }) async {
    state = const AsyncValue.loading();

    // Placeholder: simulate budget creation
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!ref.mounted) return '';

    const budgetId = 'mock-budget-1';
    state = const AsyncValue.data(budgetId);
    return budgetId;
  }
}
