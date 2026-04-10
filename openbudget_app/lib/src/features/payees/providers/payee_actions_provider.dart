import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payee_actions_provider.g.dart';

@Riverpod(keepAlive: true)
class PayeeActions extends _$PayeeActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<Payee> createPayee({
    required String name,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final payee = await client.payee.create(
        name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
      );
      if (ref.mounted) {
        ref.invalidate(payeeListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return payee;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Payee> updatePayee({
    required String payeeId,
    required String budgetId,
    String? name,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final payee = await client.payee.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(payeeId),
        name: name,
      );
      if (ref.mounted) {
        ref.invalidate(payeeListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return payee;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<int> mergePayees({
    required String sourcePayeeId,
    required String targetPayeeId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final count = await client.payee.merge(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(sourcePayeeId),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(targetPayeeId),
      );
      if (ref.mounted) {
        ref.invalidate(payeeListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return count;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<Payee> deletePayee({
    required String payeeId,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      final deleted = await client.payee.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(payeeId),
      );
      if (ref.mounted) {
        ref.invalidate(payeeListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return deleted;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Recreates a previously deleted payee for undo support.
  Future<Payee> undoDeletePayee({
    required Payee deletedPayee,
    required String budgetId,
  }) async {
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      final restored = await client.payee.create(
        deletedPayee.name,
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
      );
      if (ref.mounted) {
        ref.invalidate(payeeListProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return restored;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
