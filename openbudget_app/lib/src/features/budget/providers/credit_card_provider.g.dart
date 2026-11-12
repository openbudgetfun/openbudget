// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Each card's month spending and balance.
///
/// Spending comes from `transaction.list` filtered by account and the
/// selected month's dates; payment envelopes are deferred (Q3).

@ProviderFor(creditCardPayments)
final creditCardPaymentsProvider = CreditCardPaymentsFamily._();

/// Each card's month spending and balance.
///
/// Spending comes from `transaction.list` filtered by account and the
/// selected month's dates; payment envelopes are deferred (Q3).

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
  /// Each card's month spending and balance.
  ///
  /// Spending comes from `transaction.list` filtered by account and the
  /// selected month's dates; payment envelopes are deferred (Q3).
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
    r'fb30f9854733e2ca8a8e0928d51fca67d332c78b';

/// Each card's month spending and balance.
///
/// Spending comes from `transaction.list` filtered by account and the
/// selected month's dates; payment envelopes are deferred (Q3).

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

  /// Each card's month spending and balance.
  ///
  /// Spending comes from `transaction.list` filtered by account and the
  /// selected month's dates; payment envelopes are deferred (Q3).

  CreditCardPaymentsProvider call(String entityId) =>
      CreditCardPaymentsProvider._(argument: entityId, from: this);

  @override
  String toString() => r'creditCardPaymentsProvider';
}
