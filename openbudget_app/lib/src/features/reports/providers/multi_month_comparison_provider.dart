import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'multi_month_comparison_provider.freezed.dart';
part 'multi_month_comparison_provider.g.dart';

@freezed
sealed class MonthColumn with _$MonthColumn {
  const factory MonthColumn({
    required int year,
    required int month,
    required int totalBudgetedCents,
    required int totalSpentCents,
    required int totalAvailableCents,
    required int totalIncomeCents,
  }) = _MonthColumn;
}

@freezed
sealed class EnvelopeComparison with _$EnvelopeComparison {
  const factory EnvelopeComparison({
    required Envelope envelope,

    /// Keyed by "year-month" string, each entry holds
    /// [budgeted, spent, available].
    required Map<String, List<int>> monthData,
  }) = _EnvelopeComparison;
}

@freezed
sealed class CategoryComparison with _$CategoryComparison {
  const factory CategoryComparison({
    required Category category,
    required List<EnvelopeComparison> envelopes,

    /// Keyed by "year-month" string, each entry holds
    /// [budgeted, spent, available].
    required Map<String, List<int>> monthTotals,
  }) = _CategoryComparison;
}

@freezed
sealed class MultiMonthComparison with _$MultiMonthComparison {
  const factory MultiMonthComparison({
    required Budget budget,
    required List<MonthColumn> months,
    required List<CategoryComparison> categories,
  }) = _MultiMonthComparison;
}

/// Fetches budget data for [monthCount] consecutive months ending at the
/// current month and returns a comparison structure.
@riverpod
Future<MultiMonthComparison> multiMonthComparison(
  Ref ref,
  String budgetId, {
  int monthCount = 3,
}) async {
  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  final categories = await ref.watch(categoryListProvider(budgetId).future);

  final now = DateTime.now();
  final monthKeys = <String>[];
  final monthColumns = <MonthColumn>[];

  // Generate month ranges (most recent N months).
  final monthRanges = <(int, int)>[];
  for (var i = monthCount - 1; i >= 0; i--) {
    var y = now.year;
    var m = now.month - i;
    while (m <= 0) {
      m += 12;
      y--;
    }
    monthRanges.add((y, m));
  }

  // Fetch allocations and transactions for each month.
  final allAllocations = <String, List<MonthlyAllocation>>{};
  final allTransactions = <String, List<Transaction>>{};

  for (final (year, month) in monthRanges) {
    final key = '$year-$month';
    monthKeys.add(key);

    final allocations = await ref.watch(
      monthlyAllocationsProvider(budgetId, year, month).future,
    );
    final transactions = await ref.watch(
      monthlyTransactionsProvider(budgetId, year, month).future,
    );

    allAllocations[key] = allocations;
    allTransactions[key] = transactions;
  }

  // Build per-month allocation and spending maps.
  final monthAllocationMaps = <String, Map<String, MonthlyAllocation>>{};
  final monthSpentMaps = <String, Map<String, int>>{};
  final monthIncomeMaps = <String, int>{};

  for (final key in monthKeys) {
    final aMap = <String, MonthlyAllocation>{};
    for (final a in allAllocations[key]!) {
      aMap[a.envelopeId.toString()] = a;
    }
    monthAllocationMaps[key] = aMap;

    final sMap = <String, int>{};
    var income = 0;
    for (final t in allTransactions[key]!) {
      if (t.amountCents > 0) {
        income += t.amountCents;
      } else if (t.envelopeId != null) {
        final ek = t.envelopeId.toString();
        sMap[ek] = (sMap[ek] ?? 0) + t.amountCents.abs();
      }
    }
    monthSpentMaps[key] = sMap;
    monthIncomeMaps[key] = income;
  }

  // Build category comparison data.
  final categoryComparisons = <CategoryComparison>[];

  for (final category in categories) {
    final categoryId = category.id?.toString() ?? '';
    final envelopes = await ref.watch(envelopeListProvider(categoryId).future);

    final envelopeComparisons = <EnvelopeComparison>[];
    final catMonthTotals = <String, List<int>>{};

    for (final key in monthKeys) {
      catMonthTotals[key] = [0, 0, 0]; // [budgeted, spent, available]
    }

    for (final envelope in envelopes) {
      final ek = envelope.id?.toString() ?? '';
      final envMonthData = <String, List<int>>{};

      for (final key in monthKeys) {
        final allocation = monthAllocationMaps[key]![ek];
        final allocated = allocation?.allocatedCents ?? 0;
        final carryover = allocation?.carryoverCents ?? 0;
        final spent = monthSpentMaps[key]![ek] ?? 0;
        final available = allocated + carryover - spent;

        envMonthData[key] = [allocated, spent, available];
        catMonthTotals[key] = [
          catMonthTotals[key]![0] + allocated,
          catMonthTotals[key]![1] + spent,
          catMonthTotals[key]![2] + available,
        ];
      }

      envelopeComparisons.add(
        EnvelopeComparison(envelope: envelope, monthData: envMonthData),
      );
    }

    categoryComparisons.add(
      CategoryComparison(
        category: category,
        envelopes: envelopeComparisons,
        monthTotals: catMonthTotals,
      ),
    );
  }

  // Build month column summaries.
  for (final (year, month) in monthRanges) {
    final key = '$year-$month';
    var totalBudgeted = 0;
    var totalSpent = 0;
    var totalAvailable = 0;

    for (final cat in categoryComparisons) {
      final totals = cat.monthTotals[key];
      if (totals != null) {
        totalBudgeted += totals[0];
        totalSpent += totals[1];
        totalAvailable += totals[2];
      }
    }

    monthColumns.add(
      MonthColumn(
        year: year,
        month: month,
        totalBudgetedCents: totalBudgeted,
        totalSpentCents: totalSpent,
        totalAvailableCents: totalAvailable,
        totalIncomeCents: monthIncomeMaps[key] ?? 0,
      ),
    );
  }

  return MultiMonthComparison(
    budget: budget,
    months: monthColumns,
    categories: categoryComparisons,
  );
}
