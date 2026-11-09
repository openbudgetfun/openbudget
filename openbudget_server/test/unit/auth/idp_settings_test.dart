import 'package:openbudget_server/src/auth/idp_settings.dart';
import 'package:test/test.dart';

void main() {
  group('normalizedPassword', () {
    test('trims a value', () {
      expect(normalizedPassword(' value '), 'value');
    });

    test('treats null and whitespace as absent', () {
      expect(normalizedPassword(null), isNull);
      expect(normalizedPassword('   '), isNull);
      expect(normalizedPassword(''), isNull);
    });
  });

  group('hasRequiredPasswords', () {
    test('requires every key to be present', () {
      final values = {'a': 'one', 'b': 'two'};
      String? read(String key) => values[key];

      expect(hasRequiredPasswords(read, ['a', 'b']), isTrue);
      expect(hasRequiredPasswords(read, ['a', 'b', 'c']), isFalse);
      expect(missingPasswords(read, ['a', 'b', 'c']), ['c']);
    });

    test('treats empty and whitespace values as missing', () {
      final values = {'a': 'one', 'b': ' ', 'c': ''};
      String? read(String key) => values[key];

      expect(hasRequiredPasswords(read, ['a']), isTrue);
      expect(hasRequiredPasswords(read, ['a', 'b']), isFalse);
      expect(missingPasswords(read, ['a', 'b', 'c']), ['b', 'c']);
    });
  });

  group('SocialIdpSettings', () {
    test('disables both providers when no passwords exist', () {
      final settings = SocialIdpSettings.fromPasswords((_) => null);

      expect(settings.googleEnabled, isFalse);
      expect(settings.appleEnabled, isFalse);
    });

    test('enables Google from the web client secret alone', () {
      final settings = SocialIdpSettings.fromPasswords(
        (key) => key == 'googleClientSecret' ? '{...}' : null,
      );

      expect(settings.googleEnabled, isTrue);
      expect(settings.appleEnabled, isFalse);
    });

    test('enables Apple from all six Apple passwords', () {
      final values = {
        'appleServiceIdentifier': 'app.openbudget.signin',
        'appleBundleIdentifier': 'com.openbudget.app',
        'appleRedirectUri': 'https://app.openbudget.app/auth/apple/callback',
        'appleTeamId': 'TEAMID1234',
        'appleKeyId': 'KEYID1234',
        'appleKey': 'test-apple-key',
      };
      final settings = SocialIdpSettings.fromPasswords(
        (key) => values[key],
      );

      expect(settings.appleEnabled, isTrue);
    });

    test('disables Apple when any password is missing', () {
      final values = {
        'appleServiceIdentifier': 'app.openbudget.signin',
        'appleBundleIdentifier': 'com.openbudget.app',
        'appleRedirectUri': 'https://app.openbudget.app/auth/apple/callback',
        'appleTeamId': 'TEAMID1234',
        'appleKeyId': 'KEYID1234',
        'appleKey': 'test-apple-key',
      };

      for (final missingKey in values.keys) {
        final settings = SocialIdpSettings.fromPasswords(
          (key) => key == missingKey ? null : values[key],
        );

        expect(
          settings.appleEnabled,
          isFalse,
          reason: 'Apple should be disabled without $missingKey',
        );
      }
    });
  });
}
