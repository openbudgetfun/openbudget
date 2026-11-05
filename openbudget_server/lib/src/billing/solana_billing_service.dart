import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/solana_billing_chain.dart';
import 'package:openbudget_server/src/billing/solana_billing_plan.dart';
import 'package:openbudget_server/src/billing/solana_rpc_billing_chain.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_subscriptions/solana_kit_subscriptions.dart';

/// Issues and verifies Solana wallet ownership challenges, then records the
/// subscription once the delegation exists on chain.
class SolanaBillingService {
  SolanaBillingService({
    required this.chain,
    required this.planAddress,
    required this.usdcMint,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _plan = _parseAddress(planAddress, 'plan');
    _parseAddress(usdcMint, 'mint');
  }

  factory SolanaBillingService.fromSession(
    Session session, {
    SolanaBillingChain? chain,
  }) {
    final planAddress = BillingSecrets.require(
      session,
      BillingSecretKeys.solanaSubscriptionPlanAddress,
    );
    final usdcMint = BillingSecrets.require(
      session,
      BillingSecretKeys.solanaUsdcMint,
    );
    return SolanaBillingService(
      chain: chain ?? SolanaRpcBillingChain.fromSession(session),
      planAddress: planAddress,
      usdcMint: usdcMint,
    );
  }

  static const _challengeLifetime = Duration(minutes: 10);

  final SolanaBillingChain chain;
  final String planAddress;
  final String usdcMint;
  final DateTime Function() _clock;
  late final Address _plan;

  /// Returns the plan terms the app needs to build a subscribe transaction.
  static SolanaPlanView planView(Session session) {
    final planAddress = _parseAddress(
      BillingSecrets.require(
        session,
        BillingSecretKeys.solanaSubscriptionPlanAddress,
      ),
      'plan',
    );
    final usdcMint = _parseAddress(
      BillingSecrets.require(session, BillingSecretKeys.solanaUsdcMint),
      'mint',
    );
    return SolanaPlanView(
      planAddress: planAddress.value,
      programAddress: subscriptionsProgramAddress.value,
      usdcMint: usdcMint.value,
      amountBaseUnits: SolanaBillingPlan.amountBaseUnits,
      periodSeconds: SolanaBillingPlan.periodSeconds,
    );
  }

  /// Creates a one-time message the subscriber signs to prove wallet
  /// ownership.
  Future<String> createChallenge(Session session, UuidValue userId) async {
    final now = _clock().toUtc();
    final message =
        'OpenBudget Plus subscription ${_randomNonce()} '
        '${now.toIso8601String()}';
    await SolanaBillingChallenge.db.insertRow(
      session,
      SolanaBillingChallenge(
        userId: userId,
        message: message,
        expiresAt: now.add(_challengeLifetime),
        createdAt: now,
      ),
    );
    return message;
  }

  /// Verifies the challenge and on-chain subscription, then records the
  /// entitlement.
  Future<Entitlement> confirmSubscription(
    Session session, {
    required UuidValue userId,
    required String subscriberAddress,
    required String message,
    required String signatureBase58,
  }) async {
    final now = _clock().toUtc();
    final subscriber = _parseAddress(subscriberAddress, 'subscriber');

    final challenge = await SolanaBillingChallenge.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId) & t.message.equals(message),
    );
    if (challenge == null) {
      throw NotFoundException(message: 'Subscription challenge not found');
    }
    if (challenge.usedAt != null) {
      throw ValidationException(
        message: 'Subscription challenge was already used',
      );
    }
    if (!challenge.expiresAt.isAfter(now)) {
      throw ValidationException(message: 'Subscription challenge expired');
    }
    if (!_verifyOwnership(subscriber, message, signatureBase58)) {
      throw ValidationException(message: 'Invalid wallet signature');
    }

    final (subscriptionPda, _) = await findSubscriptionDelegationPda(
      programAddress: subscriptionsProgramAddress,
      seeds: SubscriptionDelegationSeeds(
        planPda: _plan,
        subscriber: subscriber,
      ),
    );
    final snapshot = await chain.fetchSubscription(subscriptionPda.value);
    _requireMatchingSubscription(
      snapshot,
      subscriptionAddress: subscriptionPda.value,
      subscriberAddress: subscriber.value,
    );

    // Subscribing only creates the delegation; nothing has been paid yet.
    // Collect the first period now, unless an earlier confirmation of the
    // same delegation already did and its period is still running.
    final existing = await EntitlementService.activeFor(
      session,
      userId,
      now: now,
    );
    if (existing != null &&
        existing.source == EntitlementSource.solana &&
        existing.externalId == subscriptionPda.value) {
      await _markChallengeUsed(session, challenge, now);
      return existing;
    }
    try {
      await chain.transferSubscription(
        subscriptionAddress: subscriptionPda.value,
        planAddress: planAddress,
        subscriberAddress: subscriber.value,
        mintAddress: usdcMint,
        amountBaseUnits: SolanaBillingPlan.amountBaseUnits,
      );
    } on Exception catch (error) {
      throw BillingProviderException(
        provider: 'solana',
        details: 'first payment: ${error.runtimeType}',
      );
    }

    final entitlement = await EntitlementService.record(
      session,
      userId: userId,
      source: EntitlementSource.solana,
      externalId: subscriptionPda.value,
      status: EntitlementStatus.active,
      currentPeriodStart: now,
      currentPeriodEnd: now.add(
        const Duration(seconds: SolanaBillingPlan.periodSeconds),
      ),
    );
    await _markChallengeUsed(session, challenge, now);
    return entitlement;
  }

  Future<void> _markChallengeUsed(
    Session session,
    SolanaBillingChallenge challenge,
    DateTime now,
  ) => SolanaBillingChallenge.db.updateRow(
    session,
    challenge.copyWith(usedAt: now),
  );

  void _requireMatchingSubscription(
    SolanaSubscriptionSnapshot? snapshot, {
    required String subscriptionAddress,
    required String subscriberAddress,
  }) {
    if (snapshot == null) {
      throw ValidationException(
        message: 'Subscription account not found on chain',
      );
    }
    final matches =
        snapshot.subscriptionAddress == subscriptionAddress &&
        snapshot.planAddress == planAddress &&
        snapshot.subscriberAddress == subscriberAddress &&
        snapshot.planActive &&
        snapshot.subscriptionActive &&
        snapshot.amountBaseUnits == SolanaBillingPlan.amountBaseUnits &&
        snapshot.periodSeconds == SolanaBillingPlan.periodSeconds;
    if (!matches) {
      throw ValidationException(
        message: 'Subscription does not match the plan terms',
      );
    }
  }

  bool _verifyOwnership(
    Address subscriber,
    String message,
    String signatureBase58,
  ) {
    final Uint8List signatureBytes;
    try {
      signatureBytes = getBase58Encoder().encode(signatureBase58);
    } on Object {
      return false;
    }
    if (signatureBytes.length != 64) return false;
    return verifySignature(
      getPublicKeyFromAddress(subscriber),
      SignatureBytes(signatureBytes),
      Uint8List.fromList(utf8.encode(message)),
    );
  }

  static Address _parseAddress(String value, String label) {
    try {
      return address(value);
    } on Object {
      throw BillingRailUnavailableException(
        message: 'Invalid Solana $label address',
      );
    }
  }

  static String _randomNonce() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}
