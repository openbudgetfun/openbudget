import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';

void main() {
  group('RevenueCatStorePurchases', () {
    test('an empty build key leaves the rail unavailable', () async {
      final purchases = RevenueCatStorePurchases('', supported: true);

      expect(purchases.isAvailable, isFalse);
      expect(
        await purchases.purchaseMonthly(),
        StorePurchaseOutcome.unavailable,
      );
      expect(await purchases.restore(), StorePurchaseOutcome.unavailable);
      expect(await purchases.managementUrl(), isNull);
      await purchases.identify('user-1');
    });

    test('a platform without store billing is unavailable even with a key', () {
      final purchases = RevenueCatStorePurchases('key', supported: false);

      expect(purchases.isAvailable, isFalse);
    });

    test('a key on a store platform is available', () {
      final purchases = RevenueCatStorePurchases('key', supported: true);

      expect(purchases.isAvailable, isTrue);
    });
  });

  group('storePurchasesProvider', () {
    test('has no key on a build without RevenueCat keys', () {
      final container = ProviderContainer(
        overrides: [plusPlatformProvider.overrideWithValue(PlusPlatform.ios)],
      );
      addTearDown(container.dispose);

      expect(container.read(revenueCatApiKeyProvider), isEmpty);
      expect(container.read(storePurchasesProvider).isAvailable, isFalse);
    });

    test('uses the key on iOS and Android only', () {
      final container = ProviderContainer(
        overrides: [
          plusPlatformProvider.overrideWithValue(PlusPlatform.ios),
          revenueCatApiKeyProvider.overrideWithValue('ios-key'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(storePurchasesProvider).isAvailable, isTrue);

      final desktop = ProviderContainer(
        overrides: [
          plusPlatformProvider.overrideWithValue(PlusPlatform.macos),
          revenueCatApiKeyProvider.overrideWithValue('ios-key'),
        ],
      );
      addTearDown(desktop.dispose);

      expect(desktop.read(storePurchasesProvider).isAvailable, isFalse);
    });
  });
}
