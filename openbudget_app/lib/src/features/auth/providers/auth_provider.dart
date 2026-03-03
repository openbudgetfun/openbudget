import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  static final _log = ObLogger('AuthNotifier');

  @override
  AuthState build() {
    _tryRestore();
    return const AuthRestoring();
  }

  Future<void> _tryRestore() async {
    final client = ref.read(serverpodClientProvider);
    try {
      await client.auth.initialize();
      if (!ref.mounted) return;
      if (client.auth.isAuthenticated) {
        state = Authenticated(
          userId: client.auth.authInfo!.authUserId.toString(),
        );
      } else {
        state = const Unauthenticated();
      }
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'restore.failed error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = const Unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final maskedEmail = _maskEmailForLogs(email);
    _log.info('login.start email=$maskedEmail');
    state = const AuthLoading();
    final client = ref.read(serverpodClientProvider);
    try {
      final authSuccess = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      _log.info(
        'login.success email=$maskedEmail userId=${authSuccess.authUserId}',
      );
      if (!ref.mounted) return;
      state = Authenticated(userId: authSuccess.authUserId.toString());
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'login.failed email=$maskedEmail error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyError(error));
    }
  }

  Future<void> loginWithSolanaMobileWallet() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      state = const AuthError(
        message: 'Solana wallet sign-in is only available on Android devices.',
      );
      return;
    }

    final client = ref.read(serverpodClientProvider);
    state = const AuthLoading();

    try {
      final isWalletAvailable = await MwaClientHostApi()
          .isWalletEndpointAvailable();
      if (!isWalletAvailable) {
        throw StateError(
          'No compatible Solana wallet is installed on this Android device.',
        );
      }

      final signedChallenge = await transact<_WalletChallengeSignature>((
        wallet,
      ) async {
        final authorization = await wallet.authorize(chain: 'solana:mainnet');
        if (authorization.accounts.isEmpty) {
          throw StateError('The wallet did not return an account.');
        }

        final publicKeyBase64 = authorization.accounts.first.address;
        final challenge = await client.solanaWalletAuth.createChallenge(
          publicKeyBase64,
        );

        final challengeMessageBytes = Uint8List.fromList(
          utf8.encode(challenge.message),
        );
        final signedPayloads = await wallet.signMessages(
          addresses: [publicKeyBase64],
          payloads: [_encodeBase64UrlNoPadding(challengeMessageBytes)],
        );
        if (signedPayloads.isEmpty) {
          throw StateError('The wallet did not return a signed payload.');
        }

        final signedPayload = _decodeBase64Payload(signedPayloads.first);
        if (signedPayload.length <= _ed25519SignatureLength) {
          throw StateError('The wallet returned an invalid signed payload.');
        }

        // MWA sign_messages returns the original payload with the Ed25519
        // signature appended to the end of the byte array.
        final messageBytes = signedPayload.sublist(
          0,
          signedPayload.length - _ed25519SignatureLength,
        );
        final signatureBytes = signedPayload.sublist(
          signedPayload.length - _ed25519SignatureLength,
        );

        return _WalletChallengeSignature(
          challengeId: challenge.challengeId,
          publicKeyBase64: publicKeyBase64,
          signedMessageBase64: base64Encode(messageBytes),
          signatureBase64: base64Encode(signatureBytes),
        );
      });

      final authSuccess = await client.solanaWalletAuth.login(
        signedChallenge.challengeId,
        signedChallenge.publicKeyBase64,
        signedChallenge.signedMessageBase64,
        signedChallenge.signatureBase64,
      );

      await client.auth.updateSignedInUser(authSuccess);
      _log.info('walletLogin.success userId=${authSuccess.authUserId}');
      if (!ref.mounted) return;
      state = Authenticated(userId: authSuccess.authUserId.toString());
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'walletLogin.failed error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyWalletAuthError(error));
    }
  }

  /// Starts registration and returns the account request ID as a string.
  Future<String> startRegistration({required String email}) async {
    final maskedEmail = _maskEmailForLogs(email);
    _log.info('startRegistration.start email=$maskedEmail');
    final client = ref.read(serverpodClientProvider);
    try {
      final requestId = await client.emailIdp.startRegistration(email: email);
      _log.info(
        'startRegistration.success email=$maskedEmail requestId=$requestId',
      );
      return requestId.toString();
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'startRegistration.failed email=$maskedEmail error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  /// Verifies the registration code and returns the registration token.
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required String verificationCode,
  }) async {
    _log.info(
      'verifyRegistrationCode.start accountRequestId=$accountRequestId codeLength=${verificationCode.length}',
    );
    final client = ref.read(serverpodClientProvider);
    try {
      final registrationToken = await client.emailIdp.verifyRegistrationCode(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        accountRequestId: UuidValue.fromString(accountRequestId),
        verificationCode: verificationCode,
      );
      _log.info(
        'verifyRegistrationCode.success accountRequestId=$accountRequestId tokenLength=${registrationToken.length}',
      );
      return registrationToken;
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'verifyRegistrationCode.failed accountRequestId=$accountRequestId error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> finishRegistration({
    required String registrationToken,
    required String password,
  }) async {
    _log.info(
      'finishRegistration.start tokenLength=${registrationToken.length} passwordLength=${password.length}',
    );
    state = const AuthLoading();
    final client = ref.read(serverpodClientProvider);
    try {
      final authSuccess = await client.emailIdp.finishRegistration(
        registrationToken: registrationToken,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      _log.info('finishRegistration.success userId=${authSuccess.authUserId}');
      if (!ref.mounted) return;
      state = Authenticated(userId: authSuccess.authUserId.toString());
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'finishRegistration.failed tokenLength=${registrationToken.length} error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyError(error));
    }
  }

  Future<void> logout() async {
    final client = ref.read(serverpodClientProvider);
    await client.auth.signOutDevice();
    _log.info('logout.success');
    if (!ref.mounted) return;
    state = const Unauthenticated();
  }

  /// Syncs auth state after a successful external OAuth flow.
  Future<void> syncExternalAuthState() async {
    final client = ref.read(serverpodClientProvider);
    try {
      await client.auth.initialize();
      if (!ref.mounted) return;

      final authInfo = client.auth.authInfo;
      if (authInfo == null) {
        state = const AuthError(
          message: 'Could not complete sign-in. Please try again.',
        );
        return;
      }

      state = Authenticated(userId: authInfo.authUserId.toString());
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'externalAuth.sync.failed error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyExternalAuthError(error));
    }
  }

  /// Maps external OAuth errors into user-facing auth errors.
  void setExternalAuthError(Object error) {
    _log.warning('externalAuth.error error=${error.runtimeType}: $error');
    if (!ref.mounted) return;
    state = AuthError(message: _friendlyExternalAuthError(error));
  }

  String _friendlyError(Exception e) {
    if (e is ServerpodClientException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }

  String _friendlyExternalAuthError(Object error) {
    if (error.runtimeType.toString() == 'UserFacingException') {
      return error.toString();
    }
    if (error is ServerpodClientException) return error.message;
    if (error is ArgumentError) {
      return 'OAuth configuration is missing. Check app environment values.';
    }

    final text = error.toString().toLowerCase();
    if (text.contains('cancelled') || text.contains('canceled')) {
      return 'Sign-in was canceled.';
    }

    return 'Could not complete social sign-in. Please try again.';
  }

  String _friendlyWalletAuthError(Object error) {
    if (error is ServerpodClientException) {
      return error.message;
    }

    final errorText = error.toString();
    final text = error.toString().toLowerCase();
    if (text.contains('mwaprotocolerror') && text.contains('code: -3')) {
      return 'Solana wallet sign-in was canceled.';
    }
    if (text.contains('canceled') || text.contains('cancelled')) {
      return 'Solana wallet sign-in was canceled.';
    }
    if (text.contains('no compatible solana wallet') ||
        text.contains('wallet not found') ||
        text.contains('mwawalletnotfound')) {
      return 'Install a Solana wallet app that supports Mobile Wallet Adapter.';
    }
    if (text.contains('mwasessiontimeout') || text.contains('session timeout')) {
      return 'Timed out connecting to your wallet. Please try again.';
    }
    if (text.contains('code: -1')) {
      return 'Wallet authorization was declined.';
    }
    if (text.contains('code: -2')) {
      return 'The wallet rejected the signing payload.';
    }
    if (text.contains('signed message') || text.contains('signature')) {
      return 'The wallet did not return a valid signature. Please try again.';
    }
    if (text.contains('invalid signed payload')) {
      return 'The wallet returned an invalid signature payload.';
    }

    _log.warning('walletLogin.unhandledError message=$errorText');
    return 'Could not complete Solana wallet sign-in. Please try again.';
  }
}

const _ed25519SignatureLength = 64;

String _encodeBase64UrlNoPadding(List<int> bytes) {
  return base64UrlEncode(bytes).replaceAll('=', '');
}

Uint8List _decodeBase64Payload(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw StateError('The wallet returned an empty payload.');
  }

  final padded = normalized.padRight(
    ((normalized.length + 3) ~/ 4) * 4,
    '=',
  );

  try {
    return Uint8List.fromList(base64Decode(padded));
  } on FormatException {
    final standard = padded.replaceAll('-', '+').replaceAll('_', '/');
    return Uint8List.fromList(base64Decode(standard));
  }
}

class _WalletChallengeSignature {
  const _WalletChallengeSignature({
    required this.challengeId,
    required this.publicKeyBase64,
    required this.signedMessageBase64,
    required this.signatureBase64,
  });

  final UuidValue challengeId;
  final String publicKeyBase64;
  final String signedMessageBase64;
  final String signatureBase64;
}

String _maskEmailForLogs(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return '[invalid-email]';

  final localPart = parts[0];
  final domain = parts[1];
  if (localPart.isEmpty) return '*@$domain';
  if (localPart.length == 1) return '*@$domain';
  if (localPart.length == 2) return '${localPart[0]}*@$domain';

  return '${localPart[0]}***${localPart[localPart.length - 1]}@$domain';
}
