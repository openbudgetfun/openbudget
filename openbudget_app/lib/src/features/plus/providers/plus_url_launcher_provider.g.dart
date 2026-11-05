// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plus_url_launcher_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The launcher used for Stripe and store management links.

@ProviderFor(plusUrlLauncher)
final plusUrlLauncherProvider = PlusUrlLauncherProvider._();

/// The launcher used for Stripe and store management links.

final class PlusUrlLauncherProvider
    extends
        $FunctionalProvider<PlusUrlLauncher, PlusUrlLauncher, PlusUrlLauncher>
    with $Provider<PlusUrlLauncher> {
  /// The launcher used for Stripe and store management links.
  PlusUrlLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'plusUrlLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$plusUrlLauncherHash();

  @$internal
  @override
  $ProviderElement<PlusUrlLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PlusUrlLauncher create(Ref ref) {
    return plusUrlLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlusUrlLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlusUrlLauncher>(value),
    );
  }
}

String _$plusUrlLauncherHash() => r'840d173cf2c654b85e0743755628950a0d5c1412';
