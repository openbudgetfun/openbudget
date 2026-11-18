// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_trends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Income, expenses and net income for the last [months] months, from one
/// `report.monthSummaries` call.

@ProviderFor(spendingTrends)
final spendingTrendsProvider = SpendingTrendsFamily._();

/// Income, expenses and net income for the last [months] months, from one
/// `report.monthSummaries` call.

final class SpendingTrendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingTrendsData>,
          SpendingTrendsData,
          FutureOr<SpendingTrendsData>
        >
    with
        $FutureModifier<SpendingTrendsData>,
        $FutureProvider<SpendingTrendsData> {
  /// Income, expenses and net income for the last [months] months, from one
  /// `report.monthSummaries` call.
  SpendingTrendsProvider._({
    required SpendingTrendsFamily super.from,
    required (String, {int months}) super.argument,
  }) : super(
         retry: null,
         name: r'spendingTrendsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingTrendsHash();

  @override
  String toString() {
    return r'spendingTrendsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SpendingTrendsData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SpendingTrendsData> create(Ref ref) {
    final argument = this.argument as (String, {int months});
    return spendingTrends(ref, argument.$1, months: argument.months);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingTrendsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingTrendsHash() => r'592f70064a026d1c5451b4902f09250e194d0bbc';

/// Income, expenses and net income for the last [months] months, from one
/// `report.monthSummaries` call.

final class SpendingTrendsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SpendingTrendsData>,
          (String, {int months})
        > {
  SpendingTrendsFamily._()
    : super(
        retry: null,
        name: r'spendingTrendsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Income, expenses and net income for the last [months] months, from one
  /// `report.monthSummaries` call.

  SpendingTrendsProvider call(String entityId, {int months = 6}) =>
      SpendingTrendsProvider._(
        argument: (entityId, months: months),
        from: this,
      );

  @override
  String toString() => r'spendingTrendsProvider';
}
