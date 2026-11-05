import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/billing_json.dart';
import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/billing_webhook_result.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/revenuecat_event_parser.dart';
import 'package:openbudget_server/src/billing/stripe_signature.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:serverpod/serverpod.dart';

/// Handles RevenueCat webhooks without needing a running HTTP server.
class RevenueCatWebhookHandler {
  RevenueCatWebhookHandler({this.authorization});

  static final _log = ObLogger('RevenueCatWebhookHandler');

  final String? authorization;

  /// Verifies and processes one webhook delivery.
  Future<BillingWebhookResult> handle(
    Session session, {
    required String rawBody,
    Map<String, String> headers = const {},
  }) async {
    final expected =
        authorization ??
        BillingSecrets.read(
          session,
          BillingSecretKeys.revenueCatWebhookAuthorization,
        );
    if (expected == null) {
      return const BillingWebhookResult(503, 'revenuecat webhook unavailable');
    }

    final provided = _header(headers, 'authorization');
    if (provided == null || !constantTimeStringEquals(provided, expected)) {
      return const BillingWebhookResult(401, 'invalid authorization');
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(rawBody);
    } on FormatException {
      return const BillingWebhookResult(400, 'invalid payload');
    }
    final body = asJsonMap(decoded);
    final event = asJsonMap(body?['event']);
    if (event == null) {
      return const BillingWebhookResult(400, 'invalid payload');
    }

    final type = asJsonString(event['type']);
    if (type == null) {
      return const BillingWebhookResult(400, 'invalid payload');
    }

    final update = RevenueCatEventParser.parse(event);
    if (update == null) {
      _log.warning('Skipping RevenueCat event $type');
      return const BillingWebhookResult(200);
    }

    try {
      await EntitlementService.record(
        session,
        userId: update.userId,
        source: update.source,
        externalId: update.externalId,
        status: update.status,
        currentPeriodStart: update.currentPeriodStart,
        currentPeriodEnd: update.currentPeriodEnd,
      );
    } on ValidationException catch (error) {
      _log.warning('Ignoring invalid RevenueCat event $type: ${error.message}');
    }
    return const BillingWebhookResult(200);
  }

  static String? _header(Map<String, String> headers, String name) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == name) return entry.value;
    }
    return null;
  }
}
