import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../helpers/auth_helper.dart';
import '../../test_tools/serverpod_test_tools.dart';

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '40000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

void main() {
  withServerpod('Given AgentTokenEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;

    setUp(() {
      final user = _newUser(sessionBuilder);
      authedSession = user.session;
      userId = user.userId;
      rawSession = sessionBuilder.build();
    });

    Future<List<AgentAccessToken>> storedTokens() => AgentAccessToken.db.find(
      rawSession,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt,
    );

    group('when creating a token', () {
      test(
        'then only the hash is stored and the secret is returned once',
        () async {
          final created = await endpoints.agentToken.createAccessToken(
            authedSession,
            '  Claude Code  ',
            true,
          );

          expect(created.token, startsWith('obk_'));
          expect(created.token.length, 47);
          expect(
            created.token.substring(4),
            matches(RegExp(r'^[A-Za-z0-9_-]+$')),
          );
          expect(created.view.name, 'Claude Code');
          expect(created.view.canPropose, isTrue);
          expect(created.view.tokenPrefix, created.token.substring(0, 12));
          expect(created.view.createdAt, isA<DateTime>());
          expect(created.view.lastUsedAt, isNull);
          expect(created.view.revokedAt, isNull);

          final rows = await storedTokens();
          expect(rows, hasLength(1));
          final expectedHash = sha256
              .convert(utf8.encode(created.token))
              .toString();
          expect(rows.single.tokenHash, expectedHash);
          expect(expectedHash, matches(RegExp(r'^[0-9a-f]{64}$')));
          expect(rows.single.tokenHash, isNot(created.token));
          expect(
            jsonEncode(rows.single.toJson()),
            isNot(contains(created.token)),
          );
          expect(rows.single.tokenPrefix, created.token.substring(0, 12));
        },
      );

      test('then two tokens are different secrets', () async {
        final first = await endpoints.agentToken.createAccessToken(
          authedSession,
          'First',
          false,
        );
        final second = await endpoints.agentToken.createAccessToken(
          authedSession,
          'Second',
          false,
        );

        expect(first.token, isNot(second.token));
        expect(first.view.id, isNot(second.view.id));
        expect(first.view.canPropose, isFalse);
      });

      test('then a blank or overlong name is refused', () async {
        await expectLater(
          endpoints.agentToken.createAccessToken(authedSession, '   ', true),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          endpoints.agentToken.createAccessToken(authedSession, 'x' * 61, true),
          throwsA(isA<ValidationException>()),
        );
        expect(await storedTokens(), isEmpty);
      });

      test('then a user cannot hold more than ten unrevoked tokens', () async {
        for (var index = 0; index < 10; index++) {
          await endpoints.agentToken.createAccessToken(
            authedSession,
            'Client $index',
            false,
          );
        }

        await expectLater(
          endpoints.agentToken.createAccessToken(
            authedSession,
            'One too many',
            false,
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(await storedTokens(), hasLength(10));

        final first = await storedTokens();
        await endpoints.agentToken.revokeAccessToken(
          authedSession,
          first.first.id!,
        );
        final replacement = await endpoints.agentToken.createAccessToken(
          authedSession,
          'Replacement',
          false,
        );
        expect(replacement.view.name, 'Replacement');
      });
    });

    group('when listing tokens', () {
      test('then only the owner sees views without the hash', () async {
        final created = await endpoints.agentToken.createAccessToken(
          authedSession,
          'Codex',
          true,
        );
        final other = _newUser(sessionBuilder);

        final views = await endpoints.agentToken.listAccessTokens(
          authedSession,
        );
        expect(views, hasLength(1));
        expect(views.single.id, created.view.id);
        expect(views.single.tokenPrefix, created.token.substring(0, 12));
        expect(views.single.canPropose, isTrue);
        expect(views.single.lastUsedAt, isNull);
        expect(views.single.revokedAt, isNull);

        expect(
          await endpoints.agentToken.listAccessTokens(other.session),
          isEmpty,
        );
      });
    });

    group('when revoking a token', () {
      test(
        'then it is marked revoked and revoking again is harmless',
        () async {
          final created = await endpoints.agentToken.createAccessToken(
            authedSession,
            'Claude Code',
            true,
          );

          final revoked = await endpoints.agentToken.revokeAccessToken(
            authedSession,
            created.view.id,
          );
          expect(revoked.revokedAt, isNotNull);

          final again = await endpoints.agentToken.revokeAccessToken(
            authedSession,
            created.view.id,
          );
          expect(again.revokedAt, revoked.revokedAt);

          final rows = await storedTokens();
          expect(rows.single.revokedAt, isNotNull);
        },
      );

      test('then another user cannot revoke it', () async {
        final created = await endpoints.agentToken.createAccessToken(
          authedSession,
          'Claude Code',
          true,
        );
        final other = _newUser(sessionBuilder);

        await expectLater(
          endpoints.agentToken.revokeAccessToken(
            other.session,
            created.view.id,
          ),
          throwsA(isA<NotFoundException>()),
        );
        expect((await storedTokens()).single.revokedAt, isNull);
      });
    });

    group('when the caller is not signed in', () {
      test('then every method rejects it', () async {
        final anonymous = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.unauthenticated(),
        );

        await expectLater(
          endpoints.agentToken.listAccessTokens(anonymous),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        await expectLater(
          endpoints.agentToken.createAccessToken(anonymous, 'Anonymous', false),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
        await expectLater(
          endpoints.agentToken.revokeAccessToken(
            anonymous,
            UuidValue.fromString('01900000-0000-7000-8000-000000000000'),
          ),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });
    });
  });
}
