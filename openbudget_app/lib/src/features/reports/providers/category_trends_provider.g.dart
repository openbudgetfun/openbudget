// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_trends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Spending per category for each of the last [months] months, pivoted so
/// each category carries a time series. One `report.spending` call with
/// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
/// headers come from `report.monthSummaries`.

@ProviderFor(categoryTrends)
final categoryTrendsProvider = CategoryTrendsFamily._();

/// Spending per category for each of the last [months] months, pivoted so
/// each category carries a time series. One `report.spending` call with
/// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
/// headers come from `report.monthSummaries`.

final class CategoryTrendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryTrendsData>,
          CategoryTrendsData,
          FutureOr<CategoryTrendsData>
        >
    with
        $FutureModifier<CategoryTrendsData>,
        $FutureProvider<CategoryTrendsData> {
  /// Spending per category for each of the last [months] months, pivoted so
  /// each category carries a time series. One `report.spending` call with
  /// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
  /// headers come from `report.monthSummaries`.
  CategoryTrendsProvider._({
    required CategoryTrendsFamily super.from,
    required (String, {int months}) super.argument,
  }) : super(
         retry: null,
         name: r'categoryTrendsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryTrendsHash();

  @override
  String toString() {
    return r'categoryTrendsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CategoryTrendsData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryTrendsData> create(Ref ref) {
    final argument = this.argument as (String, {int months});
    return categoryTrends(ref, argument.$1, months: argument.months);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryTrendsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryTrendsHash() => r'5bc7f61b2c299f9e64c34497188753e2820f0b9e';

/// Spending per category for each of the last [months] months, pivoted so
/// each category carries a time series. One `report.spending` call with
/// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
/// headers come from `report.monthSummaries`.

final class CategoryTrendsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CategoryTrendsData>,
          (String, {int months})
        > {
  CategoryTrendsFamily._()
    : super(
        retry: null,
        name: r'categoryTrendsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Spending per category for each of the last [months] months, pivoted so
  /// each category carries a time series. One `report.spending` call with
  /// [ReportGrouping.category] and `byMonth` feeds the whole table; the month
  /// headers come from `report.monthSummaries`.

  CategoryTrendsProvider call(String entityId, {int months = 6}) =>
      CategoryTrendsProvider._(
        argument: (entityId, months: months),
        from: this,
      );

  @override
  String toString() => r'categoryTrendsProvider';
}
