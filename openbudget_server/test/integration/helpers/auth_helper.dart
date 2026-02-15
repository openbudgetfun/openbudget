import '../test_tools/serverpod_test_tools.dart';

int _userCounter = 0;

/// Creates an authenticated [TestSessionBuilder] with a unique user identity.
///
/// Uses [AuthenticationOverride] to simulate authentication without going
/// through the email IDP flow. This is appropriate because `withServerpod`
/// does not call `initializeAuthServices`, so email registration endpoints
/// are not functional in tests.
///
/// Each call produces an isolated user context with a unique identifier,
/// enabling cross-user access tests.
TestSessionBuilder createAuthenticatedSession(
  TestSessionBuilder sessionBuilder, {
  String? userIdentifier,
}) {
  // Generate a deterministic, valid UUID v4 string for each test user.
  final counter = ++_userCounter;
  final hex = counter.toRadixString(16).padLeft(12, '0');
  final id = userIdentifier ?? '10000000-0000-4000-a000-$hex';
  return sessionBuilder.copyWith(
    authentication: AuthenticationOverride.authenticationInfo(id, {}),
  );
}
