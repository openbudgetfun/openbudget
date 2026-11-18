import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rule_list_provider.g.dart';

/// Fetches all transaction rules for a budget.
@riverpod
Future<List<TransactionRule>> ruleList(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  final budgetUuid = UuidValue.fromString(entityId);
  return client.transactionRule.list(budgetUuid);
}
