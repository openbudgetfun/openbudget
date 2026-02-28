import 'package:openbudget_server/server.dart' as server;
import 'package:openbudget_server/src/auth/email_sender.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('createEmailSender', () {
    test('when run mode is development then returns console sender', () {
      final emailSender = server.createEmailSender(
        runMode: ServerpodRunMode.development,
        smtpHost: 'smtp.example.com',
        smtpPort: 587,
        smtpUsername: 'smtp-user',
        smtpPassword: 'smtp-password',
        smtpFromAddress: 'noreply@example.com',
      );

      expect(emailSender, isA<ConsoleEmailSender>());
    });

    test('when run mode is test then returns console sender', () {
      final emailSender = server.createEmailSender(
        runMode: ServerpodRunMode.test,
        smtpHost: 'smtp.example.com',
        smtpPort: 587,
        smtpUsername: 'smtp-user',
        smtpPassword: 'smtp-password',
        smtpFromAddress: 'noreply@example.com',
      );

      expect(emailSender, isA<ConsoleEmailSender>());
    });

    test(
      'when non-local run mode has SMTP credentials then returns SMTP sender',
      () {
        final emailSender = server.createEmailSender(
          runMode: ServerpodRunMode.production,
          smtpHost: 'smtp.example.com',
          smtpPort: 587,
          smtpUsername: 'smtp-user',
          smtpPassword: 'smtp-password',
          smtpFromAddress: 'noreply@example.com',
        );

        expect(emailSender, isA<SmtpEmailSender>());
      },
    );

    test(
      'when non-local run mode misses SMTP credentials then returns null',
      () {
        final emailSender = server.createEmailSender(
          runMode: ServerpodRunMode.staging,
          smtpHost: 'smtp.example.com',
          smtpPort: null,
          smtpUsername: 'smtp-user',
          smtpPassword: 'smtp-password',
          smtpFromAddress: 'noreply@example.com',
        );

        expect(emailSender, isNull);
      },
    );
  });
}
