// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_by_payee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Spending grouped by payee for one month, in base minor units.
///
/// This pages the month's transactions and groups them here. When
/// `report.spending(grouping: payee)` arrives on the generated client, this
/// provider switches to it.

@ProviderFor(spendingByPayee)
final spendingByPayeeProvider = SpendingByPayeeFamily._();

/// Spending grouped by payee for one month, in base minor units.
///
/// This pages the month's transactions and groups them here. When
/// `report.spending(grouping: payee)` arrives on the generated client, this
/// provider switches to it.

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
  /// Spending grouped by payee for one month, in base minor units.
  ///
  /// This pages the month's transactions and groups them here. When
  /// `report.spending(grouping: payee)` arrives on the generated client, this
  /// provider switches to it.
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

String _$spendingByPayeeHash() => r'660a6ed753c5be8b0cd6961c5f57b57eeb2afe7b';

/// Spending grouped by payee for one month, in base minor units.
///
/// This pages the month's transactions and groups them here. When
/// `report.spending(grouping: payee)` arrives on the generated client, this
/// provider switches to it.

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

  /// Spending grouped by payee for one month, in base minor units.
  ///
  /// This pages the month's transactions and groups them here. When
  /// `report.spending(grouping: payee)` arrives on the generated client, this
  /// provider switches to it.

  SpendingByPayeeProvider call(String entityId, int month) =>
      SpendingByPayeeProvider._(argument: (entityId, month), from: this);

  @override
  String toString() => r'spendingByPayeeProvider';
}
