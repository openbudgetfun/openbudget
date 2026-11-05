import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'budget_detail_provider.g.dart';

@riverpod
Future<Budget> budgetDetail(Ref ref, String budgetId) async {
  final client = ref.read(serverpodClientProvider);
  return client.budget.get(UuidValue.fromString(budgetId));
}

@riverpod
Future<List<Category>> categoryList(Ref ref, String budgetId) async {
  final client = ref.read(serverpodClientProvider);
  return client.category.list(UuidValue.fromString(budgetId));
}

@riverpod
Future<List<Envelope>> envelopeList(Ref ref, String categoryId) async {
  final client = ref.read(serverpodClientProvider);
  return client.envelope.list(UuidValue.fromString(categoryId));
}

@riverpod
Future<List<Transaction>> transactionList(Ref ref, String budgetId) async {
  final client = ref.read(serverpodClientProvider);
  return client.transaction.list(UuidValue.fromString(budgetId));
}
