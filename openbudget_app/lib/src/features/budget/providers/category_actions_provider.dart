import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_actions_provider.g.dart';

@riverpod
class CategoryActions extends _$CategoryActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<Category> createCategory({
    required String name,
    required String budgetId,
    required int sortOrder,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final category = await client.category.create(
        name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        sortOrder,
      );
      ref
        ..invalidate(categoryListProvider(budgetId))
        ..invalidate(budgetSummaryProvider(budgetId));
      state = const AsyncValue.data(null);
      return category;
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteCategory({
    required String categoryId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      await client.category.delete(UuidValue.fromString(categoryId));
      ref
        ..invalidate(categoryListProvider(budgetId))
        ..invalidate(budgetSummaryProvider(budgetId));
      state = const AsyncValue.data(null);
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
