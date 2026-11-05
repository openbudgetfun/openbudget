// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_billing_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The billing calls used by the Plus feature.

@ProviderFor(plusBillingApi)
final plusBillingApiProvider = PlusBillingApiProvider._();

/// The billing calls used by the Plus feature.

final class PlusBillingApiProvider
    extends $FunctionalProvider<PlusBillingApi, PlusBillingApi, PlusBillingApi>
    with $Provider<PlusBillingApi> {
  /// The billing calls used by the Plus feature.
  PlusBillingApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusBillingApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusBillingApiHash();

  @$internal
  @override
  $ProviderElement<PlusBillingApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlusBillingApi create(Ref ref) {
    return plusBillingApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusBillingApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusBillingApi>(value),
    );
  }
}

String _$plusBillingApiHash() => r'5b85183735ef880fbac02423995c188a39a50185';
