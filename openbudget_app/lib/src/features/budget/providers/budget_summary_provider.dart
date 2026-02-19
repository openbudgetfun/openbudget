import 'package:equatable/equatable.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_summary_provider.g.dart';

class MonthlyEnvelopeData extends Equatable {
  const MonthlyEnvelopeData({
    required this.envelope,
    required this.allocatedCents,
    required this.spentCents,
    required this.availableCents,
    required this.carryoverCents,
  });

  final Envelope envelope;
  final int allocatedCents;
  final int spentCents;
  final int availableCents;
  final int carryoverCents;

  @override
  List<Object?> get props => [
    envelope,
    allocatedCents,
    spentCents,
    availableCents,
    carryoverCents,
  ];
}

class CategoryWithEnvelopes extends Equatable {
  const CategoryWithEnvelopes({
    required this.category,
    required this.envelopes,
    required this.monthlyEnvelopes,
    required this.totalBudgetedCents,
    required this.totalSpentCents,
    required this.totalAvailableCents,
  });

  final Category category;
  final List<Envelope> envelopes;
  final List<MonthlyEnvelopeData> monthlyEnvelopes;
  final int totalBudgetedCents;
  final int totalSpentCents;
  final int totalAvailableCents;

  @override
  List<Object?> get props => [
    category,
    envelopes,
    monthlyEnvelopes,
    totalBudgetedCents,
    totalSpentCents,
    totalAvailableCents,
  ];
}

class BudgetSummary extends Equatable {
  const BudgetSummary({
    required this.budget,
    required this.categories,
    required this.totalIncomeCents,
    required this.totalBudgetedCents,
    required this.readyToAssignCents,
    required this.year,
    required this.month,
  });

  final Budget budget;
  final List<CategoryWithEnvelopes> categories;
  final int totalIncomeCents;
  final int totalBudgetedCents;
  final int readyToAssignCents;
  final int year;
  final int month;

  @override
  List<Object?> get props => [
    budget,
    categories,
    totalIncomeCents,
    totalBudgetedCents,
    readyToAssignCents,
    year,
    month,
  ];
}

@riverpod
Future<BudgetSummary> budgetSummary(Ref ref, String budgetId) async {
  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  final categories = await ref.watch(categoryListProvider(budgetId).future);
  final transactions = await ref.watch(
    transactionListProvider(budgetId).future,
  );

  final totalIncomeCents = transactions
      .where((t) => t.amountCents > 0)
      .fold<int>(0, (sum, t) => sum + t.amountCents);

  final categoriesWithEnvelopes = <CategoryWithEnvelopes>[];
  var totalBudgetedCents = 0;

  for (final category in categories) {
    final categoryId = category.id?.toString() ?? '';
    final envelopes = await ref.watch(envelopeListProvider(categoryId).future);

    var catBudgeted = 0;
    var catSpent = 0;
    for (final envelope in envelopes) {
      catBudgeted += envelope.budgetedAmountCents;
      catSpent += envelope.spentAmountCents;
    }

    categoriesWithEnvelopes.add(
      CategoryWithEnvelopes(
        category: category,
        envelopes: envelopes,
        monthlyEnvelopes: const [],
        totalBudgetedCents: catBudgeted,
        totalSpentCents: catSpent,
        totalAvailableCents: catBudgeted - catSpent,
      ),
    );

    totalBudgetedCents += catBudgeted;
  }

  final now = DateTime.now();
  return BudgetSummary(
    budget: budget,
    categories: categoriesWithEnvelopes,
    totalIncomeCents: totalIncomeCents,
    totalBudgetedCents: totalBudgetedCents,
    readyToAssignCents: totalIncomeCents - totalBudgetedCents,
    year: now.year,
    month: now.month,
  );
}

/// Month-aware budget summary that uses monthly allocations and
/// month-scoped transactions.
@riverpod
Future<BudgetSummary> budgetMonthlySummary(Ref ref, String budgetId) async {
  final selectedMonth = ref.watch(selectedMonthProvider(budgetId));
  final year = selectedMonth.year;
  final month = selectedMonth.month;

  final budget = await ref.watch(budgetDetailProvider(budgetId).future);
  final categories = await ref.watch(categoryListProvider(budgetId).future);
  final monthlyTransactions = await ref.watch(
    monthlyTransactionsProvider(budgetId, year, month).future,
  );
  final allocations = await ref.watch(
    monthlyAllocationsProvider(budgetId, year, month).future,
  );

  // Build a map of envelopeId -> allocation for quick lookup.
  final allocationMap = <String, MonthlyAllocation>{};
  for (final a in allocations) {
    final key = a.envelopeId.toString();
    allocationMap[key] = a;
  }

  // Build a map of envelopeId -> spent cents for this month.
  final spentMap = <String, int>{};
  for (final t in monthlyTransactions) {
    if (t.envelopeId != null && t.amountCents < 0) {
      final key = t.envelopeId.toString();
      spentMap[key] = (spentMap[key] ?? 0) + t.amountCents.abs();
    }
  }

  final totalIncomeCents = monthlyTransactions
      .where((t) => t.amountCents > 0)
      .fold<int>(0, (sum, t) => sum + t.amountCents);

  final categoriesWithEnvelopes = <CategoryWithEnvelopes>[];
  var totalBudgetedCents = 0;

  for (final category in categories) {
    final categoryId = category.id?.toString() ?? '';
    final envelopes = await ref.watch(envelopeListProvider(categoryId).future);

    var catBudgeted = 0;
    var catSpent = 0;
    var catAvailable = 0;
    final monthlyEnvelopes = <MonthlyEnvelopeData>[];

    for (final envelope in envelopes) {
      final envelopeKey = envelope.id?.toString() ?? '';
      final allocation = allocationMap[envelopeKey];
      final allocated = allocation?.allocatedCents ?? 0;
      final carryover = allocation?.carryoverCents ?? 0;
      final spent = spentMap[envelopeKey] ?? 0;
      final available = allocated + carryover - spent;

      catBudgeted += allocated;
      catSpent += spent;
      catAvailable += available;

      monthlyEnvelopes.add(
        MonthlyEnvelopeData(
          envelope: envelope,
          allocatedCents: allocated,
          spentCents: spent,
          availableCents: available,
          carryoverCents: carryover,
        ),
      );
    }

    categoriesWithEnvelopes.add(
      CategoryWithEnvelopes(
        category: category,
        envelopes: envelopes,
        monthlyEnvelopes: monthlyEnvelopes,
        totalBudgetedCents: catBudgeted,
        totalSpentCents: catSpent,
        totalAvailableCents: catAvailable,
      ),
    );

    totalBudgetedCents += catBudgeted;
  }

  return BudgetSummary(
    budget: budget,
    categories: categoriesWithEnvelopes,
    totalIncomeCents: totalIncomeCents,
    totalBudgetedCents: totalBudgetedCents,
    readyToAssignCents: totalIncomeCents - totalBudgetedCents,
    year: year,
    month: month,
  );
}
