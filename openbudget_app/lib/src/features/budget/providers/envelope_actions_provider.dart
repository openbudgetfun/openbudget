import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'envelope_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class EnvelopeActions extends _$EnvelopeActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<Envelope> createEnvelope({
    required String name,
    required String categoryId,
    required int budgetedAmountCents,
    required String currencyCode,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final envelope = await client.envelope.create(
        name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(categoryId),
        budgetedAmountCents,
        currencyCode,
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeListProvider(categoryId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return envelope;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> updateEnvelope({
    required String envelopeId,
    required String categoryId,
    required String budgetId,
    String? name,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelope.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(envelopeId),
        name: name,
        budgetedAmountCents: budgetedAmountCents,
        spentAmountCents: spentAmountCents,
        note: note,
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeListProvider(categoryId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> toggleHidden({
    required String envelopeId,
    required String categoryId,
    required String budgetId,
    required bool isHidden,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelope.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(envelopeId),
        isHidden: isHidden,
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeListProvider(categoryId))
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

  Future<void> reorderEnvelopes({
    required String categoryId,
    required String budgetId,
    required List<String> envelopeIds,
  }) async {
    final client = ref.read(serverpodClientProvider);
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    final categoryUuid = UuidValue.fromString(categoryId);
    await client.envelope.reorder(categoryUuid, envelopeIds);
    if (ref.mounted) {
      ref
        ..invalidate(envelopeListProvider(categoryId))
        ..invalidate(budgetSummaryProvider(budgetId));
    }
  }

  Future<Envelope> deleteEnvelope({
    required String envelopeId,
    required String categoryId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      final deleted = await client.envelope.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(envelopeId),
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeListProvider(categoryId))
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

  /// Recreates a previously deleted envelope for undo support.
  Future<Envelope> undoDeleteEnvelope({
    required Envelope deletedEnvelope,
    required String categoryId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final restored = await client.envelope.create(
        deletedEnvelope.name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(categoryId),
        deletedEnvelope.budgetedAmountCents,
        deletedEnvelope.currencyCode,
      );
      if (ref.mounted) {
        ref
          ..invalidate(envelopeListProvider(categoryId))
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
