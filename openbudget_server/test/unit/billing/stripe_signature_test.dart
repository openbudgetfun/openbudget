import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:openbudget_server/src/billing/stripe_signature.dart';
import 'package:test/test.dart';

void main() {
  const secret = 'whsec_test_secret';
  final now = DateTime.utc(2026, 11, 4, 12);

  String headerFor(
    String payload, {
    String signingSecret = secret,
    DateTime? timestamp,
    List<String> extraSignatures = const [],
  }) {
    final seconds = (timestamp ?? now).millisecondsSinceEpoch ~/ 1000;
    final digest = Hmac(
      sha256,
      utf8.encode(signingSecret),
    ).convert(utf8.encode('$seconds.$payload'));
    return [
      't=$seconds',
      for (final signature in extraSignatures) 'v1=$signature',
      'v1=$digest',
    ].join(',');
  }

  group('Given a Stripe signature header', () {
    test('then a correctly signed payload is accepted', () {
      const payload = '{"id":"evt_1"}';

      expect(
        verifyStripeSignature(
          payload: payload,
          signatureHeader: headerFor(payload),
          secret: secret,
          now: now,
        ),
        isTrue,
      );
    });

    test('then a signature from another secret is rejected', () {
      const payload = '{"id":"evt_1"}';

      expect(
        verifyStripeSignature(
          payload: payload,
          signatureHeader: headerFor(payload, signingSecret: 'other'),
          secret: secret,
          now: now,
        ),
        isFalse,
      );
    });

    test('then a timestamp older than five minutes is rejected', () {
      const payload = '{"id":"evt_1"}';

      expect(
        verifyStripeSignature(
          payload: payload,
          signatureHeader: headerFor(
            payload,
            timestamp: now.subtract(const Duration(minutes: 6)),
          ),
          secret: secret,
          now: now,
        ),
        isFalse,
      );
    });

    test('then a timestamp in the future is rejected', () {
      const payload = '{"id":"evt_1"}';

      expect(
        verifyStripeSignature(
          payload: payload,
          signatureHeader: headerFor(
            payload,
            timestamp: now.add(const Duration(minutes: 6)),
          ),
          secret: secret,
          now: now,
        ),
        isFalse,
      );
    });

    test('then any matching v1 entry is accepted', () {
      const payload = '{"id":"evt_1"}';
      final correct = headerFor(payload).split('v1=').last;

      expect(
        verifyStripeSignature(
          payload: payload,
          signatureHeader: headerFor(
            payload,
            extraSignatures: ['deadbeef', correct],
          ),
          secret: secret,
          now: now,
        ),
        isTrue,
      );
    });

    test('then a tampered payload is rejected', () {
      final header = headerFor('{"id":"evt_1"}');

      expect(
        verifyStripeSignature(
          payload: '{"id":"evt_2"}',
          signatureHeader: header,
          secret: secret,
          now: now,
        ),
        isFalse,
      );
    });

    test('then a header without v1 entries is rejected', () {
      expect(
        verifyStripeSignature(
          payload: '{}',
          signatureHeader: 't=1234',
          secret: secret,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('Given constant-time string comparison', () {
    test('then equal values match', () {
      expect(constantTimeStringEquals('abc', 'abc'), isTrue);
    });

    test('then different values do not match', () {
      expect(constantTimeStringEquals('abc', 'abd'), isFalse);
      expect(constantTimeStringEquals('abc', 'ab'), isFalse);
    });
  });
}
