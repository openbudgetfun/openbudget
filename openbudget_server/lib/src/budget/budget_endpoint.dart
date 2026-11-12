import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for the envelope plan.
///
/// Every method requires authentication. The services own entity ownership,
/// archived-entity rejection and the transaction boundaries; this endpoint
/// only exposes the contract.
class BudgetEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Reads one month of the Plan screen in a single database snapshot.
  Future<BudgetMonthView> getMonth(
    Session session,
    UuidValue entityId,
    int month,
  ) => BudgetMonthService.month(session, entityId: entityId, month: month);

  /// Replaces the named envelopes' allocations for one month.
  Future<BudgetMonthView> setAllocations(
    Session session,
    UuidValue entityId,
    int month,
    List<AllocationInput> allocations,
  ) => BudgetService.setAllocations(
    session,
    entityId: entityId,
    month: month,
    allocations: allocations,
  );

  /// Moves a positive amount between envelopes or Ready to Assign.
  Future<BudgetMonthView> moveMoney(
    Session session,
    UuidValue entityId,
    int month,
    UuidValue? fromEnvelopeId,
    UuidValue? toEnvelopeId,
    int amountMinor,
  ) => BudgetService.moveMoney(
    session,
    entityId: entityId,
    month: month,
    fromEnvelopeId: fromEnvelopeId,
    toEnvelopeId: toEnvelopeId,
    amountMinor: amountMinor,
  );

  /// Replaces the target month's allocations with the source month's.
  Future<BudgetMonthView> copyMonth(
    Session session,
    UuidValue entityId,
    int fromMonth,
    int toMonth,
  ) => BudgetService.copyMonth(
    session,
    entityId: entityId,
    fromMonth: fromMonth,
    toMonth: toMonth,
  );

  /// Saves one month's exact sparse allocations as a named template.
  Future<BudgetTemplate> saveTemplate(
    Session session,
    UuidValue entityId,
    int month,
    String name,
  ) => BudgetService.saveTemplate(
    session,
    entityId: entityId,
    month: month,
    name: name,
  );

  /// Lists every template of an owned entity.
  Future<List<BudgetTemplate>> listTemplates(
    Session session,
    UuidValue entityId,
  ) => BudgetService.listTemplates(session, entityId: entityId);

  /// Loads one template's lines.
  Future<List<BudgetTemplateLine>> getTemplateLines(
    Session session,
    UuidValue templateId,
  ) => BudgetService.getTemplateLines(session, templateId: templateId);

  /// Replaces one month's allocations with a template's lines.
  Future<BudgetMonthView> applyTemplate(
    Session session,
    UuidValue templateId,
    int month,
  ) => BudgetService.applyTemplate(
    session,
    templateId: templateId,
    month: month,
  );

  /// Deletes one template.
  Future<void> deleteTemplate(
    Session session,
    UuidValue templateId,
  ) => BudgetService.deleteTemplate(session, templateId: templateId);
}
