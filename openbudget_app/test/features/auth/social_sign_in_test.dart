import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/auth/social_sign_in.dart';

const _noDefines = SocialSignInDefines(
  googleClientId: false,
  appleServiceIdentifier: false,
  appleRedirectUri: false,
);

const _googleOnly = SocialSignInDefines(
  googleClientId: true,
  appleServiceIdentifier: false,
  appleRedirectUri: false,
);

const _appleWebOnly = SocialSignInDefines(
  googleClientId: false,
  appleServiceIdentifier: true,
  appleRedirectUri: true,
);

const _allDefines = SocialSignInDefines(
  googleClientId: true,
  appleServiceIdentifier: true,
  appleRedirectUri: true,
);

void main() {
  group('socialSignInPlatform', () {
    test('resolves web before the target platform', () {
      expect(
        socialSignInPlatform(
          isWeb: true,
          targetPlatform: TargetPlatform.iOS,
        ),
        SocialSignInPlatform.web,
      );
    });

    test('maps iOS and Android', () {
      expect(
        socialSignInPlatform(
          isWeb: false,
          targetPlatform: TargetPlatform.iOS,
        ),
        SocialSignInPlatform.ios,
      );
      expect(
        socialSignInPlatform(
          isWeb: false,
          targetPlatform: TargetPlatform.android,
        ),
        SocialSignInPlatform.android,
      );
    });

    test('maps desktop platforms to other', () {
      for (final platform in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(
          socialSignInPlatform(isWeb: false, targetPlatform: platform),
          SocialSignInPlatform.other,
        );
      }
    });
  });

  group('socialSignInAvailability', () {
    test('shows nothing on desktop platforms', () {
      final availability = socialSignInAvailability(
        platform: SocialSignInPlatform.other,
        defines: _allDefines,
      );

      expect(availability.apple, isFalse);
      expect(availability.google, isFalse);
      expect(availability.hasAny, isFalse);
    });

    test('shows nothing on iOS without a Google client id', () {
      final availability = socialSignInAvailability(
        platform: SocialSignInPlatform.ios,
        defines: _noDefines,
      );

      expect(availability.apple, isTrue);
      expect(availability.google, isFalse);
      expect(availability.hasAny, isTrue);
    });

    test('shows Apple on iOS without the web-only Apple defines', () {
      final availability = socialSignInAvailability(
        platform: SocialSignInPlatform.ios,
        defines: _googleOnly,
      );

      expect(availability.apple, isTrue);
      expect(availability.google, isTrue);
    });

    test('keeps Apple hidden on Android without the web-only defines', () {
      final availability = socialSignInAvailability(
        platform: SocialSignInPlatform.android,
        defines: _googleOnly,
      );

      expect(availability.apple, isFalse);
      expect(availability.google, isTrue);
    });

    test('shows Apple on Android when the web-only defines are present', () {
      final availability = socialSignInAvailability(
        platform: SocialSignInPlatform.android,
        defines: _allDefines,
      );

      expect(availability.apple, isTrue);
      expect(availability.google, isTrue);
    });

    test('requires both Apple web values on web', () {
      final serviceOnly = socialSignInAvailability(
        platform: SocialSignInPlatform.web,
        defines: const SocialSignInDefines(
          googleClientId: false,
          appleServiceIdentifier: true,
          appleRedirectUri: false,
        ),
      );
      expect(serviceOnly.apple, isFalse);

      final redirectOnly = socialSignInAvailability(
        platform: SocialSignInPlatform.web,
        defines: const SocialSignInDefines(
          googleClientId: false,
          appleServiceIdentifier: false,
          appleRedirectUri: true,
        ),
      );
      expect(redirectOnly.apple, isFalse);

      final complete = socialSignInAvailability(
        platform: SocialSignInPlatform.web,
        defines: _appleWebOnly,
      );
      expect(complete.apple, isTrue);
      expect(complete.google, isFalse);
    });
  });
}
