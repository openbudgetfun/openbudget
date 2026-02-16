import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_by_payee_provider.g.dart';

class PayeeSpendingEntry {
  const PayeeSpendingEntry({
    required this.payeeName,
    required this.totalCents,
    required this.transactionCount,
  });

  final String payeeName;
  final int totalCents;
  final int transactionCount;
}

class PayeeSpendingReport {
  const PayeeSpendingReport({
    required this.entries,
    required this.totalSpentCents,
    required this.currencyCode,
  });

  final List<PayeeSpendingEntry> entries;
  final int totalSpentCents;
  final String currencyCode;
}

@riverpod
Future<PayeeSpendingReport> spendingByPayee(
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

  final budget = await ref.watch(budgetDetailProvider(budgetId).future);

  // Aggregate spending by payee description (expenses only).
  final payeeMap = <String, _PayeeAccumulator>{};

  for (final tx in transactions) {
    if (tx.amountCents >= 0) continue; // Skip income.

    final payeeName = tx.description;
    if (payeeName.isEmpty) continue;

    final existing = payeeMap[payeeName];
    if (existing != null) {
      existing
        ..totalCents += tx.amountCents.abs()
        ..count += 1;
    } else {
      payeeMap[payeeName] = _PayeeAccumulator(
        totalCents: tx.amountCents.abs(),
        count: 1,
      );
    }
  }

  final entries =
      payeeMap.entries
          .map(
            (e) => PayeeSpendingEntry(
              payeeName: e.key,
              totalCents: e.value.totalCents,
              transactionCount: e.value.count,
            ),
          )
          .toList()
        ..sort((a, b) => b.totalCents.compareTo(a.totalCents));

  final totalSpent = entries.fold<int>(0, (sum, e) => sum + e.totalCents);

  return PayeeSpendingReport(
    entries: entries,
    totalSpentCents: totalSpent,
    currencyCode: budget.currencyCode,
  );
}

class _PayeeAccumulator {
  _PayeeAccumulator({required this.totalCents, required this.count});

  int totalCents;
  int count;
}
