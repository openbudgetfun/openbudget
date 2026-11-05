import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';

void main() {
  group('resolvePlusPlatform', () {
    test('web wins over the host target', () {
      expect(
        resolvePlusPlatform(isWeb: true, platform: TargetPlatform.macOS),
        PlusPlatform.web,
      );
    });

    test('maps every Flutter target', () {
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.iOS),
        PlusPlatform.ios,
      );
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.android),
        PlusPlatform.android,
      );
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.macOS),
        PlusPlatform.macos,
      );
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.windows),
        PlusPlatform.windows,
      );
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.linux),
        PlusPlatform.linux,
      );
      expect(
        resolvePlusPlatform(isWeb: false, platform: TargetPlatform.fuchsia),
        PlusPlatform.linux,
      );
    });
  });

  group('plusRailsFor', () {
    test('store rules keep Stripe and Solana away from mobile', () {
      expect(plusRailsFor(PlusPlatform.ios), [PlusRail.store]);
      expect(plusRailsFor(PlusPlatform.android), [PlusRail.store]);
    });

    test('web offers card and USDC', () {
      expect(plusRailsFor(PlusPlatform.web), [
        PlusRail.stripe,
        PlusRail.solana,
      ]);
    });

    test('desktop offers card only', () {
      expect(plusRailsFor(PlusPlatform.macos), [PlusRail.stripe]);
      expect(plusRailsFor(PlusPlatform.windows), [PlusRail.stripe]);
      expect(plusRailsFor(PlusPlatform.linux), [PlusRail.stripe]);
    });
  });
}
