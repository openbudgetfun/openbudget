import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_report_provider.g.dart';

/// One month's spending and income in base minor units, read from the
/// server's month view. Activity per envelope is grouped by its category.
@riverpod
Future<SpendingReport> spendingReport(
  Ref ref,
  String entityId,
  int endMonth,
) async {
  final views = await ref.watch(
    monthFiguresProvider(entityId, endMonth, 1).future,
  );
  return _reportFor(views, views.first.currencyCode);
}

/// The last [monthCount] months combined, for the preset ranges.
@riverpod
Future<SpendingReport> spendingReportPreset(
  Ref ref,
  String entityId,
  int endMonth,
  int monthCount,
) async {
  final views = await ref.watch(
    monthFiguresProvider(entityId, endMonth, monthCount).future,
  );
  return _reportFor(views, views.first.currencyCode);
}

SpendingReport _reportFor(List<BudgetMonthView> views, String currencyCode) {
  final monthReports = views.map(_reportForView).toList();
  return SpendingReport.combine(monthReports);
}

SpendingReport _reportForView(BudgetMonthView view) {
  final categorySpending = <String, int>{};
  final categoryNameById = <String, String>{
    for (final category in view.categories)
      category.id?.toString() ?? '': category.name,
  };

  for (final envelope in view.envelopes) {
    if (envelope.activityMinor >= 0) continue;
    final categoryName =
        categoryNameById[envelope.envelope.categoryId.toString()] ?? '';
    categorySpending[categoryName] =
        (categorySpending[categoryName] ?? 0) + envelope.activityMinor.abs();
  }

  return SpendingReport(
    totalIncome: view.summary.incomeMinor,
    totalExpenses: view.summary.activityMinor < 0
        ? view.summary.activityMinor.abs()
        : 0,
    netIncome: view.summary.incomeMinor + view.summary.activityMinor,
    transactionCount: 0,
    categorySpending: categorySpending,
    currencyCode: view.currencyCode,
    month: view.month,
  );
}

/// One month (or a range of months combined) of spending, in base minor
/// units. All figures come from the server's month view; none are summed
/// from raw transactions in the app.
class SpendingReport {
  const SpendingReport({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.transactionCount,
    required this.categorySpending,
    required this.currencyCode,
    this.month,
  });

  factory SpendingReport.combine(Iterable<SpendingReport> reports) {
    var totalIncome = 0;
    var totalExpenses = 0;
    var transactionCount = 0;
    String? currencyCode;
    int? month;
    final categorySpending = <String, int>{};

    for (final report in reports) {
      totalIncome += report.totalIncome;
      totalExpenses += report.totalExpenses;
      transactionCount += report.transactionCount;
      currencyCode = report.currencyCode;
      month = report.month ?? month;

      for (final entry in report.categorySpending.entries) {
        categorySpending[entry.key] =
            (categorySpending[entry.key] ?? 0) + entry.value;
      }
    }

    return SpendingReport(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netIncome: totalIncome - totalExpenses,
      transactionCount: transactionCount,
      categorySpending: categorySpending,
      currencyCode: currencyCode ?? 'USD',
      month: month,
    );
  }

  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
  final int transactionCount;
  final Map<String, int> categorySpending;
  final String currencyCode;

  /// The yyyymm month this report covers; null when combined.
  final int? month;

  /// The (year, month) pair screens use for their titles.
  ({int year, int month})? get yearMonth =>
      month == null ? null : (year: month! ~/ 100, month: month! % 100);
}
