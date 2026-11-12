import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auto_assign_provider.g.dart';

class AutoAssignItem extends Equatable {
  const AutoAssignItem({
    required this.envelopeId,
    required this.envelopeName,
    required this.currentAllocatedMinor,
    required this.proposedAllocatedMinor,
    required this.addedMinor,
  });

  final String envelopeId;
  final String envelopeName;
  final int currentAllocatedMinor;
  final int proposedAllocatedMinor;
  final int addedMinor;

  @override
  List<Object?> get props => [
    envelopeId,
    envelopeName,
    currentAllocatedMinor,
    proposedAllocatedMinor,
    addedMinor,
  ];
}

class AutoAssignProposal extends Equatable {
  const AutoAssignProposal({
    required this.items,
    required this.totalToAssignMinor,
    required this.totalAssignedMinor,
  });

  final List<AutoAssignItem> items;
  final int totalToAssignMinor;
  final int totalAssignedMinor;

  @override
  List<Object?> get props => [items, totalToAssignMinor, totalAssignedMinor];
}

/// Computes an auto-assign proposal from the month view alone: Ready to
/// Assign money goes to underfunded envelopes, in envelope order. Nothing
/// is written until [AutoAssignActions.execute] sends one `setAllocations`.
@riverpod
Future<AutoAssignProposal> autoAssignProposal(Ref ref, String entityId) async {
  final view = await ref.watch(budgetMonthProvider(entityId).future);

  final readyToAssign = view.summary.readyToAssignMinor;
  if (readyToAssign <= 0) {
    return const AutoAssignProposal(
      items: [],
      totalToAssignMinor: 0,
      totalAssignedMinor: 0,
    );
  }

  var remaining = readyToAssign;
  final items = <AutoAssignItem>[];

  for (final envelope in view.envelopes) {
    if (remaining <= 0) break;
    final needed = envelope.goalUnderfundedMinor;
    if (needed <= 0) continue;

    final toAdd = remaining < needed ? remaining : needed;
    final envelopeId = envelope.envelope.id?.toString() ?? '';
    items.add(
      AutoAssignItem(
        envelopeId: envelopeId,
        envelopeName: envelope.envelope.name,
        currentAllocatedMinor: envelope.allocatedMinor,
        proposedAllocatedMinor: envelope.allocatedMinor + toAdd,
        addedMinor: toAdd,
      ),
    );
    remaining -= toAdd;
  }

  final totalAssigned = items.fold<int>(0, (sum, item) => sum + item.addedMinor);

  return AutoAssignProposal(
    items: items,
    totalToAssignMinor: readyToAssign,
    totalAssignedMinor: totalAssigned,
  );
}

@Riverpod(keepAlive: true)
class AutoAssignActions extends _$AutoAssignActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Applies the proposal as one `setAllocations` call and returns the new
  /// month view.
  Future<BudgetMonthView?> execute({
    required String entityId,
    required List<AutoAssignItem> items,
  }) async {
    state = const AsyncValue.loading();
    try {
      final view = await ref
          .read(budgetMonthActionsProvider.notifier)
          .setAllocations(
            entityId: entityId,
            allocations: items
                .map(
                  (item) => AllocationInput(
                    envelopeId: UuidValue.fromString(item.envelopeId),
                    allocatedMinor: item.proposedAllocatedMinor,
                  ),
                )
                .toList(),
          );
      if (ref.mounted) state = const AsyncValue.data(null);
      return view;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
