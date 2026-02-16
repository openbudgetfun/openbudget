import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_summary_provider.freezed.dart';
part 'budget_summary_provider.g.dart';

@freezed
sealed class CategoryWithEnvelopes with _$CategoryWithEnvelopes {
  const factory CategoryWithEnvelopes({
    required Category category,
    required List<Envelope> envelopes,
    required int totalBudgetedCents,
    required int totalSpentCents,
    required int totalAvailableCents,
  }) = _CategoryWithEnvelopes;
}

@freezed
sealed class BudgetSummary with _$BudgetSummary {
  const factory BudgetSummary({
    required Budget budget,
    required List<CategoryWithEnvelopes> categories,
    required int totalIncomeCents,
    required int totalBudgetedCents,
    required int readyToAssignCents,
  }) = _BudgetSummary;
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
        totalBudgetedCents: catBudgeted,
        totalSpentCents: catSpent,
        totalAvailableCents: catBudgeted - catSpent,
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
  );
}
