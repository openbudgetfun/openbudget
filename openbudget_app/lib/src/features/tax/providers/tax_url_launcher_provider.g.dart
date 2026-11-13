// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_url_launcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The launcher the tax screens use.

@ProviderFor(taxUrlLauncher)
final taxUrlLauncherProvider = TaxUrlLauncherProvider._();

/// The launcher the tax screens use.

final class TaxUrlLauncherProvider
    extends $FunctionalProvider<TaxUrlLauncher, TaxUrlLauncher, TaxUrlLauncher>
    with $Provider<TaxUrlLauncher> {
  /// The launcher the tax screens use.
  TaxUrlLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxUrlLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxUrlLauncherHash();

  @$internal
  @override
  $ProviderElement<TaxUrlLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaxUrlLauncher create(Ref ref) {
    return taxUrlLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxUrlLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxUrlLauncher>(value),
    );
  }
}

String _$taxUrlLauncherHash() => r'14929939018ec33f76d8ac858453f177ccac500e';
