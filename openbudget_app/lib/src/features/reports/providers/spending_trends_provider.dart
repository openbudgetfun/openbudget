import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_trends_provider.g.dart';

/// Fetches spending reports for the last [months] months.
@riverpod
Future<SpendingTrendsData> spendingTrends(
  Ref ref,
  String budgetId, {
  int months = 6,
}) async {
  final now = DateTime.now();
  final reports = <MonthlyTrend>[];

  for (var i = months - 1; i >= 0; i--) {
    var year = now.year;
    var month = now.month - i;
    while (month <= 0) {
      month += 12;
      year--;
    }

    final report = await ref.watch(
      spendingReportProvider(budgetId, year, month).future,
    );

    reports.add(
      MonthlyTrend(
        year: year,
        month: month,
        totalIncome: report.totalIncome,
        totalExpenses: report.totalExpenses,
        netIncome: report.netIncome,
        transactionCount: report.transactionCount,
      ),
    );
  }

  final avgIncome = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (s, r) => s + r.totalIncome) ~/ reports.length;
  final avgExpenses = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (s, r) => s + r.totalExpenses) ~/ reports.length;

  final summary = await ref.watch(budgetSummaryProvider(budgetId).future);

  return SpendingTrendsData(
    months: reports,
    averageIncome: avgIncome,
    averageExpenses: avgExpenses,
    currencyCode: summary.budget.currencyCode,
  );
}

class SpendingTrendsData {
  const SpendingTrendsData({
    required this.months,
    required this.averageIncome,
    required this.averageExpenses,
    required this.currencyCode,
  });

  final List<MonthlyTrend> months;
  final int averageIncome;
  final int averageExpenses;
  final String currencyCode;
}

class MonthlyTrend {
  const MonthlyTrend({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.transactionCount,
  });

  final int year;
  final int month;
  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
  final int transactionCount;
}
