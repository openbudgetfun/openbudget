// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every transaction write goes through `transaction.*` and relies on
/// `EntityChangedEvent` for refreshes; the local invalidations keep tests
/// and offline flows correct too. The server computes base amounts, FX
/// sources and balances; the app never converts.

@ProviderFor(TransactionActions)
final transactionActionsProvider = TransactionActionsProvider._();

/// Every transaction write goes through `transaction.*` and relies on
/// `EntityChangedEvent` for refreshes; the local invalidations keep tests
/// and offline flows correct too. The server computes base amounts, FX
/// sources and balances; the app never converts.
final class TransactionActionsProvider
    extends $NotifierProvider<TransactionActions, AsyncValue<void>> {
  /// Every transaction write goes through `transaction.*` and relies on
  /// `EntityChangedEvent` for refreshes; the local invalidations keep tests
  /// and offline flows correct too. The server computes base amounts, FX
  /// sources and balances; the app never converts.
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
    r'3b61747049264b9c15174ccf70f849fd87b3dc10';

/// Every transaction write goes through `transaction.*` and relies on
/// `EntityChangedEvent` for refreshes; the local invalidations keep tests
/// and offline flows correct too. The server computes base amounts, FX
/// sources and balances; the app never converts.

abstract class _$TransactionActions extends $Notifier<AsyncValue<void>> {
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
