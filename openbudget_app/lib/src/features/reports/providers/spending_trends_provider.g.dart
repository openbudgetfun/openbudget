// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_trends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches spending reports for the last [months] months.

@ProviderFor(spendingTrends)
final spendingTrendsProvider = SpendingTrendsFamily._();

/// Fetches spending reports for the last [months] months.

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
  /// Fetches spending reports for the last [months] months.
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

String _$spendingTrendsHash() => r'04c4cb10da2d0885578893833f4ab897c707946b';

/// Fetches spending reports for the last [months] months.

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

  /// Fetches spending reports for the last [months] months.

  SpendingTrendsProvider call(String budgetId, {int months = 6}) =>
      SpendingTrendsProvider._(
        argument: (budgetId, months: months),
        from: this,
      );

  @override
  String toString() => r'spendingTrendsProvider';
}
