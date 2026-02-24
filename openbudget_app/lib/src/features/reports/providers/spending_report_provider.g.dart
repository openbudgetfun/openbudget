// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(spendingReport)
final spendingReportProvider = SpendingReportFamily._();

final class SpendingReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingReport>,
          SpendingReport,
          FutureOr<SpendingReport>
        >
    with $FutureModifier<SpendingReport>, $FutureProvider<SpendingReport> {
  SpendingReportProvider._({
    required SpendingReportFamily super.from,
    required (String, int, int) super.argument,
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
    final argument = this.argument as (String, int, int);
    return spendingReport(ref, argument.$1, argument.$2, argument.$3);
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

String _$spendingReportHash() => r'189d7f807c51d9cb8a4d10b878fa2312e3a1d02b';

final class SpendingReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SpendingReport>,
          (String, int, int)
        > {
  SpendingReportFamily._()
    : super(
        retry: null,
        name: r'spendingReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpendingReportProvider call(String budgetId, int year, int month) =>
      SpendingReportProvider._(argument: (budgetId, year, month), from: this);

  @override
  String toString() => r'spendingReportProvider';
}

@ProviderFor(spendingReportPreset)
final spendingReportPresetProvider = SpendingReportPresetFamily._();

final class SpendingReportPresetProvider
    extends
        $FunctionalProvider<
          AsyncValue<SpendingReport>,
          SpendingReport,
          FutureOr<SpendingReport>
        >
    with $FutureModifier<SpendingReport>, $FutureProvider<SpendingReport> {
  SpendingReportPresetProvider._({
    required SpendingReportPresetFamily super.from,
    required (String, int, int, int) super.argument,
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
    final argument = this.argument as (String, int, int, int);
    return spendingReportPreset(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
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
    r'd7cd98c878c1f58785c173ff0137f87fb380bec7';

final class SpendingReportPresetFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<SpendingReport>,
          (String, int, int, int)
        > {
  SpendingReportPresetFamily._()
    : super(
        retry: null,
        name: r'spendingReportPresetProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpendingReportPresetProvider call(
    String budgetId,
    int endYear,
    int endMonth,
    int monthCount,
  ) => SpendingReportPresetProvider._(
    argument: (budgetId, endYear, endMonth, monthCount),
    from: this,
  );

  @override
  String toString() => r'spendingReportPresetProvider';
}
