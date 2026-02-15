// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetList)
final budgetListProvider = BudgetListProvider._();

final class BudgetListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Budget>>,
          List<Budget>,
          FutureOr<List<Budget>>
        >
    with $FutureModifier<List<Budget>>, $FutureProvider<List<Budget>> {
  BudgetListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetListHash();

  @$internal
  @override
  $FutureProviderElement<List<Budget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Budget>> create(Ref ref) {
    return budgetList(ref);
  }
}

String _$budgetListHash() => r'97cc52427651248b08bcef224687d72161c289dc';
