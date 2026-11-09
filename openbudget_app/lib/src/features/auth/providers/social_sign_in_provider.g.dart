// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_sign_in_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reports which social sign-in identifiers the build was given.
///
/// The client identifiers themselves are read by the provider packages from
/// the same environment; this only tells the login screen which buttons are
/// safe to show. Tests override it to exercise every platform combination.

@ProviderFor(socialSignInDefines)
final socialSignInDefinesProvider = SocialSignInDefinesProvider._();

/// Reports which social sign-in identifiers the build was given.
///
/// The client identifiers themselves are read by the provider packages from
/// the same environment; this only tells the login screen which buttons are
/// safe to show. Tests override it to exercise every platform combination.

final class SocialSignInDefinesProvider
    extends
        $FunctionalProvider<
          SocialSignInDefines,
          SocialSignInDefines,
          SocialSignInDefines
        >
    with $Provider<SocialSignInDefines> {
  /// Reports which social sign-in identifiers the build was given.
  ///
  /// The client identifiers themselves are read by the provider packages from
  /// the same environment; this only tells the login screen which buttons are
  /// safe to show. Tests override it to exercise every platform combination.
  SocialSignInDefinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialSignInDefinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialSignInDefinesHash();

  @$internal
  @override
  $ProviderElement<SocialSignInDefines> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SocialSignInDefines create(Ref ref) {
    return socialSignInDefines(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialSignInDefines value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialSignInDefines>(value),
    );
  }
}

String _$socialSignInDefinesHash() =>
    r'ca0cd7bae2f3565edc94d709148d579af686da6c';
