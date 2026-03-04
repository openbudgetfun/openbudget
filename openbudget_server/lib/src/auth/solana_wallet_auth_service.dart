import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:solana_kit/solana_kit.dart' as solana;

const _walletAuthMethod = 'solana_wallet';
const _challengeLifetime = Duration(minutes: 5);

class SolanaWalletAuthService {
  static final _log = ObLogger('SolanaWalletAuthService');

  static Future<SolanaWalletAuthChallengeResponse> createChallenge(
    Session session, {
    required String publicKeyBase64,
  }) async {
    final normalizedPublicKey = publicKeyBase64.trim();
    final publicKeyBytes = _decodePublicKey(normalizedPublicKey);
    if (publicKeyBytes.length != 32) {
      throw ValidationException('Invalid Solana public key.');
    }

    final now = DateTime.now().toUtc();
    final expiresAt = now.add(_challengeLifetime);
    final message = _buildChallengeMessage(now);

    final challenge = await SolanaWalletAuthChallenge.db.insertRow(
      session,
      SolanaWalletAuthChallenge(
        publicKeyBase64: normalizedPublicKey,
        challengeMessage: message,
        expiresAt: expiresAt,
      ),
    );

    _log.info('createChallenge.success challengeId=${challenge.id}');

    return SolanaWalletAuthChallengeResponse(
      challengeId: challenge.id!,
      message: message,
      expiresAt: expiresAt,
    );
  }

  static Future<AuthSuccess> login(
    Session session, {
    required UuidValue challengeId,
    required String publicKeyBase64,
    required String signedMessageBase64,
    required String signatureBase64,
    String? walletAddress,
  }) async {
    final normalizedPublicKey = publicKeyBase64.trim();
    final normalizedWalletAddress = walletAddress?.trim();

    final publicKeyBytes = _decodePublicKey(normalizedPublicKey);
    if (publicKeyBytes.length != 32) {
      throw ValidationException('Invalid Solana public key.');
    }

    final signedMessage = _decodeBase64Bytes(
      value: signedMessageBase64,
      fieldName: 'signedMessageBase64',
    );
    final signatureBytes = _decodeBase64Bytes(
      value: signatureBase64,
      fieldName: 'signatureBase64',
    );

    if (signatureBytes.length != 64) {
      throw ValidationException('Invalid Solana signature.');
    }

    final now = DateTime.now().toUtc();

    return DatabaseUtil.runInTransactionOrSavepoint(session.db, null, (
      tx,
    ) async {
      final challenge = await SolanaWalletAuthChallenge.db.findById(
        session,
        challengeId,
        transaction: tx,
      );

      if (challenge == null ||
          challenge.publicKeyBase64 != normalizedPublicKey) {
        throw ValidationException('Wallet login challenge is invalid.');
      }
      if (challenge.usedAt != null) {
        throw ValidationException('Wallet login challenge was already used.');
      }
      if (challenge.expiresAt.isBefore(now)) {
        throw ValidationException('Wallet login challenge has expired.');
      }

      final expectedMessage = utf8.encode(challenge.challengeMessage);
      if (!_bytesEqual(signedMessage, expectedMessage)) {
        throw ValidationException('Signed message does not match challenge.');
      }

      final signature = solana.signatureBytes(
        Uint8List.fromList(signatureBytes),
      );
      final verified = solana.verifySignature(
        Uint8List.fromList(publicKeyBytes),
        signature,
        Uint8List.fromList(expectedMessage),
      );

      if (!verified) {
        throw ValidationException('Wallet signature verification failed.');
      }

      await SolanaWalletAuthChallenge.db.updateRow(
        session,
        challenge.copyWith(usedAt: now),
        transaction: tx,
      );

      final existing = await SolanaWalletAuthAccount.db.findFirstRow(
        session,
        where: (t) => t.publicKeyBase64.equals(normalizedPublicKey),
        transaction: tx,
      );

      late final UuidValue authUserId;
      if (existing == null) {
        final authUser = await AuthServices.instance.authUsers.create(
          session,
          transaction: tx,
        );
        authUserId = authUser.id;

        await SolanaWalletAuthAccount.db.insertRow(
          session,
          SolanaWalletAuthAccount(
            authUserId: authUserId,
            publicKeyBase64: normalizedPublicKey,
            walletAddress: normalizedWalletAddress,
          ),
          transaction: tx,
        );
      } else {
        authUserId = existing.authUserId;
        await SolanaWalletAuthAccount.db.updateRow(
          session,
          existing.copyWith(
            walletAddress: normalizedWalletAddress ?? existing.walletAddress,
            updatedAt: now,
            lastAuthenticatedAt: now,
          ),
          transaction: tx,
        );
      }

      _log.info(
        'login.success challengeId=$challengeId authUserId=$authUserId',
      );

      return AuthServices.instance.tokenManager.issueToken(
        session,
        authUserId: authUserId,
        method: _walletAuthMethod,
        transaction: tx,
      );
    });
  }

  static List<int> _decodePublicKey(String publicKeyBase64) {
    return _decodeBase64Bytes(
      value: publicKeyBase64,
      fieldName: 'publicKeyBase64',
    );
  }

  static List<int> _decodeBase64Bytes({
    required String value,
    required String fieldName,
  }) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw ValidationException('$fieldName is required.');
    }

    try {
      return base64Decode(normalized);
    } on FormatException {
      throw ValidationException('$fieldName is not valid base64.');
    }
  }

  static String _buildChallengeMessage(DateTime issuedAt) {
    final nonce = _generateNonce();
    return [
      'OpenBudget Wallet Login',
      'Nonce: $nonce',
      'Issued At: ${issuedAt.toIso8601String()}',
      'This signature will not trigger a blockchain transaction.',
    ].join('\n');
  }

  static String _generateNonce([int length = 24]) {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  static bool _bytesEqual(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }
}
