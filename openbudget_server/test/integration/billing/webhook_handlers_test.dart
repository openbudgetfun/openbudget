import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:openbudget_server/src/billing/revenuecat_webhook_handler.dart';
import 'package:openbudget_server/src/billing/stripe_webhook_handler.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import '../helpers/auth_helper.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  const webhookSecret = 'whsec_test_secret';
  const revenueCatSecret = 'rc_test_secret';
  final now = DateTime.now().toUtc();

  String stripeHeader(String payload, {DateTime? at}) {
    final seconds = (at ?? now).millisecondsSinceEpoch ~/ 1000;
    final digest = Hmac(
      sha256,
      utf8.encode(webhookSecret),
    ).convert(utf8.encode('$seconds.$payload'));
    return 't=$seconds,v1=$digest';
  }

  String eventBody(
    String type,
    Map<String, Object?> object,
  ) => jsonEncode({
    'id': 'evt_1',
    'type': type,
    'data': {'object': object},
  });

  Map<String, Object?> subscriptionObject({
    required String userId,
    String status = 'active',
    String id = 'sub_integration',
    DateTime? start,
    DateTime? end,
  }) {
    final periodStart = start ?? now.subtract(const Duration(days: 1));
    final periodEnd = end ?? now.add(const Duration(days: 29));
    return {
      'id': id,
      'status': status,
      'metadata': {'user_id': userId},
      'current_period_start': periodStart.millisecondsSinceEpoch ~/ 1000,
      'current_period_end': periodEnd.millisecondsSinceEpoch ~/ 1000,
    };
  }

  Map<String, Object?> revenueCatEvent({
    required String userId,
    String type = 'INITIAL_PURCHASE',
    String store = 'APP_STORE',
    String transactionId = 'txn_integration',
  }) => {
    'event': {
      'type': type,
      'app_user_id': userId,
      'original_transaction_id': transactionId,
      'store': store,
      'purchased_at_ms': now
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch,
      'expiration_at_ms': now
          .add(const Duration(days: 29))
          .millisecondsSinceEpoch,
    },
  };

  withServerpod('Given StripeWebhookHandler', (sessionBuilder, endpoints) {
    setUp(
      () => ensureAuthUsers(sessionBuilder, [
        for (final group in ['1', '2'])
          for (var index = 1; index <= 5; index++)
            '20000000-0000-4000-a000-000000000$group${index.toString().padLeft(2, '0')}',
      ]),
    );
    test('then a valid subscription event records an entitlement', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000101',
      );
      final body = eventBody(
        'customer.subscription.created',
        subscriptionObject(userId: userId.uuid),
      );
      final handler = StripeWebhookHandler(webhookSecret: webhookSecret);

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'stripe-signature': stripeHeader(body)},
      );

      expect(result.statusCode, 200);
      final rows = await Entitlement.db.find(
        sessionBuilder.build(),
        where: (t) => t.userId.equals(userId),
      );
      expect(rows, hasLength(1));
      expect(rows.single.source, EntitlementSource.stripe);
      expect(rows.single.externalId, 'sub_integration');
      expect(rows.single.status, EntitlementStatus.active);
    });

    test('then an invalid signature is rejected', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000102',
      );
      final body = eventBody(
        'customer.subscription.created',
        subscriptionObject(userId: userId.uuid),
      );
      final handler = StripeWebhookHandler(webhookSecret: webhookSecret);

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'stripe-signature': 't=1,v1=deadbeef'},
      );

      expect(result.statusCode, 400);
      expect(
        await Entitlement.db.find(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(userId),
        ),
        isEmpty,
      );
    });

    test('then a checkout session links the Stripe customer', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000103',
      );
      final body = eventBody('checkout.session.completed', {
        'client_reference_id': userId.uuid,
        'customer': 'cus_integration',
      });
      final handler = StripeWebhookHandler(webhookSecret: webhookSecret);
      final session = sessionBuilder.build();

      for (var attempt = 0; attempt < 2; attempt++) {
        final result = await handler.handle(
          session,
          rawBody: body,
          headers: {'stripe-signature': stripeHeader(body)},
        );
        expect(result.statusCode, 200);
      }

      final rows = await StripeCustomer.db.find(
        session,
        where: (t) => t.userId.equals(userId),
      );
      expect(rows, hasLength(1));
      expect(rows.single.customerId, 'cus_integration');
    });

    test('then a missing webhook secret returns 503', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000104',
      );
      final body = eventBody(
        'customer.subscription.created',
        subscriptionObject(userId: userId.uuid),
      );
      final handler = StripeWebhookHandler();

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'stripe-signature': stripeHeader(body)},
      );

      expect(result.statusCode, 503);
    });

    test('then a cancelled subscription keeps access until its end', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000105',
      );
      final body = eventBody(
        'customer.subscription.deleted',
        subscriptionObject(
          userId: userId.uuid,
          status: 'canceled',
          id: 'sub_canceled',
        ),
      );
      final handler = StripeWebhookHandler(webhookSecret: webhookSecret);

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'stripe-signature': stripeHeader(body)},
      );

      expect(result.statusCode, 200);
      final row = await Entitlement.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.externalId.equals('sub_canceled'),
      );
      expect(row?.status, EntitlementStatus.canceled);
    });
  });

  withServerpod('Given RevenueCatWebhookHandler', (
    sessionBuilder,
    endpoints,
  ) {
    setUp(
      () => ensureAuthUsers(sessionBuilder, [
        '20000000-0000-4000-a000-000000000201',
        '20000000-0000-4000-a000-000000000202',
        '20000000-0000-4000-a000-000000000203',
        '20000000-0000-4000-a000-000000000204',
        '20000000-0000-4000-a000-000000000205',
      ]),
    );

    test('then a valid App Store event records an entitlement', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000201',
      );
      final body = jsonEncode(revenueCatEvent(userId: userId.uuid));
      final handler = RevenueCatWebhookHandler(
        authorization: revenueCatSecret,
      );

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'authorization': revenueCatSecret},
      );

      expect(result.statusCode, 200);
      final rows = await Entitlement.db.find(
        sessionBuilder.build(),
        where: (t) => t.userId.equals(userId),
      );
      expect(rows, hasLength(1));
      expect(rows.single.source, EntitlementSource.appStore);
      expect(rows.single.externalId, 'txn_integration');
    });

    test('then a wrong authorization is rejected', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000202',
      );
      final body = jsonEncode(revenueCatEvent(userId: userId.uuid));
      final handler = RevenueCatWebhookHandler(
        authorization: revenueCatSecret,
      );

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'authorization': 'wrong'},
      );

      expect(result.statusCode, 401);
      expect(
        await Entitlement.db.find(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(userId),
        ),
        isEmpty,
      );
    });

    test('then another store is a no-op', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000203',
      );
      final body = jsonEncode(
        revenueCatEvent(userId: userId.uuid, store: 'STRIPE'),
      );
      final handler = RevenueCatWebhookHandler(
        authorization: revenueCatSecret,
      );

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'authorization': revenueCatSecret},
      );

      expect(result.statusCode, 200);
      expect(
        await Entitlement.db.find(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(userId),
        ),
        isEmpty,
      );
    });

    test('then a missing authorization configuration returns 503', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000204',
      );
      final body = jsonEncode(revenueCatEvent(userId: userId.uuid));
      final handler = RevenueCatWebhookHandler();

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'authorization': revenueCatSecret},
      );

      expect(result.statusCode, 503);
    });

    test('then an anonymous app user is a no-op', () async {
      final userId = UuidValue.fromString(
        '20000000-0000-4000-a000-000000000205',
      );
      final body = jsonEncode(
        revenueCatEvent(
          userId: userId.uuid,
          type: 'TEST',
        ),
      );
      final handler = RevenueCatWebhookHandler(
        authorization: revenueCatSecret,
      );

      final result = await handler.handle(
        sessionBuilder.build(),
        rawBody: body,
        headers: {'authorization': revenueCatSecret},
      );

      expect(result.statusCode, 200);
      expect(
        await Entitlement.db.find(
          sessionBuilder.build(),
          where: (t) => t.userId.equals(userId),
        ),
        isEmpty,
      );
    });
  });
}
