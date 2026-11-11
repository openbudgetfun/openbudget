import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_template_provider.g.dart';

@riverpod
Future<List<BudgetTemplate>> budgetTemplateList(
  Ref ref,
  String entityId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.budget.listTemplates(UuidValue.fromString(entityId));
}

/// One template's envelope lines, with this month's allocations.
@riverpod
Future<List<BudgetTemplateLine>> budgetTemplateLines(
  Ref ref,
  String templateId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.budget.getTemplateLines(UuidValue.fromString(templateId));
}

@Riverpod(keepAlive: true)
class BudgetTemplateActions extends _$BudgetTemplateActions {
  @override
  void build() {}

  /// Saves the selected month's exact sparse allocations as a template and
  /// returns the new month view of `applyTemplate`.
  Future<BudgetTemplate> saveFromCurrentMonth({
    required String entityId,
    required String name,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final month = ref.read(selectedMonthProvider(entityId));

    final template = await client.budget.saveTemplate(
      UuidValue.fromString(entityId),
      month,
      name,
    );

    ref.invalidate(budgetTemplateListProvider(entityId));
    return template;
  }

  /// Applies a template to the selected month; returns the new month view.
  Future<BudgetMonthView?> applyTemplate({
    required String templateId,
    required String entityId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final month = ref.read(selectedMonthProvider(entityId));

    final view = await client.budget.applyTemplate(
      UuidValue.fromString(templateId),
      month,
    );

    ref
      ..invalidate(budgetTemplateListProvider(entityId))
      ..invalidate(budgetMonthProvider(entityId))
      ..invalidate(budgetMonthGroupsProvider);
    return view;
  }

  /// Deletes a template.
  Future<void> deleteTemplate({required String templateId}) async {
    final client = ref.read(serverpodClientProvider);
    await client.budget.deleteTemplate(UuidValue.fromString(templateId));
    ref.invalidate(budgetTemplateListProvider);
  }
}
