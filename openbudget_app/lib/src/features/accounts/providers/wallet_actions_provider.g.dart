// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WalletActions)
final walletActionsProvider = WalletActionsProvider._();

final class WalletActionsProvider
    extends $AsyncNotifierProvider<WalletActions, void> {
  WalletActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletActionsHash();

  @$internal
  @override
  WalletActions create() => WalletActions();
}

String _$walletActionsHash() => r'd67c047b1dd3071a4847f925e231bb259938d06a';

abstract class _$WalletActions extends $AsyncNotifier<void> {
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
