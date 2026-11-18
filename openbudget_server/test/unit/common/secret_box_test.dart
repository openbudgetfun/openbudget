import 'dart:convert';

import 'package:openbudget_server/src/common/secret_box.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  final key = base64Encode(utf8.encode('0123456789abcdef0123456789abcdef'));

  group('Given SecretBox', () {
    test('then a sealed secret opens with the same key', () async {
      final sealed = await SecretBox.seal(
        plaintext: 'sk-live-secret',
        base64Key: key,
      );

      expect(sealed.cipherText, isNot(contains('sk-live')));
      expect(
        await SecretBox.open(
          cipherText: sealed.cipherText,
          nonce: sealed.nonce,
          base64Key: key,
        ),
        'sk-live-secret',
      );
    });

    test('then two seals of the same plaintext differ', () async {
      final first = await SecretBox.seal(
        plaintext: 'sk-live-secret',
        base64Key: key,
      );
      final second = await SecretBox.seal(
        plaintext: 'sk-live-secret',
        base64Key: key,
      );

      expect(first.nonce, isNot(second.nonce));
      expect(first.cipherText, isNot(second.cipherText));
    });

    test('then another key cannot open the secret', () async {
      final sealed = await SecretBox.seal(
        plaintext: 'sk-live-secret',
        base64Key: key,
      );
      final otherKey = base64Encode(
        utf8.encode('abcdef0123456789abcdef0123456789'),
      );

      await expectLater(
        SecretBox.open(
          cipherText: sealed.cipherText,
          nonce: sealed.nonce,
          base64Key: otherKey,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a wrong-length key is rejected', () async {
      await expectLater(
        SecretBox.seal(
          plaintext: 'sk-live-secret',
          base64Key: base64Encode(utf8.encode('too-short')),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
