// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Writes tax profiles and categorisation, then refreshes what they change.

@ProviderFor(TaxActions)
final taxActionsProvider = TaxActionsProvider._();

/// Writes tax profiles and categorisation, then refreshes what they change.
final class TaxActionsProvider
    extends $NotifierProvider<TaxActions, AsyncValue<void>> {
  /// Writes tax profiles and categorisation, then refreshes what they change.
  TaxActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxActionsHash();

  @$internal
  @override
  TaxActions create() => TaxActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$taxActionsHash() => r'1af385abec0014bf41dd6af82a43092814e19ab9';

/// Writes tax profiles and categorisation, then refreshes what they change.

abstract class _$TaxActions extends $Notifier<AsyncValue<void>> {
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
