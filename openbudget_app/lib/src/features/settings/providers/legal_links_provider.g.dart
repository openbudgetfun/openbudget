// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The launcher Settings uses for the privacy policy and terms.

@ProviderFor(legalLinkLauncher)
final legalLinkLauncherProvider = LegalLinkLauncherProvider._();

/// The launcher Settings uses for the privacy policy and terms.

final class LegalLinkLauncherProvider
    extends
        $FunctionalProvider<
          LegalLinkLauncher,
          LegalLinkLauncher,
          LegalLinkLauncher
        >
    with $Provider<LegalLinkLauncher> {
  /// The launcher Settings uses for the privacy policy and terms.
  LegalLinkLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legalLinkLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legalLinkLauncherHash();

  @$internal
  @override
  $ProviderElement<LegalLinkLauncher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LegalLinkLauncher create(Ref ref) {
    return legalLinkLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LegalLinkLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LegalLinkLauncher>(value),
    );
  }
}

String _$legalLinkLauncherHash() => r'3c7ec0576ae9f8bcf38a3baed49c032d2527aa7e';
