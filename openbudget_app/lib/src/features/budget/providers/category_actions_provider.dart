import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class CategoryActions extends _$CategoryActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<Category> createCategory({
    required String name,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final category = await client.category.create(
        UuidValue.fromString(entityId),
        name,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(entityId))
          ..invalidate(budgetMonthGroupsProvider)
          ..invalidate(budgetMonthProvider);
        state = const AsyncValue.data(null);
      }
      return category;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> reorderCategories({
    required String entityId,
    required List<String> categoryIds,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.category.reorder(
        UuidValue.fromString(entityId),
        categoryIds.map(UuidValue.fromString).toList(),
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(entityId))
          ..invalidate(budgetMonthGroupsProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> toggleHidden({
    required String categoryId,
    required String entityId,
    required bool isHidden,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.category.update(
        UuidValue.fromString(categoryId),
        isHidden: isHidden,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(entityId))
          ..invalidate(budgetMonthGroupsProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<Category> updateCategory({
    required String categoryId,
    required String entityId,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final category = await client.category.update(
        UuidValue.fromString(categoryId),
        name: name,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(entityId))
          ..invalidate(budgetMonthGroupsProvider);
        state = const AsyncValue.data(null);
      }
      return category;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Deletes an empty category; the server refuses while envelopes remain.
  Future<void> deleteCategory({
    required String categoryId,
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.category.delete(UuidValue.fromString(categoryId));
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(entityId))
          ..invalidate(budgetMonthGroupsProvider);
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
