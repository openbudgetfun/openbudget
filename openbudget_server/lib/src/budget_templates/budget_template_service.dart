import 'dart:convert';

import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/monthly_allocations/monthly_allocation_service.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for budget templates.
///
/// Templates store a snapshot of envelope allocations that can be applied
/// to any month.
class BudgetTemplateService {
  /// Saves a new template from the current allocations of a given month.
  static Future<BudgetTemplate> saveFromMonth(
    Session session, {
    required UuidValue budgetId,
    required String name,
    required int year,
    required int month,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    final allocations = await MonthlyAllocationService.listForBudgetMonth(
      session,
      budgetId: budgetId,
      year: year,
      month: month,
    );

    final data = <String, int>{};
    for (final alloc in allocations) {
      data[alloc.envelopeId.toString()] = alloc.allocatedCents;
    }

    final template = BudgetTemplate(
      budgetId: budgetId,
      name: name,
      allocationData: jsonEncode(data),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return BudgetTemplate.db.insertRow(session, template);
  }

  /// Lists all templates for a budget.
  static Future<List<BudgetTemplate>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await BudgetService.getById(session, budgetId: budgetId);

    return BudgetTemplate.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.name,
    );
  }

  /// Applies a template to a target month by upserting allocations.
  ///
  /// Returns the list of created/updated allocations.
  static Future<List<MonthlyAllocation>> applyToMonth(
    Session session, {
    required UuidValue templateId,
    required UuidValue budgetId,
    required int year,
    required int month,
  }) async {
    final template = await BudgetTemplate.db.findById(session, templateId);
    if (template == null) {
      throw Exception('Budget template not found');
    }

    await BudgetService.getById(session, budgetId: budgetId);

    final data = (jsonDecode(template.allocationData) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as int));

    final results = <MonthlyAllocation>[];
    for (final entry in data.entries) {
      final allocation = await MonthlyAllocationService.upsert(
        session,
        envelopeId: UuidValue.fromString(entry.key),
        budgetId: budgetId,
        year: year,
        month: month,
        allocatedCents: entry.value,
      );
      results.add(allocation);
    }

    return results;
  }

  /// Deletes a template by ID.
  static Future<BudgetTemplate> delete(
    Session session, {
    required UuidValue templateId,
  }) async {
    final template = await BudgetTemplate.db.findById(session, templateId);
    if (template == null) {
      throw Exception('Budget template not found');
    }

    await BudgetService.getById(session, budgetId: template.budgetId);
    return BudgetTemplate.db.deleteRow(session, template);
  }
}
