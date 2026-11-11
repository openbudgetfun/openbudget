// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(entitySummaries)
final entitySummariesProvider = EntitySummariesProvider._();

final class EntitySummariesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EntitySummary>>,
          List<EntitySummary>,
          FutureOr<List<EntitySummary>>
        >
    with
        $FutureModifier<List<EntitySummary>>,
        $FutureProvider<List<EntitySummary>> {
  EntitySummariesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entitySummariesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entitySummariesHash();

  @$internal
  @override
  $FutureProviderElement<List<EntitySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EntitySummary>> create(Ref ref) {
    return entitySummaries(ref);
  }
}

String _$entitySummariesHash() => r'ecb88b5e8e9caf14b7e192521544be2195e928f2';
