import 'dart:convert';
import 'dart:typed_data';

import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/solana_billing_chain.dart';
import 'package:openbudget_server/src/billing/solana_billing_collector.dart';
import 'package:openbudget_server/src/billing/solana_billing_plan.dart';
import 'package:openbudget_server/src/billing/solana_billing_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';
import 'fake_solana_billing_chain.dart';

void main() {
  const planAddress = '11111111111111111111111111111111';
  const usdcMint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
  final baseNow = DateTime.utc(2026, 11, 4, 12);

  Future<String> subscriptionAddress(String subscriber) async {
    final (pda, _) = await findSubscriptionDelegationPda(
      programAddress: subscriptionsProgramAddress,
      seeds: SubscriptionDelegationSeeds(
        planPda: address(planAddress),
        subscriber: address(subscriber),
      ),
    );
    return pda.value;
  }

  SolanaSubscriptionSnapshot snapshotFor({
    required String subscriptionAddress,
    required String subscriberAddress,
    String? plan,
    bool planActive = true,
    bool subscriptionActive = true,
  }) => SolanaSubscriptionSnapshot(
    subscriptionAddress: subscriptionAddress,
    planAddress: plan ?? planAddress,
    subscriberAddress: subscriberAddress,
    planActive: planActive,
    subscriptionActive: subscriptionActive,
    amountBaseUnits: SolanaBillingPlan.amountBaseUnits,
    periodSeconds: SolanaBillingPlan.periodSeconds,
  );

  String sign(String message, KeyPair keyPair) {
    final signature = signBytes(
      keyPair.privateKey,
      Uint8List.fromList(utf8.encode(message)),
    );
    return getBase58Decoder().decode(signature.value);
  }

  withServerpod('Given SolanaBillingService', (sessionBuilder, endpoints) {
    test('then a challenge is stored with a ten minute lifetime', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000001',
      );
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      final message = await service.createChallenge(
        sessionBuilder.build(),
        userId,
      );

      expect(message, startsWith('OpenBudget Plus subscription '));
      final challenge = await SolanaBillingChallenge.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.userId.equals(userId),
      );
      expect(challenge?.message, message);
      expect(
        challenge?.expiresAt,
        baseNow.add(const Duration(minutes: 10)),
      );
      expect(challenge?.usedAt, isNull);
    });

    test('then a valid signed subscription records an entitlement', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000002',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          subscription: snapshotFor(
            subscriptionAddress: subscription,
            subscriberAddress: subscriber,
          ),
        },
      );
      final service = SolanaBillingService(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);

      final entitlement = await service.confirmSubscription(
        session,
        userId: userId,
        subscriberAddress: subscriber,
        message: message,
        signatureBase58: sign(message, keyPair),
      );

      expect(chain.transfers, hasLength(1));
      expect(chain.transfers.single.subscriptionAddress, subscription);
      expect(chain.transfers.single.amountBaseUnits, 10_000_000);
      expect(entitlement.source, EntitlementSource.solana);
      expect(entitlement.externalId, subscription);
      expect(entitlement.status, EntitlementStatus.active);
      expect(entitlement.currentPeriodStart, baseNow);
      expect(
        entitlement.currentPeriodEnd,
        baseNow.add(
          const Duration(seconds: SolanaBillingPlan.periodSeconds),
        ),
      );
      final challenge = await SolanaBillingChallenge.db.findFirstRow(
        session,
        where: (t) => t.message.equals(message),
      );
      expect(challenge?.usedAt, isNotNull);
    });

    test('then a failed first payment grants nothing', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-0000000000f1',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          subscription: snapshotFor(
            subscriptionAddress: subscription,
            subscriberAddress: subscriber,
          ),
        },
        transferError: Exception('insufficient funds'),
      );
      final service = SolanaBillingService(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);

      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        ),
        throwsA(isA<BillingProviderException>()),
      );
      expect(
        await EntitlementService.activeFor(session, userId, now: baseNow),
        isNull,
      );
      final challenge = await SolanaBillingChallenge.db.findFirstRow(
        session,
        where: (t) => t.message.equals(message),
      );
      expect(challenge?.usedAt, isNull);
    });

    test('then confirming again does not charge twice', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-0000000000f2',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          subscription: snapshotFor(
            subscriptionAddress: subscription,
            subscriberAddress: subscriber,
          ),
        },
      );
      final service = SolanaBillingService(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      Future<Entitlement> confirm() async {
        final message = await service.createChallenge(session, userId);
        return service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        );
      }

      final first = await confirm();
      final second = await confirm();

      expect(second.id, first.id);
      expect(second.currentPeriodEnd, first.currentPeriodEnd);
      expect(chain.transfers, hasLength(1));
    });

    test('then an expired challenge is rejected', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000003',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      var clock = baseNow;
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          subscription: snapshotFor(
            subscriptionAddress: subscription,
            subscriberAddress: subscriber,
          ),
        },
      );
      final service = SolanaBillingService(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => clock,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);
      clock = baseNow.add(const Duration(minutes: 11));

      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a challenge cannot be reused', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000004',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(
          subscriptions: {
            subscription: snapshotFor(
              subscriptionAddress: subscription,
              subscriberAddress: subscriber,
            ),
          },
        ),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);
      final signature = sign(message, keyPair);

      await service.confirmSubscription(
        session,
        userId: userId,
        subscriberAddress: subscriber,
        message: message,
        signatureBase58: signature,
      );
      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: signature,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then another user cannot use the challenge', () async {
      final owner = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000005',
      );
      final other = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000006',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(
          subscriptions: {
            subscription: snapshotFor(
              subscriptionAddress: subscription,
              subscriberAddress: subscriber,
            ),
          },
        ),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, owner);

      await expectLater(
        service.confirmSubscription(
          session,
          userId: other,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('then a signature over another message is rejected', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000007',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(
          subscriptions: {
            subscription: snapshotFor(
              subscriptionAddress: subscription,
              subscriberAddress: subscriber,
            ),
          },
        ),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);

      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign('another message', keyPair),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a subscription for another plan is rejected', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000008',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(
          subscriptions: {
            subscription: snapshotFor(
              subscriptionAddress: subscription,
              subscriberAddress: subscriber,
              plan: usdcMint,
            ),
          },
        ),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);

      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(
        await Entitlement.db.find(
          session,
          where: (t) => t.userId.equals(userId),
        ),
        isEmpty,
      );
    });

    test('then an inactive subscription is rejected', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000009',
      );
      final keyPair = generateKeyPair();
      final subscriber = getAddressFromPublicKey(keyPair.publicKey).value;
      final subscription = await subscriptionAddress(subscriber);
      final service = SolanaBillingService(
        chain: FakeSolanaBillingChain(
          subscriptions: {
            subscription: snapshotFor(
              subscriptionAddress: subscription,
              subscriberAddress: subscriber,
              subscriptionActive: false,
            ),
          },
        ),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );
      final session = sessionBuilder.build();
      final message = await service.createChallenge(session, userId);

      await expectLater(
        service.confirmSubscription(
          session,
          userId: userId,
          subscriberAddress: subscriber,
          message: message,
          signatureBase58: sign(message, keyPair),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  withServerpod('Given SolanaBillingCollector', (sessionBuilder, endpoints) {
    Future<Entitlement> seed({
      required UuidValue userId,
      required String externalId,
      required DateTime start,
      required DateTime end,
      EntitlementStatus status = EntitlementStatus.active,
    }) => EntitlementService.record(
      sessionBuilder.build(),
      userId: userId,
      source: EntitlementSource.solana,
      externalId: externalId,
      status: status,
      currentPeriodStart: start,
      currentPeriodEnd: end,
    );

    test('then a due subscription is collected and extended', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000101',
      );
      const externalId = 'solana_collect_success';
      final end = baseNow.add(const Duration(hours: 12));
      await seed(
        userId: userId,
        externalId: externalId,
        start: end.subtract(const Duration(days: 30)),
        end: end,
      );
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          externalId: snapshotFor(
            subscriptionAddress: externalId,
            subscriberAddress: 'subscriber_success',
          ),
        },
      );
      final collector = SolanaBillingCollector(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      final report = await collector.run(
        sessionBuilder.build(),
        now: baseNow,
      );

      expect(report.processed, 1);
      expect(report.collected, 1);
      expect(chain.transfers, hasLength(1));
      expect(chain.transfers.single.amountBaseUnits, 10_000_000);
      final row = await Entitlement.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.externalId.equals(externalId),
      );
      expect(row?.status, EntitlementStatus.active);
      expect(
        row?.currentPeriodEnd,
        end.add(const Duration(days: 30)),
      );
    });

    test('then a failed transfer marks the subscription past due', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000102',
      );
      const externalId = 'solana_collect_failure';
      final end = baseNow.add(const Duration(hours: 12));
      await seed(
        userId: userId,
        externalId: externalId,
        start: end.subtract(const Duration(days: 30)),
        end: end,
      );
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          externalId: snapshotFor(
            subscriptionAddress: externalId,
            subscriberAddress: 'subscriber_failure',
          ),
        },
        transferError: Exception('rpc failed'),
      );
      final collector = SolanaBillingCollector(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      final report = await collector.run(
        sessionBuilder.build(),
        now: baseNow,
      );

      expect(report.failed, 1);
      final row = await Entitlement.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.externalId.equals(externalId),
      );
      expect(row?.status, EntitlementStatus.pastDue);
      expect(row?.currentPeriodEnd, end);
    });

    test('then a failure past the grace period expires it', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000103',
      );
      const externalId = 'solana_collect_expired';
      final end = baseNow.subtract(const Duration(days: 4));
      await seed(
        userId: userId,
        externalId: externalId,
        start: end.subtract(const Duration(days: 30)),
        end: end,
      );
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          externalId: snapshotFor(
            subscriptionAddress: externalId,
            subscriberAddress: 'subscriber_expired',
          ),
        },
        transferError: Exception('rpc failed'),
      );
      final collector = SolanaBillingCollector(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      await collector.run(sessionBuilder.build(), now: baseNow);

      final row = await Entitlement.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.externalId.equals(externalId),
      );
      expect(row?.status, EntitlementStatus.expired);
    });

    test('then a subscription outside the window is untouched', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000104',
      );
      const externalId = 'solana_collect_later';
      final end = baseNow.add(const Duration(days: 10));
      await seed(
        userId: userId,
        externalId: externalId,
        start: baseNow,
        end: end,
      );
      final chain = FakeSolanaBillingChain(
        subscriptions: {
          externalId: snapshotFor(
            subscriptionAddress: externalId,
            subscriberAddress: 'subscriber_later',
          ),
        },
      );
      final collector = SolanaBillingCollector(
        chain: chain,
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      final report = await collector.run(
        sessionBuilder.build(),
        now: baseNow,
      );

      expect(report.processed, 0);
      expect(chain.transfers, isEmpty);
    });

    test('then a missing on-chain subscription fails safely', () async {
      final userId = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000105',
      );
      const externalId = 'solana_collect_missing';
      final end = baseNow.add(const Duration(hours: 2));
      await seed(
        userId: userId,
        externalId: externalId,
        start: end.subtract(const Duration(days: 30)),
        end: end,
      );
      final collector = SolanaBillingCollector(
        chain: FakeSolanaBillingChain(),
        planAddress: planAddress,
        usdcMint: usdcMint,
        clock: () => baseNow,
      );

      final report = await collector.run(
        sessionBuilder.build(),
        now: baseNow,
      );

      expect(report.failed, 1);
      final row = await Entitlement.db.findFirstRow(
        sessionBuilder.build(),
        where: (t) => t.externalId.equals(externalId),
      );
      expect(row?.status, EntitlementStatus.pastDue);
    });
  });
}
