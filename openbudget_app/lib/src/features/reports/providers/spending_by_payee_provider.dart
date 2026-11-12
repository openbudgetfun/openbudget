import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
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

/// Spending grouped by payee for one month, in base minor units, from one
/// `report.spending` call with [ReportGrouping.payee].
@riverpod
Future<PayeeSpendingReport> spendingByPayee(
  Ref ref,
  String entityId,
  int month,
) async {
  final client = ref.read(serverpodClientProvider);
  final entity = await ref.watch(entityDetailProvider(entityId).future);
  final rows = await client.report.spending(
    UuidValue.fromString(entityId),
    month,
    month,
    ReportGrouping.payee,
    false,
  );

  final entries = <PayeeSpendingEntry>[
    for (final row in rows)
      if (row.outflowMinor < 0)
        PayeeSpendingEntry(
          payeeName: row.name,
          totalMinor: row.outflowMinor.abs(),
          transactionCount: row.transactionCount,
        ),
  ]..sort((first, second) => second.totalMinor.compareTo(first.totalMinor));

  return PayeeSpendingReport(
    entries: entries,
    totalSpentMinor: entries.fold<int>(
      0,
      (sum, entry) => sum + entry.totalMinor,
    ),
    currencyCode: entity.baseCurrencyCode,
  );
}
