// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes to the books, then refreshes what the writes change.

@ProviderFor(LedgerActions)
final ledgerActionsProvider = LedgerActionsProvider._();

/// Writes to the books, then refreshes what the writes change.
final class LedgerActionsProvider
    extends $NotifierProvider<LedgerActions, AsyncValue<void>> {
  /// Writes to the books, then refreshes what the writes change.
  LedgerActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ledgerActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ledgerActionsHash();

  @$internal
  @override
  LedgerActions create() => LedgerActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$ledgerActionsHash() => r'c6dd6029d54e1f5ea45565bd8cbc0c839ce3a375';

/// Writes to the books, then refreshes what the writes change.

abstract class _$LedgerActions extends $Notifier<AsyncValue<void>> {
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
