// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_breakdown_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What one entity's wallets are worth in the reporting currency, split by
/// chain or by asset, straight from `report.cryptoBreakdown`.
///
/// The server converts and sums; the app never does. A `walletCount` of zero
/// means the entity has no wallets and the net worth screen hides the
/// section.

@ProviderFor(cryptoBreakdown)
final cryptoBreakdownProvider = CryptoBreakdownFamily._();

/// What one entity's wallets are worth in the reporting currency, split by
/// chain or by asset, straight from `report.cryptoBreakdown`.
///
/// The server converts and sums; the app never does. A `walletCount` of zero
/// means the entity has no wallets and the net worth screen hides the
/// section.

final class CryptoBreakdownProvider
    extends
        $FunctionalProvider<
          AsyncValue<CryptoBreakdownView>,
          CryptoBreakdownView,
          FutureOr<CryptoBreakdownView>
        >
    with
        $FutureModifier<CryptoBreakdownView>,
        $FutureProvider<CryptoBreakdownView> {
  /// What one entity's wallets are worth in the reporting currency, split by
  /// chain or by asset, straight from `report.cryptoBreakdown`.
  ///
  /// The server converts and sums; the app never does. A `walletCount` of zero
  /// means the entity has no wallets and the net worth screen hides the
  /// section.
  CryptoBreakdownProvider._({
    required CryptoBreakdownFamily super.from,
    required (String, CryptoBreakdownGrouping) super.argument,
  }) : super(
         retry: null,
         name: r'cryptoBreakdownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cryptoBreakdownHash();

  @override
  String toString() {
    return r'cryptoBreakdownProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CryptoBreakdownView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CryptoBreakdownView> create(Ref ref) {
    final argument = this.argument as (String, CryptoBreakdownGrouping);
    return cryptoBreakdown(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CryptoBreakdownProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cryptoBreakdownHash() => r'1c08d27521db103cae3000e06087333eb2953cb9';

/// What one entity's wallets are worth in the reporting currency, split by
/// chain or by asset, straight from `report.cryptoBreakdown`.
///
/// The server converts and sums; the app never does. A `walletCount` of zero
/// means the entity has no wallets and the net worth screen hides the
/// section.

final class CryptoBreakdownFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CryptoBreakdownView>,
          (String, CryptoBreakdownGrouping)
        > {
  CryptoBreakdownFamily._()
    : super(
        retry: null,
        name: r'cryptoBreakdownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What one entity's wallets are worth in the reporting currency, split by
  /// chain or by asset, straight from `report.cryptoBreakdown`.
  ///
  /// The server converts and sums; the app never does. A `walletCount` of zero
  /// means the entity has no wallets and the net worth screen hides the
  /// section.

  CryptoBreakdownProvider call(
    String entityId,
    CryptoBreakdownGrouping grouping,
  ) => CryptoBreakdownProvider._(argument: (entityId, grouping), from: this);

  @override
  String toString() => r'cryptoBreakdownProvider';
}
