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

String _$budgetSummaryHash() => r'93e5f35a130d9d773be8a28974773652ad80afb3';

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
