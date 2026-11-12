// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'institution_catalog_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(institutionCatalog)
final institutionCatalogProvider = InstitutionCatalogFamily._();

final class InstitutionCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Institution>>,
          List<Institution>,
          FutureOr<List<Institution>>
        >
    with
        $FutureModifier<List<Institution>>,
        $FutureProvider<List<Institution>> {
  InstitutionCatalogProvider._({
    required InstitutionCatalogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'institutionCatalogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$institutionCatalogHash();

  @override
  String toString() {
    return r'institutionCatalogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Institution>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Institution>> create(Ref ref) {
    final argument = this.argument as String;
    return institutionCatalog(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InstitutionCatalogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$institutionCatalogHash() =>
    r'bc8be4ac1e2c255d0867e49070de77f494123d3b';

final class InstitutionCatalogFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Institution>>, String> {
  InstitutionCatalogFamily._()
    : super(
        retry: null,
        name: r'institutionCatalogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InstitutionCatalogProvider call(String locationCode) =>
      InstitutionCatalogProvider._(argument: locationCode, from: this);

  @override
  String toString() => r'institutionCatalogProvider';
}
