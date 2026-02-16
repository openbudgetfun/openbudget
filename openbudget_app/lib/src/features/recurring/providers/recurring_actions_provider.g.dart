// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecurringActions)
final recurringActionsProvider = RecurringActionsProvider._();

final class RecurringActionsProvider
    extends $NotifierProvider<RecurringActions, AsyncValue<void>> {
  RecurringActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringActionsHash();

  @$internal
  @override
  RecurringActions create() => RecurringActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$recurringActionsHash() => r'408c9560f098cffe5cc4c176d5f5f0c5e33cf5d0';

abstract class _$RecurringActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
