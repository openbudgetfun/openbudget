import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'duplicate_check_provider.g.dart';

/// Same account, same amount, date within ±3 days.
@riverpod
Future<List<TransactionView>> duplicateCheck(
  Ref ref,
  String accountId,
  int amountMinor,
  DateTime date,
) async {
  if (amountMinor == 0) return const [];

  final client = ref.read(serverpodClientProvider);
  return client.transaction.findDuplicates(
    UuidValue.fromString(accountId),
    date,
    amountMinor,
  );
}
