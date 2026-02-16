// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransactionActions)
final transactionActionsProvider = TransactionActionsProvider._();

final class TransactionActionsProvider
    extends $NotifierProvider<TransactionActions, AsyncValue<void>> {
  TransactionActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionActionsHash();

  @$internal
  @override
  TransactionActions create() => TransactionActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$transactionActionsHash() =>
    r'f97ecbcf4498f665b80f42966dcd70ebfd0c202c';

abstract class _$TransactionActions extends $Notifier<AsyncValue<void>> {
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
