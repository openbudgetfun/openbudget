import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_template_provider.g.dart';

@riverpod
Future<List<BudgetTemplate>> budgetTemplateList(
  Ref ref,
  String budgetId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.budgetTemplate.list(UuidValue.fromString(budgetId));
}

@Riverpod(keepAlive: true)
class BudgetTemplateActions extends _$BudgetTemplateActions {
  @override
  void build() {}

  /// Saves the current month's allocations as a named template.
  Future<BudgetTemplate> saveFromCurrentMonth({
    required String budgetId,
    required String name,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final selectedMonth = ref.read(selectedMonthProvider(budgetId));

    final budgetUuid = UuidValue.fromString(budgetId);
    final template = await client.budgetTemplate.saveFromMonth(
      budgetUuid,
      name,
      selectedMonth.year,
      selectedMonth.month,
    );

    ref.invalidate(budgetTemplateListProvider(budgetId));
    return template;
  }

  /// Applies a template to the currently selected month.
  Future<void> applyTemplate({
    required String templateId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    final selectedMonth = ref.read(selectedMonthProvider(budgetId));

    final templateUuid = UuidValue.fromString(templateId);
    final budgetUuid = UuidValue.fromString(budgetId);
    await client.budgetTemplate.applyToMonth(
      templateUuid,
      budgetUuid,
      selectedMonth.year,
      selectedMonth.month,
    );

    ref
      ..invalidate(
        monthlyAllocationsProvider(
          budgetId,
          selectedMonth.year,
          selectedMonth.month,
        ),
      )
      ..invalidate(budgetMonthlySummaryProvider(budgetId));
  }

  /// Deletes a template.
  Future<void> deleteTemplate({
    required String templateId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    await client.budgetTemplate.delete(UuidValue.fromString(templateId));

    ref.invalidate(budgetTemplateListProvider(budgetId));
  }
}
