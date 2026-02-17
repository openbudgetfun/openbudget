import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing monthly envelope allocations.
///
/// All methods verify budget ownership before operating.
class MonthlyAllocationService {
  static final _log = ObLogger('MonthlyAllocationService');

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
    _log.info(
      'Upserting allocation envelope=$envelopeId year=$year month=$month',
    );
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
    _log.info('Listing allocations budget=$budgetId year=$year month=$month');
    await BudgetService.getById(session, budgetId: budgetId);

    return MonthlyAllocation.db.find(
      session,
      where: (t) =>
          t.budgetId.equals(budgetId) &
          t.year.equals(year) &
          t.month.equals(month),
    );
  }

  /// Copies all allocations from a source month to a target month.
  ///
  /// Existing allocations in the target month are overwritten.
  static Future<List<MonthlyAllocation>> copyMonth(
    Session session, {
    required UuidValue budgetId,
    required int sourceYear,
    required int sourceMonth,
    required int targetYear,
    required int targetMonth,
  }) async {
    _log.info(
      'Copying allocations $sourceYear/$sourceMonth -> $targetYear/$targetMonth',
    );
    await BudgetService.getById(session, budgetId: budgetId);

    final sourceAllocations = await listForBudgetMonth(
      session,
      budgetId: budgetId,
      year: sourceYear,
      month: sourceMonth,
    );

    final results = <MonthlyAllocation>[];
    for (final alloc in sourceAllocations) {
      final copied = await upsert(
        session,
        envelopeId: alloc.envelopeId,
        budgetId: budgetId,
        year: targetYear,
        month: targetMonth,
        allocatedCents: alloc.allocatedCents,
      );
      results.add(copied);
    }

    return results;
  }

  /// Moves money between two envelopes in the same budget and month.
  ///
  /// Decreases the source envelope allocation and increases the target.
  static Future<List<MonthlyAllocation>> moveMoney(
    Session session, {
    required UuidValue fromEnvelopeId,
    required UuidValue toEnvelopeId,
    required UuidValue budgetId,
    required int year,
    required int month,
    required int amountCents,
  }) async {
    _log.info(
      'Moving $amountCents cents from=$fromEnvelopeId to=$toEnvelopeId',
    );
    await BudgetService.getById(session, budgetId: budgetId);
    await EnvelopeService.getById(session, envelopeId: fromEnvelopeId);
    await EnvelopeService.getById(session, envelopeId: toEnvelopeId);

    // Get or create source allocation.
    final fromExisting = await MonthlyAllocation.db.findFirstRow(
      session,
      where: (t) =>
          t.envelopeId.equals(fromEnvelopeId) &
          t.year.equals(year) &
          t.month.equals(month),
    );

    final fromAllocated = (fromExisting?.allocatedCents ?? 0) - amountCents;
    final updatedFrom = await upsert(
      session,
      envelopeId: fromEnvelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      allocatedCents: fromAllocated,
      carryoverCents: fromExisting?.carryoverCents ?? 0,
    );

    // Get or create target allocation.
    final toExisting = await MonthlyAllocation.db.findFirstRow(
      session,
      where: (t) =>
          t.envelopeId.equals(toEnvelopeId) &
          t.year.equals(year) &
          t.month.equals(month),
    );

    final toAllocated = (toExisting?.allocatedCents ?? 0) + amountCents;
    final updatedTo = await upsert(
      session,
      envelopeId: toEnvelopeId,
      budgetId: budgetId,
      year: year,
      month: month,
      allocatedCents: toAllocated,
      carryoverCents: toExisting?.carryoverCents ?? 0,
    );

    return [updatedFrom, updatedTo];
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
