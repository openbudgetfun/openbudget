import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// An AES-GCM ciphertext and the nonce that produced it, both base64.
class AgentSealedSecret {
  const AgentSealedSecret({required this.cipherText, required this.nonce});

  final String cipherText;
  final String nonce;
}

/// Encrypts provider API keys at rest.
///
/// AES-256-GCM authenticates the ciphertext as well as hiding it, so a
/// tampered row fails to decrypt instead of yielding a wrong key.
abstract final class AgentSecretBox {
  static final AesGcm _algorithm = AesGcm.with256bits();

  /// Encrypts [plaintext] with the base64 [base64Key].
  ///
  /// The ciphertext carries the GCM tag; the nonce is stored beside it because
  /// a nonce must never be reused with the same key.
  static Future<AgentSealedSecret> seal({
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
    return AgentSealedSecret(
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
      throw AgentProviderUnavailableException(
        message: 'The stored agent provider key is not valid base64.',
      );
    }
    if (cipherBytes is! List<int> || nonceBytes is! List<int>) {
      throw AgentProviderUnavailableException(
        message: 'The stored agent provider key is unreadable.',
      );
    }

    final tagLength = _algorithm.macAlgorithm.macLength;
    if (cipherBytes.length <= tagLength) {
      throw AgentProviderUnavailableException(
        message: 'The stored agent provider key is too short.',
      );
    }
    final split = cipherBytes.length - tagLength;
    final secretBox = SecretBox(
      cipherBytes.sublist(0, split),
      nonce: nonceBytes,
      mac: Mac(cipherBytes.sublist(split)),
    );

    try {
      final clearBytes = await _algorithm.decrypt(secretBox, secretKey: key);
      return utf8.decode(clearBytes);
    } on SecretBoxAuthenticationError {
      throw AgentProviderUnavailableException(
        message: 'The stored agent provider key could not be decrypted.',
      );
    } on FormatException {
      throw AgentProviderUnavailableException(
        message: 'The stored agent provider key is not valid text.',
      );
    }
  }

  static SecretKey _keyFor(String base64Key) {
    final Object? decoded;
    try {
      decoded = base64Decode(base64Key.trim());
    } on FormatException {
      throw AgentProviderUnavailableException(
        message: 'agentKeyEncryptionKey must be base64.',
      );
    }
    if (decoded is! List<int> || decoded.length != 32) {
      throw AgentProviderUnavailableException(
        message: 'agentKeyEncryptionKey must decode to 32 bytes.',
      );
    }
    return SecretKey(decoded);
  }
}
