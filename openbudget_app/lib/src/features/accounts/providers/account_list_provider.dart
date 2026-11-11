import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_list_provider.g.dart';

@riverpod
Future<List<Account>> accountList(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.account.list(UuidValue.fromString(entityId));
}

/// Every account in every entity the user owns, for pickers that cross
/// entities (transfers).
@riverpod
Future<List<Account>> accountListAll(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.account.listAll();
}
