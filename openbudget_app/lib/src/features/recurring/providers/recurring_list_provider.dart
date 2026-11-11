import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_list_provider.g.dart';

@riverpod
Future<List<RecurringTransaction>> recurringList(
  Ref ref,
  String entityId,
) async {
  final client = ref.read(serverpodClientProvider);
  return client.recurringTransaction.list(UuidValue.fromString(entityId));
}
