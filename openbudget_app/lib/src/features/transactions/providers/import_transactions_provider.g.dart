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
    r'2cabfddc1d8f0d8fdb9025ed2207232cb861129c';

abstract class _$ImportTransactions extends $Notifier<AsyncValue<void>> {
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
