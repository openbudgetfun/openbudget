// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope_goal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(envelopeGoal)
final envelopeGoalProvider = EnvelopeGoalFamily._();

final class EnvelopeGoalProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvelopeGoal?>,
          EnvelopeGoal?,
          FutureOr<EnvelopeGoal?>
        >
    with $FutureModifier<EnvelopeGoal?>, $FutureProvider<EnvelopeGoal?> {
  EnvelopeGoalProvider._({
    required EnvelopeGoalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'envelopeGoalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$envelopeGoalHash();

  @override
  String toString() {
    return r'envelopeGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EnvelopeGoal?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvelopeGoal?> create(Ref ref) {
    final argument = this.argument as String;
    return envelopeGoal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EnvelopeGoalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$envelopeGoalHash() => r'c0c0da344c879f218e3a14efaa013e05e7688857';

final class EnvelopeGoalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EnvelopeGoal?>, String> {
  EnvelopeGoalFamily._()
    : super(
        retry: null,
        name: r'envelopeGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EnvelopeGoalProvider call(String envelopeId) =>
      EnvelopeGoalProvider._(argument: envelopeId, from: this);

  @override
  String toString() => r'envelopeGoalProvider';
}

@ProviderFor(envelopeGoals)
final envelopeGoalsProvider = EnvelopeGoalsFamily._();

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
  EnvelopeGoalsProvider._({
    required EnvelopeGoalsFamily super.from,
    required List<String> super.argument,
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
    final argument = this.argument as List<String>;
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

String _$envelopeGoalsHash() => r'fe1f9df02e1f7e52b9ab120b9bab7bf9eff50c07';

final class EnvelopeGoalsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<EnvelopeGoal>>, List<String>> {
  EnvelopeGoalsFamily._()
    : super(
        retry: null,
        name: r'envelopeGoalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EnvelopeGoalsProvider call(List<String> envelopeIds) =>
      EnvelopeGoalsProvider._(argument: envelopeIds, from: this);

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
    r'37ebd985d5c0652a978d0307fdbe3e71dea181db';

abstract class _$EnvelopeGoalActions extends $Notifier<AsyncValue<void>> {
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
