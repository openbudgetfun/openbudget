import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payee_list_provider.g.dart';

@riverpod
Future<List<Payee>> payeeList(Ref ref, String budgetId) async {
  final client = ref.read(serverpodClientProvider);
  return client.payee.list(UuidValue.fromString(budgetId));
}
