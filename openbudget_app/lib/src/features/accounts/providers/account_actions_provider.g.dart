// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountActions)
final accountActionsProvider = AccountActionsProvider._();

final class AccountActionsProvider
    extends $AsyncNotifierProvider<AccountActions, void> {
  AccountActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountActionsHash();

  @$internal
  @override
  AccountActions create() => AccountActions();
}

String _$accountActionsHash() => r'a14863828715a12395dc03a7c33b6c5fb4715c95';

abstract class _$AccountActions extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
