import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'envelope_goal_provider.g.dart';

@riverpod
Future<EnvelopeGoal?> envelopeGoal(Ref ref, String envelopeId) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  return client.envelopeGoal.getForEnvelope(UuidValue.fromString(envelopeId));
}

@riverpod
Future<List<EnvelopeGoal>> envelopeGoals(
  Ref ref,
  List<String> envelopeIds,
) async {
  if (envelopeIds.isEmpty) return [];
  final client = ref.read(serverpodClientProvider);
  final uuids = envelopeIds
      .map(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString,
      )
      .toList();
  return client.envelopeGoal.listForEnvelopes(uuids);
}

@Riverpod(keepAlive: true)
class EnvelopeGoalActions extends _$EnvelopeGoalActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<EnvelopeGoal> upsertGoal({
    required String envelopeId,
    required String goalType,
    required int targetAmountCents,
    required String budgetId,
    DateTime? targetDate,
    int? monthlyFundingCents,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final goal = await client.envelopeGoal.upsert(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(envelopeId),
        goalType,
        targetAmountCents,
        targetDate: targetDate,
        monthlyFundingCents: monthlyFundingCents,
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeGoalProvider(envelopeId))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
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

  Future<void> deleteGoal({
    required String goalId,
    required String envelopeId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      await client.envelopeGoal.delete(UuidValue.fromString(goalId));
      if (ref.mounted) {
        ref
          ..invalidate(envelopeGoalProvider(envelopeId))
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
}
