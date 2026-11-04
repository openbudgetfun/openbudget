/// The HTTP outcome a webhook handler returns to its thin route adapter.
class BillingWebhookResult {
  const BillingWebhookResult(this.statusCode, [this.body = 'ok']);

  final int statusCode;
  final String body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
