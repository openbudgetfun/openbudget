import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_report_provider.g.dart';

@riverpod
Future<SpendingReport> spendingReport(
  Ref ref,
  String budgetId,
  int year,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final transactions = await client.transaction.listByMonth(
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    UuidValue.fromString(budgetId),
    year,
    month,
  );

  final summary = await ref.watch(budgetSummaryProvider(budgetId).future);

  var totalIncome = 0;
  var totalExpenses = 0;
  final categorySpending = <String, int>{};
  final envelopeCategoryById = <String, String>{};

  for (final categorySummary in summary.categories) {
    final categoryName = categorySummary.category.name;
    for (final envelopeSummary in categorySummary.envelopes) {
      final envelopeId = envelopeSummary.id?.toString();
      if (envelopeId != null) {
        envelopeCategoryById[envelopeId] = categoryName;
      }
    }
  }

  for (final tx in transactions) {
    if (tx.amountCents > 0) {
      totalIncome += tx.amountCents;
    } else {
      totalExpenses += tx.amountCents.abs();
    }

    if (tx.envelopeId != null) {
      final envelopeIdStr = tx.envelopeId.toString();
      final categoryName = envelopeCategoryById[envelopeIdStr];
      if (categoryName != null) {
        categorySpending[categoryName] =
            (categorySpending[categoryName] ?? 0) + tx.amountCents.abs();
      }
    }
  }

  return SpendingReport(
    totalIncome: totalIncome,
    totalExpenses: totalExpenses,
    netIncome: totalIncome - totalExpenses,
    transactionCount: transactions.length,
    categorySpending: categorySpending,
    currencyCode: summary.budget.currencyCode,
  );
}

@riverpod
Future<SpendingReport> spendingReportPreset(
  Ref ref,
  String budgetId,
  int endYear,
  int endMonth,
  int monthCount,
) async {
  final normalizedMonthCount = monthCount < 1 ? 1 : monthCount;
  final monthRange = _buildMonthRange(
    endYear: endYear,
    endMonth: endMonth,
    monthCount: normalizedMonthCount,
  );
  final reports = await Future.wait(
    monthRange.map(
      (month) => ref.watch(
        spendingReportProvider(budgetId, month.year, month.month).future,
      ),
    ),
  );

  return SpendingReport.combine(reports);
}

List<_YearMonth> _buildMonthRange({
  required int endYear,
  required int endMonth,
  required int monthCount,
}) {
  final months = <_YearMonth>[];
  var year = endYear;
  var month = endMonth;

  for (var index = 0; index < monthCount; index++) {
    months.add(_YearMonth(year: year, month: month));
    if (month == 1) {
      year -= 1;
      month = 12;
    } else {
      month -= 1;
    }
  }

  return months;
}

class SpendingReport {
  const SpendingReport({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.transactionCount,
    required this.categorySpending,
    required this.currencyCode,
  });

  factory SpendingReport.combine(Iterable<SpendingReport> reports) {
    var totalIncome = 0;
    var totalExpenses = 0;
    var transactionCount = 0;
    var currencyCode = 'USD';
    final categorySpending = <String, int>{};

    for (final report in reports) {
      totalIncome += report.totalIncome;
      totalExpenses += report.totalExpenses;
      transactionCount += report.transactionCount;
      currencyCode = report.currencyCode;

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
      currencyCode: currencyCode,
    );
  }

  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
  final int transactionCount;
  final Map<String, int> categorySpending;
  final String currencyCode;
}

class _YearMonth {
  const _YearMonth({required this.year, required this.month});

  final int year;
  final int month;
}
