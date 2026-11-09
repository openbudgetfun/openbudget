import 'package:openbudget_server/src/auth/google_id_token_audience.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// A second Google identity provider for tokens minted for the iOS client id.
///
/// A native iOS app that does not configure a server client id receives an ID
/// token whose audience is the iOS OAuth client id. Serverpod's Google provider
/// pins the audience to the web client id from `googleClientSecret`, so this
/// provider gives those iOS tokens a verifier of their own.
///
/// The client secret on this provider is a placeholder. Only the ID-token login
/// path uses it, and that path verifies the token directly with Google instead
/// of exchanging an authorization code.
class GoogleIosAudienceIdp {
  GoogleIosAudienceIdp._();

  static GoogleIdp? _idp;
  static String? _clientId;

  /// Builds the verifier for [clientId].
  static void configure({
    required String clientId,
    required TokenIssuer tokenIssuer,
    required AuthUsers authUsers,
    required UserProfiles userProfiles,
  }) {
    _clientId = clientId;
    _idp = GoogleIdp(
      GoogleIdpConfig(
        clientSecret: GoogleClientSecret.fromJson({
          'web': {
            'client_id': clientId,
            'client_secret': 'unused-native-ios-audience',
            'redirect_uris': <String>[],
          },
        }),
      ),
      tokenIssuer: tokenIssuer,
      authUsers: authUsers,
      userProfiles: userProfiles,
    );
  }

  /// Returns the iOS verifier when [idToken] is addressed to the iOS client.
  static GoogleIdp? forIdToken(String idToken) {
    final clientId = _clientId;
    final idp = _idp;
    if (clientId == null || idp == null) return null;
    return googleIdTokenAudiences(idToken).contains(clientId) ? idp : null;
  }

  /// Clears the configured verifier. Intended for tests.
  static void resetForTests() {
    _idp = null;
    _clientId = null;
  }
}
