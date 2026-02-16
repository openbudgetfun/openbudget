// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_trends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches spending‐by‐category for each of the last [months] months and
/// pivots the data so each category has a time series of spending amounts.

@ProviderFor(categoryTrends)
final categoryTrendsProvider = CategoryTrendsFamily._();

/// Fetches spending‐by‐category for each of the last [months] months and
/// pivots the data so each category has a time series of spending amounts.

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
  /// Fetches spending‐by‐category for each of the last [months] months and
  /// pivots the data so each category has a time series of spending amounts.
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

String _$categoryTrendsHash() => r'043d4aa143716c1e02277cc9b0481205b84bbb26';

/// Fetches spending‐by‐category for each of the last [months] months and
/// pivots the data so each category has a time series of spending amounts.

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

  /// Fetches spending‐by‐category for each of the last [months] months and
  /// pivots the data so each category has a time series of spending amounts.

  CategoryTrendsProvider call(String budgetId, {int months = 6}) =>
      CategoryTrendsProvider._(
        argument: (budgetId, months: months),
        from: this,
      );

  @override
  String toString() => r'categoryTrendsProvider';
}
