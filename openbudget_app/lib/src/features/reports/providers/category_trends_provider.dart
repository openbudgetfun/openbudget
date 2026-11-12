import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'category_trends_provider.g.dart';

/// Spending per category for each of the last [months] months, pivoted so
/// each category carries a time series. One `monthFigures` fetch feeds the
/// whole table.
@riverpod
Future<CategoryTrendsData> categoryTrends(
  Ref ref,
  String entityId, {
  int months = 6,
}) async {
  final endMonth = MonthKey.fromDate(DateTime.now());
  final views = await ref.watch(
    monthFiguresProvider(entityId, endMonth, months).future,
  );

  final monthHeaders = views.map((view) => view.month).toList();
  final categoryMap = <String, List<int>>{};

  for (final view in views) {
    final categoryNameById = <String, String>{
      for (final category in view.categories)
        category.id?.toString() ?? '': category.name,
    };
    final spentByCategory = <String, int>{};
    for (final envelope in view.envelopes) {
      if (envelope.activityMinor >= 0) continue;
      final name =
          categoryNameById[envelope.envelope.categoryId.toString()] ?? '';
      spentByCategory[name] =
          (spentByCategory[name] ?? 0) + envelope.activityMinor.abs();
    }

    for (final entry in spentByCategory.entries) {
      categoryMap
          .putIfAbsent(
            entry.key,
            () => List.filled(monthHeaders.length - 1, 0),
          )
          .add(entry.value);
    }
    // Every earlier-known category gets a zero for this month.
    for (final entry in categoryMap.entries) {
      if (!spentByCategory.containsKey(entry.key)) entry.value.add(0);
      while (entry.value.length < monthHeaders.length) {
        entry.value.add(0);
      }
    }
  }

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
          monthlyMinor: e.value,
          totalMinor: e.value.fold<int>(0, (s, v) => s + v),
        ),
      )
      .toList();

  return CategoryTrendsData(
    months: monthHeaders,
    categories: categories,
    currencyCode: views.first.currencyCode,
  );
}

class CategoryTrendsData {
  const CategoryTrendsData({
    required this.months,
    required this.categories,
    required this.currencyCode,
  });

  /// yyyymm month headers, oldest first.
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
