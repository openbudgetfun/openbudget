import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openbudget_server/src/exceptions/exceptions.dart';

/// Minimal Stripe API client for the checkout and billing portal flows.
///
/// Uses raw HTTPS instead of an SDK so the server only depends on the few
/// endpoints it actually calls.
class StripeClient {
  StripeClient({http.Client? httpClient, Uri? apiBaseUri})
    : _httpClient = httpClient ?? http.Client(),
      _apiBaseUri = apiBaseUri ?? Uri.parse('https://api.stripe.com');

  final http.Client _httpClient;
  final Uri _apiBaseUri;

  /// Creates a subscription Checkout session and returns its hosted URL.
  Future<String> createCheckoutSession({
    required String secretKey,
    required String priceId,
    required String userId,
    required String successUrl,
    required String cancelUrl,
    String? customerId,
  }) async {
    final response = await _postForm(
      path: '/v1/checkout/sessions',
      secretKey: secretKey,
      fields: {
        'mode': 'subscription',
        'line_items[0][price]': priceId,
        'line_items[0][quantity]': '1',
        'client_reference_id': userId,
        'subscription_data[metadata][user_id]': userId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
        'customer': ?customerId,
      },
    );
    final url = response['url'];
    if (url is! String || url.isEmpty) {
      throw BillingProviderException('stripe', 'missing checkout url');
    }
    return url;
  }

  /// Creates a billing portal session and returns its hosted URL.
  Future<String> createPortalSession({
    required String secretKey,
    required String customerId,
    required String returnUrl,
  }) async {
    final response = await _postForm(
      path: '/v1/billing_portal/sessions',
      secretKey: secretKey,
      fields: {'customer': customerId, 'return_url': returnUrl},
    );
    final url = response['url'];
    if (url is! String || url.isEmpty) {
      throw BillingProviderException('stripe', 'missing portal url');
    }
    return url;
  }

  Future<Map<String, Object?>> _postForm({
    required String path,
    required String secretKey,
    required Map<String, String> fields,
  }) async {
    final response = await _httpClient.post(
      _apiBaseUri.resolve(path),
      headers: {
        'Authorization': 'Bearer $secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: fields,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BillingProviderException(
        'stripe',
        'status ${response.statusCode}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw BillingProviderException('stripe', 'invalid response');
    }
    return decoded;
  }
}
