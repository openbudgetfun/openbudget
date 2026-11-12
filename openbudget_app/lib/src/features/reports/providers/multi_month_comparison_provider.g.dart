// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'multi_month_comparison_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Compares the last [monthCount] months for each envelope that moved.
///
/// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
/// supplies every month of activity; `report.monthSummaries` supplies the
/// month headers and totals. Envelope and category metadata comes from the
/// entity's whole lists, never from a month view.

@ProviderFor(multiMonthComparison)
final multiMonthComparisonProvider = MultiMonthComparisonFamily._();

/// Compares the last [monthCount] months for each envelope that moved.
///
/// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
/// supplies every month of activity; `report.monthSummaries` supplies the
/// month headers and totals. Envelope and category metadata comes from the
/// entity's whole lists, never from a month view.

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
  /// Compares the last [monthCount] months for each envelope that moved.
  ///
  /// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
  /// supplies every month of activity; `report.monthSummaries` supplies the
  /// month headers and totals. Envelope and category metadata comes from the
  /// entity's whole lists, never from a month view.
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
    r'7a1180d2bdeaf39f7a88dc53e0cdcb4e03300b9e';

/// Compares the last [monthCount] months for each envelope that moved.
///
/// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
/// supplies every month of activity; `report.monthSummaries` supplies the
/// month headers and totals. Envelope and category metadata comes from the
/// entity's whole lists, never from a month view.

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

  /// Compares the last [monthCount] months for each envelope that moved.
  ///
  /// One `report.spending` call with [ReportGrouping.envelope] and `byMonth`
  /// supplies every month of activity; `report.monthSummaries` supplies the
  /// month headers and totals. Envelope and category metadata comes from the
  /// entity's whole lists, never from a month view.

  MultiMonthComparisonProvider call(String entityId, {int monthCount = 3}) =>
      MultiMonthComparisonProvider._(
        argument: (entityId, monthCount: monthCount),
        from: this,
      );

  @override
  String toString() => r'multiMonthComparisonProvider';
}
