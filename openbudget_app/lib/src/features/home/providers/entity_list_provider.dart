import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_list_provider.g.dart';

/// Every entity the signed-in user owns, in the server's order.
@riverpod
Future<List<Entity>> entityList(Ref ref) async {
  final client = ref.read(serverpodClientProvider);
  return client.entity.list();
}
