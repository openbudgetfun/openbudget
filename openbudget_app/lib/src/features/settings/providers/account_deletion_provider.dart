import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_deletion_provider.g.dart';

/// Permanently deletes the signed-in account through
/// `settings.deleteAccount`, then signs this device out.
///
/// The state is loading while the request runs and holds the error when it
/// fails, so the screen can disable its button and explain what happened.
@Riverpod(keepAlive: true)
class AccountDeletion extends _$AccountDeletion {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Returns true when the account was deleted.
  Future<bool> deleteAccount() async {
    if (state.isLoading) return false;
    state = const AsyncValue.loading();
    final client = ref.read(serverpodClientProvider);
    try {
      await client.settings.deleteAccount();
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) state = AsyncValue.error(error, stackTrace);
      return false;
    }
    if (!ref.mounted) return true;
    state = const AsyncValue.data(null);
    await ref.read(authProvider.notifier).forgetDeletedAccount();
    return true;
  }
}
