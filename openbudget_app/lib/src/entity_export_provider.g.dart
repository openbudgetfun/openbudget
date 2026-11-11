// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exports one entity through `entity.exportData` as a portable JSON
/// document. The settings screen copies it to the clipboard.

@ProviderFor(EntityExport)
final entityExportProvider = EntityExportProvider._();

/// Exports one entity through `entity.exportData` as a portable JSON
/// document. The settings screen copies it to the clipboard.
final class EntityExportProvider
    extends $NotifierProvider<EntityExport, AsyncValue<void>> {
  /// Exports one entity through `entity.exportData` as a portable JSON
  /// document. The settings screen copies it to the clipboard.
  EntityExportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityExportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityExportHash();

  @$internal
  @override
  EntityExport create() => EntityExport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$entityExportHash() => r'c24b4d1f89cd3702f555237005f9c8054ebf49a3';

/// Exports one entity through `entity.exportData` as a portable JSON
/// document. The settings screen copies it to the clipboard.

abstract class _$EntityExport extends $Notifier<AsyncValue<void>> {
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
