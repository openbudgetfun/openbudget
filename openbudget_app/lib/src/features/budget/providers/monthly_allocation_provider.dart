import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monthly_allocation_provider.g.dart';

@riverpod
Future<List<MonthlyAllocation>> monthlyAllocations(
  Ref ref,
  String budgetId,
  int year,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.monthlyAllocation.list(
    UuidValue.fromString(budgetId),
    year,
    month,
  );
}

@riverpod
Future<List<Transaction>> monthlyTransactions(
  Ref ref,
  String budgetId,
  int year,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.transaction.listByMonth(
    UuidValue.fromString(budgetId),
    year,
    month,
  );
}

@Riverpod(keepAlive: true)
class MonthlyAllocationActions extends _$MonthlyAllocationActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<List<MonthlyAllocation>> moveMoney({
    required String fromEnvelopeId,
    required String toEnvelopeId,
    required String budgetId,
    required int year,
    required int month,
    required int amountCents,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final result = await client.monthlyAllocation.moveMoney(
        UuidValue.fromString(fromEnvelopeId),
        UuidValue.fromString(toEnvelopeId),
        UuidValue.fromString(budgetId),
        year,
        month,
        amountCents,
      );
      if (ref.mounted) {
        ref
            .read(recentMovesProvider.notifier)
            .recordMove(
              budgetId: budgetId,
              fromEnvelopeId: fromEnvelopeId,
              toEnvelopeId: toEnvelopeId,
              amountCents: amountCents,
            );
        ref
          ..invalidate(monthlyAllocationsProvider(budgetId, year, month))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return result;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<List<MonthlyAllocation>> copyPreviousMonth({
    required String budgetId,
    required int currentYear,
    required int currentMonth,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);

    // Calculate previous month.
    final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;
    final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;

    try {
      final result = await client.monthlyAllocation.copyMonth(
        UuidValue.fromString(budgetId),
        prevYear,
        prevMonth,
        currentYear,
        currentMonth,
      );
      if (ref.mounted) {
        ref
          ..invalidate(
            monthlyAllocationsProvider(budgetId, currentYear, currentMonth),
          )
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return result;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<MonthlyAllocation> upsertAllocation({
    required String envelopeId,
    required String budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    int carryoverCents = 0,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final allocation = await client.monthlyAllocation.upsert(
        UuidValue.fromString(envelopeId),
        UuidValue.fromString(budgetId),
        year,
        month,
        allocatedCents,
        carryoverCents: carryoverCents,
      );
      if (ref.mounted) {
        ref
            .read(recentMovesProvider.notifier)
            .recordAssigned(
              budgetId: budgetId,
              envelopeId: envelopeId,
              amountCents: allocatedCents,
            );
        ref
          ..invalidate(monthlyAllocationsProvider(budgetId, year, month))
          ..invalidate(budgetMonthlySummaryProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return allocation;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
