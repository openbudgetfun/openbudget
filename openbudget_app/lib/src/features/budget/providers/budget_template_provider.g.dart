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
    r'8b5f12c22919a24d84b541cd5d692050ce74c535';

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

  BudgetTemplateListProvider call(String entityId) =>
      BudgetTemplateListProvider._(argument: entityId, from: this);

  @override
  String toString() => r'budgetTemplateListProvider';
}

/// One template's envelope lines, with this month's allocations.

@ProviderFor(budgetTemplateLines)
final budgetTemplateLinesProvider = BudgetTemplateLinesFamily._();

/// One template's envelope lines, with this month's allocations.

final class BudgetTemplateLinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetTemplateLine>>,
          List<BudgetTemplateLine>,
          FutureOr<List<BudgetTemplateLine>>
        >
    with
        $FutureModifier<List<BudgetTemplateLine>>,
        $FutureProvider<List<BudgetTemplateLine>> {
  /// One template's envelope lines, with this month's allocations.
  BudgetTemplateLinesProvider._({
    required BudgetTemplateLinesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetTemplateLinesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetTemplateLinesHash();

  @override
  String toString() {
    return r'budgetTemplateLinesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BudgetTemplateLine>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetTemplateLine>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetTemplateLines(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetTemplateLinesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetTemplateLinesHash() =>
    r'03b5f78548f14a402775afe26aa018d2fcf7d001';

/// One template's envelope lines, with this month's allocations.

final class BudgetTemplateLinesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BudgetTemplateLine>>, String> {
  BudgetTemplateLinesFamily._()
    : super(
        retry: null,
        name: r'budgetTemplateLinesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One template's envelope lines, with this month's allocations.

  BudgetTemplateLinesProvider call(String templateId) =>
      BudgetTemplateLinesProvider._(argument: templateId, from: this);

  @override
  String toString() => r'budgetTemplateLinesProvider';
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
    r'cffeb02412037f1e9b2b3e55a65820e7aeb104db';

abstract class _$BudgetTemplateActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
