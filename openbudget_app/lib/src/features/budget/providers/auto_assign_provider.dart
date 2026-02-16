import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_assign_provider.freezed.dart';
part 'auto_assign_provider.g.dart';

@freezed
sealed class AutoAssignItem with _$AutoAssignItem {
  const factory AutoAssignItem({
    required String envelopeId,
    required String envelopeName,
    required int currentAllocatedCents,
    required int proposedAllocatedCents,
    required int addedCents,
  }) = _AutoAssignItem;
}

@freezed
sealed class AutoAssignProposal with _$AutoAssignProposal {
  const factory AutoAssignProposal({
    required List<AutoAssignItem> items,
    required int totalToAssignCents,
    required int totalAssignedCents,
  }) = _AutoAssignProposal;
}

/// Computes an auto-assign proposal that distributes Ready to Assign money
/// across underfunded envelopes based on their goals.
@riverpod
Future<AutoAssignProposal> autoAssignProposal(Ref ref, String budgetId) async {
  final summary = await ref.watch(
    budgetMonthlySummaryProvider(budgetId).future,
  );
  final goals = await ref.watch(budgetGoalsProvider(budgetId).future);

  final readyToAssign = summary.readyToAssignCents;
  if (readyToAssign <= 0 || goals.isEmpty) {
    return const AutoAssignProposal(
      items: [],
      totalToAssignCents: 0,
      totalAssignedCents: 0,
    );
  }

  // Build list of underfunded envelopes with their needed amounts.
  final underfunded =
      <({String envelopeId, String name, int needed, int current})>[];

  for (final cat in summary.categories) {
    for (final envData in cat.monthlyEnvelopes) {
      final envelopeId = envData.envelope.id?.toString() ?? '';
      final goal = goals[envelopeId];
      if (goal == null) continue;

      final needed = computeUnderfundedCents(
        goal: goal,
        budgetedCents: envData.allocatedCents,
        availableCents: envData.availableCents,
      );

      if (needed > 0) {
        underfunded.add((
          envelopeId: envelopeId,
          name: envData.envelope.name,
          needed: needed,
          current: envData.allocatedCents,
        ));
      }
    }
  }

  if (underfunded.isEmpty) {
    return AutoAssignProposal(
      items: const [],
      totalToAssignCents: readyToAssign,
      totalAssignedCents: 0,
    );
  }

  // Distribute money: fund each envelope up to its needed amount until we
  // run out of Ready to Assign money.
  var remaining = readyToAssign;
  final items = <AutoAssignItem>[];

  for (final entry in underfunded) {
    if (remaining <= 0) break;

    final toAdd = remaining < entry.needed ? remaining : entry.needed;
    items.add(
      AutoAssignItem(
        envelopeId: entry.envelopeId,
        envelopeName: entry.name,
        currentAllocatedCents: entry.current,
        proposedAllocatedCents: entry.current + toAdd,
        addedCents: toAdd,
      ),
    );
    remaining -= toAdd;
  }

  final totalAssigned = items.fold<int>(
    0,
    (sum, item) => sum + item.addedCents,
  );

  return AutoAssignProposal(
    items: items,
    totalToAssignCents: readyToAssign,
    totalAssignedCents: totalAssigned,
  );
}

@Riverpod(keepAlive: true)
class AutoAssignActions extends _$AutoAssignActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Executes the auto-assign proposal by upserting allocations for each item.
  Future<int> execute({
    required String budgetId,
    required List<AutoAssignItem> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      final selectedMonth = ref.read(selectedMonthProvider(budgetId));
      final year = selectedMonth.year;
      final month = selectedMonth.month;
      final actions = ref.read(monthlyAllocationActionsProvider.notifier);

      var count = 0;
      for (final item in items) {
        await actions.upsertAllocation(
          envelopeId: item.envelopeId,
          budgetId: budgetId,
          year: year,
          month: month,
          allocatedCents: item.proposedAllocatedCents,
        );
        count++;
      }

      if (ref.mounted) {
        ref.invalidate(budgetMonthlySummaryProvider(budgetId));
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
