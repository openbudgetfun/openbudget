// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The server's month view for the selected month: envelope figures come
/// from `EnvelopeMonthView`, never from `Envelope`.

@ProviderFor(budgetMonth)
final budgetMonthProvider = BudgetMonthFamily._();

/// The server's month view for the selected month: envelope figures come
/// from `EnvelopeMonthView`, never from `Envelope`.

final class BudgetMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<BudgetMonthView>,
          BudgetMonthView,
          FutureOr<BudgetMonthView>
        >
    with $FutureModifier<BudgetMonthView>, $FutureProvider<BudgetMonthView> {
  /// The server's month view for the selected month: envelope figures come
  /// from `EnvelopeMonthView`, never from `Envelope`.
  BudgetMonthProvider._({
    required BudgetMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthHash();

  @override
  String toString() {
    return r'budgetMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BudgetMonthView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BudgetMonthView> create(Ref ref) {
    final argument = this.argument as String;
    return budgetMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetMonthHash() => r'4849b0972a4569c685bfd65aa6e77b0d699fd5e2';

/// The server's month view for the selected month: envelope figures come
/// from `EnvelopeMonthView`, never from `Envelope`.

final class BudgetMonthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BudgetMonthView>, String> {
  BudgetMonthFamily._()
    : super(
        retry: null,
        name: r'budgetMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The server's month view for the selected month: envelope figures come
  /// from `EnvelopeMonthView`, never from `Envelope`.

  BudgetMonthProvider call(String entityId) =>
      BudgetMonthProvider._(argument: entityId, from: this);

  @override
  String toString() => r'budgetMonthProvider';
}

/// The month view grouped by category in display order, ready for the plan
/// screen. Envelope figures always come from [EnvelopeMonthView].

@ProviderFor(budgetMonthGroups)
final budgetMonthGroupsProvider = BudgetMonthGroupsFamily._();

/// The month view grouped by category in display order, ready for the plan
/// screen. Envelope figures always come from [EnvelopeMonthView].

final class BudgetMonthGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryMonthGroup>>,
          List<CategoryMonthGroup>,
          FutureOr<List<CategoryMonthGroup>>
        >
    with
        $FutureModifier<List<CategoryMonthGroup>>,
        $FutureProvider<List<CategoryMonthGroup>> {
  /// The month view grouped by category in display order, ready for the plan
  /// screen. Envelope figures always come from [EnvelopeMonthView].
  BudgetMonthGroupsProvider._({
    required BudgetMonthGroupsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetMonthGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthGroupsHash();

  @override
  String toString() {
    return r'budgetMonthGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategoryMonthGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryMonthGroup>> create(Ref ref) {
    final argument = this.argument as String;
    return budgetMonthGroups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetMonthGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetMonthGroupsHash() => r'f850b95f7d3c024a359516c80f07c87121c270dc';

/// The month view grouped by category in display order, ready for the plan
/// screen. Envelope figures always come from [EnvelopeMonthView].

final class BudgetMonthGroupsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CategoryMonthGroup>>, String> {
  BudgetMonthGroupsFamily._()
    : super(
        retry: null,
        name: r'budgetMonthGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The month view grouped by category in display order, ready for the plan
  /// screen. Envelope figures always come from [EnvelopeMonthView].

  BudgetMonthGroupsProvider call(String entityId) =>
      BudgetMonthGroupsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'budgetMonthGroupsProvider';
}

/// Every category of the entity, for pickers and the category screens.

@ProviderFor(categoryList)
final categoryListProvider = CategoryListFamily._();

/// Every category of the entity, for pickers and the category screens.

final class CategoryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Category>>,
          List<Category>,
          FutureOr<List<Category>>
        >
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// Every category of the entity, for pickers and the category screens.
  CategoryListProvider._({
    required CategoryListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @override
  String toString() {
    return r'categoryListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryListHash() => r'1bad9f79b3c3755e7be3c3ecb2047e159bfaaafa';

/// Every category of the entity, for pickers and the category screens.

final class CategoryListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Category>>, String> {
  CategoryListFamily._()
    : super(
        retry: null,
        name: r'categoryListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every category of the entity, for pickers and the category screens.

  CategoryListProvider call(String entityId) =>
      CategoryListProvider._(argument: entityId, from: this);

  @override
  String toString() => r'categoryListProvider';
}

/// Every envelope of the entity, replacing the old per-category list.

@ProviderFor(envelopeList)
final envelopeListProvider = EnvelopeListFamily._();

/// Every envelope of the entity, replacing the old per-category list.

final class EnvelopeListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Envelope>>,
          List<Envelope>,
          FutureOr<List<Envelope>>
        >
    with $FutureModifier<List<Envelope>>, $FutureProvider<List<Envelope>> {
  /// Every envelope of the entity, replacing the old per-category list.
  EnvelopeListProvider._({
    required EnvelopeListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'envelopeListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$envelopeListHash();

  @override
  String toString() {
    return r'envelopeListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Envelope>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Envelope>> create(Ref ref) {
    final argument = this.argument as String;
    return envelopeList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EnvelopeListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$envelopeListHash() => r'afbf37ee5d76171ea1ef2b24d630a797b6420dc6';

/// Every envelope of the entity, replacing the old per-category list.

final class EnvelopeListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Envelope>>, String> {
  EnvelopeListFamily._()
    : super(
        retry: null,
        name: r'envelopeListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every envelope of the entity, replacing the old per-category list.

  EnvelopeListProvider call(String entityId) =>
      EnvelopeListProvider._(argument: entityId, from: this);

  @override
  String toString() => r'envelopeListProvider';
}

/// One envelope's row of the month view. Throws when the envelope has no
/// row this month, which the category detail screen reports as "not found".

@ProviderFor(budgetMonthEnvelope)
final budgetMonthEnvelopeProvider = BudgetMonthEnvelopeFamily._();

/// One envelope's row of the month view. Throws when the envelope has no
/// row this month, which the category detail screen reports as "not found".

final class BudgetMonthEnvelopeProvider
    extends
        $FunctionalProvider<
          AsyncValue<EnvelopeMonthView>,
          EnvelopeMonthView,
          FutureOr<EnvelopeMonthView>
        >
    with
        $FutureModifier<EnvelopeMonthView>,
        $FutureProvider<EnvelopeMonthView> {
  /// One envelope's row of the month view. Throws when the envelope has no
  /// row this month, which the category detail screen reports as "not found".
  BudgetMonthEnvelopeProvider._({
    required BudgetMonthEnvelopeFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'budgetMonthEnvelopeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthEnvelopeHash();

  @override
  String toString() {
    return r'budgetMonthEnvelopeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<EnvelopeMonthView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EnvelopeMonthView> create(Ref ref) {
    final argument = this.argument as (String, String);
    return budgetMonthEnvelope(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetMonthEnvelopeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetMonthEnvelopeHash() =>
    r'f6c2d1ea12e4ba88b331f5d3d292b294cf47c648';

/// One envelope's row of the month view. Throws when the envelope has no
/// row this month, which the category detail screen reports as "not found".

final class BudgetMonthEnvelopeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<EnvelopeMonthView>,
          (String, String)
        > {
  BudgetMonthEnvelopeFamily._()
    : super(
        retry: null,
        name: r'budgetMonthEnvelopeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One envelope's row of the month view. Throws when the envelope has no
  /// row this month, which the category detail screen reports as "not found".

  BudgetMonthEnvelopeProvider call(String entityId, String envelopeId) =>
      BudgetMonthEnvelopeProvider._(
        argument: (entityId, envelopeId),
        from: this,
      );

  @override
  String toString() => r'budgetMonthEnvelopeProvider';
}

/// The month view's currency code.

@ProviderFor(budgetMonthCurrency)
final budgetMonthCurrencyProvider = BudgetMonthCurrencyFamily._();

/// The month view's currency code.

final class BudgetMonthCurrencyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The month view's currency code.
  BudgetMonthCurrencyProvider._({
    required BudgetMonthCurrencyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'budgetMonthCurrencyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthCurrencyHash();

  @override
  String toString() {
    return r'budgetMonthCurrencyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return budgetMonthCurrency(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetMonthCurrencyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetMonthCurrencyHash() =>
    r'c570e4828aafc6ae4bfa2512f9e07fd6bab96250';

/// The month view's currency code.

final class BudgetMonthCurrencyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  BudgetMonthCurrencyFamily._()
    : super(
        retry: null,
        name: r'budgetMonthCurrencyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The month view's currency code.

  BudgetMonthCurrencyProvider call(String entityId) =>
      BudgetMonthCurrencyProvider._(argument: entityId, from: this);

  @override
  String toString() => r'budgetMonthCurrencyProvider';
}

/// The selected month as yyyymm, for dialogs that need the month.

@ProviderFor(selectedYyyymm)
final selectedYyyymmProvider = SelectedYyyymmFamily._();

/// The selected month as yyyymm, for dialogs that need the month.

final class SelectedYyyymmProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// The selected month as yyyymm, for dialogs that need the month.
  SelectedYyyymmProvider._({
    required SelectedYyyymmFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectedYyyymmProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedYyyymmHash();

  @override
  String toString() {
    return r'selectedYyyymmProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return selectedYyyymm(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedYyyymmProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedYyyymmHash() => r'fbcfaa0e5abca6d5b3b161bb8c4a3a8b92f29445';

/// The selected month as yyyymm, for dialogs that need the month.

final class SelectedYyyymmFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  SelectedYyyymmFamily._()
    : super(
        retry: null,
        name: r'selectedYyyymmProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The selected month as yyyymm, for dialogs that need the month.

  SelectedYyyymmProvider call(String entityId) =>
      SelectedYyyymmProvider._(argument: entityId, from: this);

  @override
  String toString() => r'selectedYyyymmProvider';
}

/// Writes allocations and moves. Every write returns the fresh
/// month view, which replaces the cached one immediately.

@ProviderFor(BudgetMonthActions)
final budgetMonthActionsProvider = BudgetMonthActionsProvider._();

/// Writes allocations and moves. Every write returns the fresh
/// month view, which replaces the cached one immediately.
final class BudgetMonthActionsProvider
    extends
        $NotifierProvider<BudgetMonthActions, AsyncValue<BudgetMonthView?>> {
  /// Writes allocations and moves. Every write returns the fresh
  /// month view, which replaces the cached one immediately.
  BudgetMonthActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetMonthActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetMonthActionsHash();

  @$internal
  @override
  BudgetMonthActions create() => BudgetMonthActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<BudgetMonthView?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<BudgetMonthView?>>(value),
    );
  }
}

String _$budgetMonthActionsHash() =>
    r'0aa91d8aa2e12199698c3c06ae72f407b3ebea97';

/// Writes allocations and moves. Every write returns the fresh
/// month view, which replaces the cached one immediately.

abstract class _$BudgetMonthActions
    extends $Notifier<AsyncValue<BudgetMonthView?>> {
  AsyncValue<BudgetMonthView?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<BudgetMonthView?>, AsyncValue<BudgetMonthView?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<BudgetMonthView?>,
                AsyncValue<BudgetMonthView?>
              >,
              AsyncValue<BudgetMonthView?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
