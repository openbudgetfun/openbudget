// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_figures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The month views for the [monthCount] months ending at [endMonth],
/// newest first. The interim source for the spending reports until
/// `report.spending` and `report.monthSummaries` land on the client;
/// swapping to them is one file per feature.

@ProviderFor(monthFigures)
final monthFiguresProvider = MonthFiguresFamily._();

/// The month views for the [monthCount] months ending at [endMonth],
/// newest first. The interim source for the spending reports until
/// `report.spending` and `report.monthSummaries` land on the client;
/// swapping to them is one file per feature.

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
  /// newest first. The interim source for the spending reports until
  /// `report.spending` and `report.monthSummaries` land on the client;
  /// swapping to them is one file per feature.
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

String _$monthFiguresHash() => r'a9437eab6363ef6353d9bcb7c898ada5f1bb1c8e';

/// The month views for the [monthCount] months ending at [endMonth],
/// newest first. The interim source for the spending reports until
/// `report.spending` and `report.monthSummaries` land on the client;
/// swapping to them is one file per feature.

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
  /// newest first. The interim source for the spending reports until
  /// `report.spending` and `report.monthSummaries` land on the client;
  /// swapping to them is one file per feature.

  MonthFiguresProvider call(String entityId, int endMonth, int monthCount) =>
      MonthFiguresProvider._(
        argument: (entityId, endMonth, monthCount),
        from: this,
      );

  @override
  String toString() => r'monthFiguresProvider';
}
