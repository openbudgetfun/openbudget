// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_purchases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Store purchases for the current platform.

@ProviderFor(storePurchases)
final storePurchasesProvider = StorePurchasesProvider._();

/// Store purchases for the current platform.

final class StorePurchasesProvider
    extends $FunctionalProvider<StorePurchases, StorePurchases, StorePurchases>
    with $Provider<StorePurchases> {
  /// Store purchases for the current platform.
  StorePurchasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storePurchasesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storePurchasesHash();

  @$internal
  @override
  $ProviderElement<StorePurchases> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorePurchases create(Ref ref) {
    return storePurchases(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorePurchases value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorePurchases>(value),
    );
  }
}

String _$storePurchasesHash() => r'dba5724aebc761b8ac7d90e4c59f84acbc91b524';
