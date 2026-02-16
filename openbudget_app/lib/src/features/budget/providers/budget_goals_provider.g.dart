// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_goals_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all envelope goals for a budget and returns them as a map
/// keyed by envelope ID string for quick lookup.

@ProviderFor(budgetGoals)
final budgetGoalsProvider = BudgetGoalsFamily._();

/// Fetches all envelope goals for a budget and returns them as a map
/// keyed by envelope ID string for quick lookup.

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
  /// Fetches all envelope goals for a budget and returns them as a map
  /// keyed by envelope ID string for quick lookup.
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

String _$budgetGoalsHash() => r'b5ac89cdc7c29235195212d8f82d8d38118c9bbf';

/// Fetches all envelope goals for a budget and returns them as a map
/// keyed by envelope ID string for quick lookup.

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

  /// Fetches all envelope goals for a budget and returns them as a map
  /// keyed by envelope ID string for quick lookup.

  BudgetGoalsProvider call(String budgetId) =>
      BudgetGoalsProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetGoalsProvider';
}
