import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_trends_provider.g.dart';

/// Income, expenses and net income for the last [months] months, from one
/// `report.monthSummaries` call.
@riverpod
Future<SpendingTrendsData> spendingTrends(
  Ref ref,
  String entityId, {
  int months = 6,
}) async {
  final endMonth = MonthKey.fromDate(DateTime.now());
  final summaries = await ref.watch(
    monthFiguresProvider(entityId, endMonth, months).future,
  );
  final entity = await ref.watch(entityDetailProvider(entityId).future);

  final reports = [
    for (final summary in summaries)
      MonthlyTrend(
        month: summary.month,
        totalIncome: summary.incomeMinor,
        totalExpenses: summary.activityMinor < 0
            ? summary.activityMinor.abs()
            : 0,
        netIncome: summary.incomeMinor + summary.activityMinor,
      ),
  ];

  final avgIncome = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (sum, report) => sum + report.totalIncome) ~/
            reports.length;
  final avgExpenses = reports.isEmpty
      ? 0
      : reports.fold<int>(0, (sum, report) => sum + report.totalExpenses) ~/
            reports.length;

  return SpendingTrendsData(
    months: reports,
    averageIncome: avgIncome,
    averageExpenses: avgExpenses,
    currencyCode: entity.baseCurrencyCode,
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
