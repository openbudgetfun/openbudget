import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_detail_provider.g.dart';

/// One entity, reloaded when entity-scoped events arrive.
@riverpod
Future<Entity> entityDetail(Ref ref, String entityId) async {
  final client = ref.read(serverpodClientProvider);
  return client.entity.get(UuidValue.fromString(entityId));
}
