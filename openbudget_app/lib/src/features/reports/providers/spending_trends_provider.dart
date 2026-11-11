import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_trends_provider.g.dart';

/// Income, expenses and net income for the last [months] months, one
/// `monthFigures` fetch for the whole range.
@riverpod
Future<SpendingTrendsData> spendingTrends(
  Ref ref,
  String entityId, {
  int months = 6,
}) async {
  final endMonth = MonthKey.fromDate(DateTime.now());
  final views = await ref.watch(
    monthFiguresProvider(entityId, endMonth, months).future,
  );

  final reports = views
      .map(
        (view) => MonthlyTrend(
          month: view.month,
          totalIncome: view.summary.incomeMinor,
          totalExpenses: view.summary.activityMinor < 0
              ? view.summary.activityMinor.abs()
              : 0,
          netIncome: view.summary.incomeMinor + view.summary.activityMinor,
        ),
      )
      .toList();

  final avgIncome = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (s, r) => s + r.totalIncome) ~/ reports.length;
  final avgExpenses = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (s, r) => s + r.totalExpenses) ~/ reports.length;

  return SpendingTrendsData(
    months: reports,
    averageIncome: avgIncome,
    averageExpenses: avgExpenses,
    currencyCode: views.first.currencyCode,
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
    required this.month,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
  });

  /// The yyyymm month.
  final int month;
  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
}
