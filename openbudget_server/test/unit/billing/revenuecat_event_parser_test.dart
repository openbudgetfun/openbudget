import 'package:openbudget_server/src/billing/revenuecat_event_parser.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const userId = '20000000-0000-4000-a000-000000000020';
  final purchasedAt = DateTime.utc(2026, 11);
  final expirationAt = DateTime.utc(2026, 12);

  Map<String, Object?> event({
    String type = 'INITIAL_PURCHASE',
    String store = 'APP_STORE',
    String appUserId = userId,
    String? transactionId = 'txn_1',
  }) => {
    'type': type,
    'app_user_id': appUserId,
    'original_transaction_id': transactionId,
    'store': store,
    'purchased_at_ms': purchasedAt.millisecondsSinceEpoch,
    'expiration_at_ms': expirationAt.millisecondsSinceEpoch,
  };

  group('Given a RevenueCat event', () {
    test('then an App Store purchase becomes an appStore entitlement', () {
      final update = RevenueCatEventParser.parse(event());

      expect(update, isNotNull);
      expect(update!.source, EntitlementSource.appStore);
      expect(update.status, EntitlementStatus.active);
      expect(update.externalId, 'txn_1');
      expect(update.currentPeriodStart, purchasedAt);
      expect(update.currentPeriodEnd, expirationAt);
    });

    test('then a Play Store purchase becomes a playStore entitlement', () {
      expect(
        RevenueCatEventParser.parse(event(store: 'PLAY_STORE'))?.source,
        EntitlementSource.playStore,
      );
    });

    test('then another store is ignored', () {
      expect(
        RevenueCatEventParser.parse(event(store: 'STRIPE')),
        isNull,
      );
    });

    test('then a non-UUID app user is ignored', () {
      expect(
        RevenueCatEventParser.parse(event(appUserId: r'$RCAnonymousID:abc')),
        isNull,
      );
    });

    test('then a missing transaction id is ignored', () {
      expect(
        RevenueCatEventParser.parse(event(transactionId: null)),
        isNull,
      );
    });
  });

  group('Given RevenueCat event types', () {
    EntitlementStatus? status(String type) =>
        RevenueCatEventParser.statusForType(type);

    test('then purchases and renewals are active', () {
      expect(status('INITIAL_PURCHASE'), EntitlementStatus.active);
      expect(status('RENEWAL'), EntitlementStatus.active);
      expect(status('UNCANCELLATION'), EntitlementStatus.active);
      expect(status('PRODUCT_CHANGE'), EntitlementStatus.active);
    });

    test('then cancellation keeps access until expiration', () {
      expect(status('CANCELLATION'), EntitlementStatus.canceled);
    });

    test('then billing issues are past due', () {
      expect(status('BILLING_ISSUE'), EntitlementStatus.pastDue);
    });

    test('then expiration is expired', () {
      expect(status('EXPIRATION'), EntitlementStatus.expired);
    });

    test('then test and unknown events are ignored', () {
      expect(status('TEST'), isNull);
      expect(status('SOMETHING_ELSE'), isNull);
      expect(RevenueCatEventParser.parse(event(type: 'TEST')), isNull);
    });
  });
}
