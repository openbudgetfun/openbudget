import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entity_actions_provider.g.dart';

/// Create and delete actions for entities. Every mutation refreshes the
/// entity list; the callers navigate with the returned id.
@Riverpod(keepAlive: true)
class EntityActions extends _$EntityActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Creates an entity and returns its id, or an empty string on failure.
  ///
  /// [timeZone] comes from `defaultTimeZone(countryCode)` unless the user
  /// picked another zone. The financial year end is pre-filled from
  /// `defaultFiscalYearEnd` for sole traders and companies.
  Future<String> create({
    required String name,
    required EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);

    try {
      final entity = await client.entity.create(
        name,
        kind,
        countryCode,
        baseCurrencyCode,
        timeZone,
        fiscalYearEndMonth: fiscalYearEndMonth,
        fiscalYearEndDay: fiscalYearEndDay,
      );
      if (!ref.mounted) return '';

      final entityId = entity.id?.toString() ?? '';
      state = const AsyncValue.data(null);
      ref.invalidate(entityListProvider);
      return entityId;
    } on Exception catch (e, st) {
      if (!ref.mounted) return '';
      state = AsyncValue.error(e, st);
      return '';
    }
  }

  /// Deletes the entity and everything under it. The server requires the
  /// entity's exact name as confirmation.
  Future<void> deleteEntity({
    required String entityId,
    required String confirmName,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.entity.delete(
        UuidValue.fromString(entityId),
        confirmName,
      );
      if (ref.mounted) {
        ref.invalidate(entityListProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> archive({required String entityId}) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.entity.archive(UuidValue.fromString(entityId));
      if (ref.mounted) {
        ref.invalidate(entityListProvider);
        state = const AsyncValue.data(null);
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
