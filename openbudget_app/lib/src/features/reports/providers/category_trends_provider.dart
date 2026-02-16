import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_trends_provider.g.dart';

/// Fetches spending‐by‐category for each of the last [months] months and
/// pivots the data so each category has a time series of spending amounts.
@riverpod
Future<CategoryTrendsData> categoryTrends(
  Ref ref,
  String budgetId, {
  int months = 6,
}) async {
  final now = DateTime.now();
  final monthHeaders = <MonthLabel>[];
  final categoryMap = <String, List<int>>{};

  for (var i = months - 1; i >= 0; i--) {
    var year = now.year;
    var month = now.month - i;
    while (month <= 0) {
      month += 12;
      year--;
    }

    monthHeaders.add(MonthLabel(year: year, month: month));

    final report = await ref.watch(
      spendingReportProvider(budgetId, year, month).future,
    );

    // Ensure every category has an entry for this month index.
    final monthIndex = monthHeaders.length - 1;
    for (final existing in categoryMap.keys) {
      if (categoryMap[existing]!.length <= monthIndex) {
        categoryMap[existing]!.add(0);
      }
    }

    for (final entry in report.categorySpending.entries) {
      categoryMap.putIfAbsent(entry.key, () => List.filled(monthIndex, 0));
      categoryMap[entry.key]!.add(entry.value);
    }

    // Back-fill any newly added categories for this month.
    for (final entry in categoryMap.entries) {
      while (entry.value.length <= monthIndex) {
        entry.value.add(0);
      }
    }
  }

  // Sort categories by total descending.
  final sortedEntries = categoryMap.entries.toList()
    ..sort((a, b) {
      final totalA = a.value.fold<int>(0, (s, v) => s + v);
      final totalB = b.value.fold<int>(0, (s, v) => s + v);
      return totalB.compareTo(totalA);
    });

  final categories = sortedEntries
      .map(
        (e) => CategoryTrendLine(
          categoryName: e.key,
          monthlyCents: e.value,
          totalCents: e.value.fold<int>(0, (s, v) => s + v),
        ),
      )
      .toList();

  // Resolve the currency from the first report that has data.
  final firstReport = await ref.watch(
    spendingReportProvider(budgetId, now.year, now.month).future,
  );

  return CategoryTrendsData(
    months: monthHeaders,
    categories: categories,
    currencyCode: firstReport.currencyCode,
  );
}

class CategoryTrendsData {
  const CategoryTrendsData({
    required this.months,
    required this.categories,
    required this.currencyCode,
  });

  final List<MonthLabel> months;
  final List<CategoryTrendLine> categories;
  final String currencyCode;
}

class MonthLabel {
  const MonthLabel({required this.year, required this.month});

  final int year;
  final int month;
}

class CategoryTrendLine {
  const CategoryTrendLine({
    required this.categoryName,
    required this.monthlyCents,
    required this.totalCents,
  });

  final String categoryName;
  final List<int> monthlyCents;
  final int totalCents;
}
