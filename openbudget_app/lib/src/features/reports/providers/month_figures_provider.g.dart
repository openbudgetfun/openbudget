// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_figures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month-level figures for [monthCount] months ending at [endMonth],
/// newest first, from one `report.monthSummaries` call.
///
/// This replaces the old one-`budget.getMonth`-per-month loop; screens that
/// also need grouped spending call `report.spending` once themselves.

@ProviderFor(monthFigures)
final monthFiguresProvider = MonthFiguresFamily._();

/// The month-level figures for [monthCount] months ending at [endMonth],
/// newest first, from one `report.monthSummaries` call.
///
/// This replaces the old one-`budget.getMonth`-per-month loop; screens that
/// also need grouped spending call `report.spending` once themselves.

final class MonthFiguresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetMonthSummary>>,
          List<BudgetMonthSummary>,
          FutureOr<List<BudgetMonthSummary>>
        >
    with
        $FutureModifier<List<BudgetMonthSummary>>,
        $FutureProvider<List<BudgetMonthSummary>> {
  /// The month-level figures for [monthCount] months ending at [endMonth],
  /// newest first, from one `report.monthSummaries` call.
  ///
  /// This replaces the old one-`budget.getMonth`-per-month loop; screens that
  /// also need grouped spending call `report.spending` once themselves.
  MonthFiguresProvider._({
    required MonthFiguresFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthFiguresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthFiguresHash();

  @override
  String toString() {
    return r'monthFiguresProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<BudgetMonthSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetMonthSummary>> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return monthFigures(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthFiguresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthFiguresHash() => r'7079789e471f8c1a359e3b756ac6dec80e8e6074';

/// The month-level figures for [monthCount] months ending at [endMonth],
/// newest first, from one `report.monthSummaries` call.
///
/// This replaces the old one-`budget.getMonth`-per-month loop; screens that
/// also need grouped spending call `report.spending` once themselves.

final class MonthFiguresFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BudgetMonthSummary>>,
          (String, int, int)
        > {
  MonthFiguresFamily._()
    : super(
        retry: null,
        name: r'monthFiguresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The month-level figures for [monthCount] months ending at [endMonth],
  /// newest first, from one `report.monthSummaries` call.
  ///
  /// This replaces the old one-`budget.getMonth`-per-month loop; screens that
  /// also need grouped spending call `report.spending` once themselves.

  MonthFiguresProvider call(String entityId, int endMonth, int monthCount) =>
      MonthFiguresProvider._(
        argument: (entityId, endMonth, monthCount),
        from: this,
      );

  @override
  String toString() => r'monthFiguresProvider';
}
