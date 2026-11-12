import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'month_figures_provider.g.dart';

/// The month views for the [monthCount] months ending at [endMonth],
/// newest first. The interim source for the spending reports until
/// `report.spending` and `report.monthSummaries` land on the client;
/// swapping to them is one file per feature.
@riverpod
Future<List<BudgetMonthView>> monthFigures(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) async {
  final client = ref.read(serverpodClientProvider);
  final entityUuid = UuidValue.fromString(entityId);

  final views = <BudgetMonthView>[];
  var month = endMonth;
  for (var i = 0; i < monthCount; i++) {
    views.add(await client.budget.getMonth(entityUuid, month));
    month = MonthKey.previous(month);
  }
  return views;
}
