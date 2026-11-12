import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class RecurringActions extends _$RecurringActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Amounts are in the account's currency; posting is the server's job
  /// through the hourly recurring job, so there is no client auto-post.
  Future<RecurringTransaction> createRecurring({
    required String accountId,
    required String description,
    required int amountMinor,
    required RecurrenceFrequency frequency,
    required DateTime nextOccurrence,
    String? envelopeId,
    String? payeeId,
    String? memo,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.create(
        UuidValue.fromString(accountId),
        description,
        amountMinor,
        frequency,
        nextOccurrence,
        envelopeId: envelopeId != null
            ? UuidValue.fromString(envelopeId)
            : null,
        payeeId: payeeId != null ? UuidValue.fromString(payeeId) : null,
        memo: memo,
        endDate: endDate,
      );
      if (ref.mounted) {
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
    required String entityId,
    String? accountId,
    String? description,
    int? amountMinor,
    RecurrenceFrequency? frequency,
    DateTime? nextOccurrence,
    String? envelopeId,
    bool clearEnvelope = false,
    String? payeeId,
    bool clearPayee = false,
    String? memo,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.update(
        UuidValue.fromString(recurringId),
        accountId: accountId == null ? null : UuidValue.fromString(accountId),
        description: description,
        amountMinor: amountMinor,
        frequency: frequency,
        nextDate: nextOccurrence,
        envelopeId: envelopeId == null
            ? null
            : UuidValue.fromString(envelopeId),
        clearEnvelope: clearEnvelope,
        payeeId: payeeId == null ? null : UuidValue.fromString(payeeId),
        clearPayee: clearPayee,
        memo: memo,
        endDate: endDate,
        clearEndDate: clearEndDate,
        isActive: isActive,
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(entityId));
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
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final recurring = await client.recurringTransaction.skipOccurrence(
        UuidValue.fromString(recurringId),
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(entityId));
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
    required String entityId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.recurringTransaction.delete(
        UuidValue.fromString(recurringId),
      );
      if (ref.mounted) {
        ref.invalidate(recurringListProvider(entityId));
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

/// How many recurring transactions are due in [entityId] right now.
@riverpod
Future<int> recurringDueCount(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.recurringTransaction.countDue(UuidValue.fromString(entityId));
}
