// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spending_by_payee_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(spendingByPayee)
final spendingByPayeeProvider = SpendingByPayeeFamily._();

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
  SpendingByPayeeProvider._({
    required SpendingByPayeeFamily super.from,
    required (String, int, int) super.argument,
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
    final argument = this.argument as (String, int, int);
    return spendingByPayee(ref, argument.$1, argument.$2, argument.$3);
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

String _$spendingByPayeeHash() => r'69e031091260249c680a0482ad09581e3aaf69bd';

final class SpendingByPayeeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PayeeSpendingReport>,
          (String, int, int)
        > {
  SpendingByPayeeFamily._()
    : super(
        retry: null,
        name: r'spendingByPayeeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpendingByPayeeProvider call(String budgetId, int year, int month) =>
      SpendingByPayeeProvider._(argument: (budgetId, year, month), from: this);

  @override
  String toString() => r'spendingByPayeeProvider';
}
