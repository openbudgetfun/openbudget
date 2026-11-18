import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/settings/account_deletion_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given SettingsEndpoint.deleteAccount', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder ownerSession;
    late UuidValue ownerId;
    late TestSessionBuilder otherSession;
    late UuidValue otherId;

    setUp(() async {
      final owner = await createAuthenticatedUser(sessionBuilder);
      final other = await createAuthenticatedUser(sessionBuilder);
      ownerSession = owner.session;
      ownerId = owner.userId;
      otherSession = other.session;
      otherId = other.userId;
    });

    Future<Entity> createBook(TestSessionBuilder session, String name) async {
      final entity = await endpoints.entity.create(
        session,
        name,
        EntityKind.individual,
        'GB',
        'GBP',
        'Europe/London',
      );
      final account = await endpoints.account.create(
        session,
        entity.id!,
        'Checking',
        AccountKind.checking,
        'GBP',
        onBudget: true,
        openingBalanceMinor: 100000,
      );
      final category = await endpoints.category.create(
        session,
        entity.id!,
        'Everyday',
      );
      await endpoints.envelope.create(session, category.id!, 'Groceries');
      await PlaidConnection.db.insertRow(
        sessionBuilder.build(),
        PlaidConnection(
          entityId: entity.id!,
          plaidItemId: 'item-${account.id}',
          accessTokenCiphertext: 'ciphertext',
          accessTokenNonce: 'nonce',
        ),
      );
      return entity;
    }

    Future<void> recordEntitlement(
      UuidValue userId,
      EntitlementStatus status,
    ) async {
      final now = DateTime.now().toUtc();
      await EntitlementService.record(
        sessionBuilder.build(),
        userId: userId,
        source: EntitlementSource.stripe,
        externalId: 'sub_$userId',
        status: status,
        currentPeriodStart: now.subtract(const Duration(days: 1)),
        currentPeriodEnd: now.add(const Duration(days: 29)),
      );
    }

    Future<int> authUserCount(UuidValue userId) async {
      final rows = await sessionBuilder.build().db.unsafeQuery(
        'SELECT 1 FROM serverpod_auth_core_user WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': userId.toString()}),
      );
      return rows.length;
    }

    group('when the user has data and no renewing subscription', () {
      test('then their entities, rows and auth user are removed', () async {
        final mine = await createBook(ownerSession, 'Mine');
        await createBook(ownerSession, 'Business');
        final theirs = await createBook(otherSession, 'Theirs');
        await endpoints.settings.setReportingCurrency(ownerSession, 'USD');

        await endpoints.settings.deleteAccount(ownerSession);

        final raw = sessionBuilder.build();
        expect(
          await Entity.db.count(raw, where: (t) => t.ownerId.equals(ownerId)),
          0,
        );
        expect(
          await Account.db.count(raw, where: (t) => t.entityId.equals(mine.id)),
          0,
        );
        expect(
          await PlaidConnection.db.count(
            raw,
            where: (t) => t.entityId.equals(mine.id),
          ),
          0,
        );
        expect(
          await UserSettings.db.count(
            raw,
            where: (t) => t.userId.equals(ownerId),
          ),
          0,
        );
        expect(await authUserCount(ownerId), 0);

        // Another user's books are untouched.
        expect(await authUserCount(otherId), 1);
        final remaining = await endpoints.entity.list(otherSession);
        expect(remaining.map((e) => e.id), [theirs.id]);
        expect(
          await Account.db.count(
            raw,
            where: (t) => t.entityId.equals(theirs.id),
          ),
          1,
        );
      });

      test('then a user with no entities is still removed', () async {
        await endpoints.settings.deleteAccount(ownerSession);

        expect(await authUserCount(ownerId), 0);
      });

      test(
        'then a cancelled plan running to period end does not block',
        () async {
          await createBook(ownerSession, 'Mine');
          await recordEntitlement(ownerId, EntitlementStatus.canceled);

          await endpoints.settings.deleteAccount(ownerSession);

          expect(await authUserCount(ownerId), 0);
          expect(
            await Entitlement.db.count(
              sessionBuilder.build(),
              where: (t) => t.userId.equals(ownerId),
            ),
            0,
          );
        },
      );
    });

    for (final status in AccountDeletionService.renewingStatuses) {
      test(
        'when a ${status.name} subscription renews then deletion is refused '
        'and nothing is removed',
        () async {
          await createBook(ownerSession, 'Mine');
          await recordEntitlement(ownerId, status);

          await expectLater(
            endpoints.settings.deleteAccount(ownerSession),
            throwsA(
              isA<ValidationException>().having(
                (e) => e.message,
                'message',
                AccountDeletionService.renewingSubscriptionMessage,
              ),
            ),
          );

          expect(await authUserCount(ownerId), 1);
          expect(await endpoints.entity.list(ownerSession), hasLength(1));
        },
      );
    }

    test('when the caller is signed out then it is rejected', () async {
      await expectLater(
        endpoints.settings.deleteAccount(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });
  });
}
