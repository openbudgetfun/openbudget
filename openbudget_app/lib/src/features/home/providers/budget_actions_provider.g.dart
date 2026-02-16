// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetActions)
final budgetActionsProvider = BudgetActionsProvider._();

final class BudgetActionsProvider
    extends $NotifierProvider<BudgetActions, AsyncValue<void>> {
  BudgetActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetActionsHash();

  @$internal
  @override
  BudgetActions create() => BudgetActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$budgetActionsHash() => r'172ea3035afcd6b28711eaf2a060d3810614007a';

abstract class _$BudgetActions extends $Notifier<AsyncValue<void>> {
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
