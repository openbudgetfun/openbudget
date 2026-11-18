import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_queue_provider.g.dart';

/// The month's uncategorised transactions, newest first: the review
/// sheet's queue, from `transaction.list` with `uncategorizedOnly`.
@riverpod
Future<List<TransactionView>> reviewQueue(Ref ref, String entityId) async {
  final month = ref.watch(selectedMonthProvider(entityId));
  final client = ref.read(serverpodClientProvider);
  final page = await client.transaction.list(
    TransactionQuery(
      entityId: UuidValue.fromString(entityId),
      uncategorizedOnly: true,
      fromDate: MonthKey.toFirstDate(month),
      toDate: MonthKey.toLastDate(month),
      limit: 100,
    ),
  );
  return page.items;
}
