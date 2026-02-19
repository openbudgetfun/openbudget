import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    _tryRestore();
    return const AuthLoading();
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
    } on Exception catch (_) {
      if (!ref.mounted) return;
      state = const Unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthLoading();
    final client = ref.read(serverpodClientProvider);
    try {
      final authSuccess = await client.emailIdp.login(
        email: email,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      if (!ref.mounted) return;
      state = Authenticated(
        userId: authSuccess.authUserId.toString(),
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyError(e));
    }
  }

  /// Starts registration and returns the account request ID as a string.
  Future<String> startRegistration({required String email}) async {
    final client = ref.read(serverpodClientProvider);
    final requestId = await client.emailIdp.startRegistration(email: email);
    return requestId.toString();
  }

  /// Verifies the registration code and returns the registration token.
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required String verificationCode,
  }) async {
    final client = ref.read(serverpodClientProvider);
    return client.emailIdp.verifyRegistrationCode(
      // Serverpod API requires UuidValue which is experimental in uuid package.
      // ignore: experimental_member_use
      accountRequestId: UuidValue.fromString(accountRequestId),
      verificationCode: verificationCode,
    );
  }

  Future<void> finishRegistration({
    required String registrationToken,
    required String password,
  }) async {
    state = const AuthLoading();
    final client = ref.read(serverpodClientProvider);
    try {
      final authSuccess = await client.emailIdp.finishRegistration(
        registrationToken: registrationToken,
        password: password,
      );
      await client.auth.updateSignedInUser(authSuccess);
      if (!ref.mounted) return;
      state = Authenticated(
        userId: authSuccess.authUserId.toString(),
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = AuthError(message: _friendlyError(e));
    }
  }

  Future<void> logout() async {
    final client = ref.read(serverpodClientProvider);
    await client.auth.signOutDevice();
    if (!ref.mounted) return;
    state = const Unauthenticated();
  }

  String _friendlyError(Exception e) {
    if (e is ServerpodClientException) {
      return e.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
