import 'package:flutter/foundation.dart';

/// Platforms that can offer a social sign-in provider.
///
/// The login screen only offers social providers on web, iOS and Android. The
/// platform is resolved from the running app so the decision can be unit tested
/// without a widget tree.
enum SocialSignInPlatform { web, ios, android, other }

/// The compile-time client identifiers supplied to the build.
///
/// Each value records whether a `--dart-define` was supplied. The values
/// themselves are read by the provider packages from the environment; this
/// object only decides which buttons are safe to show.
class SocialSignInDefines {
  /// Creates a new [SocialSignInDefines].
  const SocialSignInDefines({
    required this.googleClientId,
    required this.googleServerClientId,
    required this.appleServiceIdentifier,
    required this.appleRedirectUri,
  });

  /// Whether `GOOGLE_CLIENT_ID` was supplied.
  ///
  /// On iOS this is the iOS OAuth client id. On Android and web it is that
  /// platform's client id.
  final bool googleClientId;

  /// Whether `GOOGLE_SERVER_CLIENT_ID` was supplied.
  ///
  /// Native iOS and Android sign-in pass it to Google so the ID token is
  /// addressed to the web client, which is the only audience the server's
  /// Google provider verifies. Without it the server rejects native tokens.
  final bool googleServerClientId;

  /// Whether `APPLE_SERVICE_IDENTIFIER` was supplied.
  ///
  /// This is only needed for web and Android. Native Apple sign-in on iOS and
  /// macOS identifies the app by its bundle id instead.
  final bool appleServiceIdentifier;

  /// Whether `APPLE_REDIRECT_URI` was supplied.
  ///
  /// This is only needed for web and Android, like
  /// [appleServiceIdentifier].
  final bool appleRedirectUri;
}

/// The social buttons that can be shown on a platform.
class SocialSignInAvailability {
  /// Creates a new [SocialSignInAvailability].
  const SocialSignInAvailability({
    required this.apple,
    required this.google,
  });

  /// Whether Sign in with Apple is available.
  final bool apple;

  /// Whether Sign in with Google is available.
  final bool google;

  /// Whether at least one social provider is available.
  bool get hasAny => apple || google;
}

/// Resolves the social sign-in platform the app is running on.
///
/// [isWeb] must be checked before [targetPlatform] because Flutter reports a
/// mobile target platform in some browsers.
SocialSignInPlatform socialSignInPlatform({
  required bool isWeb,
  required TargetPlatform targetPlatform,
}) {
  if (isWeb) return SocialSignInPlatform.web;

  return switch (targetPlatform) {
    TargetPlatform.iOS => SocialSignInPlatform.ios,
    TargetPlatform.android => SocialSignInPlatform.android,
    _ => SocialSignInPlatform.other,
  };
}

/// Decides which social sign-in buttons the login screen may show.
///
/// Native Apple sign-in on iOS works from the app's bundle id and its
/// entitlement, so it never needs `APPLE_SERVICE_IDENTIFIER` or
/// `APPLE_REDIRECT_URI`; those exist for the web and Android flows. Google
/// needs a client id on every platform, and native platforms also need the
/// server (web) client id so the server can verify the token.
SocialSignInAvailability socialSignInAvailability({
  required SocialSignInPlatform platform,
  required SocialSignInDefines defines,
}) {
  final appleWebConfigured =
      defines.appleServiceIdentifier && defines.appleRedirectUri;
  final googleNativeConfigured =
      defines.googleClientId && defines.googleServerClientId;

  return switch (platform) {
    SocialSignInPlatform.web => SocialSignInAvailability(
      apple: appleWebConfigured,
      google: defines.googleClientId,
    ),
    SocialSignInPlatform.android => SocialSignInAvailability(
      apple: appleWebConfigured,
      google: googleNativeConfigured,
    ),
    SocialSignInPlatform.ios => SocialSignInAvailability(
      apple: true,
      google: googleNativeConfigured,
    ),
    SocialSignInPlatform.other => const SocialSignInAvailability(
      apple: false,
      google: false,
    ),
  };
}
