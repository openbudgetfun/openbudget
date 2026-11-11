import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'month_figures_provider.g.dart';

/// The month views for the [monthCount] months ending at [endMonth],
/// oldest first.
///
/// Reports read every month-level figure from these views. This is the one
/// place that loops months; when `report.spending` and
/// `report.monthSummaries` arrive on the generated client, this provider
/// switches to them and every report screen follows.
@riverpod
Future<List<BudgetMonthView>> monthFigures(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) async {
  final client = ref.read(serverpodClientProvider);
  final entityUuid = UuidValue.fromString(entityId);
  MonthKey.validate(endMonth);
  final count = monthCount < 1 ? 1 : monthCount;

  final months = <int>[];
  var month = endMonth;
  for (var i = 0; i < count; i++) {
    months.add(month);
    month = MonthKey.previous(month);
  }

  final views = await Future.wait(
    months.reversed.map((m) => client.budget.getMonth(entityUuid, m)),
  );
  return views;
}
