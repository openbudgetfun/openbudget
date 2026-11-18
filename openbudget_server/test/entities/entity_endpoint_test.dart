import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EntityEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late TestSessionBuilder otherSession;

    setUp(() async {
      final owner = await createAuthenticatedUser(sessionBuilder);
      final other = await createAuthenticatedUser(sessionBuilder);
      authedSession = owner.session;
      otherSession = other.session;
    });

    Matcher throwsUnsupportedCurrency(String code) => throwsA(
      isA<ValidationException>().having(
        (error) => error.message,
        'message',
        contains('Unsupported currency: $code'),
      ),
    );

    Future<Entity> createEntity([
      String name = 'Household',
      String currency = 'GBP',
    ]) => endpoints.entity.create(
      authedSession,
      name,
      EntityKind.individual,
      'GB',
      currency,
      'Europe/London',
    );

    group('when creating an entity', () {
      test('then the request fields are stored with fiscal defaults', () async {
        final entity = await createEntity();

        expect(entity.name, 'Household');
        expect(entity.kind, EntityKind.individual);
        expect(entity.countryCode, 'GB');
        expect(entity.baseCurrencyCode, 'GBP');
        expect(entity.timeZone, 'Europe/London');
        expect(entity.includeInNetWorth, isTrue);
      });

      test('then an unsupported base currency is rejected', () async {
        await expectLater(
          endpoints.entity.create(
            authedSession,
            'Bad Entity',
            EntityKind.individual,
            'GB',
            'XYZ',
            'Europe/London',
          ),
          throwsUnsupportedCurrency('XYZ'),
        );

        expect(await endpoints.entity.list(authedSession), isEmpty);
      });

      test('then a lowercase currency code is normalised', () async {
        final entity = await endpoints.entity.create(
          authedSession,
          'Lowercase',
          EntityKind.individual,
          'GB',
          ' gbp ',
          'Europe/London',
        );

        expect(entity.baseCurrencyCode, 'GBP');
      });

      test(
        'then a company excludes itself from net worth by default',
        () async {
          final company = await endpoints.entity.create(
            authedSession,
            'Ltd',
            EntityKind.company,
            'GB',
            'GBP',
            'Europe/London',
          );

          expect(company.includeInNetWorth, isFalse);
        },
      );
    });

    group('when updating an entity', () {
      test(
        'then an unsupported base currency is rejected and keeps the old',
        () async {
          final entity = await createEntity('Keep USD', 'USD');

          await expectLater(
            endpoints.entity.update(
              authedSession,
              entity.id!,
              baseCurrencyCode: 'XYZ',
            ),
            throwsUnsupportedCurrency('XYZ'),
          );

          final unchanged = await endpoints.entity.get(
            authedSession,
            entity.id!,
          );
          expect(unchanged.baseCurrencyCode, 'USD');
        },
      );

      test('then renames and the archive round trip', () async {
        final entity = await createEntity();

        final renamed = await endpoints.entity.update(
          authedSession,
          entity.id!,
          name: 'Renamed',
        );
        expect(renamed.name, 'Renamed');

        final archived = await endpoints.entity.archive(
          authedSession,
          entity.id!,
        );
        expect(archived.archivedAt, isNotNull);
        expect(await endpoints.entity.list(authedSession), isEmpty);
        expect(
          await endpoints.entity.list(authedSession, includeArchived: true),
          hasLength(1),
        );

        final restored = await endpoints.entity.unarchive(
          authedSession,
          entity.id!,
        );
        expect(restored.archivedAt, isNull);
      });
    });

    group('when listing and reading entities', () {
      test('then only the owner entities are visible', () async {
        final mine = await createEntity('Mine');
        await endpoints.entity.create(
          otherSession,
          'Theirs',
          EntityKind.individual,
          'GB',
          'GBP',
          'Europe/London',
        );

        final rows = await endpoints.entity.list(authedSession);
        expect(rows, hasLength(1));
        expect(rows.single.id, mine.id);

        await expectLater(
          endpoints.entity.get(otherSession, mine.id!),
          throwsA(isA<ForbiddenException>()),
        );
      });
    });

    group('when deleting an entity', () {
      test('then the exact name is required', () async {
        final entity = await createEntity('Fragile');

        await expectLater(
          endpoints.entity.delete(authedSession, entity.id!, 'fragile'),
          throwsA(isA<ValidationException>()),
        );
        expect(await endpoints.entity.list(authedSession), hasLength(1));

        await endpoints.entity.delete(authedSession, entity.id!, 'Fragile');
        expect(await endpoints.entity.list(authedSession), isEmpty);
      });
    });

    group('when exporting an entity', () {
      test('then every record travels with minor amounts and lines', () async {
        final entity = await createEntity();
        final account = await endpoints.account.create(
          authedSession,
          entity.id!,
          'Checking',
          AccountKind.checking,
          'GBP',
          onBudget: true,
          openingBalanceMinor: 100000,
        );
        final category = await endpoints.category.create(
          authedSession,
          entity.id!,
          'Everyday',
        );
        final envelope = await endpoints.envelope.create(
          authedSession,
          category.id!,
          'Groceries',
        );
        final payee = await endpoints.payee.create(
          authedSession,
          'Tesco',
          entity.id!,
        );
        final transaction = await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: DateTime.utc(2026, 11, 3),
            amountMinor: -2500,
            payeeId: payee.id,
            description: 'Weekly shop',
            lines: [
              TransactionLineInput(
                amountMinor: -2500,
                envelopeId: envelope.id,
              ),
            ],
          ),
        );
        final month = MonthKey.fromDate(DateTime.utc(2026, 11, 3));
        await endpoints.budget.setAllocations(
          authedSession,
          entity.id!,
          month,
          [
            AllocationInput(envelopeId: envelope.id!, allocatedMinor: 30000),
          ],
        );
        await endpoints.recurringTransaction.create(
          authedSession,
          account.id!,
          'Rent',
          -100000,
          RecurrenceFrequency.monthly,
          DateTime.utc(2026, 12, 15),
        );

        final export = await endpoints.entity.exportData(
          authedSession,
          entity.id!,
        );
        final decoded = jsonDecode(export) as Map<String, Object?>;

        expect(decoded['exportVersion'], 2);
        final entityJson = decoded['entity']! as Map<String, Object?>;
        expect(entityJson['name'], 'Household');
        expect(entityJson['baseCurrencyCode'], 'GBP');

        final accounts = decoded['accounts']! as List<Object?>;
        expect(accounts, hasLength(1));
        expect(
          (accounts.single! as Map<String, Object?>)['balanceMinor'],
          97500, // opening 100000 minus the 2500 spend.
        );

        final categories = decoded['categories']! as List<Object?>;
        expect(categories, hasLength(1));

        final envelopes = decoded['envelopes']! as List<Object?>;
        expect(
          (envelopes.single! as Map<String, Object?>)['name'],
          'Groceries',
        );

        final transactions = decoded['transactions']! as List<Object?>;
        // The opening balance fact and the weekly shop.
        expect(transactions, hasLength(2));
        final transactionJson = transactions
            .map((row) => row! as Map<String, Object?>)
            .singleWhere((row) => row['description'] == 'Weekly shop');
        expect(transactionJson['id'], transaction.transaction.id.toString());
        expect(transactionJson['amountMinor'], -2500);
        expect(transactionJson['baseAmountMinor'], -2500);
        expect(transactionJson['fxRate'], '1');
        final lines = transactionJson['lines']! as List<Object?>;
        expect(
          (lines.single! as Map<String, Object?>)['envelopeId'],
          envelope.id.toString(),
        );

        expect(
          ((decoded['payees']! as List<Object?>).single!
              as Map<String, Object?>)['name'],
          'Tesco',
        );
        expect(decoded['recurringTransactions'], hasLength(1));

        final allocations = decoded['monthlyAllocations']! as List<Object?>;
        expect(
          (allocations.single! as Map<String, Object?>)['allocatedMinor'],
          30000,
        );
      });

      test('then another user cannot export', () async {
        final entity = await createEntity();

        await expectLater(
          endpoints.entity.exportData(otherSession, entity.id!),
          throwsA(isA<ForbiddenException>()),
        );
      });
    });
  });
}
