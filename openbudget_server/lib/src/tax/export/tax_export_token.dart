import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

/// How long a signed download link stays valid.
///
/// The app opens the link straight away; ten minutes covers a slow handoff
/// to the system browser without leaving a reusable URL behind.
const taxExportLinkTtl = Duration(minutes: 10);

/// The domain string the export signing key is derived from.
///
/// Deriving from Serverpod's existing service secret through this fixed
/// context keeps the export out of the secret store: no new owner secret,
/// and a token can never be reused for another purpose of the same key.
const taxExportKeyContext = 'openbudget.tax-export.v1';

/// Derives the HMAC key the export links are signed with.
abstract final class TaxExportSigningKey {
  /// HMAC-SHA256 of [taxExportKeyContext] under [serviceSecret].
  ///
  /// [serviceSecret] comes from the server's own password store; a missing
  /// secret is a configuration failure the caller must report, never a
  /// reason to sign with a fallback.
  static Uint8List derive(String serviceSecret) {
    final hmac = Hmac(
      sha256,
      utf8.encode(serviceSecret),
    );
    return Uint8List.fromList(
      hmac.convert(utf8.encode(taxExportKeyContext)).bytes,
    );
  }
}

/// What a signed export link carries: opaque ids, a year and an expiry.
///
/// No name, email or entity name ever enters the token. The payload is
/// signed, not encrypted: anyone holding the link can decode the two UUIDs,
/// which are opaque ids with no personal data in them.
@immutable
final class TaxExportTokenPayload {
  const TaxExportTokenPayload({
    required this.userId,
    required this.entityId,
    required this.startYear,
    required this.expiresAt,
  });

  final UuidValue userId;
  final UuidValue entityId;
  final int startYear;

  /// When the link stops working, inclusive.
  final DateTime expiresAt;

  /// Wire bytes: 16 id bytes, 16 entity bytes, a 4-byte year and an 8-byte
  /// expiry in epoch milliseconds, all big-endian.
  Uint8List _encode() {
    final bytes = Uint8List(44);
    final data = ByteData.sublistView(bytes);
    bytes
      ..setRange(0, 16, userId.toBytes())
      ..setRange(16, 32, entityId.toBytes());
    data
      ..setInt32(32, startYear)
      ..setInt64(36, expiresAt.millisecondsSinceEpoch);
    return bytes;
  }

  static TaxExportTokenPayload? _decode(Uint8List bytes) {
    if (bytes.length != 44) return null;
    final data = ByteData.sublistView(bytes);
    return TaxExportTokenPayload(
      userId: UuidValue.fromByteList(Uint8List.sublistView(bytes, 0, 16)),
      entityId: UuidValue.fromByteList(Uint8List.sublistView(bytes, 16, 32)),
      startYear: data.getInt32(32),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        data.getInt64(36),
        isUtc: true,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TaxExportTokenPayload &&
      other.userId == userId &&
      other.entityId == entityId &&
      other.startYear == startYear &&
      other.expiresAt == expiresAt;

  @override
  int get hashCode => Object.hash(userId, entityId, startYear, expiresAt);
}

/// Mints and verifies the signed tokens behind export download links.
///
/// A token is `<payload>.<signature>` with both parts base64url without
/// padding: the payload encodes the ids, year and expiry, and the
/// signature is HMAC-SHA256 over those bytes. Verification compares the
/// signatures in constant time and rejects anything about the shape it
/// cannot parse.
abstract final class TaxExportToken {
  /// Signs [payload] into one URL-safe token.
  static String mint({
    required Uint8List signingKey,
    required TaxExportTokenPayload payload,
  }) {
    final bytes = payload._encode();
    final signature = _sign(signingKey, bytes);
    return '${_encodePart(bytes)}.${_encodePart(signature)}';
  }

  /// Verifies [token] and returns its payload, or null for anything
  /// malformed, wrongly signed or expired at [now].
  ///
  /// Null is the only answer a caller gets for a bad token: no reason is
  /// distinguished here, so a download route can answer every rejection
  /// the same way without leaking which check failed.
  static TaxExportTokenPayload? verify({
    required String token,
    required Uint8List signingKey,
    required DateTime now,
  }) {
    final parts = token.split('.');
    if (parts.length != 2) return null;
    final bytes = _decodePart(parts[0]);
    final signature = _decodePart(parts[1]);
    if (bytes == null || signature == null) return null;
    if (!_signatureMatches(signingKey, bytes, signature)) return null;

    final payload = TaxExportTokenPayload._decode(bytes);
    if (payload == null) return null;
    if (now.isAfter(payload.expiresAt)) return null;
    return payload;
  }

  static Uint8List _sign(Uint8List key, Uint8List message) =>
      Uint8List.fromList(Hmac(sha256, key).convert(message).bytes);

  /// Compares the expected and given MACs over every byte of the fixed
  /// 32-byte digest, so the first differing byte does not short-circuit.
  ///
  /// A length mismatch rejects immediately: the digest length is public
  /// and carries nothing about the secret or the payload.
  static bool _signatureMatches(
    Uint8List key,
    Uint8List message,
    Uint8List given,
  ) {
    final expected = _sign(key, message);
    if (expected.length != given.length) return false;
    var diff = 0;
    for (var index = 0; index < expected.length; index++) {
      diff |= expected[index] ^ given[index];
    }
    return diff == 0;
  }

  static String _encodePart(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  static Uint8List? _decodePart(String part) {
    try {
      // Restore the padding the URL-safe form dropped; normalize also
      // rejects anything the alphabet does not carry.
      return base64Url.decode(base64Url.normalize(part));
    } on FormatException {
      return null;
    }
  }
}
