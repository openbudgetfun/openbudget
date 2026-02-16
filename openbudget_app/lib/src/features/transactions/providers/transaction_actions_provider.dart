import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_actions_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class TransactionActions extends _$TransactionActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<Transaction> addIncome({
    required String description,
    required int amountCents,
    required String currencyCode,
    required String budgetId,
    required DateTime date,
    String? memo,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final transaction = await client.transaction.create(
        description,
        amountCents.abs(),
        currencyCode,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        date,
        memo: memo,
      );
      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return transaction;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Transaction> updateTransaction({
    required String transactionId,
    required String budgetId,
    String? description,
    int? amountCents,
    String? envelopeId,
    DateTime? transactionDate,
    String? memo,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final transaction = await client.transaction.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(transactionId),
        description: description,
        amountCents: amountCents,
        envelopeId: envelopeId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(envelopeId)
            : null,
        transactionDate: transactionDate,
        memo: memo,
      );
      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return transaction;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> deleteTransaction({
    required String transactionId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      await client.transaction.delete(UuidValue.fromString(transactionId));
      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Transaction> toggleCleared({
    required String transactionId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      final transaction = await client.transaction.toggleCleared(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(transactionId),
      );
      if (ref.mounted) {
        ref.invalidate(transactionListProvider(budgetId));
      }
      return transaction;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Transaction> setFlag({
    required String transactionId,
    required String budgetId,
    String? flagColor,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      final transaction = await client.transaction.setFlag(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(transactionId),
        flagColor: flagColor,
      );
      if (ref.mounted) {
        ref.invalidate(transactionListProvider(budgetId));
      }
      return transaction;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Transaction> addExpense({
    required String description,
    required int amountCents,
    required String currencyCode,
    required String budgetId,
    required DateTime date,
    String? envelopeId,
    String? categoryId,
    String? payeeId,
    String? memo,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final transaction = await client.transaction.create(
        description,
        -amountCents.abs(),
        currencyCode,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        date,
        envelopeId: envelopeId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(envelopeId)
            : null,
        payeeId: payeeId != null
            // Serverpod API requires UuidValue which is experimental in uuid package.
            // ignore: experimental_member_use
            ? UuidValue.fromString(payeeId)
            : null,
        memo: memo,
      );

      if (envelopeId != null && categoryId != null && ref.mounted) {
        await ref
            .read(envelopeActionsProvider.notifier)
            .updateEnvelope(
              envelopeId: envelopeId,
              categoryId: categoryId,
              budgetId: budgetId,
              spentAmountCents: amountCents.abs(),
            );
      }

      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return transaction;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
