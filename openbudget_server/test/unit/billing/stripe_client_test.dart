import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openbudget_server/src/billing/stripe_client.dart';
import 'package:test/test.dart';

void main() {
  group('Given a Stripe client', () {
    test('then checkout sends only the required fields', () async {
      late http.Request captured;
      final client = StripeClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{"url":"https://checkout.stripe.test/1"}', 200);
        }),
      );

      final url = await client.createCheckoutSession(
        secretKey: 'sk_test',
        priceId: 'price_123',
        userId: '20000000-0000-4000-a000-000000000001',
        successUrl: 'https://openbudget.test/plus/success',
        cancelUrl: 'https://openbudget.test/plus/cancel',
      );

      expect(url, 'https://checkout.stripe.test/1');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/checkout/sessions');
      expect(captured.headers['Authorization'], 'Bearer sk_test');

      final body = Uri.splitQueryString(captured.body);
      expect(body, {
        'mode': 'subscription',
        'line_items[0][price]': 'price_123',
        'line_items[0][quantity]': '1',
        'client_reference_id': '20000000-0000-4000-a000-000000000001',
        'subscription_data[metadata][user_id]':
            '20000000-0000-4000-a000-000000000001',
        'success_url': 'https://openbudget.test/plus/success',
        'cancel_url': 'https://openbudget.test/plus/cancel',
      });
    });

    test('then checkout reuses a stored customer', () async {
      late http.Request captured;
      final client = StripeClient(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response('{"url":"https://checkout.stripe.test/2"}', 200);
        }),
      );

      await client.createCheckoutSession(
        secretKey: 'sk_test',
        priceId: 'price_123',
        userId: '20000000-0000-4000-a000-000000000001',
        successUrl: 'https://openbudget.test/s',
        cancelUrl: 'https://openbudget.test/c',
        customerId: 'cus_123',
      );

      expect(
        Uri.splitQueryString(captured.body)['customer'],
        'cus_123',
      );
    });

    test('then a provider error does not leak the response body', () async {
      final client = StripeClient(
        httpClient: MockClient(
          (_) async => http.Response('secret detail', 500),
        ),
      );

      await expectLater(
        client.createCheckoutSession(
          secretKey: 'sk_test',
          priceId: 'price_123',
          userId: '20000000-0000-4000-a000-000000000001',
          successUrl: 'https://openbudget.test/s',
          cancelUrl: 'https://openbudget.test/c',
        ),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('status 500') &&
                !error.toString().contains('secret detail'),
          ),
        ),
      );
    });
  });
}
