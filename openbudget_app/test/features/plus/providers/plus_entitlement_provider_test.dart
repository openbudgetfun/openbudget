import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_entitlement_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../support/fakes.dart';

void main() {
  group('plusEntitlementProvider', () {
    late FakePlusBillingApi api;
    late ProviderContainer container;

    setUp(() {
      api = FakePlusBillingApi();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [plusBillingApiProvider.overrideWithValue(api)],
      );
      addTearDown(container.dispose);
    });

    test('returns null on the free plan', () async {
      expect(await container.read(plusEntitlementProvider.future), isNull);
      expect(api.entitlementReads, 1);
    });

    test('returns the active entitlement', () async {
      api.entitlement = makeEntitlement();

      final entitlement = await container.read(
        plusEntitlementProvider.future,
      );

      expect(entitlement?.status, EntitlementStatus.active);
      expect(entitlement?.source, EntitlementSource.stripe);
    });

    test('re-reads after invalidation', () async {
      expect(await container.read(plusEntitlementProvider.future), isNull);
      api.entitlement = makeEntitlement(status: EntitlementStatus.pastDue);

      container.invalidate(plusEntitlementProvider);

      final entitlement = await container.read(
        plusEntitlementProvider.future,
      );
      expect(entitlement?.status, EntitlementStatus.pastDue);
      expect(api.entitlementReads, 2);
    });

    test('surfaces a failed read as an async error', () async {
      api.entitlementError = Exception('billing down');
      final subscription = container.listen(plusEntitlementProvider, (_, _) {});
      addTearDown(subscription.close);

      await expectLater(
        container.read(plusEntitlementProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}
