// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BudgetExport)
final budgetExportProvider = BudgetExportProvider._();

final class BudgetExportProvider
    extends $NotifierProvider<BudgetExport, AsyncValue<void>> {
  BudgetExportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetExportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetExportHash();

  @$internal
  @override
  BudgetExport create() => BudgetExport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$budgetExportHash() => r'fc62a5c571fc648a7e765d06759022f9eedda940';

abstract class _$BudgetExport extends $Notifier<AsyncValue<void>> {
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
