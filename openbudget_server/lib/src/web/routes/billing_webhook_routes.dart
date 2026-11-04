import 'dart:convert';
import 'dart:typed_data';

import 'package:openbudget_server/src/billing/billing_webhook_result.dart';
import 'package:openbudget_server/src/billing/revenuecat_webhook_handler.dart';
import 'package:openbudget_server/src/billing/stripe_webhook_handler.dart';
import 'package:serverpod/serverpod.dart';

/// Thin Relic adapter for [StripeWebhookHandler].
class StripeWebhookRoute extends Route {
  StripeWebhookRoute({StripeWebhookHandler? handler})
    : _handler = handler ?? StripeWebhookHandler(),
      super(methods: {Method.post});

  final StripeWebhookHandler _handler;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final body = utf8.decode(await _readBody(request));
    final result = await _handler.handle(
      session,
      rawBody: body,
      headers: _headers(request),
    );
    return _response(result);
  }
}

/// Thin Relic adapter for the RevenueCat webhook handler.
class RevenueCatWebhookRoute extends Route {
  RevenueCatWebhookRoute({RevenueCatWebhookHandler? handler})
    : _handler = handler ?? RevenueCatWebhookHandler(),
      super(methods: {Method.post});

  final RevenueCatWebhookHandler _handler;

  @override
  Future<Result> handleCall(Session session, Request request) async {
    final body = utf8.decode(await _readBody(request));
    final result = await _handler.handle(
      session,
      rawBody: body,
      headers: _headers(request),
    );
    return _response(result);
  }
}

Future<Uint8List> _readBody(Request request) async {
  final buffered = request.body.bytes;
  if (buffered != null) return buffered;
  final chunks = await request.read().toList();
  return Uint8List.fromList([
    for (final chunk in chunks) ...chunk,
  ]);
}

Map<String, String> _headers(Request request) => {
  for (final entry in request.headers.toMap().entries)
    entry.key.toLowerCase(): entry.value.first,
};

Result _response(BillingWebhookResult result) =>
    Response(result.statusCode, body: Body.fromString(result.body));
