import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_export_provider.g.dart';

/// Exports one entity through `entity.exportData` as a portable JSON
/// document. The settings screen copies it to the clipboard.
@Riverpod(keepAlive: true)
class EntityExport extends _$EntityExport {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<String> exportEntity(String entityId) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final json = await client.entity.exportData(
        UuidValue.fromString(entityId),
      );
      if (ref.mounted) {
        state = const AsyncValue.data(null);
      }
      return json;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
