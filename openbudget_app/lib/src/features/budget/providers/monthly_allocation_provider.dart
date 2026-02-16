import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
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
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  return client.monthlyAllocation.list(
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
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
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  return client.transaction.listByMonth(
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    UuidValue.fromString(budgetId),
    year,
    month,
  );
}

@Riverpod(keepAlive: true)
class MonthlyAllocationActions extends _$MonthlyAllocationActions {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
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
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(envelopeId),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        year,
        month,
        allocatedCents,
        carryoverCents: carryoverCents,
      );
      if (ref.mounted) {
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
