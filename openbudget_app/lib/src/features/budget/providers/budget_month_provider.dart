import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_month_provider.g.dart';

/// The server's month view for the selected month: envelope figures come
/// from `EnvelopeMonthView`, never from `Envelope`.
@riverpod
Future<BudgetMonthView> budgetMonth(Ref ref, String entityId) async {
  final month = ref.watch(selectedMonthProvider(entityId));
  final client = ref.read(serverpodClientProvider);
  return client.budget.getMonth(UuidValue.fromString(entityId), month);
}

/// A category with its envelopes' month figures, for the plan list.
class CategoryMonthGroup {
  const CategoryMonthGroup({
    required this.category,
    required this.envelopes,
  });

  final Category category;
  final List<EnvelopeMonthView> envelopes;

  int get allocatedMinor =>
      envelopes.fold(0, (sum, e) => sum + e.allocatedMinor);

  int get activityMinor => envelopes.fold(0, (sum, e) => sum + e.activityMinor);

  int get availableMinor => envelopes.fold(0, (sum, e) => sum + e.availableMinor);

  bool get isOverspent => envelopes.any((e) => e.availableMinor < 0);
}

/// The month view grouped by category in display order, ready for the plan
/// screen. Envelope figures always come from [EnvelopeMonthView].
@riverpod
Future<List<CategoryMonthGroup>> budgetMonthGroups(
  Ref ref,
  String entityId,
) async {
  final view = await ref.watch(budgetMonthProvider(entityId).future);
  final byCategory = <String, List<EnvelopeMonthView>>{};
  for (final envelope in view.envelopes) {
    final categoryId = envelope.envelope.categoryId.toString();
    byCategory.putIfAbsent(categoryId, () => []).add(envelope);
  }

  final groups = <CategoryMonthGroup>[];
  for (final category in view.categories) {
    final categoryId = category.id?.toString() ?? '';
    final envelopes = byCategory.remove(categoryId) ?? const [];
    if (category.isHidden && envelopes.isEmpty) continue;
    groups.add(
      CategoryMonthGroup(category: category, envelopes: envelopes),
    );
  }
  return groups;
}

/// Every category of the entity, for pickers and the category screens.
@riverpod
Future<List<Category>> categoryList(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.category.list(UuidValue.fromString(entityId));
}

/// Every envelope of the entity, replacing the old per-category list.
@riverpod
Future<List<Envelope>> envelopeList(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.envelope.list(UuidValue.fromString(entityId));
}

/// Writes allocations and moves. Every write returns the fresh
/// month view, which replaces the cached one immediately.
@riverpod
class BudgetMonthActions extends _$BudgetMonthActions {
  @override
  AsyncValue<BudgetMonthView?> build() => const AsyncValue.data(null);

  Future<BudgetMonthView?> setAllocations({
    required String entityId,
    required List<AllocationInput> allocations,
  }) async {
    final month = ref.read(selectedMonthProvider(entityId));
    return _run(
      entityId,
      () => ref.read(serverpodClientProvider).budget.setAllocations(
        UuidValue.fromString(entityId),
        month,
        allocations,
      ),
    );
  }

  /// A null envelope id means Ready to Assign; [amountMinor] is positive.
  Future<BudgetMonthView?> moveMoney({
    required String entityId,
    String? fromEnvelopeId,
    String? toEnvelopeId,
    required int amountMinor,
  }) async {
    final month = ref.read(selectedMonthProvider(entityId));
    return _run(
      entityId,
      () => ref.read(serverpodClientProvider).budget.moveMoney(
        UuidValue.fromString(entityId),
        month,
        fromEnvelopeId == null
            ? null
            : UuidValue.fromString(fromEnvelopeId),
        toEnvelopeId == null ? null : UuidValue.fromString(toEnvelopeId),
        amountMinor,
      ),
    );
  }

  Future<BudgetMonthView?> copyPreviousMonth({required String entityId}) async {
    final month = ref.read(selectedMonthProvider(entityId));
    return _run(
      entityId,
      () => ref
          .read(serverpodClientProvider)
          .budget
          .copyMonth(
            UuidValue.fromString(entityId),
            MonthKey.previous(month),
            month,
          ),
    );
  }

  Future<BudgetMonthView?> _run(
    String entityId,
    Future<BudgetMonthView> Function() action,
  ) async {
    state = const AsyncValue.loading();
    try {
      final view = await action();
      if (ref.mounted) {
        state = AsyncValue.data(view);
        // The write path already posted an entity event; invalidating here
        // as well keeps the screen correct in tests and offline runs.
        ref.invalidate(budgetMonthProvider(entityId));
      }
      return view;
    } on Exception catch (e, st) {
      if (ref.mounted) state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
