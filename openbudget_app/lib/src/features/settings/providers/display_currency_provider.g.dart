// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(displayCurrency)
final displayCurrencyProvider = DisplayCurrencyFamily._();

final class DisplayCurrencyProvider
    extends
        $FunctionalProvider<
          AsyncValue<CurrencyCode>,
          CurrencyCode,
          FutureOr<CurrencyCode>
        >
    with $FutureModifier<CurrencyCode>, $FutureProvider<CurrencyCode> {
  DisplayCurrencyProvider._({
    required DisplayCurrencyFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'displayCurrencyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayCurrencyHash();

  @override
  String toString() {
    return r'displayCurrencyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CurrencyCode> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CurrencyCode> create(Ref ref) {
    final argument = this.argument as String;
    return displayCurrency(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayCurrencyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayCurrencyHash() => r'e3b14a2fc31a00e5d60d4e03478f88092244f1a9';

final class DisplayCurrencyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CurrencyCode>, String> {
  DisplayCurrencyFamily._()
    : super(
        retry: null,
        name: r'displayCurrencyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DisplayCurrencyProvider call(String budgetId) =>
      DisplayCurrencyProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'displayCurrencyProvider';
}

@ProviderFor(fxLatestRates)
final fxLatestRatesProvider = FxLatestRatesProvider._();

final class FxLatestRatesProvider
    extends
        $FunctionalProvider<
          AsyncValue<FxLatestSnapshot?>,
          FxLatestSnapshot?,
          FutureOr<FxLatestSnapshot?>
        >
    with
        $FutureModifier<FxLatestSnapshot?>,
        $FutureProvider<FxLatestSnapshot?> {
  FxLatestRatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fxLatestRatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fxLatestRatesHash();

  @$internal
  @override
  $FutureProviderElement<FxLatestSnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FxLatestSnapshot?> create(Ref ref) {
    return fxLatestRates(ref);
  }
}

String _$fxLatestRatesHash() => r'bf37078b239e37ec22f0de9b3edda99e4b4e51a9';

@ProviderFor(displayCurrencyConverter)
final displayCurrencyConverterProvider = DisplayCurrencyConverterFamily._();

final class DisplayCurrencyConverterProvider
    extends
        $FunctionalProvider<
          AsyncValue<DisplayCurrencyConverter>,
          DisplayCurrencyConverter,
          FutureOr<DisplayCurrencyConverter>
        >
    with
        $FutureModifier<DisplayCurrencyConverter>,
        $FutureProvider<DisplayCurrencyConverter> {
  DisplayCurrencyConverterProvider._({
    required DisplayCurrencyConverterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'displayCurrencyConverterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayCurrencyConverterHash();

  @override
  String toString() {
    return r'displayCurrencyConverterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<DisplayCurrencyConverter> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DisplayCurrencyConverter> create(Ref ref) {
    final argument = this.argument as String;
    return displayCurrencyConverter(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayCurrencyConverterProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayCurrencyConverterHash() =>
    r'c48b83d3c5c620e5cace05a11fa305109c1b011c';

final class DisplayCurrencyConverterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<DisplayCurrencyConverter>, String> {
  DisplayCurrencyConverterFamily._()
    : super(
        retry: null,
        name: r'displayCurrencyConverterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DisplayCurrencyConverterProvider call(String budgetId) =>
      DisplayCurrencyConverterProvider._(argument: budgetId, from: this);

  @override
  String toString() => r'displayCurrencyConverterProvider';
}

@ProviderFor(updateDisplayCurrency)
final updateDisplayCurrencyProvider = UpdateDisplayCurrencyProvider._();

final class UpdateDisplayCurrencyProvider
    extends
        $FunctionalProvider<
          UpdateDisplayCurrency,
          UpdateDisplayCurrency,
          UpdateDisplayCurrency
        >
    with $Provider<UpdateDisplayCurrency> {
  UpdateDisplayCurrencyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateDisplayCurrencyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateDisplayCurrencyHash();

  @$internal
  @override
  $ProviderElement<UpdateDisplayCurrency> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateDisplayCurrency create(Ref ref) {
    return updateDisplayCurrency(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateDisplayCurrency value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateDisplayCurrency>(value),
    );
  }
}

String _$updateDisplayCurrencyHash() =>
    r'b7fc36310bed2bfcc453c8df0b7cace6c537d0b7';
