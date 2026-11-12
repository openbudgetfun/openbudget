// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Subscribes to the entity's change stream and invalidates the providers
/// each [ChangeScope] covers, so open screens refresh when any write lands
/// on the server — including writes made by the assistant or another
/// device. The app shell watches this once per signed-in entity.

@ProviderFor(entityEvents)
final entityEventsProvider = EntityEventsFamily._();

/// Subscribes to the entity's change stream and invalidates the providers
/// each [ChangeScope] covers, so open screens refresh when any write lands
/// on the server — including writes made by the assistant or another
/// device. The app shell watches this once per signed-in entity.

final class EntityEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EntityChangedEvent>,
          EntityChangedEvent,
          Stream<EntityChangedEvent>
        >
    with
        $FutureModifier<EntityChangedEvent>,
        $StreamProvider<EntityChangedEvent> {
  /// Subscribes to the entity's change stream and invalidates the providers
  /// each [ChangeScope] covers, so open screens refresh when any write lands
  /// on the server — including writes made by the assistant or another
  /// device. The app shell watches this once per signed-in entity.
  EntityEventsProvider._({
    required EntityEventsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'entityEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entityEventsHash();

  @override
  String toString() {
    return r'entityEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<EntityChangedEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EntityChangedEvent> create(Ref ref) {
    final argument = this.argument as String;
    return entityEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EntityEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entityEventsHash() => r'68139061b87c794f3235b0223564d1413d64b647';

/// Subscribes to the entity's change stream and invalidates the providers
/// each [ChangeScope] covers, so open screens refresh when any write lands
/// on the server — including writes made by the assistant or another
/// device. The app shell watches this once per signed-in entity.

final class EntityEventsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<EntityChangedEvent>, String> {
  EntityEventsFamily._()
    : super(
        retry: null,
        name: r'entityEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Subscribes to the entity's change stream and invalidates the providers
  /// each [ChangeScope] covers, so open screens refresh when any write lands
  /// on the server — including writes made by the assistant or another
  /// device. The app shell watches this once per signed-in entity.

  EntityEventsProvider call(String entityId) =>
      EntityEventsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'entityEventsProvider';
}
