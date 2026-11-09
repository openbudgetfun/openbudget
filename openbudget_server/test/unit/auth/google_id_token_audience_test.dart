import 'dart:convert';

import 'package:openbudget_server/src/auth/google_id_token_audience.dart';
import 'package:test/test.dart';

void main() {
  group('googleIdTokenAudiences', () {
    test('reads a string audience', () {
      final token = _jwt({'aud': 'ios-client.apps.googleusercontent.com'});

      expect(googleIdTokenAudiences(token), {
        'ios-client.apps.googleusercontent.com',
      });
    });

    test('reads a list audience', () {
      final token = _jwt({
        'aud': ['web-client.apps.googleusercontent.com', 'ios-client'],
      });

      expect(googleIdTokenAudiences(token), {
        'web-client.apps.googleusercontent.com',
        'ios-client',
      });
    });

    test('returns empty for a missing audience', () {
      expect(googleIdTokenAudiences(_jwt({'sub': '123'})), isEmpty);
    });

    test('returns empty for a malformed token', () {
      expect(googleIdTokenAudiences('not-a-jwt'), isEmpty);
      expect(googleIdTokenAudiences('a.b'), isEmpty);
      expect(googleIdTokenAudiences('a.%%%.c'), isEmpty);
      expect(googleIdTokenAudiences('a.${_encode('not a map')}.c'), isEmpty);
    });
  });
}

String _jwt(Map<String, Object?> payload) =>
    '${_encode({'alg': 'RS256'})}.${_encode(payload)}.signature';

String _encode(Object value) {
  final bytes = utf8.encode(jsonEncode(value));
  return base64Url.encode(bytes).replaceAll('=', '');
}
