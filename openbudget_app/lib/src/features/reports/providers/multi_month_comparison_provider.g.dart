// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_month_comparison_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches budget data for [monthCount] consecutive months ending at the
/// current month and returns a comparison structure.

@ProviderFor(multiMonthComparison)
final multiMonthComparisonProvider = MultiMonthComparisonFamily._();

/// Fetches budget data for [monthCount] consecutive months ending at the
/// current month and returns a comparison structure.

final class MultiMonthComparisonProvider
    extends
        $FunctionalProvider<
          AsyncValue<MultiMonthComparison>,
          MultiMonthComparison,
          FutureOr<MultiMonthComparison>
        >
    with
        $FutureModifier<MultiMonthComparison>,
        $FutureProvider<MultiMonthComparison> {
  /// Fetches budget data for [monthCount] consecutive months ending at the
  /// current month and returns a comparison structure.
  MultiMonthComparisonProvider._({
    required MultiMonthComparisonFamily super.from,
    required (String, {int monthCount}) super.argument,
  }) : super(
         retry: null,
         name: r'multiMonthComparisonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$multiMonthComparisonHash();

  @override
  String toString() {
    return r'multiMonthComparisonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<MultiMonthComparison> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MultiMonthComparison> create(Ref ref) {
    final argument = this.argument as (String, {int monthCount});
    return multiMonthComparison(
      ref,
      argument.$1,
      monthCount: argument.monthCount,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MultiMonthComparisonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$multiMonthComparisonHash() =>
    r'179d987ca68a2ed999aafdf16a218c9284c53d90';

/// Fetches budget data for [monthCount] consecutive months ending at the
/// current month and returns a comparison structure.

final class MultiMonthComparisonFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<MultiMonthComparison>,
          (String, {int monthCount})
        > {
  MultiMonthComparisonFamily._()
    : super(
        retry: null,
        name: r'multiMonthComparisonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches budget data for [monthCount] consecutive months ending at the
  /// current month and returns a comparison structure.

  MultiMonthComparisonProvider call(String budgetId, {int monthCount = 3}) =>
      MultiMonthComparisonProvider._(
        argument: (budgetId, monthCount: monthCount),
        from: this,
      );

  @override
  String toString() => r'multiMonthComparisonProvider';
}
