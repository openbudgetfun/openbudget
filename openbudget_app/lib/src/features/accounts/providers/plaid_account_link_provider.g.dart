// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plaid_account_link_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PlaidAccountLink)
final plaidAccountLinkProvider = PlaidAccountLinkProvider._();

final class PlaidAccountLinkProvider
    extends $AsyncNotifierProvider<PlaidAccountLink, void> {
  PlaidAccountLinkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plaidAccountLinkProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plaidAccountLinkHash();

  @$internal
  @override
  PlaidAccountLink create() => PlaidAccountLink();
}

String _$plaidAccountLinkHash() => r'a04840ccf3598d59a12249fe43d8c3551cfac9df';

abstract class _$PlaidAccountLink extends $AsyncNotifier<void> {
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
