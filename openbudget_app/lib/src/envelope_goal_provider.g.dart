// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_goal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every goal of the entity; the month view carries per-envelope goals for
/// display.

@ProviderFor(envelopeGoals)
final envelopeGoalsProvider = EnvelopeGoalsFamily._();

/// Every goal of the entity; the month view carries per-envelope goals for
/// display.

final class EnvelopeGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EnvelopeGoal>>,
          List<EnvelopeGoal>,
          FutureOr<List<EnvelopeGoal>>
        >
    with
        $FutureModifier<List<EnvelopeGoal>>,
        $FutureProvider<List<EnvelopeGoal>> {
  /// Every goal of the entity; the month view carries per-envelope goals for
  /// display.
  EnvelopeGoalsProvider._({
    required EnvelopeGoalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'envelopeGoalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$envelopeGoalsHash();

  @override
  String toString() {
    return r'envelopeGoalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<EnvelopeGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EnvelopeGoal>> create(Ref ref) {
    final argument = this.argument as String;
    return envelopeGoals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EnvelopeGoalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$envelopeGoalsHash() => r'b1aa26f94d261dac8e420f9b054776c889c5499f';

/// Every goal of the entity; the month view carries per-envelope goals for
/// display.

final class EnvelopeGoalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<EnvelopeGoal>>, String> {
  EnvelopeGoalsFamily._()
    : super(
        retry: null,
        name: r'envelopeGoalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every goal of the entity; the month view carries per-envelope goals for
  /// display.

  EnvelopeGoalsProvider call(String entityId) =>
      EnvelopeGoalsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'envelopeGoalsProvider';
}

@ProviderFor(EnvelopeGoalActions)
final envelopeGoalActionsProvider = EnvelopeGoalActionsProvider._();

final class EnvelopeGoalActionsProvider
    extends $NotifierProvider<EnvelopeGoalActions, AsyncValue<void>> {
  EnvelopeGoalActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'envelopeGoalActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$envelopeGoalActionsHash();

  @$internal
  @override
  EnvelopeGoalActions create() => EnvelopeGoalActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$envelopeGoalActionsHash() =>
    r'758f30af9566d9eae4d52cad97235aa3d7fa99cd';

abstract class _$EnvelopeGoalActions extends $Notifier<AsyncValue<void>> {
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
