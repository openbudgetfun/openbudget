import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

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

    LocalAssociationScenario? scenario;
    try {
      final isWalletAvailable = await LocalAssociationScenario.isAvailable();
      if (!isWalletAvailable) {
        throw StateError(
          'No compatible Solana wallet is installed on this Android device.',
        );
      }

      scenario = await LocalAssociationScenario.create();
      await scenario.startActivityForResult(null);
      final walletClient = await scenario.start();

      final authorization = await walletClient.authorize(
        identityUri: Uri.parse('https://openbudget.app'),
        iconUri: Uri.parse('https://openbudget.app/favicon.ico'),
        identityName: 'OpenBudget',
        cluster: 'mainnet-beta',
      );
      if (authorization == null) {
        throw const _WalletAuthCanceledException();
      }

      final publicKeyBytes = authorization.publicKey;
      final publicKeyBase64 = base64Encode(publicKeyBytes);

      final challenge = await client.solanaWalletAuth.createChallenge(
        publicKeyBase64,
      );
      final challengeMessageBytes = Uint8List.fromList(
        utf8.encode(challenge.message),
      );

      final signedMessages = await walletClient.signMessages(
        messages: [challengeMessageBytes],
        addresses: [publicKeyBytes],
      );
      if (signedMessages.signedMessages.isEmpty) {
        throw StateError('The wallet did not return a signed message.');
      }

      final signed = signedMessages.signedMessages.first;
      if (signed.signatures.isEmpty) {
        throw StateError('The wallet did not return a signature.');
      }

      final authSuccess = await client.solanaWalletAuth.login(
        challenge.challengeId,
        publicKeyBase64,
        base64Encode(signed.message),
        base64Encode(signed.signatures.first),
      );

      await client.auth.updateSignedInUser(authSuccess);
      _log.info('walletLogin.success userId=${authSuccess.authUserId}');
      if (!ref.mounted) return;
      state = Authenticated(userId: authSuccess.authUserId.toString());
    } on _WalletAuthCanceledException {
      if (!ref.mounted) return;
      state = const AuthError(message: 'Solana wallet sign-in was canceled.');
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'walletLogin.failed error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyWalletAuthError(error));
    } finally {
      if (scenario != null) {
        try {
          await scenario.close();
        } on Exception {
          // Best-effort close; ignore cleanup errors.
        }
      }
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

    final text = error.toString().toLowerCase();
    if (text.contains('canceled') || text.contains('cancelled')) {
      return 'Solana wallet sign-in was canceled.';
    }
    if (text.contains('no compatible solana wallet')) {
      return 'Install a Solana wallet app that supports Mobile Wallet Adapter.';
    }
    if (text.contains('signed message') || text.contains('signature')) {
      return 'The wallet did not return a valid signature. Please try again.';
    }

    return 'Could not complete Solana wallet sign-in. Please try again.';
  }
}

class _WalletAuthCanceledException implements Exception {
  const _WalletAuthCanceledException();
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
