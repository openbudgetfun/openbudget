import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:openbudget_server/src/tax/export/tax_export_token.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  const secret = 'test-service-secret';
  final key = TaxExportSigningKey.derive(secret);
  final userId = const Uuid().v7obj();
  final entityId = const Uuid().v7obj();
  final expiry = DateTime.utc(2026, 11, 13, 12, 10);

  TaxExportTokenPayload payload({UuidValue? entity, int year = 2026}) =>
      TaxExportTokenPayload(
        userId: userId,
        entityId: entity ?? entityId,
        startYear: year,
        expiresAt: expiry,
      );

  /// Decodes the token's payload part back to its wire bytes.
  Uint8List payloadBytes(String token) => Uint8List.fromList(
    base64Url.decode(base64Url.normalize(token.split('.').first)),
  );

  /// Re-encodes wire bytes as the token's payload part, unpadded.
  String payloadPart(Uint8List bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');

  group('TaxExportSigningKey', () {
    test('then the key is an HMAC over the fixed export context', () {
      // Recomputing the derivation by hand pins the scheme: the same
      // secret and context always give the same 32-byte key.
      final expected = Hmac(
        sha256,
        utf8.encode(secret),
      ).convert(utf8.encode(taxExportKeyContext)).bytes;
      expect(key, expected);
      expect(key, hasLength(32));
    });

    test('then another secret or another purpose derives a different key', () {
      expect(
        TaxExportSigningKey.derive('another-secret'),
        isNot(key),
      );
      expect(
        // Deriving with the raw secret as its own context must not give
        // the export key, or the key derivation would be an identity.
        Hmac(sha256, utf8.encode(secret)).convert(utf8.encode(secret)).bytes,
        isNot(key),
      );
    });
  });

  group('TaxExportToken', () {
    test('then a minted token verifies to the same payload', () {
      final token = TaxExportToken.mint(
        signingKey: key,
        payload: payload(),
      );

      final verified = TaxExportToken.verify(
        token: token,
        signingKey: key,
        now: expiry.subtract(const Duration(minutes: 1)),
      );

      expect(verified, payload());
      expect(verified!.userId, userId);
      expect(verified.entityId, entityId);
      expect(verified.startYear, 2026);
      expect(verified.expiresAt, expiry);
    });

    test('then the link lives for exactly ten minutes', () {
      expect(taxExportLinkTtl, const Duration(minutes: 10));
    });

    test('then the token is valid at the expiry instant and dead after', () {
      final token = TaxExportToken.mint(
        signingKey: key,
        payload: payload(),
      );

      expect(
        TaxExportToken.verify(token: token, signingKey: key, now: expiry),
        isNotNull,
        reason: 'the expiry is inclusive',
      );
      expect(
        TaxExportToken.verify(
          token: token,
          signingKey: key,
          now: expiry.add(const Duration(milliseconds: 1)),
        ),
        isNull,
      );
    });

    test('then a token signed with another key is rejected', () {
      final token = TaxExportToken.mint(
        signingKey: key,
        payload: payload(),
      );

      expect(
        TaxExportToken.verify(
          token: token,
          signingKey: TaxExportSigningKey.derive('another-secret'),
          now: DateTime.utc(2026, 11, 13, 12),
        ),
        isNull,
      );
    });

    test('then a tampered user id, entity id, year or expiry is rejected', () {
      final token = TaxExportToken.mint(
        signingKey: key,
        payload: payload(),
      );
      final parts = token.split('.');
      final bytes = payloadBytes(token);

      void expectRejected(Uint8List mutated) {
        final forged = '${payloadPart(mutated)}.${parts.last}';
        expect(
          TaxExportToken.verify(token: forged, signingKey: key, now: expiry),
          isNull,
        );
      }

      // Every field the HMAC covers is bound: flipping the bytes without
      // re-signing must fail the signature check.
      final yearMutated = Uint8List.fromList(bytes)..[32] = bytes[32] ^ 0x01;
      final expiryMutated = Uint8List.fromList(bytes)..[43] = bytes[43] ^ 0x01;
      final entityMutated = Uint8List.fromList(bytes)..[16] = bytes[16] ^ 0xff;
      final userMutated = Uint8List.fromList(bytes)..[0] = bytes[0] ^ 0xff;

      expectRejected(yearMutated);
      expectRejected(expiryMutated);
      expectRejected(entityMutated);
      expectRejected(userMutated);
    });

    test('then malformed tokens are rejected without throwing', () {
      for (final token in ['', 'abc', 'a.b.c', '....', 'x.y', r'$$$.###']) {
        expect(
          TaxExportToken.verify(token: token, signingKey: key, now: expiry),
          isNull,
          reason: 'token "$token" must be rejected',
        );
      }
    });

    test('then the token carries nothing but ids, a year and an expiry', () {
      final token = TaxExportToken.mint(
        signingKey: key,
        payload: payload(),
      );

      // Two base64url parts and nothing else: no dot-separated email or
      // name can hide in the token, and the payload is exactly the 44
      // wire bytes.
      final parts = token.split('.');
      expect(parts, hasLength(2));
      expect(token, matches(RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$')));
      expect(payloadBytes(token), hasLength(44));
      expect(token, isNot(contains('@')));
    });
  });
}
