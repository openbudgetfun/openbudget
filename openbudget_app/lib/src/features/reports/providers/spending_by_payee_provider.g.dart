// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_by_payee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Spending grouped by payee for one month, in base minor units, from one
/// `report.spending` call with [ReportGrouping.payee].

@ProviderFor(spendingByPayee)
final spendingByPayeeProvider = SpendingByPayeeFamily._();

/// Spending grouped by payee for one month, in base minor units, from one
/// `report.spending` call with [ReportGrouping.payee].

final class SpendingByPayeeProvider
    extends
        $FunctionalProvider<
          AsyncValue<PayeeSpendingReport>,
          PayeeSpendingReport,
          FutureOr<PayeeSpendingReport>
        >
    with
        $FutureModifier<PayeeSpendingReport>,
        $FutureProvider<PayeeSpendingReport> {
  /// Spending grouped by payee for one month, in base minor units, from one
  /// `report.spending` call with [ReportGrouping.payee].
  SpendingByPayeeProvider._({
    required SpendingByPayeeFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'spendingByPayeeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingByPayeeHash();

  @override
  String toString() {
    return r'spendingByPayeeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PayeeSpendingReport> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PayeeSpendingReport> create(Ref ref) {
    final argument = this.argument as (String, int);
    return spendingByPayee(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingByPayeeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingByPayeeHash() => r'594b2c919c7093e03ff8d7450df813d7336bb009';

/// Spending grouped by payee for one month, in base minor units, from one
/// `report.spending` call with [ReportGrouping.payee].

final class SpendingByPayeeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PayeeSpendingReport>,
          (String, int)
        > {
  SpendingByPayeeFamily._()
    : super(
        retry: null,
        name: r'spendingByPayeeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Spending grouped by payee for one month, in base minor units, from one
  /// `report.spending` call with [ReportGrouping.payee].

  SpendingByPayeeProvider call(String entityId, int month) =>
      SpendingByPayeeProvider._(argument: (entityId, month), from: this);

  @override
  String toString() => r'spendingByPayeeProvider';
}
