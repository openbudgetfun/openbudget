// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Computes credit card payment information for all credit card accounts
/// in a budget, based on the selected month's transactions.

@ProviderFor(creditCardPayments)
final creditCardPaymentsProvider = CreditCardPaymentsFamily._();

/// Computes credit card payment information for all credit card accounts
/// in a budget, based on the selected month's transactions.

final class CreditCardPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CreditCardPaymentInfo>>,
          List<CreditCardPaymentInfo>,
          FutureOr<List<CreditCardPaymentInfo>>
        >
    with
        $FutureModifier<List<CreditCardPaymentInfo>>,
        $FutureProvider<List<CreditCardPaymentInfo>> {
  /// Computes credit card payment information for all credit card accounts
  /// in a budget, based on the selected month's transactions.
  CreditCardPaymentsProvider._({
    required CreditCardPaymentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'creditCardPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$creditCardPaymentsHash();

  @override
  String toString() {
    return r'creditCardPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CreditCardPaymentInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CreditCardPaymentInfo>> create(Ref ref) {
    final argument = this.argument as String;
    return creditCardPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CreditCardPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$creditCardPaymentsHash() =>
    r'b91aa0beb8758964081d44b3ea3e9934ed2b6559';

/// Computes credit card payment information for all credit card accounts
/// in a budget, based on the selected month's transactions.

final class CreditCardPaymentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CreditCardPaymentInfo>>,
          String
        > {
  CreditCardPaymentsFamily._()
    : super(
        retry: null,
        name: r'creditCardPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Computes credit card payment information for all credit card accounts
  /// in a budget, based on the selected month's transactions.

  CreditCardPaymentsProvider call(String budgetId) =>
      CreditCardPaymentsProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'creditCardPaymentsProvider';
}
