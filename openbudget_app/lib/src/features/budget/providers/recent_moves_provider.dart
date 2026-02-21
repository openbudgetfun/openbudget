import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum RecentMoveType { moved, assigned }

@immutable
class RecentMoveEvent {
  const RecentMoveEvent({
    required this.occurredAt,
    required this.type,
    required this.toEnvelopeId,
    required this.amountCents,
    this.fromEnvelopeId,
  });

  final DateTime occurredAt;
  final RecentMoveType type;
  final String toEnvelopeId;
  final String? fromEnvelopeId;
  final int amountCents;
}

class RecentMovesNotifier extends Notifier<Map<String, List<RecentMoveEvent>>> {
  static const _maxEvents = 120;

  @override
  Map<String, List<RecentMoveEvent>> build() => {};

  void recordMove({
    required String budgetId,
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required int amountCents,
  }) {
    if (amountCents <= 0) {
      return;
    }
    _insert(
      budgetId: budgetId,
      event: RecentMoveEvent(
        occurredAt: DateTime.now(),
        type: RecentMoveType.moved,
        fromEnvelopeId: fromEnvelopeId,
        toEnvelopeId: toEnvelopeId,
        amountCents: amountCents,
      ),
    );
  }

  void recordAssigned({
    required String budgetId,
    required String envelopeId,
    required int amountCents,
  }) {
    if (amountCents <= 0) {
      return;
    }
    _insert(
      budgetId: budgetId,
      event: RecentMoveEvent(
        occurredAt: DateTime.now(),
        type: RecentMoveType.assigned,
        toEnvelopeId: envelopeId,
        amountCents: amountCents,
      ),
    );
  }

  void _insert({required String budgetId, required RecentMoveEvent event}) {
    final current = state[budgetId] ?? const <RecentMoveEvent>[];
    state = {
      ...state,
      budgetId: [event, ...current].take(_maxEvents).toList(),
    };
  }
}

final recentMovesProvider =
    NotifierProvider<RecentMovesNotifier, Map<String, List<RecentMoveEvent>>>(
      RecentMovesNotifier.new,
    );

final recentMovesForBudgetProvider =
    Provider.family<List<RecentMoveEvent>, String>((ref, budgetId) {
      final allEvents = ref.watch(recentMovesProvider);
      return allEvents[budgetId] ?? const <RecentMoveEvent>[];
    });
