// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_figures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month views for the [monthCount] months ending at [endMonth],
/// oldest first.
///
/// Reports read every month-level figure from these views. This is the one
/// place that loops months; when `report.spending` and
/// `report.monthSummaries` arrive on the generated client, this provider
/// switches to them and every report screen follows.

@ProviderFor(monthFigures)
final monthFiguresProvider = MonthFiguresFamily._();

/// The month views for the [monthCount] months ending at [endMonth],
/// oldest first.
///
/// Reports read every month-level figure from these views. This is the one
/// place that loops months; when `report.spending` and
/// `report.monthSummaries` arrive on the generated client, this provider
/// switches to them and every report screen follows.

final class MonthFiguresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetMonthView>>,
          List<BudgetMonthView>,
          FutureOr<List<BudgetMonthView>>
        >
    with
        $FutureModifier<List<BudgetMonthView>>,
        $FutureProvider<List<BudgetMonthView>> {
  /// The month views for the [monthCount] months ending at [endMonth],
  /// oldest first.
  ///
  /// Reports read every month-level figure from these views. This is the one
  /// place that loops months; when `report.spending` and
  /// `report.monthSummaries` arrive on the generated client, this provider
  /// switches to them and every report screen follows.
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
  $FutureProviderElement<List<BudgetMonthView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetMonthView>> create(Ref ref) {
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

String _$monthFiguresHash() => r'593b8ad9af5bc32468fca15e3d9121960a0966f7';

/// The month views for the [monthCount] months ending at [endMonth],
/// oldest first.
///
/// Reports read every month-level figure from these views. This is the one
/// place that loops months; when `report.spending` and
/// `report.monthSummaries` arrive on the generated client, this provider
/// switches to them and every report screen follows.

final class MonthFiguresFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<BudgetMonthView>>,
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

  /// The month views for the [monthCount] months ending at [endMonth],
  /// oldest first.
  ///
  /// Reports read every month-level figure from these views. This is the one
  /// place that loops months; when `report.spending` and
  /// `report.monthSummaries` arrive on the generated client, this provider
  /// switches to them and every report screen follows.

  MonthFiguresProvider call(String entityId, int endMonth, int monthCount) =>
      MonthFiguresProvider._(
        argument: (entityId, endMonth, monthCount),
        from: this,
      );

  @override
  String toString() => r'monthFiguresProvider';
}
