import 'package:serverpod/serverpod.dart';

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
///
/// The identifier is not backed by a `serverpod_auth_core_user` row. Use
/// [createAuthenticatedUser] when the test writes rows whose owner column
/// carries a real foreign key.
TestSessionBuilder createAuthenticatedSession(
  TestSessionBuilder sessionBuilder, {
  String? userIdentifier,
}) {
  final id = _nextUserId(userIdentifier);
  return sessionBuilder.copyWith(
    authentication: AuthenticationOverride.authenticationInfo(id, {}),
  );
}

/// Creates the auth user row and an authenticated session for it.
///
/// Entity-owned tables reference `serverpod_auth_core_user`, so any test
/// that creates an entity (directly or through an endpoint) needs the row.
Future<({TestSessionBuilder session, UuidValue userId})>
createAuthenticatedUser(
  TestSessionBuilder sessionBuilder, {
  String? userIdentifier,
}) async {
  final id = _nextUserId(userIdentifier);
  await ensureAuthUsers(sessionBuilder, [id]);
  return (
    session: sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(id, {}),
    ),
    userId: UuidValue.fromString(id),
  );
}

/// Inserts auth user rows for the ids a test family writes into.
///
/// Entitlements, billing challenges and entities all carry a real foreign
/// key to `serverpod_auth_core_user`, so rows that reference a user id need
/// the user row to exist first.
Future<void> ensureAuthUsers(
  TestSessionBuilder sessionBuilder,
  List<String> userIds,
) async {
  final session = sessionBuilder.build();
  for (final id in userIds) {
    await session.db.unsafeExecute(
      'INSERT INTO serverpod_auth_core_user '
      '(id, "createdAt", "scopeNames", blocked) '
      "VALUES (@id::uuid, now(), '[]'::json, false) "
      'ON CONFLICT (id) DO NOTHING',
      parameters: QueryParameters.named({'id': id}),
    );
  }
  await session.close();
}

String _nextUserId(String? userIdentifier) {
  // Generate a deterministic, valid UUID v4 string for each test user.
  final counter = ++_userCounter;
  final hex = counter.toRadixString(16).padLeft(12, '0');
  return userIdentifier ?? '10000000-0000-4000-a000-$hex';
}
