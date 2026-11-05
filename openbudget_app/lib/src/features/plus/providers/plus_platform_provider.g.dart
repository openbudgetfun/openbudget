// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_platform_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current platform, injectable so tests can pin iOS, web or macOS.

@ProviderFor(plusPlatform)
final plusPlatformProvider = PlusPlatformProvider._();

/// The current platform, injectable so tests can pin iOS, web or macOS.

final class PlusPlatformProvider
    extends $FunctionalProvider<PlusPlatform, PlusPlatform, PlusPlatform>
    with $Provider<PlusPlatform> {
  /// The current platform, injectable so tests can pin iOS, web or macOS.
  PlusPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusPlatformProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusPlatformHash();

  @$internal
  @override
  $ProviderElement<PlusPlatform> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlusPlatform create(Ref ref) {
    return plusPlatform(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusPlatform value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusPlatform>(value),
    );
  }
}

String _$plusPlatformHash() => r'713073e5800b70adaa154817ea5f746ad08b2053';

/// The RevenueCat public key for this platform, or an empty string when the
/// build has none. An empty key leaves the store rail unavailable.

@ProviderFor(revenueCatApiKey)
final revenueCatApiKeyProvider = RevenueCatApiKeyProvider._();

/// The RevenueCat public key for this platform, or an empty string when the
/// build has none. An empty key leaves the store rail unavailable.

final class RevenueCatApiKeyProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The RevenueCat public key for this platform, or an empty string when the
  /// build has none. An empty key leaves the store rail unavailable.
  RevenueCatApiKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revenueCatApiKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revenueCatApiKeyHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return revenueCatApiKey(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$revenueCatApiKeyHash() => r'4b7242738de7bb4054765e1bb02731fe64452054';
