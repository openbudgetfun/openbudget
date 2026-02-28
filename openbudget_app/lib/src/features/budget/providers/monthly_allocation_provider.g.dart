// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_allocation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthlyAllocations)
final monthlyAllocationsProvider = MonthlyAllocationsFamily._();

final class MonthlyAllocationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyAllocation>>,
          List<MonthlyAllocation>,
          FutureOr<List<MonthlyAllocation>>
        >
    with
        $FutureModifier<List<MonthlyAllocation>>,
        $FutureProvider<List<MonthlyAllocation>> {
  MonthlyAllocationsProvider._({
    required MonthlyAllocationsFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthlyAllocationsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyAllocationsHash();

  @override
  String toString() {
    return r'monthlyAllocationsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<MonthlyAllocation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlyAllocation>> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return monthlyAllocations(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyAllocationsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyAllocationsHash() =>
    r'b912d598eaf9a7168839f100602984fd2fcc41ae';

final class MonthlyAllocationsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<MonthlyAllocation>>,
          (String, int, int)
        > {
  MonthlyAllocationsFamily._()
    : super(
        retry: null,
        name: r'monthlyAllocationsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyAllocationsProvider call(String budgetId, int year, int month) =>
      MonthlyAllocationsProvider._(
        argument: (budgetId, year, month),
        from: this,
      );

  @override
  String toString() => r'monthlyAllocationsProvider';
}

@ProviderFor(monthlyTransactions)
final monthlyTransactionsProvider = MonthlyTransactionsFamily._();

final class MonthlyTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Transaction>>,
          List<Transaction>,
          FutureOr<List<Transaction>>
        >
    with
        $FutureModifier<List<Transaction>>,
        $FutureProvider<List<Transaction>> {
  MonthlyTransactionsProvider._({
    required MonthlyTransactionsFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthlyTransactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyTransactionsHash();

  @override
  String toString() {
    return r'monthlyTransactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Transaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Transaction>> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return monthlyTransactions(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyTransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyTransactionsHash() =>
    r'55c96da09a6b028dd767ec487cd930135dd85a64';

final class MonthlyTransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Transaction>>,
          (String, int, int)
        > {
  MonthlyTransactionsFamily._()
    : super(
        retry: null,
        name: r'monthlyTransactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyTransactionsProvider call(String budgetId, int year, int month) =>
      MonthlyTransactionsProvider._(
        argument: (budgetId, year, month),
        from: this,
      );

  @override
  String toString() => r'monthlyTransactionsProvider';
}

@ProviderFor(MonthlyAllocationActions)
final monthlyAllocationActionsProvider = MonthlyAllocationActionsProvider._();

final class MonthlyAllocationActionsProvider
    extends $NotifierProvider<MonthlyAllocationActions, AsyncValue<void>> {
  MonthlyAllocationActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyAllocationActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyAllocationActionsHash();

  @$internal
  @override
  MonthlyAllocationActions create() => MonthlyAllocationActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$monthlyAllocationActionsHash() =>
    r'118cb861316ec91b700f851010dae46144b64b3b';

abstract class _$MonthlyAllocationActions extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
