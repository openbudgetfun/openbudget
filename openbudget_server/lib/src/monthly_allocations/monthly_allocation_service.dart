import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing monthly envelope allocations.
///
/// All methods verify budget ownership before operating.
class MonthlyAllocationService {
  /// Upserts an allocation for an envelope in a given month.
  ///
  /// If an allocation already exists for the envelope/year/month, it is
  /// updated. Otherwise a new row is created.
  static Future<MonthlyAllocation> upsert(
    Session session, {
    required UuidValue envelopeId,
    required UuidValue budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    int carryoverCents = 0,
  }) async {
    // Verify ownership.
    await BudgetService.getById(session, budgetId: budgetId);
    await EnvelopeService.getById(session, envelopeId: envelopeId);

    final existing = await MonthlyAllocation.db.findFirstRow(
      session,
      where: (t) =>
          t.envelopeId.equals(envelopeId) &
          t.year.equals(year) &
          t.month.equals(month),
    );

    if (existing != null) {
      final updated = existing.copyWith(
        allocatedCents: allocatedCents,
        carryoverCents: carryoverCents,
        updatedAt: DateTime.now(),
      );
      return MonthlyAllocation.db.updateRow(session, updated);
    }

    final allocation = MonthlyAllocation(
      envelopeId: envelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      allocatedCents: allocatedCents,
      carryoverCents: carryoverCents,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return MonthlyAllocation.db.insertRow(session, allocation);
  }

  /// Lists all allocations for a budget in a given month.
  static Future<List<MonthlyAllocation>> listForBudgetMonth(
    Session session, {
    required UuidValue budgetId,
    required int year,
    required int month,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return MonthlyAllocation.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.year.equals(year) &
          t.month.equals(month),
    );
  }

  /// Deletes an allocation by ID, verifying ownership.
  static Future<MonthlyAllocation> delete(
    Session session, {
    required UuidValue allocationId,
  }) async {
    final allocation = await MonthlyAllocation.db.findById(
      session,
      allocationId,
    );
    if (allocation == null) {
      throw Exception('Monthly allocation not found');
    }

    await BudgetService.getById(session, budgetId: allocation.budgetId);
    return MonthlyAllocation.db.deleteRow(session, allocation);
  }
}
