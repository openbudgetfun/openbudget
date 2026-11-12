// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Imports parsed rows into the chosen target account. Amounts are parsed
/// with the account's own decimals; the server turns them into ordinary
/// postings and reports inserted, duplicate and error counts.

@ProviderFor(ImportTransactions)
final importTransactionsProvider = ImportTransactionsProvider._();

/// Imports parsed rows into the chosen target account. Amounts are parsed
/// with the account's own decimals; the server turns them into ordinary
/// postings and reports inserted, duplicate and error counts.
final class ImportTransactionsProvider
    extends $NotifierProvider<ImportTransactions, AsyncValue<ImportResult?>> {
  /// Imports parsed rows into the chosen target account. Amounts are parsed
  /// with the account's own decimals; the server turns them into ordinary
  /// postings and reports inserted, duplicate and error counts.
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
  Override overrideWithValue(AsyncValue<ImportResult?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ImportResult?>>(value),
    );
  }
}

String _$importTransactionsHash() =>
    r'255c589fbdb847b14e1832c9246f998f4e554320';

/// Imports parsed rows into the chosen target account. Amounts are parsed
/// with the account's own decimals; the server turns them into ordinary
/// postings and reports inserted, duplicate and error counts.

abstract class _$ImportTransactions
    extends $Notifier<AsyncValue<ImportResult?>> {
  AsyncValue<ImportResult?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ImportResult?>, AsyncValue<ImportResult?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ImportResult?>, AsyncValue<ImportResult?>>,
              AsyncValue<ImportResult?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
