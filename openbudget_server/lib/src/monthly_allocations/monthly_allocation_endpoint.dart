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
    return MonthlyAllocationService.upsert(
      session,
      envelopeId: envelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      allocatedCents: allocatedCents,
      carryoverCents: carryoverCents,
    );
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

  /// Deletes a monthly allocation by ID.
  Future<MonthlyAllocation> delete(
    Session session,
    UuidValue allocationId,
  ) async {
    return MonthlyAllocationService.delete(session, allocationId: allocationId);
  }
}
