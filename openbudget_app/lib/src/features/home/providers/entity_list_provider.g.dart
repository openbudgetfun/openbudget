// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every entity the signed-in user owns, in the server's order.

@ProviderFor(entityList)
final entityListProvider = EntityListProvider._();

/// Every entity the signed-in user owns, in the server's order.

final class EntityListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Entity>>,
          List<Entity>,
          FutureOr<List<Entity>>
        >
    with $FutureModifier<List<Entity>>, $FutureProvider<List<Entity>> {
  /// Every entity the signed-in user owns, in the server's order.
  EntityListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityListHash();

  @$internal
  @override
  $FutureProviderElement<List<Entity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Entity>> create(Ref ref) {
    return entityList(ref);
  }
}

String _$entityListHash() => r'd562b8316a5442411257948e80f8079e26c1b513';
