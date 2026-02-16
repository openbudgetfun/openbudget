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

  Future<void> deleteEnvelope({
    required String envelopeId,
    required String categoryId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      await client.envelope.delete(UuidValue.fromString(envelopeId));
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
}
