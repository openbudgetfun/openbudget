import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'month_figures_provider.g.dart';

/// The month-level figures for [monthCount] months ending at [endMonth],
/// newest first, from one `report.monthSummaries` call.
///
/// This replaces the old one-`budget.getMonth`-per-month loop; screens that
/// also need grouped spending call `report.spending` once themselves.
@riverpod
Future<List<BudgetMonthSummary>> monthFigures(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) async {
  final client = ref.read(serverpodClientProvider);
  final summaries = await client.report.monthSummaries(
    UuidValue.fromString(entityId),
    monthRangeStart(endMonth, monthCount),
    endMonth,
  );
  return summaries
    ..sort((first, second) => second.month.compareTo(first.month));
}
