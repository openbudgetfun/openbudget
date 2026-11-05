import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/billing_json.dart';
import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/billing_webhook_result.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/stripe_signature.dart';
import 'package:openbudget_server/src/billing/stripe_subscription_parser.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Handles Stripe webhooks without needing a running HTTP server.
class StripeWebhookHandler {
  StripeWebhookHandler({
    this.webhookSecret,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static final _log = ObLogger('StripeWebhookHandler');

  final String? webhookSecret;
  final DateTime Function() _clock;

  /// Verifies and processes one webhook delivery.
  Future<BillingWebhookResult> handle(
    Session session, {
    required String rawBody,
    Map<String, String> headers = const {},
  }) async {
    final secret =
        webhookSecret ??
        BillingSecrets.read(session, BillingSecretKeys.stripeWebhookSecret);
    if (secret == null) {
      return const BillingWebhookResult(503, 'stripe webhook unavailable');
    }

    final signature = _header(headers, 'stripe-signature');
    if (signature == null ||
        !verifyStripeSignature(
          payload: rawBody,
          signatureHeader: signature,
          secret: secret,
          now: _clock(),
        )) {
      return const BillingWebhookResult(400, 'invalid signature');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return const BillingWebhookResult(400, 'invalid payload');
    }
    final event = asJsonMap(decoded);
    final type = asJsonString(event?['type']);
    final data = asJsonMap(event?['data']);
    final object = asJsonMap(data?['object']);
    if (type == null || object == null) {
      return const BillingWebhookResult(400, 'invalid payload');
    }

    try {
      switch (type) {
        case 'checkout.session.completed':
          await _handleCheckoutSession(session, object);
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
        case 'customer.subscription.deleted':
          await _handleSubscription(session, object);
        default:
          break;
      }
    } on ValidationException catch (error) {
      _log.warning('Ignoring invalid Stripe event $type: ${error.message}');
    }
    return const BillingWebhookResult(200);
  }

  Future<void> _handleCheckoutSession(
    Session session,
    Map<String, Object?> checkout,
  ) async {
    final userIdValue = asJsonString(checkout['client_reference_id']);
    final customerId = asJsonString(checkout['customer']);
    if (!isUuid(userIdValue) || customerId == null) {
      _log.warning('Stripe checkout session missing user or customer');
      return;
    }
    final userId = UuidValue.fromString(userIdValue!);
    final byUser = await StripeCustomer.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    if (byUser != null) {
      if (byUser.customerId != customerId) {
        await StripeCustomer.db.updateRow(
          session,
          byUser.copyWith(customerId: customerId),
        );
      }
      return;
    }

    final byCustomer = await StripeCustomer.db.findFirstRow(
      session,
      where: (t) => t.customerId.equals(customerId),
    );
    if (byCustomer != null) {
      _log.warning('Stripe customer is already linked to another user');
      return;
    }

    await StripeCustomer.db.insertRow(
      session,
      StripeCustomer(
        userId: userId,
        customerId: customerId,
        createdAt: _clock().toUtc(),
      ),
    );
  }

  Future<void> _handleSubscription(
    Session session,
    Map<String, Object?> subscription,
  ) async {
    final update = StripeSubscriptionParser.parse(
      subscription,
      now: _clock(),
    );
    if (update == null) {
      _log.warning('Skipping Stripe subscription without usable terms');
      return;
    }
    await EntitlementService.record(
      session,
      userId: update.userId,
      source: update.source,
      externalId: update.externalId,
      status: update.status,
      currentPeriodStart: update.currentPeriodStart,
      currentPeriodEnd: update.currentPeriodEnd,
    );
  }

  static String? _header(Map<String, String> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value;
    }
    return null;
  }
}
