import 'package:flutter/foundation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

/// Placeholders for the web authentication options that the Apple sign-in
/// package asks for before opening the native sheet.
///
/// `serverpod_auth_idp_flutter` 4.1.0 reads the web options on every platform,
/// even though iOS and macOS never use them: the native flow takes the app's
/// bundle id from the entitlement. Supplying harmless values here keeps native
/// Apple sign-in free of the web-only dart defines.
const _nativeServiceIdentifier = 'openbudget-native-apple-sign-in';
const _nativeRedirectUri = 'https://openbudget.app/auth/apple/callback';

/// Seeds the Apple sign-in service on native Apple platforms.
///
/// The login screen can therefore show Sign in with Apple on iOS without
/// `APPLE_SERVICE_IDENTIFIER` or `APPLE_REDIRECT_URI` being configured.
Future<void> prepareNativeAppleSignIn() async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.macOS) {
    return;
  }

  try {
    await AppleSignInService.instance.ensureInitialized(
      serviceIdentifier: _nativeServiceIdentifier,
      redirectUri: _nativeRedirectUri,
    );
  } on Exception catch (error) {
    // Apple sign-in stays unavailable rather than blocking app startup.
    debugPrint('Could not prepare native Apple sign-in: $error');
  }
}
