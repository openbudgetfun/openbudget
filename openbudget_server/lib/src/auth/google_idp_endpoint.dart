import 'package:openbudget_server/src/auth/google_ios_audience_idp.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Routes Google ID tokens to the verifier that matches their audience.
///
/// Most tokens are addressed to the web OAuth client id and use Serverpod's
/// default Google provider. Native iOS tokens can instead be addressed to the
/// iOS OAuth client id, which [GoogleIosAudienceIdp] verifies.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) {
    final idp = GoogleIosAudienceIdp.forIdToken(idToken) ?? googleIdp;
    return idp.login(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
