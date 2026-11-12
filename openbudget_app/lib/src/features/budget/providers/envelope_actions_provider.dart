import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'envelope_actions_provider.g.dart';

/// Envelope writes: create, edit, hide, reorder and delete. Deleting an
/// envelope with history asks which envelope to move it to; allocations and
/// goals are plan data, edited through `budget.*` elsewhere.
@Riverpod(keepAlive: true)
class EnvelopeActions extends _$EnvelopeActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<Envelope> createEnvelope({
    required String name,
    required String categoryId,
    String? note,
    String? taxCategoryCode,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final envelope = await client.envelope.create(
        UuidValue.fromString(categoryId),
        name,
        note: note,
        taxCategoryCode: taxCategoryCode,
      );
      if (ref.mounted) {
        ref.invalidate(budgetMonthGroupsProvider);
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
    required String entityId,
    String? name,
    String? note,
    bool? isHidden,
    String? taxCategoryCode,
    bool clearTaxCategoryCode = false,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelope.update(
        UuidValue.fromString(envelopeId),
        name: name,
        categoryId: UuidValue.fromString(categoryId),
        note: note,
        isHidden: isHidden,
        taxCategoryCode: taxCategoryCode,
        clearTaxCategoryCode: clearTaxCategoryCode,
      );
      if (ref.mounted) {
        ref
          ..invalidate(budgetMonthGroupsProvider)
          ..invalidate(budgetMonthProvider);
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
    required String entityId,
    required bool isHidden,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelope.update(
        UuidValue.fromString(envelopeId),
        isHidden: isHidden,
      );
      if (ref.mounted) {
        ref
          ..invalidate(budgetMonthGroupsProvider)
          ..invalidate(budgetMonthProvider);
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
    required List<String> envelopeIds,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.envelope.reorder(
      UuidValue.fromString(categoryId),
      envelopeIds.map(UuidValue.fromString).toList(),
    );
    if (ref.mounted) {
      ref.invalidate(budgetMonthGroupsProvider);
    }
  }

  /// Deletes an envelope. When its history must survive, the caller passes
  /// [reassignToEnvelopeId]; the server refuses otherwise.
  Future<void> deleteEnvelope({
    required String envelopeId,
    String? reassignToEnvelopeId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.envelope.delete(
        UuidValue.fromString(envelopeId),
        reassignToEnvelopeId: reassignToEnvelopeId == null
            ? null
            : UuidValue.fromString(reassignToEnvelopeId),
      );
      if (ref.mounted) {
        ref
          ..invalidate(budgetMonthGroupsProvider)
          ..invalidate(budgetMonthProvider);
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
