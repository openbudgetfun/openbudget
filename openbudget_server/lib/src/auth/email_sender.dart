import 'package:serverpod/serverpod.dart';

/// Abstraction for sending email verification codes.
///
/// Implementations handle the actual delivery mechanism (console logging,
/// SMTP, third-party service, etc.).
abstract class EmailSender {
  /// Sends a registration verification code to the given email.
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  });

  /// Sends a password reset verification code to the given email.
  Future<void> sendPasswordResetCode(
    Session session, {
    required String email,
    required String code,
  });
}

/// Logs verification codes to the console. For development and testing only.
class ConsoleEmailSender implements EmailSender {
  @override
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    session.log('[EmailIdp] Registration code ($email): $code');
  }

  @override
  Future<void> sendPasswordResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    session.log('[EmailIdp] Password reset code ($email): $code');
  }
}

/// Sends verification codes via SMTP. For staging and production.
class SmtpEmailSender implements EmailSender {
  SmtpEmailSender({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.fromAddress,
  });

  final String host;
  final int port;
  final String username;
  final String password;
  final String fromAddress;

  @override
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    // TODO(openbudget): Implement SMTP email sending for registration codes.
    session.log('[SMTP] Would send registration code to $email: $code');
  }

  @override
  Future<void> sendPasswordResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    // TODO(openbudget): Implement SMTP email sending for password reset codes.
    session.log('[SMTP] Would send password reset code to $email: $code');
  }
}
