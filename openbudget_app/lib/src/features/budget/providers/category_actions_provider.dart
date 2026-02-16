import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_actions_provider.g.dart';

@Riverpod(keepAlive: true)
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
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
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
    required String budgetId,
    required List<String> categoryIds,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.category.reorder(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        categoryIds
            .map(
              // Serverpod API requires UuidValue which is experimental in uuid package.
              // ignore: experimental_member_use
              UuidValue.fromString,
            )
            .toList(),
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
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
    required String budgetId,
    required bool isHidden,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.category.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(categoryId),
        isHidden: isHidden,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
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
    required String budgetId,
    required String name,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final category = await client.category.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(categoryId),
        name: name,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
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

  Future<Category> deleteCategory({
    required String categoryId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      final deleted = await client.category.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(categoryId),
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return deleted;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Recreates a previously deleted category for undo support.
  Future<Category> undoDeleteCategory({
    required Category deletedCategory,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final restored = await client.category.create(
        deletedCategory.name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        deletedCategory.sortOrder,
      );
      if (ref.mounted) {
        ref
          ..invalidate(categoryListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return restored;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
