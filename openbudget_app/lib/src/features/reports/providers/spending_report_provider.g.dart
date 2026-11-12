// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One month of spending grouped by category, from one `report.spending`
/// call plus the month's figure from `report.monthSummaries`.

@ProviderFor(spendingReport)
final spendingReportProvider = SpendingReportFamily._();

/// One month of spending grouped by category, from one `report.spending`
/// call plus the month's figure from `report.monthSummaries`.

final class SpendingReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingReport>,
          SpendingReport,
          FutureOr<SpendingReport>
        >
    with $FutureModifier<SpendingReport>, $FutureProvider<SpendingReport> {
  /// One month of spending grouped by category, from one `report.spending`
  /// call plus the month's figure from `report.monthSummaries`.
  SpendingReportProvider._({
    required SpendingReportFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'spendingReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingReportHash();

  @override
  String toString() {
    return r'spendingReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SpendingReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SpendingReport> create(Ref ref) {
    final argument = this.argument as (String, int);
    return spendingReport(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingReportHash() => r'90c1f17a37828e6aa4054636412763647fb9db5d';

/// One month of spending grouped by category, from one `report.spending`
/// call plus the month's figure from `report.monthSummaries`.

final class SpendingReportFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SpendingReport>, (String, int)> {
  SpendingReportFamily._()
    : super(
        retry: null,
        name: r'spendingReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One month of spending grouped by category, from one `report.spending`
  /// call plus the month's figure from `report.monthSummaries`.

  SpendingReportProvider call(String entityId, int endMonth) =>
      SpendingReportProvider._(argument: (entityId, endMonth), from: this);

  @override
  String toString() => r'spendingReportProvider';
}

/// The last [monthCount] months combined, for the preset ranges.

@ProviderFor(spendingReportPreset)
final spendingReportPresetProvider = SpendingReportPresetFamily._();

/// The last [monthCount] months combined, for the preset ranges.

final class SpendingReportPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingReport>,
          SpendingReport,
          FutureOr<SpendingReport>
        >
    with $FutureModifier<SpendingReport>, $FutureProvider<SpendingReport> {
  /// The last [monthCount] months combined, for the preset ranges.
  SpendingReportPresetProvider._({
    required SpendingReportPresetFamily super.from,
    required (String, int, int) super.argument,
  }) : super(
         retry: null,
         name: r'spendingReportPresetProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingReportPresetHash();

  @override
  String toString() {
    return r'spendingReportPresetProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<SpendingReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SpendingReport> create(Ref ref) {
    final argument = this.argument as (String, int, int);
    return spendingReportPreset(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingReportPresetProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingReportPresetHash() =>
    r'c002ca6885b65923017d11292f0b50fa80968f28';

/// The last [monthCount] months combined, for the preset ranges.

final class SpendingReportPresetFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SpendingReport>,
          (String, int, int)
        > {
  SpendingReportPresetFamily._()
    : super(
        retry: null,
        name: r'spendingReportPresetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The last [monthCount] months combined, for the preset ranges.

  SpendingReportPresetProvider call(
    String entityId,
    int endMonth,
    int monthCount,
  ) => SpendingReportPresetProvider._(
    argument: (entityId, endMonth, monthCount),
    from: this,
  );

  @override
  String toString() => r'spendingReportPresetProvider';
}
