import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_trends_provider.g.dart';

/// Spending per category for each of the last [months] months, pivoted so
/// each category carries a time series. One `report.spending` call with
/// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
/// headers come from `report.monthSummaries`.
@riverpod
Future<CategoryTrendsData> categoryTrends(
  Ref ref,
  String entityId, {
  int months = 6,
}) async {
  final client = ref.read(serverpodClientProvider);
  final endMonth = MonthKey.fromDate(DateTime.now());
  final summaries = await ref.watch(
    monthFiguresProvider(entityId, endMonth, months).future,
  );
  final entity = await ref.watch(entityDetailProvider(entityId).future);
  final rows = await client.report.spending(
    UuidValue.fromString(entityId),
    monthRangeStart(endMonth, months),
    endMonth,
    ReportGrouping.category,
    true,
  );

  final spentByCategory = <String, Map<int, int>>{};
  for (final row in rows) {
    final month = row.month;
    if (month == null || row.groupId == null || row.outflowMinor >= 0) {
      continue;
    }
    spentByCategory
        .putIfAbsent(row.name, () => {})
        .update(
          month,
          (spent) => spent + row.outflowMinor.abs(),
          ifAbsent: row.outflowMinor.abs,
        );
  }

  final monthHeaders = [for (final summary in summaries) summary.month];
  final categories =
      spentByCategory.entries
          .map(
            (entry) => CategoryTrendLine(
              categoryName: entry.key,
              monthlyMinor: [
                for (final month in monthHeaders) entry.value[month] ?? 0,
              ],
              totalMinor: entry.value.values.fold<int>(
                0,
                (sum, spent) => sum + spent,
              ),
            ),
          )
          .toList()
        ..sort(
          (first, second) => second.totalMinor.compareTo(first.totalMinor),
        );

  return CategoryTrendsData(
    months: monthHeaders,
    categories: categories,
    currencyCode: entity.baseCurrencyCode,
  );
}

class CategoryTrendsData {
  const CategoryTrendsData({
    required this.months,
    required this.categories,
    required this.currencyCode,
  });

  /// yyyymm month headers, newest first.
  final List<int> months;
  final List<CategoryTrendLine> categories;
  final String currencyCode;
}

class CategoryTrendLine {
  const CategoryTrendLine({
    required this.categoryName,
    required this.monthlyMinor,
    required this.totalMinor,
  });

  final String categoryName;
  final List<int> monthlyMinor;
  final int totalMinor;
}
