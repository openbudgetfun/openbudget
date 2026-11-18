// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One entity, reloaded when entity-scoped events arrive.

@ProviderFor(entityDetail)
final entityDetailProvider = EntityDetailFamily._();

/// One entity, reloaded when entity-scoped events arrive.

final class EntityDetailProvider
    extends $FunctionalProvider<AsyncValue<Entity>, Entity, FutureOr<Entity>>
    with $FutureModifier<Entity>, $FutureProvider<Entity> {
  /// One entity, reloaded when entity-scoped events arrive.
  EntityDetailProvider._({
    required EntityDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'entityDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entityDetailHash();

  @override
  String toString() {
    return r'entityDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Entity> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Entity> create(Ref ref) {
    final argument = this.argument as String;
    return entityDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EntityDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entityDetailHash() => r'5a24211dda278666d5430d51c574b97c1ce48152';

/// One entity, reloaded when entity-scoped events arrive.

final class EntityDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Entity>, String> {
  EntityDetailFamily._()
    : super(
        retry: null,
        name: r'entityDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One entity, reloaded when entity-scoped events arrive.

  EntityDetailProvider call(String entityId) =>
      EntityDetailProvider._(argument: entityId, from: this);

  @override
  String toString() => r'entityDetailProvider';
}
