import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The maximum accepted age of a Stripe webhook signature timestamp.
const Duration stripeSignatureTolerance = Duration(seconds: 300);

/// Verifies a Stripe `Stripe-Signature` header.
///
/// Stripe sends `t=<unix seconds>,v1=<hex digest>` and may include several
/// `v1` entries while a signing secret is being rotated. The digest is
/// HMAC-SHA256 over `<t>.<raw body>`.
bool verifyStripeSignature({
  required String payload,
  required String signatureHeader,
  required String secret,
  DateTime? now,
  Duration tolerance = stripeSignatureTolerance,
}) {
  if (secret.isEmpty) return false;

  int? timestamp;
  final candidates = <List<int>>[];
  for (final part in signatureHeader.split(',')) {
    final trimmed = part.trim();
    final separator = trimmed.indexOf('=');
    if (separator <= 0) continue;
    final key = trimmed.substring(0, separator).trim();
    final value = trimmed.substring(separator + 1).trim();
    if (key == 't') {
      timestamp ??= int.tryParse(value);
    } else if (key == 'v1') {
      final bytes = _decodeHex(value);
      if (bytes != null) candidates.add(bytes);
    }
  }

  if (timestamp == null || candidates.isEmpty) return false;

  final currentSeconds =
      (now ?? DateTime.now()).toUtc().millisecondsSinceEpoch ~/ 1000;
  if ((currentSeconds - timestamp).abs() > tolerance.inSeconds) return false;

  final digest = Hmac(
    sha256,
    utf8.encode(secret),
  ).convert(utf8.encode('$timestamp.$payload')).bytes;

  var matched = false;
  for (final candidate in candidates) {
    if (_constantTimeEquals(candidate, digest)) matched = true;
  }
  return matched;
}

bool _constantTimeEquals(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  var difference = 0;
  for (var index = 0; index < left.length; index++) {
    difference |= left[index] ^ right[index];
  }
  return difference == 0;
}

List<int>? _decodeHex(String value) {
  if (value.isEmpty || value.length.isOdd) return null;
  final bytes = <int>[];
  for (var index = 0; index < value.length; index += 2) {
    final byte = int.tryParse(value.substring(index, index + 2), radix: 16);
    if (byte == null) return null;
    bytes.add(byte);
  }
  return bytes;
}

/// Compares two strings without leaking their contents through timing.
bool constantTimeStringEquals(String left, String right) {
  final leftBytes = utf8.encode(left);
  final rightBytes = utf8.encode(right);
  return _constantTimeEquals(leftBytes, rightBytes);
}
