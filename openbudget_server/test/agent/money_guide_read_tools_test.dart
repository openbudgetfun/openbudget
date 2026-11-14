import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
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

void main() {
  withServerpod('Given money guide read tools', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;

    setUp(() async {
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

      final today = EntityClock.today(entity);
      final currentMonth = today.year * 100 + today.month;
      // previous month
      var py = today.year;
      var pm = today.month - 1;
      if (pm == 0) {
        pm = 12;
        py -= 1;
      }
      final prevMonth = py * 100 + pm;

      for (final month in [currentMonth, prevMonth]) {
        await endpoints.transaction.create(
          authedSession,
          TransactionInput(
            accountId: account.id!,
            date: _firstDayOfMonth(month),
            amountMinor: -2500,
            description: 'Supermarket',
            lines: [
              TransactionLineInput(
                amountMinor: -2500,
                envelopeId: envelope.id,
              ),
            ],
          ),
        );
      }

      final context = AgentToolContext(
        session: rawSession,
        userId: userId,
        canPropose: false,
      );
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_spending_summary', {
        'entityId': entity.id.toString(),
        'months': 3,
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      expect(decoded['currencyCode'], 'GBP');
      expect(decoded['months'], 3);
      expect(decoded['totalSpendingMinor'], -5000);
      final envelopes = decoded['envelopes']! as List<Object?>;
      expect(envelopes.length, lessThanOrEqualTo(21));
      expect(decoded['trendRatePerMillion'], isNull);
    });

    test('get_tax_calendar GB returns deadlines capped at 10', () async {
      final entity = await createEntity(
        'Household',
        'GB',
        'GBP',
        'Europe/London',
      );
      final context = AgentToolContext(
        session: rawSession,
        userId: userId,
        canPropose: false,
      );
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_calendar', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final deadlines = decoded['deadlines']! as List<Object?>;
      expect(deadlines.length, lessThanOrEqualTo(10));
      expect(deadlines, isNotEmpty);
    });

    test('get_tax_calendar KE returns universal tax-year end', () async {
      final entity = await createEntity(
        'Nairobi books',
        'KE',
        'KES',
        'Africa/Nairobi',
      );
      final context = AgentToolContext(
        session: rawSession,
        userId: userId,
        canPropose: false,
      );
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_calendar', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded['jurisdictionState'], 'universal');
      expect(decoded.containsKey('taxYearEnd'), isTrue);
    });

    test('get_tax_summary KE carries guidance universal', () async {
      final entity = await createEntity(
        'Nairobi books',
        'KE',
        'KES',
        'Africa/Nairobi',
      );
      final context = AgentToolContext(
        session: rawSession,
        userId: userId,
        canPropose: false,
      );
      const registry = AgentToolRegistry();
      final raw = await registry.call(context, 'get_tax_summary', {
        'entityId': entity.id.toString(),
      });
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      expect(decoded.containsKey('error'), isFalse);
      final guidance = decoded['guidance']! as Map<String, Object?>;
      expect(guidance['jurisdictionState'], 'universal');
      expect(decoded['citeAs'], startsWith('summary-'));
    });
  });
}
