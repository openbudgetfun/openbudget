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

  for (final tx in transactions) {
    if (tx.amountCents > 0) {
      totalIncome += tx.amountCents;
    } else {
      totalExpenses += tx.amountCents.abs();
    }

    if (tx.envelopeId != null) {
      final envelopeIdStr = tx.envelopeId.toString();
      for (final cat in summary.categories) {
        for (final env in cat.envelopes) {
          if (env.id?.toString() == envelopeIdStr) {
            categorySpending[cat.category.name] =
                (categorySpending[cat.category.name] ?? 0) +
                tx.amountCents.abs();
          }
        }
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

class SpendingReport {
  const SpendingReport({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.transactionCount,
    required this.categorySpending,
    required this.currencyCode,
  });

  final int totalIncome;
  final int totalExpenses;
  final int netIncome;
  final int transactionCount;
  final Map<String, int> categorySpending;
  final String currencyCode;
}
