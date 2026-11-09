import 'dart:convert';

/// Returns the audiences of a Google ID token without verifying it.
///
/// Only use this to choose which verifier should validate the token. Each
/// verifier still checks the signature and pins the audience it accepts, so an
/// unverified claim cannot be used to bypass validation.
Set<String> googleIdTokenAudiences(String idToken) {
  final parts = idToken.split('.');
  if (parts.length != 3) return const {};

  try {
    final payloadBytes = base64Url.decode(base64Url.normalize(parts[1]));
    final payload = jsonDecode(utf8.decode(payloadBytes));
    if (payload is! Map<String, dynamic>) return const {};

    final audience = payload['aud'];
    if (audience is String) return {audience};
    if (audience is List) {
      return audience.whereType<String>().toSet();
    }
    return const {};
  } on FormatException {
    return const {};
  }
}
