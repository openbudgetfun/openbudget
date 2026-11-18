import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'envelope_goal_provider.g.dart';

/// Every goal of the entity; the month view carries per-envelope goals for
/// display.
@riverpod
Future<List<EnvelopeGoal>> envelopeGoals(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.envelopeGoal.list(UuidValue.fromString(entityId));
}

@Riverpod(keepAlive: true)
class EnvelopeGoalActions extends _$EnvelopeGoalActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Creates or replaces one envelope's goal: one kind and one amount.
  Future<EnvelopeGoal> upsertGoal({
    required String envelopeId,
    required EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final goal = await client.envelopeGoal.upsert(
        UuidValue.fromString(envelopeId),
        kind,
        amountMinor,
        targetDate: targetDate,
      );
      if (ref.mounted) {
        ref.invalidate(envelopeGoalsProvider);
        state = const AsyncValue.data(null);
      }
      return goal;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> deleteGoal({required String goalId}) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelopeGoal.delete(UuidValue.fromString(goalId));
      if (ref.mounted) {
        ref.invalidate(envelopeGoalsProvider);
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
