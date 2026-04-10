import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/monthly_allocations/monthly_allocation_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for monthly allocation operations.
///
/// All methods require authentication.
class MonthlyAllocationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Creates or updates an allocation for an envelope in a given month.
  Future<MonthlyAllocation> upsert(
    Session session,
    UuidValue envelopeId,
    UuidValue budgetId,
    int year,
    int month,
    int allocatedCents, {
    int carryoverCents = 0,
  }) async {
    final allocation = await MonthlyAllocationService.upsert(
      session,
      envelopeId: envelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      allocatedCents: allocatedCents,
      carryoverCents: carryoverCents,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(allocation.budgetId);
    return allocation;
  }

  /// Lists all allocations for a budget in a given month.
  Future<List<MonthlyAllocation>> list(
    Session session,
    UuidValue budgetId,
    int year,
    int month,
  ) async {
    return MonthlyAllocationService.listForBudgetMonth(
      session,
      budgetId: budgetId,
      year: year,
      month: month,
    );
  }

  /// Copies all allocations from a source month to a target month.
  Future<List<MonthlyAllocation>> copyMonth(
    Session session,
    UuidValue budgetId,
    int sourceYear,
    int sourceMonth,
    int targetYear,
    int targetMonth,
  ) async {
    final allocations = await MonthlyAllocationService.copyMonth(
      session,
      budgetId: budgetId,
      sourceYear: sourceYear,
      sourceMonth: sourceMonth,
      targetYear: targetYear,
      targetMonth: targetMonth,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return allocations;
  }

  /// Moves money between two envelopes in the same budget and month.
  Future<List<MonthlyAllocation>> moveMoney(
    Session session,
    UuidValue fromEnvelopeId,
    UuidValue toEnvelopeId,
    UuidValue budgetId,
    int year,
    int month,
    int amountCents,
  ) async {
    final allocations = await MonthlyAllocationService.moveMoney(
      session,
      fromEnvelopeId: fromEnvelopeId,
      toEnvelopeId: toEnvelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      amountCents: amountCents,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return allocations;
  }

  /// Deletes a monthly allocation by ID.
  Future<MonthlyAllocation> delete(
    Session session,
    UuidValue allocationId,
  ) async {
    final allocation = await MonthlyAllocationService.delete(
      session,
      allocationId: allocationId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(allocation.budgetId);
    return allocation;
  }
}
