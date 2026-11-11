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

String _$recurringActionsHash() => r'e8d07b444043594944111b0a4b3f513de946f675';

abstract class _$RecurringActions extends $Notifier<AsyncValue<void>> {
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

/// How many recurring transactions are due in [entityId] right now.

@ProviderFor(recurringDueCount)
final recurringDueCountProvider = RecurringDueCountFamily._();

/// How many recurring transactions are due in [entityId] right now.

final class RecurringDueCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// How many recurring transactions are due in [entityId] right now.
  RecurringDueCountProvider._({
    required RecurringDueCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'recurringDueCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$recurringDueCountHash();

  @override
  String toString() {
    return r'recurringDueCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return recurringDueCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RecurringDueCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recurringDueCountHash() => r'9f381b88e248edc1a095be50af7abaf30d036d24';

/// How many recurring transactions are due in [entityId] right now.

final class RecurringDueCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  RecurringDueCountFamily._()
    : super(
        retry: null,
        name: r'recurringDueCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many recurring transactions are due in [entityId] right now.

  RecurringDueCountProvider call(String entityId) =>
      RecurringDueCountProvider._(argument: entityId, from: this);

  @override
  String toString() => r'recurringDueCountProvider';
}
