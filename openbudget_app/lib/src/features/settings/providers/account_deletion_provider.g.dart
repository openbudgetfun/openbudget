// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deletion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Permanently deletes the signed-in account through
/// `settings.deleteAccount`, then signs this device out.
///
/// The state is loading while the request runs and holds the error when it
/// fails, so the screen can disable its button and explain what happened.

@ProviderFor(AccountDeletion)
final accountDeletionProvider = AccountDeletionProvider._();

/// Permanently deletes the signed-in account through
/// `settings.deleteAccount`, then signs this device out.
///
/// The state is loading while the request runs and holds the error when it
/// fails, so the screen can disable its button and explain what happened.
final class AccountDeletionProvider
    extends $NotifierProvider<AccountDeletion, AsyncValue<void>> {
  /// Permanently deletes the signed-in account through
  /// `settings.deleteAccount`, then signs this device out.
  ///
  /// The state is loading while the request runs and holds the error when it
  /// fails, so the screen can disable its button and explain what happened.
  AccountDeletionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountDeletionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountDeletionHash();

  @$internal
  @override
  AccountDeletion create() => AccountDeletion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$accountDeletionHash() => r'64db3cba4d29a813b647c0f3203a9d3e200377f5';

/// Permanently deletes the signed-in account through
/// `settings.deleteAccount`, then signs this device out.
///
/// The state is loading while the request runs and holds the error when it
/// fails, so the screen can disable its button and explain what happened.

abstract class _$AccountDeletion extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
