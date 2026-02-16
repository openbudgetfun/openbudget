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

String _$spendingReportHash() => r'301acb699c738d9d491fc3f4e46a0841d40a3a75';

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
