// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetSummary)
final budgetSummaryProvider = BudgetSummaryFamily._();

final class BudgetSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetSummary>,
          BudgetSummary,
          FutureOr<BudgetSummary>
        >
    with $FutureModifier<BudgetSummary>, $FutureProvider<BudgetSummary> {
  BudgetSummaryProvider._({
    required BudgetSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetSummaryHash();

  @override
  String toString() {
    return r'budgetSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BudgetSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetSummary> create(Ref ref) {
    final argument = this.argument as String;
    return budgetSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetSummaryHash() => r'db2271b364b593c401f79395788d8cd4284eeeb0';

final class BudgetSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BudgetSummary>, String> {
  BudgetSummaryFamily._()
    : super(
        retry: null,
        name: r'budgetSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetSummaryProvider call(String budgetId) =>
      BudgetSummaryProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetSummaryProvider';
}

/// Month-aware budget summary that uses monthly allocations and
/// month-scoped transactions.

@ProviderFor(budgetMonthlySummary)
final budgetMonthlySummaryProvider = BudgetMonthlySummaryFamily._();

/// Month-aware budget summary that uses monthly allocations and
/// month-scoped transactions.

final class BudgetMonthlySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetSummary>,
          BudgetSummary,
          FutureOr<BudgetSummary>
        >
    with $FutureModifier<BudgetSummary>, $FutureProvider<BudgetSummary> {
  /// Month-aware budget summary that uses monthly allocations and
  /// month-scoped transactions.
  BudgetMonthlySummaryProvider._({
    required BudgetMonthlySummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetMonthlySummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthlySummaryHash();

  @override
  String toString() {
    return r'budgetMonthlySummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BudgetSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetSummary> create(Ref ref) {
    final argument = this.argument as String;
    return budgetMonthlySummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetMonthlySummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetMonthlySummaryHash() =>
    r'22901c55b70a2b158d1298dfa031b649b43a6a02';

/// Month-aware budget summary that uses monthly allocations and
/// month-scoped transactions.

final class BudgetMonthlySummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BudgetSummary>, String> {
  BudgetMonthlySummaryFamily._()
    : super(
        retry: null,
        name: r'budgetMonthlySummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Month-aware budget summary that uses monthly allocations and
  /// month-scoped transactions.

  BudgetMonthlySummaryProvider call(String budgetId) =>
      BudgetMonthlySummaryProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetMonthlySummaryProvider';
}
