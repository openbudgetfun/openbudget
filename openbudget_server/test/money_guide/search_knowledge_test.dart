import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/knowledge/knowledge_cards.g.dart';
import 'package:openbudget_server/src/money_guide/search_knowledge.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';
import '../support/tax_test_book.dart';

var _userCounter = 0;

({TestSessionBuilder session, UuidValue userId}) _newUser(
  TestSessionBuilder base,
) {
  final counter = ++_userCounter;
  final id =
      '70000000-0000-4000-a000-${counter.toRadixString(16).padLeft(12, '0')}';
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

void main() {
  withServerpod('Given searchKnowledgeResult', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;

    setUp(() async {
      final user = _newUser(sessionBuilder);
      await _ensureAuthUser(sessionBuilder, user.userId);
      authedSession = user.session;
      userId = user.userId;
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

    group('for a GB entity', () {
      test(
        'then a matching query returns cards with the required shape',
        () async {
          final entity = await createEntity(
            'Household',
            'GB',
            'GBP',
            'Europe/London',
          );

          final result = searchKnowledgeResult(
            entity: entity,
            args: {'query': 'emergency fund'},
          );

          final cards = result['cards']! as List<Object?>;
          expect(cards, isNotEmpty);
          for (final raw in cards) {
            final card = raw! as Map<String, Object?>;
            for (final key in const [
              'id',
              'citeAs',
              'title',
              'grade',
              'verifiedOn',
              'perimeter',
              'needsEvidence',
              'announced',
              'body',
              'sources',
            ]) {
              expect(card, containsPair(key, isNotNull));
            }
            final body = card['body']! as String;
            expect(body, isNot(contains('{{')));
          }
          final guidance = result['guidance']! as Map<String, Object?>;
          for (final key in const [
            'disclaimerKey',
            'scopeStatement',
            'jurisdictionState',
            'rulesVersion',
          ]) {
            expect(guidance, contains(key));
          }
          expect(result.containsKey('crossBorder'), isFalse);
        },
      );

      test('then ids reads a named card directly', () async {
        final entity = await createEntity(
          'Household',
          'GB',
          'GBP',
          'Europe/London',
        );

        // Find a known card id.
        final first = searchKnowledgeResult(
          entity: entity,
          args: {'query': 'emergency fund'},
        );
        final cards = first['cards']! as List<Object?>;
        final id = (cards.first! as Map<String, Object?>)['id']! as String;

        final byId = searchKnowledgeResult(
          entity: entity,
          args: {
            'ids': [id],
          },
        );
        final byIdCards = byId['cards']! as List<Object?>;
        expect(byIdCards, hasLength(1));
        expect((byIdCards.first! as Map<String, Object?>)['id'], id);
      });

      test('then more than 4 ids are capped at 4', () async {
        final entity = await createEntity(
          'Household',
          'GB',
          'GBP',
          'Europe/London',
        );

        final ids = knowledgeCards.take(6).map((c) => c.id).toList();
        final result = searchKnowledgeResult(
          entity: entity,
          args: {'ids': ids},
        );
        final cards = result['cards']! as List<Object?>;
        expect(cards.length, 4);
      });

      test(
        'then a cross-country search sets crossBorder and excludes GB cards',
        () async {
          final entity = await createEntity(
            'Household',
            'GB',
            'GBP',
            'Europe/London',
          );

          final result = searchKnowledgeResult(
            entity: entity,
            args: {'query': 'emergency fund', 'country': 'DE'},
          );

          final guidance = result['guidance']! as Map<String, Object?>;
          expect(guidance['crossBorder'], isTrue);
          final cards = result['cards']! as List<Object?>;
          for (final raw in cards) {
            final card = raw! as Map<String, Object?>;
            // card has no countryCode in output, but guidance crossBorder true.
            // We assert no GB-only card by checking id prefix.
            final id = card['id']! as String;
            expect(id.startsWith('gb-'), isFalse);
          }
        },
      );
    });

    group('get_tax_report via registry', () {
      test('then a KE entity returns universal hint', () async {
        final entity = await createEntity(
          'Nairobi books',
          'KE',
          'KES',
          'Africa/Nairobi',
        );
        final context = AgentToolContext(
          session: authedSession.build(),
          userId: userId,
          canPropose: false,
        );
        final raw = await const AgentToolRegistry().call(
          context,
          'get_tax_report',
          {'entityId': entity.id.toString()},
        );
        final decoded = jsonDecode(raw) as Map<String, Object?>;
        expect(decoded['jurisdictionState'], 'universal');
        expect(decoded['use'], 'get_tax_summary');
        expect(decoded.containsKey('guidance'), isTrue);
      });

      test('then a GB entity report carries a guidance block', () async {
        final entity = await createEntity(
          'Household',
          'GB',
          'GBP',
          'Europe/London',
        );
        await endpoints.tax.saveProfile(
          authedSession,
          entity.id!,
          'GB',
          'individual',
          gbProfileJson(EntityKind.individual),
        );
        final context = AgentToolContext(
          session: authedSession.build(),
          userId: userId,
          canPropose: false,
        );
        final raw = await const AgentToolRegistry().call(
          context,
          'get_tax_report',
          {'entityId': entity.id.toString()},
        );
        final decoded = jsonDecode(raw) as Map<String, Object?>;
        expect(decoded.containsKey('error'), isFalse);
        expect(decoded.containsKey('guidance'), isTrue);
      });
    });
  });
}
