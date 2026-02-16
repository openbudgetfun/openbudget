import 'package:openbudget_server/src/budget_templates/budget_template_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for budget template operations.
///
/// All methods require authentication.
class BudgetTemplateEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Saves a new template from the allocations of a given month.
  Future<BudgetTemplate> saveFromMonth(
    Session session,
    UuidValue budgetId,
    String name,
    int year,
    int month,
  ) async {
    return BudgetTemplateService.saveFromMonth(
      session,
      budgetId: budgetId,
      name: name,
      year: year,
      month: month,
    );
  }

  /// Lists all templates for a budget.
  Future<List<BudgetTemplate>> list(Session session, UuidValue budgetId) async {
    return BudgetTemplateService.listForBudget(session, budgetId: budgetId);
  }

  /// Applies a template to a target month.
  Future<List<MonthlyAllocation>> applyToMonth(
    Session session,
    UuidValue templateId,
    UuidValue budgetId,
    int year,
    int month,
  ) async {
    return BudgetTemplateService.applyToMonth(
      session,
      templateId: templateId,
      budgetId: budgetId,
      year: year,
      month: month,
    );
  }

  /// Deletes a template by ID.
  Future<BudgetTemplate> delete(Session session, UuidValue templateId) async {
    return BudgetTemplateService.delete(session, templateId: templateId);
  }
}
