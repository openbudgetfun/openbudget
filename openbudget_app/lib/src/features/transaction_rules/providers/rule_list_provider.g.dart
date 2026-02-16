// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches all transaction rules for a budget.

@ProviderFor(ruleList)
final ruleListProvider = RuleListFamily._();

/// Fetches all transaction rules for a budget.

final class RuleListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TransactionRule>>,
          List<TransactionRule>,
          FutureOr<List<TransactionRule>>
        >
    with
        $FutureModifier<List<TransactionRule>>,
        $FutureProvider<List<TransactionRule>> {
  /// Fetches all transaction rules for a budget.
  RuleListProvider._({
    required RuleListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'ruleListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ruleListHash();

  @override
  String toString() {
    return r'ruleListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TransactionRule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TransactionRule>> create(Ref ref) {
    final argument = this.argument as String;
    return ruleList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RuleListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ruleListHash() => r'6c353a3f33abddfe5717c7c24f6f869aa0f4f51b';

/// Fetches all transaction rules for a budget.

final class RuleListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TransactionRule>>, String> {
  RuleListFamily._()
    : super(
        retry: null,
        name: r'ruleListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches all transaction rules for a budget.

  RuleListProvider call(String budgetId) =>
      RuleListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'ruleListProvider';
}
