// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Suggestions for one envelope from the previous three months' views.

@ProviderFor(quickBudgetSuggestion)
final quickBudgetSuggestionProvider = QuickBudgetSuggestionFamily._();

/// Suggestions for one envelope from the previous three months' views.

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
  /// Suggestions for one envelope from the previous three months' views.
  QuickBudgetSuggestionProvider._({
    required QuickBudgetSuggestionFamily super.from,
    required (String, String, int) super.argument,
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
    final argument = this.argument as (String, String, int);
    return quickBudgetSuggestion(ref, argument.$1, argument.$2, argument.$3);
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
    r'c440fc0380609acb4bfcbcc7aeaef37da41a3148';

/// Suggestions for one envelope from the previous three months' views.

final class QuickBudgetSuggestionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<QuickBudgetSuggestion>,
          (String, String, int)
        > {
  QuickBudgetSuggestionFamily._()
    : super(
        retry: null,
        name: r'quickBudgetSuggestionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Suggestions for one envelope from the previous three months' views.

  QuickBudgetSuggestionProvider call(
    String entityId,
    String envelopeId,
    int month,
  ) => QuickBudgetSuggestionProvider._(
    argument: (entityId, envelopeId, month),
    from: this,
  );

  @override
  String toString() => r'quickBudgetSuggestionProvider';
}
