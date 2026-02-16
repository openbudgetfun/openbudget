import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class RecurringActions extends _$RecurringActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<RecurringTransaction> createRecurring({
    required String description,
    required int amountCents,
    required String currencyCode,
    required String budgetId,
    required String frequency,
    required DateTime nextOccurrence,
    String? envelopeId,
    String? accountId,
    String? payeeId,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.create(
        description,
        amountCents,
        currencyCode,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        frequency,
        nextOccurrence,
        envelopeId: envelopeId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(envelopeId)
            : null,
        accountId: accountId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(accountId)
            : null,
        payeeId: payeeId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(payeeId)
            : null,
        endDate: endDate,
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return recurring;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<RecurringTransaction> updateRecurring({
    required String recurringId,
    required String budgetId,
    String? description,
    int? amountCents,
    String? frequency,
    DateTime? nextOccurrence,
    DateTime? endDate,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(recurringId),
        description: description,
        amountCents: amountCents,
        frequency: frequency,
        nextOccurrence: nextOccurrence,
        endDate: endDate,
        isActive: isActive,
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return recurring;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<RecurringTransaction> skipOccurrence({
    required String recurringId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.skipOccurrence(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(recurringId),
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return recurring;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> deleteRecurring({
    required String recurringId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.recurringTransaction.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(recurringId),
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(budgetId));
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
