import 'dart:io';

import 'package:openbudget_server/src/auth/apple_oauth_callback_route.dart';
import 'package:openbudget_server/src/auth/email_sender.dart';
import 'package:openbudget_server/src/fx_rates/fx_rate_service.dart';
import 'package:openbudget_server/src/generated/endpoints.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:openbudget_server/src/logging/server_logging.dart';
import 'package:openbudget_server/src/web/routes/app_config_route.dart';
import 'package:openbudget_server/src/web/routes/root.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/apple.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

const List<String> _smtpPasswordKeys = [
  'smtpHost',
  'smtpPort',
  'smtpUsername',
  'smtpPassword',
  'smtpFromAddress',
];

/// The starting point of the Serverpod server.
Future<void> run(List<String> args) async {
  // Initialize logging before anything else.
  initServerLogging();

  final pod = Serverpod(args, Protocol(), Endpoints());
  final emailSender = createEmailSender(
    runMode: pod.runMode,
    smtpHost: _readPassword(pod, 'smtpHost'),
    smtpPort: _readIntPassword(pod, 'smtpPort'),
    smtpUsername: _readPassword(pod, 'smtpUsername'),
    smtpPassword: _readPassword(pod, 'smtpPassword'),
    smtpFromAddress: _readPassword(pod, 'smtpFromAddress'),
    smtpFromName: _readPassword(pod, 'smtpFromName'),
    smtpUseSsl: _readBoolPassword(pod, 'smtpUseSsl'),
    smtpIgnoreBadCertificate:
        _readBoolPassword(pod, 'smtpIgnoreBadCertificate') ?? false,
  );
  final emailIdpEnabled = emailSender != null;
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
  if (!emailIdpEnabled) {
    stderr.writeln(
      'Email IDP disabled for run mode "${pod.runMode}". Missing required SMTP passwords: ${_smtpPasswordKeys.join(', ')}.',
    );
  }

  // Initialize Serverpod and connect it with your generated code.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password
      // authentication.
      if (emailIdpEnabled)
        EmailIdpConfigFromPasswords(
          sendRegistrationVerificationCode:
              (
                session, {
                required email,
                required accountRequestId,
                required verificationCode,
                required transaction,
              }) => emailSender.sendVerificationCode(
                session,
                email: email,
                code: verificationCode,
              ),
          sendPasswordResetVerificationCode:
              (
                session, {
                required email,
                required passwordResetRequestId,
                required verificationCode,
                required transaction,
              }) => emailSender.sendPasswordResetCode(
                session,
                email: email,
                code: verificationCode,
              ),
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

  // Ensure institution catalog seed data exists for account linking/search.
  await _seedInstitutions(pod);

  // Keep persisted FX rates fresh for display-currency conversion.
  FxRateService.startBackgroundRefresh(pod);
}

String? _readPassword(Serverpod pod, String key) {
  final value = pod.getPassword(key)?.trim();
  if (value == null || value.isEmpty) return null;
  return value;
}

int? _readIntPassword(Serverpod pod, String key) {
  final value = _readPassword(pod, key);
  if (value == null) return null;
  return int.tryParse(value);
}

bool? _readBoolPassword(Serverpod pod, String key) {
  final value = _readPassword(pod, key)?.toLowerCase();
  if (value == null) return null;

  switch (value) {
    case '1':
    case 'true':
    case 'yes':
    case 'on':
      return true;
    case '0':
    case 'false':
    case 'no':
    case 'off':
      return false;
    default:
      return null;
  }
}

bool _hasRequiredPasswords(Serverpod pod, List<String> keys) =>
    keys.every((key) => _readPassword(pod, key) != null);

Future<void> _seedInstitutions(Serverpod pod) async {
  final session = await pod.createSession(enableLogging: false);
  try {
    await InstitutionService.ensureCatalogSeeded(session);
  } on Exception catch (error, stackTrace) {
    stderr.writeln('Institution seed failed: $error\n$stackTrace');
  } finally {
    await session.close();
  }
}

EmailSender? createEmailSender({
  required String runMode,
  required String? smtpHost,
  required int? smtpPort,
  required String? smtpUsername,
  required String? smtpPassword,
  required String? smtpFromAddress,
  String? smtpFromName,
  bool? smtpUseSsl,
  bool smtpIgnoreBadCertificate = false,
}) {
  if (_isLocalRunMode(runMode)) {
    return ConsoleEmailSender();
  }

  if (smtpHost == null ||
      smtpPort == null ||
      smtpUsername == null ||
      smtpPassword == null ||
      smtpFromAddress == null) {
    return null;
  }

  return SmtpEmailSender(
    host: smtpHost,
    port: smtpPort,
    username: smtpUsername,
    password: smtpPassword,
    fromAddress: smtpFromAddress,
    fromName: smtpFromName,
    useSsl: smtpUseSsl,
    ignoreBadCertificate: smtpIgnoreBadCertificate,
  );
}

bool _isLocalRunMode(String runMode) =>
    runMode == ServerpodRunMode.development || runMode == ServerpodRunMode.test;
