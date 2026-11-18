import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '90000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
  return (
    session: createAuthenticatedSession(base, userIdentifier: id),
    userId: UuidValue.fromString(id),
  );
}

Future<void> _ensureAuthUser(
  TestSessionBuilder base,
  UuidValue userId,
) async {
  final session = base.build();
  await session.db.unsafeExecute(
    'INSERT INTO serverpod_auth_core_user '
    '(id, "createdAt", "scopeNames", blocked) '
    "VALUES (@id::uuid, now(), '[]'::json, false) "
    'ON CONFLICT (id) DO NOTHING',
    parameters: QueryParameters.named({'id': userId.toString()}),
  );
  await session.close();
}

DateTime _firstDayOfMonth(int monthKey) =>
    DateTime.utc(monthKey ~/ 100, monthKey % 100);

List<int> _lastMonths(Entity entity, int months) {
  final today = EntityClock.today(entity);
  final result = <int>[];
  var year = today.year;
  var month = today.month;
  for (var index = 0; index < months; index++) {
    result.add(year * 100 + month);
    month -= 1;
    if (month == 0) {
      month = 12;
      year -= 1;
    }
  }
  return result.reversed.toList();
}

void main() {
  withServerpod('Given money guide read tools', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late DateTime Function() savedTaxSummaryClock;
    late DateTime Function() savedTaxServiceClock;

    setUp(() async {
      savedTaxSummaryClock = TaxSummaryService.clock;
      savedTaxServiceClock = TaxService.clock;
      final user = _newUser(sessionBuilder);
      await _ensureAuthUser(sessionBuilder, user.userId);
      authedSession = user.session;
      userId = user.userId;
      rawSession = sessionBuilder.build()
        ..updateAuthenticated(
          AuthenticationInfo(
            userId.toString(),
            const {},
            authId: 'test-read-$userId',
          ),
        );
    });

    tearDown(() {
      TaxSummaryService.clock = savedTaxSummaryClock;
      TaxService.clock = savedTaxServiceClock;
    });

    Future<Entity> createEntity(
      String name,
      String country,
      String currency,
      String tz,
    ) => endpoints.entity.create(
      authedSession,
      name,
      EntityKind.individual,
      country,
      currency,
      tz,
    );

    Future<AgentToolContext> ownerContext() async => AgentToolContext(
      session: rawSession,
      userId: userId,
      canPropose: false,
    );

    test('get_spending_summary aggregates seeded transactions', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
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
      final account = await endpoints.account.create(
        authedSession,
        entity.id!,
        'Checking',
        AccountKind.checking,
        'GBP',
        onBudget: true,
      );

      final monthKeys = _lastMonths(entity, 6);
      // First three months spend 2000, last three spend 4000. Income is
      // 10000 every month. Trend = (lastSum - prevSum) * 1e6 / prevSum
      // = ((-12000) - (-6000)) * 1e6 / (-6000) = 1000000.
      for (var index = 0; index < monthKeys.length; index++) {
        final month = monthKeys[index];
        final spend = index < 3 ? 2000 : 4000;
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: _firstDayOfMonth(month),
            amountMinor: 10000,
            description: 'Salary',
            lines: [TransactionLineInput(amountMinor: 10000)],
          ),
        );
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: _firstDayOfMonth(month),
            amountMinor: -spend,
            description: 'Supermarket',
            lines: [
              TransactionLineInput(
                amountMinor: -spend,
                envelopeId: envelope.id,
              ),
            ],
          ),
        );
      }

      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_spending_summary', {
        'entityId': entity.id.toString(),
        'months': 6,
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      expect(decoded['currencyCode'], 'GBP');
      expect(decoded['months'], 6);
      expect(decoded['totalIncomeMinor'], 60000);
      expect(decoded['totalSpendingMinor'], -18000);
      expect(decoded['averageIncomeMinor'], 10000);
      expect(decoded['averageSpendingMinor'], -3000);
      final envelopes = decoded['envelopes']! as List<Object?>;
      final groceryRow = envelopes.cast<Map<String, Object?>>().firstWhere(
        (row) => row['name'] == 'Groceries',
      );
      expect(groceryRow['totalIncomeMinor'], 0);
      expect(groceryRow['totalSpendingMinor'], -18000);
      expect(groceryRow['averageIncomeMinor'], 0);
      expect(groceryRow['averageSpendingMinor'], -3000);
      expect(decoded['trendRatePerMillion'], 1000000);
    });

    test('get_spending_summary caps envelopes at 20 plus Other', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final category = await endpoints.category.create(
        authedSession,
        entity.id!,
        'Everyday',
      );
      final account = await endpoints.account.create(
        authedSession,
        entity.id!,
        'Checking',
        AccountKind.checking,
        'GBP',
        onBudget: true,
      );

      final envelopes = <Envelope>[];
      for (var i = 0; i < 22; i++) {
        final env = await endpoints.envelope.create(
          authedSession,
          category.id!,
          'Env $i',
        );
        envelopes.add(env);
      }
      final month = _lastMonths(entity, 1).last;
      for (var i = 0; i < 22; i++) {
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: _firstDayOfMonth(month),
            amountMinor: -1000,
            description: 'spend',
            lines: [
              TransactionLineInput(
                amountMinor: -1000,
                envelopeId: envelopes[i].id,
              ),
            ],
          ),
        );
      }

      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_spending_summary', {
        'entityId': entity.id.toString(),
        'months': 1,
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final rows = decoded['envelopes']! as List<Object?>;
      expect(rows.length, 21);
      final other = rows.last! as Map<String, Object?>;
      expect(other['name'], 'Other');
      expect(other['totalSpendingMinor'], -2000);
    });

    test('get_spending_summary with 3 envelopes has no Other row', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final category = await endpoints.category.create(
        authedSession,
        entity.id!,
        'Everyday',
      );
      final account = await endpoints.account.create(
        authedSession,
        entity.id!,
        'Checking',
        AccountKind.checking,
        'GBP',
        onBudget: true,
      );

      final envelopes = <Envelope>[];
      for (var i = 0; i < 3; i++) {
        final env = await endpoints.envelope.create(
          authedSession,
          category.id!,
          'Env $i',
        );
        envelopes.add(env);
      }
      final month = _lastMonths(entity, 1).last;
      for (var i = 0; i < 3; i++) {
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: _firstDayOfMonth(month),
            amountMinor: -1000,
            description: 'spend',
            lines: [
              TransactionLineInput(
                amountMinor: -1000,
                envelopeId: envelopes[i].id,
              ),
            ],
          ),
        );
      }

      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_spending_summary', {
        'entityId': entity.id.toString(),
        'months': 1,
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final rows = decoded['envelopes']! as List<Object?>;
      expect(rows.length, 3);
      expect(
        rows.any((row) => (row! as Map<String, Object?>)['name'] == 'Other'),
        isFalse,
      );
    });

    test('months validation rejects 0 and 13', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final context = await ownerContext();
      const registry = AgentToolRegistry();
      for (final months in [0, 13]) {
        final raw = await registry.call(context, 'get_spending_summary', {
          'entityId': entity.id.toString(),
          'months': months,
        });
        final decoded = jsonDecode(raw) as Map<String, Object?>;
        expect(
          decoded['error'],
          contains('months must be between 1 and 12'),
          reason: 'months=$months',
        );
      }
    });

    test('ownership: each read tool refuses another user entity', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final other = _newUser(sessionBuilder);
      await _ensureAuthUser(sessionBuilder, other.userId);
      final otherSession = other.session.build()
        ..updateAuthenticated(
          AuthenticationInfo(
            other.userId.toString(),
            const {},
            authId: 'test-agent-${other.userId}',
          ),
        );
      final context = AgentToolContext(
        session: otherSession,
        userId: other.userId,
        canPropose: false,
      );
      const registry = AgentToolRegistry();
      for (final tool in [
        'get_spending_summary',
        'get_tax_calendar',
        'get_tax_summary',
      ]) {
        final raw = await registry.call(context, tool, {
          'entityId': entity.id.toString(),
        });
        final decoded = jsonDecode(raw) as Map<String, Object?>;
        expect(decoded['error'], 'Entity not found', reason: tool);
      }
    });

    test('get_tax_calendar GB deadlines equal first 10 of TaxService.listDeadlines', () async {
      TaxService.clock = () => DateTime.utc(2026, 7);
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_calendar', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final deadlines = decoded['deadlines']! as List<Object?>;
      final expected = await TaxService.listDeadlines(
        rawSession,
        entityId: entity.id!,
      );
      expect(deadlines.length, expected.take(10).length);
      final registryIds = deadlines
          .map((row) => (row! as Map<String, Object?>)['id'])
          .toList();
      final expectedIds = expected.take(10).map((d) => d.id).toList();
      expect(registryIds, expectedIds);
    });

    test('get_tax_calendar KE returns universal tax-year end', () async {
      TaxSummaryService.clock = () => DateTime.utc(2026, 7);
      final entity = await createEntity(
        'Nairobi books',
        'KE',
        'KES',
        'Africa/Nairobi',
      );
      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_calendar', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded['jurisdictionState'], 'universal');
      expect(decoded['taxYearEnd'], '2026-12-31');
    });

    test('get_tax_summary KE carries guidance universal', () async {
      final entity = await createEntity(
        'Nairobi books',
        'KE',
        'KES',
        'Africa/Nairobi',
      );
      final context = await ownerContext();
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_summary', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final guidance = decoded['guidance']! as Map<String, Object?>;
      expect(guidance['jurisdictionState'], 'universal');
      expect(decoded.containsKey('citeAs'), isFalse);
    });
  });
}
