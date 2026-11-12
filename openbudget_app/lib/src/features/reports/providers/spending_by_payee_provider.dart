import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'spending_by_payee_provider.g.dart';

class PayeeSpendingEntry {
  const PayeeSpendingEntry({
    required this.payeeName,
    required this.totalMinor,
    required this.transactionCount,
  });

  final String payeeName;
  final int totalMinor;
  final int transactionCount;
}

class PayeeSpendingReport {
  const PayeeSpendingReport({
    required this.entries,
    required this.totalSpentMinor,
    required this.currencyCode,
  });

  final List<PayeeSpendingEntry> entries;
  final int totalSpentMinor;
  final String currencyCode;
}

/// Spending grouped by payee for one month, in base minor units.
///
/// This pages the month's transactions and groups them here. When
/// `report.spending(grouping: payee)` arrives on the generated client, this
/// provider switches to it.
@riverpod
Future<PayeeSpendingReport> spendingByPayee(
  Ref ref,
  String entityId,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  final entity = await ref.watch(entityDetailProvider(entityId).future);

  final firstDay = MonthKey.toFirstDate(month);
  final lastDay = MonthKey.toLastDate(month);
  final payeeMap = <String, _PayeeAccumulator>{};
  var totalSpent = 0;
  String? cursor;

  // Three bounded pages keep the request finite while the server-side
  // payee grouping is still pending.
  for (var page = 0; page < 3; page++) {
    final query = TransactionQuery(
      entityId: UuidValue.fromString(entityId),
      fromDate: firstDay,
      toDate: lastDay,
      limit: 200,
    )..cursor = cursor;
    final result = await client.transaction.list(query);

    for (final view in result.items) {
      final amount = view.transaction.amountMinor;
      if (amount >= 0) continue; // Expenses only.
      final payeeName = view.payeeName ?? view.transaction.description;
      if (payeeName.isEmpty) continue;
      payeeMap.putIfAbsent(payeeName, _PayeeAccumulator.new).add(amount);
      totalSpent += amount.abs();
    }

    cursor = result.nextCursor;
    if (cursor == null) break;
  }

  final entries =
      payeeMap.entries
          .map(
            (e) => PayeeSpendingEntry(
              payeeName: e.key,
              totalMinor: e.value.totalMinor,
              transactionCount: e.value.count,
            ),
          )
          .toList()
        ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));

  return PayeeSpendingReport(
    entries: entries,
    totalSpentMinor: totalSpent,
    currencyCode: entity.baseCurrencyCode,
  );
}

class _PayeeAccumulator {
  int totalMinor = 0;
  int count = 0;

  void add(int amountMinor) {
    totalMinor += amountMinor.abs();
    count += 1;
  }
}
