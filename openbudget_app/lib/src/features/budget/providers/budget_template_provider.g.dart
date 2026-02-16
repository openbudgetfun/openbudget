// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_template_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetTemplateList)
final budgetTemplateListProvider = BudgetTemplateListFamily._();

final class BudgetTemplateListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetTemplate>>,
          List<BudgetTemplate>,
          FutureOr<List<BudgetTemplate>>
        >
    with
        $FutureModifier<List<BudgetTemplate>>,
        $FutureProvider<List<BudgetTemplate>> {
  BudgetTemplateListProvider._({
    required BudgetTemplateListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetTemplateListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetTemplateListHash();

  @override
  String toString() {
    return r'budgetTemplateListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BudgetTemplate>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetTemplate>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetTemplateList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetTemplateListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetTemplateListHash() =>
    r'9ab7d8cfa7604942ef1bf031d82a9b6254b67a4a';

final class BudgetTemplateListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BudgetTemplate>>, String> {
  BudgetTemplateListFamily._()
    : super(
        retry: null,
        name: r'budgetTemplateListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BudgetTemplateListProvider call(String budgetId) =>
      BudgetTemplateListProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'budgetTemplateListProvider';
}

@ProviderFor(BudgetTemplateActions)
final budgetTemplateActionsProvider = BudgetTemplateActionsProvider._();

final class BudgetTemplateActionsProvider
    extends $NotifierProvider<BudgetTemplateActions, void> {
  BudgetTemplateActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetTemplateActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetTemplateActionsHash();

  @$internal
  @override
  BudgetTemplateActions create() => BudgetTemplateActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$budgetTemplateActionsHash() =>
    r'99ee15a269a726522c60e792d7e17f3695d1fade';

abstract class _$BudgetTemplateActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
