import 'package:openbudget_server/src/billing/stripe_subscription_parser.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  const userId = '20000000-0000-4000-a000-000000000010';
  const subscriptionId = 'sub_123';
  final now = DateTime.utc(2026, 11, 15);
  final periodStart = DateTime.utc(2026, 11);
  final periodEnd = DateTime.utc(2026, 12);

  Map<String, Object?> subscription({
    String status = 'active',
    Map<String, Object?>? metadata,
    bool includeTopLevelPeriod = true,
    bool includeItemPeriod = true,
  }) => {
    'id': subscriptionId,
    'status': status,
    'metadata': metadata ?? {'user_id': userId},
    if (includeTopLevelPeriod) ...{
      'current_period_start': periodStart.millisecondsSinceEpoch ~/ 1000,
      'current_period_end': periodEnd.millisecondsSinceEpoch ~/ 1000,
    },
    'items': {
      'data': [
        {
          if (includeItemPeriod) ...{
            'current_period_start': periodStart.millisecondsSinceEpoch ~/ 1000,
            'current_period_end': periodEnd.millisecondsSinceEpoch ~/ 1000,
          },
        },
      ],
    },
  };

  group('Given a Stripe subscription payload', () {
    test('then the top-level period fields are used', () {
      final update = StripeSubscriptionParser.parse(
        subscription(includeItemPeriod: false),
        now: now,
      );

      expect(update, isNotNull);
      expect(update!.userId.uuid, userId);
      expect(update.externalId, subscriptionId);
      expect(update.source, EntitlementSource.stripe);
      expect(update.currentPeriodStart, periodStart);
      expect(update.currentPeriodEnd, periodEnd);
    });

    test('then the item period fields are used when top-level is absent', () {
      final update = StripeSubscriptionParser.parse(
        subscription(includeTopLevelPeriod: false),
        now: now,
      );

      expect(update?.currentPeriodStart, periodStart);
      expect(update?.currentPeriodEnd, periodEnd);
    });

    test('then missing metadata is skipped', () {
      expect(
        StripeSubscriptionParser.parse(
          subscription(metadata: const {}),
          now: now,
        ),
        isNull,
      );
    });

    test('then a non-UUID metadata user is skipped', () {
      expect(
        StripeSubscriptionParser.parse(
          subscription(metadata: const {'user_id': 'not-a-uuid'}),
          now: now,
        ),
        isNull,
      );
    });
  });

  group('Given Stripe subscription statuses', () {
    EntitlementStatus? status(String value, {DateTime? end}) =>
        StripeSubscriptionParser.mapStatus(
          value,
          periodEnd: end ?? periodEnd,
          now: now,
        );

    test('then active and trialing grant access', () {
      expect(status('active'), EntitlementStatus.active);
      expect(status('trialing'), EntitlementStatus.active);
    });

    test('then past_due and unpaid are past due', () {
      expect(status('past_due'), EntitlementStatus.pastDue);
      expect(status('unpaid'), EntitlementStatus.pastDue);
    });

    test('then canceled keeps access until the period ends', () {
      expect(status('canceled'), EntitlementStatus.canceled);
      expect(
        status('canceled', end: now.subtract(const Duration(seconds: 1))),
        EntitlementStatus.expired,
      );
    });

    test('then incomplete_expired is expired', () {
      expect(status('incomplete_expired'), EntitlementStatus.expired);
    });

    test('then incomplete and paused are ignored', () {
      expect(status('incomplete'), isNull);
      expect(status('paused'), isNull);
    });

    test('then unknown statuses are ignored', () {
      expect(status('mystery'), isNull);
    });
  });
}
