// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One month's spending and income in base minor units, read from the
/// server's month view. Activity per envelope is grouped by its category.

@ProviderFor(spendingReport)
final spendingReportProvider = SpendingReportFamily._();

/// One month's spending and income in base minor units, read from the
/// server's month view. Activity per envelope is grouped by its category.

final class SpendingReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingReport>,
          SpendingReport,
          FutureOr<SpendingReport>
        >
    with $FutureModifier<SpendingReport>, $FutureProvider<SpendingReport> {
  /// One month's spending and income in base minor units, read from the
  /// server's month view. Activity per envelope is grouped by its category.
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

String _$spendingReportHash() => r'6a9a7e4943a60c1143b10b866d59cde4317b5c3c';

/// One month's spending and income in base minor units, read from the
/// server's month view. Activity per envelope is grouped by its category.

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

  /// One month's spending and income in base minor units, read from the
  /// server's month view. Activity per envelope is grouped by its category.

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
    r'e9887f2b16f3ba9875b54a5f125188a694c1ac99';

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
