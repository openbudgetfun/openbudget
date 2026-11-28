import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/common/secret_box.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/settings/account_deletion_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

const _plaidKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';

/// A local Plaid stand-in that records the access token each `/item/remove`
/// call carries.
Future<HttpServer> _startPlaidServer(List<String> removals) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((request) async {
    final body = await utf8.decoder.bind(request).join();
    if (request.uri.path == '/item/remove') removals.add(body);
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write('{}');
    await request.response.close();
  });
  return server;
}

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

    /// Points Plaid at [server] with a key that can seal and open tokens.
    void usePlaid(HttpServer server) {
      final passwords = sessionBuilder.build().passwords;
      passwords['plaidClientId'] = 'test-client';
      passwords['plaidSecret'] = 'test-secret';
      passwords['plaidBaseUrl'] = 'http://127.0.0.1:${server.port}';
      passwords['plaidTokenEncryptionKey'] = _plaidKey;
      addTearDown(() {
        passwords
          ..remove('plaidClientId')
          ..remove('plaidSecret')
          ..remove('plaidBaseUrl')
          ..remove('plaidTokenEncryptionKey');
      });
    }

    Future<Entity> createBook(
      TestSessionBuilder session,
      String name, {
      EntityKind kind = EntityKind.individual,
    }) async {
      final entity = await endpoints.entity.create(
        session,
        name,
        kind,
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

    /// Adds a second Plaid item whose token the service can actually open.
    Future<PlaidConnection> addLinkedItem(
      Entity entity, {
      required String token,
      String itemId = 'item-linked',
    }) async {
      final sealed = await SecretBox.seal(
        plaintext: token,
        base64Key: _plaidKey,
      );
      return PlaidConnection.db.insertRow(
        sessionBuilder.build(),
        PlaidConnection(
          entityId: entity.id!,
          plaidItemId: itemId,
          accessTokenCiphertext: sealed.cipherText,
          accessTokenNonce: sealed.nonce,
        ),
      );
    }

    /// Seeds the rows a busy book carries: a transaction with an envelope line
    /// and a ledger line, a posted journal and its reversal, a wallet, and a
    /// Money guide conversation.
    Future<
      ({
        TransactionView transaction,
        Journal posted,
        Journal reversal,
        Wallet wallet,
        AgentConversation conversation,
      })
    >
    seedActivity(Entity entity) async {
      final raw = sessionBuilder.build();
      final account = await Account.db.findFirstRow(
        raw,
        where: (t) => t.entityId.equals(entity.id),
      );
      if (account == null) {
        throw StateError('The book should have a checking account.');
      }
      final envelope = await Envelope.db.findFirstRow(
        raw,
        where: (t) => t.entityId.equals(entity.id),
      );
      if (envelope == null) {
        throw StateError('The book should have an envelope.');
      }
      final envelopeId = envelope.id;
      final chart = await endpoints.ledger.listAccounts(
        ownerSession,
        entity.id!,
        includeArchived: false,
      );
      final ledgerAccountId = chart
          .firstWhere((ledger) => ledger.id != account.ledgerAccountId)
          .id!;
      final transaction = await endpoints.transaction.create(
        ownerSession,
        TransactionInput(
          accountId: account.id!,
          date: DateTime.utc(2026, 6, 10),
          amountMinor: -4500,
          description: 'Groceries',
          lines: [
            TransactionLineInput(
              amountMinor: -3000,
              envelopeId: envelopeId,
            ),
            TransactionLineInput(
              amountMinor: -1500,
              ledgerAccountId: ledgerAccountId,
            ),
          ],
        ),
      );

      final posted = await Journal.db.insertRow(
        raw,
        Journal(
          entityId: entity.id!,
          date: DateTime.utc(2026, 6, 11),
          reference: 'JB-test',
          status: JournalStatus.posted,
          postedAt: DateTime.utc(2026, 6, 11),
        ),
      );
      await JournalLine.db.insertRow(
        raw,
        JournalLine(
          journalId: posted.id!,
          ledgerAccountId: ledgerAccountId,
          currencyCode: 'GBP',
          fxRateDate: DateTime.utc(2026, 6, 11),
          debitMinor: 4500,
        ),
      );
      final reversal = await Journal.db.insertRow(
        raw,
        Journal(
          entityId: entity.id!,
          date: DateTime.utc(2026, 6, 12),
          reference: 'JB-test-reversal',
          status: JournalStatus.posted,
          source: JournalSource.reversal,
          reversalOfJournalId: posted.id,
          postedAt: DateTime.utc(2026, 6, 12),
        ),
      );
      await JournalLine.db.insertRow(
        raw,
        JournalLine(
          journalId: reversal.id!,
          ledgerAccountId: ledgerAccountId,
          currencyCode: 'GBP',
          fxRateDate: DateTime.utc(2026, 6, 12),
          creditMinor: 4500,
        ),
      );

      final crypto = await endpoints.account.create(
        ownerSession,
        entity.id!,
        'Solana',
        AccountKind.crypto,
        'GBP',
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      final wallet = await Wallet.db.insertRow(
        raw,
        Wallet(
          entityId: entity.id!,
          accountId: crypto.id!,
          network: WalletNetwork.solanaMainnet,
          address: 'So11111111111111111111111111111111111111112',
        ),
      );

      final conversation = await AgentConversation.db.insertRow(
        raw,
        AgentConversation(
          userId: ownerId,
          entityId: entity.id!,
          title: 'Where can I cut spending?',
        ),
      );
      await AgentMessage.db.insertRow(
        raw,
        AgentMessage(
          conversationId: conversation.id!,
          role: AgentMessageRole.user,
          content: 'Where can I cut spending?',
        ),
      );

      return (
        transaction: transaction,
        posted: posted,
        reversal: reversal,
        wallet: wallet,
        conversation: conversation,
      );
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

      test(
        'then transactions, journals, wallets and conversations go too',
        () async {
          final mine = await createBook(
            ownerSession,
            'Mine',
            kind: EntityKind.company,
          );
          await endpoints.ledger.enableLedger(ownerSession, mine.id!);
          final seeded = await seedActivity(mine);
          final raw = sessionBuilder.build();
          expect(
            await TransactionLine.db.count(
              raw,
              where: (t) =>
                  t.transactionId.equals(seeded.transaction.transaction.id),
            ),
            2,
          );
          expect(
            await JournalLine.db.count(
              raw,
              where: (t) => t.journalId.equals(seeded.posted.id),
            ),
            1,
          );
          expect(
            await AgentMessage.db.count(
              raw,
              where: (t) => t.conversationId.equals(seeded.conversation.id),
            ),
            1,
          );

          await endpoints.settings.deleteAccount(ownerSession);

          final after = sessionBuilder.build();
          expect(
            await Transaction.db.count(
              after,
              where: (t) => t.entityId.equals(mine.id),
            ),
            0,
          );
          expect(
            await TransactionLine.db.count(
              after,
              where: (t) =>
                  t.transactionId.equals(seeded.transaction.transaction.id),
            ),
            0,
          );
          for (final journal in [seeded.posted, seeded.reversal]) {
            expect(
              await Journal.db.count(
                after,
                where: (t) => t.id.equals(journal.id),
              ),
              0,
            );
            expect(
              await JournalLine.db.count(
                after,
                where: (t) => t.journalId.equals(journal.id),
              ),
              0,
            );
          }
          expect(
            await Wallet.db.count(
              after,
              where: (t) => t.id.equals(seeded.wallet.id),
            ),
            0,
          );
          expect(
            await AgentConversation.db.count(
              after,
              where: (t) => t.id.equals(seeded.conversation.id),
            ),
            0,
          );
          expect(
            await AgentMessage.db.count(
              after,
              where: (t) => t.conversationId.equals(seeded.conversation.id),
            ),
            0,
          );
          expect(
            await LedgerAccount.db.count(
              after,
              where: (t) => t.entityId.equals(mine.id),
            ),
            0,
          );
        },
      );

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

    group('when a linked bank account exists', () {
      test(
        'then the Plaid item is removed after the account is gone',
        () async {
          final mine = await createBook(ownerSession, 'Mine');
          final removals = <String>[];
          final server = await _startPlaidServer(removals);
          addTearDown(() => server.close(force: true));
          usePlaid(server);
          const token = 'access-sandbox-linked';
          await addLinkedItem(mine, token: token);

          await endpoints.settings.deleteAccount(ownerSession);

          expect(removals, hasLength(1));
          expect(removals.single, contains(token));
          expect(
            await PlaidConnection.db.count(
              sessionBuilder.build(),
              where: (t) => t.entityId.equals(mine.id),
            ),
            0,
          );
        },
      );

      test(
        'when a renewing subscription refuses then Plaid is untouched',
        () async {
          final mine = await createBook(ownerSession, 'Mine');
          await recordEntitlement(ownerId, EntitlementStatus.active);
          final removals = <String>[];
          final server = await _startPlaidServer(removals);
          addTearDown(() => server.close(force: true));
          usePlaid(server);
          await addLinkedItem(mine, token: 'access-sandbox-linked');

          await expectLater(
            endpoints.settings.deleteAccount(ownerSession),
            throwsA(isA<ValidationException>()),
          );

          // The delete rolled back, so the bank link still works and no
          // /item/remove call went out.
          expect(removals, isEmpty);
          expect(
            await PlaidConnection.db.count(
              sessionBuilder.build(),
              where: (t) => t.entityId.equals(mine.id),
            ),
            2,
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
