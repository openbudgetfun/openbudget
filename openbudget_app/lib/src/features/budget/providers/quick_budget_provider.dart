import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quick_budget_provider.g.dart';

class QuickBudgetSuggestion extends Equatable {
  const QuickBudgetSuggestion({
    required this.budgetedLastMonth,
    required this.spentLastMonth,
    required this.averageBudgeted,
    required this.averageSpent,
  });

  final int budgetedLastMonth;
  final int spentLastMonth;
  final int averageBudgeted;
  final int averageSpent;

  @override
  List<Object?> get props => [
    budgetedLastMonth,
    spentLastMonth,
    averageBudgeted,
    averageSpent,
  ];
}

/// Computes quick-budget suggestions for an envelope based on historical data.
@riverpod
Future<QuickBudgetSuggestion> quickBudgetSuggestion(
  Ref ref,
  String budgetId,
  String envelopeId,
  int year,
  int month,
) async {
  // Compute previous 3 months for averages.
  final months = <({int year, int month})>[];
  for (var i = 1; i <= 3; i++) {
    var m = month - i;
    var y = year;
    while (m <= 0) {
      m += 12;
      y -= 1;
    }
    months.add((year: y, month: m));
  }

  var totalBudgeted = 0;
  var totalSpent = 0;
  var monthsWithData = 0;

  for (final m in months) {
    final allocations = await ref.watch(
      monthlyAllocationsProvider(budgetId, m.year, m.month).future,
    );
    final transactions = await ref.watch(
      monthlyTransactionsProvider(budgetId, m.year, m.month).future,
    );

    final allocation = allocations
        .where((a) => a.envelopeId.toString() == envelopeId)
        .firstOrNull;
    final allocated = allocation?.allocatedCents ?? 0;

    final spent = transactions
        .where(
          (t) => t.envelopeId?.toString() == envelopeId && t.amountCents < 0,
        )
        .fold<int>(0, (sum, t) => sum + t.amountCents.abs());

    totalBudgeted += allocated;
    totalSpent += spent;

    if (allocated > 0 || spent > 0) {
      monthsWithData++;
    }
  }

  // Last month is the first item in the months list.
  final lastMonth = months.first;
  final lastAllocations = await ref.watch(
    monthlyAllocationsProvider(
      budgetId,
      lastMonth.year,
      lastMonth.month,
    ).future,
  );
  final lastTransactions = await ref.watch(
    monthlyTransactionsProvider(
      budgetId,
      lastMonth.year,
      lastMonth.month,
    ).future,
  );

  final lastAllocation = lastAllocations
      .where((a) => a.envelopeId.toString() == envelopeId)
      .firstOrNull;
  final budgetedLastMonth = lastAllocation?.allocatedCents ?? 0;

  final spentLastMonth = lastTransactions
      .where((t) => t.envelopeId?.toString() == envelopeId && t.amountCents < 0)
      .fold<int>(0, (sum, t) => sum + t.amountCents.abs());

  final divisor = monthsWithData > 0 ? monthsWithData : 1;

  return QuickBudgetSuggestion(
    budgetedLastMonth: budgetedLastMonth,
    spentLastMonth: spentLastMonth,
    averageBudgeted: (totalBudgeted / divisor).round(),
    averageSpent: (totalSpent / divisor).round(),
  );
}
