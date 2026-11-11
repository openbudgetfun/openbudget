import 'dart:convert';

import 'package:cryptography/cryptography.dart' as crypto;
import 'package:openbudget_server/src/generated/protocol.dart';

/// An AES-GCM ciphertext and the nonce that produced it, both base64.
class SealedSecret {
  const SealedSecret({required this.cipherText, required this.nonce});

  final String cipherText;
  final String nonce;
}

/// Encrypts server-held secrets at rest: provider API keys, Plaid access
/// tokens.
///
/// AES-256-GCM authenticates the ciphertext as well as hiding it, so a
/// tampered row fails to decrypt instead of yielding a wrong secret. A
/// service that stores both fields must always write [SealedSecret.cipherText]
/// and [SealedSecret.nonce] together.
abstract final class SecretBox {
  static final crypto.AesGcm _algorithm = crypto.AesGcm.with256bits();

  /// Encrypts [plaintext] with the base64 [base64Key].
  ///
  /// The ciphertext carries the GCM tag; the nonce is stored beside it because
  /// a nonce must never be reused with the same key.
  static Future<SealedSecret> seal({
    required String plaintext,
    required String base64Key,
  }) async {
    final key = _keyFor(base64Key);
    final nonce = _algorithm.newNonce();
    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: key,
      nonce: nonce,
    );
    return SealedSecret(
      cipherText: base64Encode([
        ...secretBox.cipherText,
        ...secretBox.mac.bytes,
      ]),
      nonce: base64Encode(secretBox.nonce),
    );
  }

  /// Decrypts a sealed secret, throwing when the key or data is wrong.
  static Future<String> open({
    required String cipherText,
    required String nonce,
    required String base64Key,
  }) async {
    final key = _keyFor(base64Key);
    final Object? cipherBytes;
    final Object? nonceBytes;
    try {
      cipherBytes = base64Decode(cipherText);
      nonceBytes = base64Decode(nonce);
    } on FormatException {
      throw ValidationException(
        message: 'The stored secret is not valid base64.',
      );
    }
    if (cipherBytes is! List<int> || nonceBytes is! List<int>) {
      throw ValidationException(message: 'The stored secret is unreadable.');
    }

    final tagLength = _algorithm.macAlgorithm.macLength;
    if (cipherBytes.length <= tagLength) {
      throw ValidationException(message: 'The stored secret is too short.');
    }
    final split = cipherBytes.length - tagLength;
    final secretBox = crypto.SecretBox(
      cipherBytes.sublist(0, split),
      nonce: nonceBytes,
      mac: crypto.Mac(cipherBytes.sublist(split)),
    );

    try {
      final clearBytes = await _algorithm.decrypt(secretBox, secretKey: key);
      return utf8.decode(clearBytes);
    } on crypto.SecretBoxAuthenticationError {
      throw ValidationException(
        message: 'The stored secret could not be decrypted.',
      );
    } on FormatException {
      throw ValidationException(message: 'The stored secret is not text.');
    }
  }

  static crypto.SecretKey _keyFor(String base64Key) {
    final Object? decoded;
    try {
      decoded = base64Decode(base64Key.trim());
    } on FormatException {
      throw ValidationException(
        message: 'The secret encryption key must be base64.',
      );
    }
    if (decoded is! List<int> || decoded.length != 32) {
      throw ValidationException(
        message: 'The secret encryption key must decode to 32 bytes.',
      );
    }
    return crypto.SecretKey(decoded);
  }
}
