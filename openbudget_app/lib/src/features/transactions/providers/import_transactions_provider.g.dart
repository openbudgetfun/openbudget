// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImportTransactions)
final importTransactionsProvider = ImportTransactionsProvider._();

final class ImportTransactionsProvider
    extends $NotifierProvider<ImportTransactions, AsyncValue<void>> {
  ImportTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importTransactionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importTransactionsHash();

  @$internal
  @override
  ImportTransactions create() => ImportTransactions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$importTransactionsHash() =>
    r'f18832061bfbd8c9f9ca34e5b0f7c0be53637d47';

abstract class _$ImportTransactions extends $Notifier<AsyncValue<void>> {
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
