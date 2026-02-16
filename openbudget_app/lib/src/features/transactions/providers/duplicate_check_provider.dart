import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'duplicate_check_provider.g.dart';

@riverpod
Future<List<Transaction>> duplicateCheck(
  Ref ref,
  String budgetId,
  int amountCents,
  DateTime transactionDate,
) async {
  if (amountCents == 0) return [];

  final client = ref.read(serverpodClientProvider);
  return client.transaction.findDuplicates(
    // Serverpod API requires UuidValue which is experimental in uuid package.
    // ignore: experimental_member_use
    UuidValue.fromString(budgetId),
    amountCents,
    transactionDate,
  );
}
