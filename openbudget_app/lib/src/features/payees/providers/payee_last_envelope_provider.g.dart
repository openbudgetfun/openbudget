// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payee_last_envelope_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches the last-used envelope ID for a payee in a budget.
///
/// Returns null if the payee has no previous transactions with an envelope.

@ProviderFor(payeeLastEnvelope)
final payeeLastEnvelopeProvider = PayeeLastEnvelopeFamily._();

/// Fetches the last-used envelope ID for a payee in a budget.
///
/// Returns null if the payee has no previous transactions with an envelope.

final class PayeeLastEnvelopeProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Fetches the last-used envelope ID for a payee in a budget.
  ///
  /// Returns null if the payee has no previous transactions with an envelope.
  PayeeLastEnvelopeProvider._({
    required PayeeLastEnvelopeFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'payeeLastEnvelopeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$payeeLastEnvelopeHash();

  @override
  String toString() {
    return r'payeeLastEnvelopeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return payeeLastEnvelope(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PayeeLastEnvelopeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$payeeLastEnvelopeHash() => r'b987f3d9d79be1eafd5999d26e0715a86add8710';

/// Fetches the last-used envelope ID for a payee in a budget.
///
/// Returns null if the payee has no previous transactions with an envelope.

final class PayeeLastEnvelopeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (String, String)> {
  PayeeLastEnvelopeFamily._()
    : super(
        retry: null,
        name: r'payeeLastEnvelopeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fetches the last-used envelope ID for a payee in a budget.
  ///
  /// Returns null if the payee has no previous transactions with an envelope.

  PayeeLastEnvelopeProvider call(String payeeId, String budgetId) =>
      PayeeLastEnvelopeProvider._(argument: (payeeId, budgetId), from: this);

  @override
  String toString() => r'payeeLastEnvelopeProvider';
}
