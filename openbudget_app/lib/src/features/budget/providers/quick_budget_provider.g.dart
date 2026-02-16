// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes quick-budget suggestions for an envelope based on historical data.

@ProviderFor(quickBudgetSuggestion)
final quickBudgetSuggestionProvider = QuickBudgetSuggestionFamily._();

/// Computes quick-budget suggestions for an envelope based on historical data.

final class QuickBudgetSuggestionProvider
    extends
        $FunctionalProvider<
          AsyncValue<QuickBudgetSuggestion>,
          QuickBudgetSuggestion,
          FutureOr<QuickBudgetSuggestion>
        >
    with
        $FutureModifier<QuickBudgetSuggestion>,
        $FutureProvider<QuickBudgetSuggestion> {
  /// Computes quick-budget suggestions for an envelope based on historical data.
  QuickBudgetSuggestionProvider._({
    required QuickBudgetSuggestionFamily super.from,
    required (String, String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'quickBudgetSuggestionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$quickBudgetSuggestionHash();

  @override
  String toString() {
    return r'quickBudgetSuggestionProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<QuickBudgetSuggestion> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<QuickBudgetSuggestion> create(Ref ref) {
    final argument = this.argument as (String, String, int, int);
    return quickBudgetSuggestion(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuickBudgetSuggestionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$quickBudgetSuggestionHash() =>
    r'81627e09189f9ba65496fb1ef0c3113a35f954f8';

/// Computes quick-budget suggestions for an envelope based on historical data.

final class QuickBudgetSuggestionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<QuickBudgetSuggestion>,
          (String, String, int, int)
        > {
  QuickBudgetSuggestionFamily._()
    : super(
        retry: null,
        name: r'quickBudgetSuggestionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Computes quick-budget suggestions for an envelope based on historical data.

  QuickBudgetSuggestionProvider call(
    String budgetId,
    String envelopeId,
    int year,
    int month,
  ) => QuickBudgetSuggestionProvider._(
    argument: (budgetId, envelopeId, year, month),
    from: this,
  );

  @override
  String toString() => r'quickBudgetSuggestionProvider';
}
