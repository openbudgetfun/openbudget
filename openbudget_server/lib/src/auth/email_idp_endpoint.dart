import 'package:openbudget_core/openbudget_core.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  static final _log = ObLogger('EmailIdpEndpoint');

  @override
  Future<AuthSuccess> login(
    Session session, {
    required String email,
    required String password,
  }) async {
    final maskedEmail = _maskEmailForLogs(email);
    _log.info('login.start email=$maskedEmail');
    try {
      final result = await super.login(
        session,
        email: email,
        password: password,
      );
      _log.info('login.success email=$maskedEmail userId=${result.authUserId}');
      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'login.failed email=$maskedEmail error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    final maskedEmail = _maskEmailForLogs(email);
    _log.info('startRegistration.start email=$maskedEmail');
    try {
      final requestId = await super.startRegistration(session, email: email);
      _log.info(
        'startRegistration.success email=$maskedEmail requestId=$requestId',
      );
      return requestId;
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'startRegistration.failed email=$maskedEmail error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<String> verifyRegistrationCode(
    Session session, {
    required UuidValue accountRequestId,
    required String verificationCode,
  }) async {
    _log.info(
      'verifyRegistrationCode.start accountRequestId=$accountRequestId codeLength=${verificationCode.length}',
    );
    try {
      final registrationToken = await super.verifyRegistrationCode(
        session,
        accountRequestId: accountRequestId,
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

  @override
  Future<AuthSuccess> finishRegistration(
    Session session, {
    required String registrationToken,
    required String password,
  }) async {
    _log.info(
      'finishRegistration.start tokenLength=${registrationToken.length} passwordLength=${password.length}',
    );
    try {
      final result = await super.finishRegistration(
        session,
        registrationToken: registrationToken,
        password: password,
      );
      _log.info('finishRegistration.success userId=${result.authUserId}');
      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning(
        'finishRegistration.failed tokenLength=${registrationToken.length} error=${error.runtimeType}: $error',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
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
