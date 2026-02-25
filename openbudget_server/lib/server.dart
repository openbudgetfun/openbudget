import 'dart:io';

import 'package:openbudget_server/src/auth/apple_oauth_callback_route.dart';
import 'package:openbudget_server/src/auth/email_sender.dart';
import 'package:openbudget_server/src/fx_rates/fx_rate_service.dart';
import 'package:openbudget_server/src/generated/endpoints.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/logging/server_logging.dart';
import 'package:openbudget_server/src/web/routes/app_config_route.dart';
import 'package:openbudget_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

/// Email sender instance. Replace with [SmtpEmailSender] for production.
final EmailSender _emailSender = ConsoleEmailSender();

/// The starting point of the Serverpod server.
Future<void> run(List<String> args) async {
  // Initialize logging before anything else.
  initServerLogging();

  final pod = Serverpod(args, Protocol(), Endpoints());
  final googleIdpEnabled = _hasRequiredPasswords(pod, const [
    'googleClientSecret',
  ]);
  final appleIdpEnabled = _hasRequiredPasswords(pod, const [
    'appleServiceIdentifier',
    'appleBundleIdentifier',
    'appleRedirectUri',
    'appleTeamId',
    'appleKeyId',
    'appleKey',
  ]);

  // Initialize Serverpod and connect it with your generated code.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password
      // authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
      if (googleIdpEnabled) GoogleIdpConfigFromPasswords(),
      if (appleIdpEnabled) AppleIdpConfigFromPasswords(),
    ],
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute());
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  if (appleIdpEnabled) {
    pod.webServer.addRoute(
      AppleOauthCallbackRoute(
        androidPackageIdentifier: _readPassword(
          pod,
          'appleAndroidPackageIdentifier',
        ),
      ),
      '/auth/apple/callback',
    );
    pod.webServer.addRoute(
      AuthServices.instance.appleIdp.revokedNotificationRoute(),
      '/hooks/apple-notification',
    );
  }

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    pod.webServer.addRoute(
      FlutterRoute(Directory(Uri(path: 'web/app').toFilePath())),
      '/app',
    );
  } else {
    pod.webServer.addRoute(
      StaticRoute.file(
        File(Uri(path: 'web/pages/build_flutter_app.html').toFilePath()),
      ),
      '/app/**',
    );
  }

  FxRateService.configure(
    apiKey: _readPassword(pod, 'currencyApiKey'),
    baseUrl: _readPassword(pod, 'currencyApiBaseUrl'),
  );

  // Start the server.
  await pod.start();

  // Keep persisted FX rates fresh for display-currency conversion.
  FxRateService.startBackgroundRefresh(pod);
}

String? _readPassword(Serverpod pod, String key) {
  final value = pod.getPassword(key)?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

bool _hasRequiredPasswords(Serverpod pod, List<String> keys) {
  return keys.every((key) => _readPassword(pod, key) != null);
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  _emailSender.sendVerificationCode(
    session,
    email: email,
    code: verificationCode,
  );
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  _emailSender.sendPasswordResetCode(
    session,
    email: email,
    code: verificationCode,
  );
}
