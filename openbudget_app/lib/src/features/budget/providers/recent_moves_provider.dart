import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';

enum RecentMoveType { moved, assigned }

@immutable
class RecentMoveEvent {
  const RecentMoveEvent({
    required this.occurredAt,
    required this.type,
    required this.toEnvelopeId,
    required this.amountMinor,
    this.fromEnvelopeId,
  });

  final DateTime occurredAt;
  final RecentMoveType type;
  final String toEnvelopeId;
  final String? fromEnvelopeId;
  final int amountMinor;
}

class RecentMovesNotifier extends Notifier<Map<String, List<RecentMoveEvent>>> {
  static const _maxEvents = 120;

  @override
  Map<String, List<RecentMoveEvent>> build() => {};

  void recordMove({
    required String entityId,
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required int amountMinor,
  }) {
    if (amountMinor <= 0) {
      return;
    }
    _insert(
      entityId: entityId,
      event: RecentMoveEvent(
        occurredAt: DateTime.now(),
        type: RecentMoveType.moved,
        fromEnvelopeId: fromEnvelopeId,
        toEnvelopeId: toEnvelopeId,
        amountMinor: amountMinor,
      ),
    );
  }

  void recordAssigned({
    required String entityId,
    required String envelopeId,
    required int amountMinor,
  }) {
    if (amountMinor <= 0) {
      return;
    }
    _insert(
      entityId: entityId,
      event: RecentMoveEvent(
        occurredAt: DateTime.now(),
        type: RecentMoveType.assigned,
        toEnvelopeId: envelopeId,
        amountMinor: amountMinor,
      ),
    );
  }

  bool undoLast({required String entityId}) {
    final current = state[entityId];
    if (current == null || current.isEmpty) {
      return false;
    }

    final remaining = current.length > 1
        ? current.sublist(1)
        : const <RecentMoveEvent>[];
    final next = Map<String, List<RecentMoveEvent>>.from(state);
    if (remaining.isEmpty) {
      next.remove(entityId);
    } else {
      next[entityId] = remaining;
    }
    state = next;
    return true;
  }

  void _insert({required String entityId, required RecentMoveEvent event}) {
    final current = state[entityId] ?? const <RecentMoveEvent>[];
    state = {
      ...state,
      entityId: [event, ...current].take(_maxEvents).toList(),
    };
  }
}

final recentMovesProvider =
    NotifierProvider<RecentMovesNotifier, Map<String, List<RecentMoveEvent>>>(
      RecentMovesNotifier.new,
    );

final ProviderFamily<List<RecentMoveEvent>, String>
recentMovesForBudgetProvider = Provider.family<List<RecentMoveEvent>, String>((
  ref,
  entityId,
) {
  final allEvents = ref.watch(recentMovesProvider);
  return allEvents[entityId] ?? const <RecentMoveEvent>[];
});

class RecentMovesIntroNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void markSeen(String entityId) {
    state = {...state, entityId};
  }
}

final recentMovesIntroSeenSetProvider =
    NotifierProvider<RecentMovesIntroNotifier, Set<String>>(
      RecentMovesIntroNotifier.new,
    );

final ProviderFamily<bool, String> recentMovesIntroSeenProvider =
    Provider.family<bool, String>((
      ref,
      entityId,
    ) {
      final seen = ref.watch(recentMovesIntroSeenSetProvider);
      return seen.contains(entityId);
    });
