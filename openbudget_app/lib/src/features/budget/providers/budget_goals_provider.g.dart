// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All envelope goals of the entity, keyed by envelope id. The month view
/// already carries each envelope's goal; this covers screens that edit
/// goals across envelopes.

@ProviderFor(budgetGoals)
final budgetGoalsProvider = BudgetGoalsFamily._();

/// All envelope goals of the entity, keyed by envelope id. The month view
/// already carries each envelope's goal; this covers screens that edit
/// goals across envelopes.

final class BudgetGoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, EnvelopeGoal>>,
          Map<String, EnvelopeGoal>,
          FutureOr<Map<String, EnvelopeGoal>>
        >
    with
        $FutureModifier<Map<String, EnvelopeGoal>>,
        $FutureProvider<Map<String, EnvelopeGoal>> {
  /// All envelope goals of the entity, keyed by envelope id. The month view
  /// already carries each envelope's goal; this covers screens that edit
  /// goals across envelopes.
  BudgetGoalsProvider._({
    required BudgetGoalsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetGoalsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetGoalsHash();

  @override
  String toString() {
    return r'budgetGoalsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, EnvelopeGoal>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, EnvelopeGoal>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetGoals(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetGoalsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetGoalsHash() => r'0d8be0a3f5ac03f63b7299d3cc9d6cbc89c97503';

/// All envelope goals of the entity, keyed by envelope id. The month view
/// already carries each envelope's goal; this covers screens that edit
/// goals across envelopes.

final class BudgetGoalsFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<Map<String, EnvelopeGoal>>, String> {
  BudgetGoalsFamily._()
    : super(
        retry: null,
        name: r'budgetGoalsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All envelope goals of the entity, keyed by envelope id. The month view
  /// already carries each envelope's goal; this covers screens that edit
  /// goals across envelopes.

  BudgetGoalsProvider call(String entityId) =>
      BudgetGoalsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'budgetGoalsProvider';
}
