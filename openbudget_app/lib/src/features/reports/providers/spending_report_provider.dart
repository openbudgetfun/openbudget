import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_report_provider.g.dart';

/// One month of spending grouped by category, from one `report.spending`
/// call plus the month's figure from `report.monthSummaries`.
@riverpod
Future<SpendingReport> spendingReport(
  Ref ref,
  String entityId,
  int endMonth,
) => _spendingReport(ref, entityId, endMonth, 1);

/// The last [monthCount] months combined, for the preset ranges.
@riverpod
Future<SpendingReport> spendingReportPreset(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) => _spendingReport(ref, entityId, endMonth, monthCount);

Future<SpendingReport> _spendingReport(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) async {
  final client = ref.read(serverpodClientProvider);
  final entity = await ref.watch(entityDetailProvider(entityId).future);
  final summaries = await ref.watch(
    monthFiguresProvider(entityId, endMonth, monthCount).future,
  );

  final isSingleMonth = monthCount <= 1;
  final rows = await client.report.spending(
    UuidValue.fromString(entityId),
    monthRangeStart(endMonth, monthCount),
    endMonth,
    ReportGrouping.category,
    false,
  );

  final categorySpending = <String, int>{};
  var totalExpenses = 0;
  for (final row in rows) {
    if (row.outflowMinor >= 0) continue;
    final spentMinor = row.outflowMinor.abs();
    totalExpenses += spentMinor;
    // Lines with no envelope are uncategorised spending. They stay in the
    // total, but "No category" is not a label the app translates, so the
    // chart shows them under its own "Other categories" row instead.
    if (row.groupId == null) continue;
    categorySpending[row.name] = (categorySpending[row.name] ?? 0) + spentMinor;
  }

  final totalIncome = summaries.fold<int>(
    0,
    (sum, summary) => sum + summary.incomeMinor,
  );

  return SpendingReport(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netIncome: totalIncome - totalExpenses,
    categorySpending: categorySpending,
    currencyCode: entity.baseCurrencyCode,
    month: isSingleMonth ? endMonth : null,
  );
}

/// One month (or a range of months combined) of spending, in base minor
/// units. Spending comes from `report.spending`; income comes from
/// `report.monthSummaries`. Neither is summed from raw transactions in the
/// app.
class SpendingReport {
  const SpendingReport({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.categorySpending,
    required this.currencyCode,
    this.month,
  });

  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
  final Map<String, int> categorySpending;
  final String currencyCode;

  /// The yyyymm month this report covers; null when combined.
  final int? month;
}
