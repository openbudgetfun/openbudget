// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fx_rate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The market quote the server would use between two currencies on a date.
///
/// Throws [FxRateUnavailableException] when no rate exists; catch it to open
/// the manual-rate sheet. The app never computes rates itself.

@ProviderFor(fxQuote)
final fxQuoteProvider = FxQuoteFamily._();

/// The market quote the server would use between two currencies on a date.
///
/// Throws [FxRateUnavailableException] when no rate exists; catch it to open
/// the manual-rate sheet. The app never computes rates itself.

final class FxQuoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<FxQuoteView>,
          FxQuoteView,
          FutureOr<FxQuoteView>
        >
    with $FutureModifier<FxQuoteView>, $FutureProvider<FxQuoteView> {
  /// The market quote the server would use between two currencies on a date.
  ///
  /// Throws [FxRateUnavailableException] when no rate exists; catch it to open
  /// the manual-rate sheet. The app never computes rates itself.
  FxQuoteProvider._({
    required FxQuoteFamily super.from,
    required (String, String, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'fxQuoteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fxQuoteHash();

  @override
  String toString() {
    return r'fxQuoteProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FxQuoteView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FxQuoteView> create(Ref ref) {
    final argument = this.argument as (String, String, DateTime);
    return fxQuote(ref, argument.$1, argument.$2, argument.$3);
  }

  @override
  bool operator ==(Object other) {
    return other is FxQuoteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fxQuoteHash() => r'4ee2fbc1fc17d90607b5e5c7901ef39d1521f3f2';

/// The market quote the server would use between two currencies on a date.
///
/// Throws [FxRateUnavailableException] when no rate exists; catch it to open
/// the manual-rate sheet. The app never computes rates itself.

final class FxQuoteFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FxQuoteView>,
          (String, String, DateTime)
        > {
  FxQuoteFamily._()
    : super(
        retry: null,
        name: r'fxQuoteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The market quote the server would use between two currencies on a date.
  ///
  /// Throws [FxRateUnavailableException] when no rate exists; catch it to open
  /// the manual-rate sheet. The app never computes rates itself.

  FxQuoteProvider call(
    String fromCurrencyCode,
    String toCurrencyCode,
    DateTime date,
  ) => FxQuoteProvider._(
    argument: (fromCurrencyCode, toCurrencyCode, date),
    from: this,
  );

  @override
  String toString() => r'fxQuoteProvider';
}
