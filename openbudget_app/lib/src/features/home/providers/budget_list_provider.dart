import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_list_provider.g.dart';

@riverpod
Future<List<Budget>> budgetList(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.budget.list();
}
