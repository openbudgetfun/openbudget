import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:serverpod/serverpod.dart' hide Message;

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
    this.fromName,
    bool? useSsl,
    this.ignoreBadCertificate = false,
    SmtpMessageSender? messageSender,
  }) : useSsl = useSsl ?? port == 465,
       _messageSender = messageSender ?? _defaultSmtpMessageSender;

  final String host;
  final int port;
  final String username;
  final String password;
  final String fromAddress;
  final String? fromName;
  final bool useSsl;
  final bool ignoreBadCertificate;
  final SmtpMessageSender _messageSender;

  @override
  Future<void> sendVerificationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    await _sendCode(
      session: session,
      email: email,
      code: code,
      subject: 'Your OpenBudget verification code',
      purpose: 'registration',
      description: 'registration verification code',
    );
  }

  @override
  Future<void> sendPasswordResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    await _sendCode(
      session: session,
      email: email,
      code: code,
      subject: 'Your OpenBudget password reset code',
      purpose: 'password reset',
      description: 'password reset verification code',
    );
  }

  Future<void> _sendCode({
    required Session session,
    required String email,
    required String code,
    required String subject,
    required String purpose,
    required String description,
  }) async {
    final message = Message()
      ..from = fromName == null
          ? Address(fromAddress)
          : Address(fromAddress, fromName)
      ..recipients.add(email)
      ..subject = subject
      ..text =
          '''
Your OpenBudget $purpose code is: $code

If you did not request this code, you can safely ignore this email.
''';

    final smtpServer = SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ssl: useSsl,
      ignoreBadCertificate: ignoreBadCertificate,
    );

    try {
      await _messageSender(message, smtpServer);
      session.log(
        '[EmailIdp] Sent $description to ${_maskEmailForLogs(email)} via SMTP.',
      );
    } on MailerException catch (error, stackTrace) {
      session.log(
        '[EmailIdp] Failed to send $description to ${_maskEmailForLogs(email)} via SMTP.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

typedef SmtpMessageSender =
    Future<void> Function(Message message, SmtpServer smtpServer);

Future<void> _defaultSmtpMessageSender(
  Message message,
  SmtpServer smtpServer,
) async {
  await send(message, smtpServer);
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
