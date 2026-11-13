// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Asks the server for a signed summary link and opens it.
///
/// The state is the progress of the latest attempt: loading while the link
/// is made and opened, an error when either step failed, data once the
/// download has started.

@ProviderFor(TaxExport)
final taxExportProvider = TaxExportProvider._();

/// Asks the server for a signed summary link and opens it.
///
/// The state is the progress of the latest attempt: loading while the link
/// is made and opened, an error when either step failed, data once the
/// download has started.
final class TaxExportProvider
    extends $NotifierProvider<TaxExport, AsyncValue<void>> {
  /// Asks the server for a signed summary link and opens it.
  ///
  /// The state is the progress of the latest attempt: loading while the link
  /// is made and opened, an error when either step failed, data once the
  /// download has started.
  TaxExportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxExportProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxExportHash();

  @$internal
  @override
  TaxExport create() => TaxExport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$taxExportHash() => r'b6d94dde62a6eecf6bdf6657a75c5c7c38c9a3bd';

/// Asks the server for a signed summary link and opens it.
///
/// The state is the progress of the latest attempt: loading while the link
/// is made and opened, an error when either step failed, data once the
/// download has started.

abstract class _$TaxExport extends $Notifier<AsyncValue<void>> {
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
