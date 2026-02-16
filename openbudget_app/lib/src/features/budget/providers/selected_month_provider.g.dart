// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedMonth)
final selectedMonthProvider = SelectedMonthFamily._();

final class SelectedMonthProvider
    extends $NotifierProvider<SelectedMonth, BudgetMonth> {
  SelectedMonthProvider._({
    required SelectedMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'selectedMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$selectedMonthHash();

  @override
  String toString() {
    return r'selectedMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SelectedMonth create() => SelectedMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetMonth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetMonth>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$selectedMonthHash() => r'752aa951ee1c1763eec378dc60f01af7369ffa56';

final class SelectedMonthFamily extends $Family
    with
        $ClassFamilyOverride<
          SelectedMonth,
          BudgetMonth,
          BudgetMonth,
          BudgetMonth,
          String
        > {
  SelectedMonthFamily._()
    : super(
        retry: null,
        name: r'selectedMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SelectedMonthProvider call(String budgetId) =>
      SelectedMonthProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'selectedMonthProvider';
}

abstract class _$SelectedMonth extends $Notifier<BudgetMonth> {
  late final _$args = ref.$arg as String;
  String get budgetId => _$args;

  BudgetMonth build(String budgetId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BudgetMonth, BudgetMonth>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetMonth, BudgetMonth>,
              BudgetMonth,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
