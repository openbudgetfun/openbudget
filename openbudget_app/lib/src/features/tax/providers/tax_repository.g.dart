// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taxRepository)
final taxRepositoryProvider = TaxRepositoryProvider._();

final class TaxRepositoryProvider
    extends $FunctionalProvider<TaxRepository, TaxRepository, TaxRepository>
    with $Provider<TaxRepository> {
  TaxRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taxRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taxRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaxRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaxRepository create(Ref ref) {
    return taxRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaxRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaxRepository>(value),
    );
  }
}

String _$taxRepositoryHash() => r'a2b941989f7d6f594558164107e828bfc8d21899';
