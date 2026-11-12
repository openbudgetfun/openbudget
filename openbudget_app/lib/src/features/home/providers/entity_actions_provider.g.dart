// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create and delete actions for entities. Every mutation refreshes the
/// entity list; the callers navigate with the returned id.

@ProviderFor(EntityActions)
final entityActionsProvider = EntityActionsProvider._();

/// Create and delete actions for entities. Every mutation refreshes the
/// entity list; the callers navigate with the returned id.
final class EntityActionsProvider
    extends $NotifierProvider<EntityActions, AsyncValue<void>> {
  /// Create and delete actions for entities. Every mutation refreshes the
  /// entity list; the callers navigate with the returned id.
  EntityActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entityActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entityActionsHash();

  @$internal
  @override
  EntityActions create() => EntityActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$entityActionsHash() => r'6d9fcae1aadbdaac012904a2ee2def8897e36ac8';

/// Create and delete actions for entities. Every mutation refreshes the
/// entity list; the callers navigate with the returned id.

abstract class _$EntityActions extends $Notifier<AsyncValue<void>> {
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
