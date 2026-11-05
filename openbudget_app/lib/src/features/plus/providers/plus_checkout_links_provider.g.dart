// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_checkout_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Return links for the current platform.
///
/// Web comes back to the running app so the success state refreshes in place;
/// desktop returns to the public app page because the browser is outside the
/// app.

@ProviderFor(plusCheckoutLinks)
final plusCheckoutLinksProvider = PlusCheckoutLinksProvider._();

/// Return links for the current platform.
///
/// Web comes back to the running app so the success state refreshes in place;
/// desktop returns to the public app page because the browser is outside the
/// app.

final class PlusCheckoutLinksProvider
    extends
        $FunctionalProvider<
          PlusCheckoutLinks,
          PlusCheckoutLinks,
          PlusCheckoutLinks
        >
    with $Provider<PlusCheckoutLinks> {
  /// Return links for the current platform.
  ///
  /// Web comes back to the running app so the success state refreshes in place;
  /// desktop returns to the public app page because the browser is outside the
  /// app.
  PlusCheckoutLinksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusCheckoutLinksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusCheckoutLinksHash();

  @$internal
  @override
  $ProviderElement<PlusCheckoutLinks> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlusCheckoutLinks create(Ref ref) {
    return plusCheckoutLinks(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusCheckoutLinks value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusCheckoutLinks>(value),
    );
  }
}

String _$plusCheckoutLinksHash() => r'0ff9b027dd4770de3b5ea85592a429a375caa11d';
