// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payee_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PayeeActions)
final payeeActionsProvider = PayeeActionsProvider._();

final class PayeeActionsProvider
    extends $NotifierProvider<PayeeActions, AsyncValue<void>> {
  PayeeActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'payeeActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$payeeActionsHash();

  @$internal
  @override
  PayeeActions create() => PayeeActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$payeeActionsHash() => r'5221d707ad04c3c291dbac12605c468fedf66650';

abstract class _$PayeeActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
