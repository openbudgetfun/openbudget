import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_usage_service.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

/// The day the usage view is read on, so the period never depends on the
/// machine's clock.
final DateTime _now = DateTime.utc(2026, 11, 14, 9);
final DateTime _periodStart = DateTime.utc(2026, 11);
final DateTime _periodEnd = DateTime.utc(2026, 12);

const int _allowance = BillingPlan.includedAgentUsageMicroUsd;

void main() {
  group('AgentUsageService.conversationsLeft', () {
    test('is null below three conversations', () {
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [],
          remainingMicroUsd: _allowance,
        ),
        isNull,
      );
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [200000, 300000],
          remainingMicroUsd: _allowance,
        ),
        isNull,
      );
    });

    test('divides what is left by the median of an odd count', () {
      // Sorted: 200,000, 300,000, 500,000. The median is 300,000, and
      // 4,000,000 / 300,000 is 13.33, which rounds down to 13.
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [500000, 200000, 300000],
          remainingMicroUsd: 4000000,
        ),
        13,
      );
    });

    test('uses the mean of the two middle costs for an even count', () {
      // Sorted: 100,000, 200,000, 300,000, 500,000. The median is
      // (200,000 + 300,000) / 2 = 250,000, and 4,000,000 / 250,000 is 16.
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [300000, 100000, 500000, 200000],
          remainingMicroUsd: 4000000,
        ),
        16,
      );
    });

    test('is zero once nothing is left', () {
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [200000, 300000, 500000],
          remainingMicroUsd: 0,
        ),
        0,
      );
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [200000, 300000, 500000],
          remainingMicroUsd: -50000,
        ),
        0,
      );
    });

    test('is null when the typical conversation costs nothing', () {
      expect(
        AgentUsageService.conversationsLeft(
          conversationCostsMicroUsd: const [0, 0, 400000],
          remainingMicroUsd: _allowance,
        ),
        isNull,
      );
    });
  });

  withServerpod('Given a user with a subscription', (
    sessionBuilder,
    endpoints,
  ) {
    late TestSessionBuilder authedSession;
    late UuidValue userId;
    late Session rawSession;
    late Entity entity;

    setUp(() async {
      const id = '92000000-0000-4000-a000-000000000001';
      final base = sessionBuilder.build();
      await base.db.unsafeExecute(
        'INSERT INTO serverpod_auth_core_user '
        '(id, "createdAt", "scopeNames", blocked) '
        "VALUES (@id::uuid, now(), '[]'::json, false) "
        'ON CONFLICT (id) DO NOTHING',
        parameters: QueryParameters.named({'id': id}),
      );
      await base.close();
      authedSession = createAuthenticatedSession(
        sessionBuilder,
        userIdentifier: id,
      );
      userId = UuidValue.fromString(id);
      rawSession = sessionBuilder.build()
        ..updateAuthenticated(
          AuthenticationInfo(id, const {}, authId: 'test-usage-$id'),
        );
      entity = await endpoints.entity.create(
        authedSession,
        'Household',
        EntityKind.individual,
        'GB',
        'GBP',
        'Europe/London',
      );
      await EntitlementService.record(
        rawSession,
        userId: userId,
        source: EntitlementSource.stripe,
        externalId: 'sub-$id',
        status: EntitlementStatus.active,
        currentPeriodStart: _periodStart,
        currentPeriodEnd: _periodEnd,
      );
    });

    Future<UuidValue> newConversation() async {
      final conversation = await AgentConversation.db.insertRow(
        rawSession,
        AgentConversation(
          userId: userId,
          entityId: entity.id!,
          title: 'Conversation',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
      return conversation.id!;
    }

    Future<void> record({
      required int costMicroUsd,
      required DateTime at,
      UuidValue? conversationId,
      AgentProvider provider = AgentProvider.zen,
    }) async {
      await AgentUsageRecord.db.insertRow(
        rawSession,
        AgentUsageRecord(
          userId: userId,
          conversationId: conversationId,
          provider: provider,
          model: 'test-model',
          promptTokens: 0,
          cachedTokens: 0,
          completionTokens: 0,
          costMicroUsd: costMicroUsd,
          createdAt: at,
        ),
      );
    }

    /// A conversation whose calls cost [costs] in all, newest call last.
    Future<void> conversation(List<int> costs, {required DateTime at}) async {
      final id = await newConversation();
      for (final cost in costs) {
        await record(costMicroUsd: cost, at: at, conversationId: id);
      }
    }

    test('then two conversations give no estimate', () async {
      await conversation([120000, 80000], at: DateTime.utc(2026, 11, 3));
      await conversation([300000], at: DateTime.utc(2026, 11, 5));

      final view = await AgentUsageService.view(rawSession, userId, now: _now);

      expect(view.usedMicroUsd, 500000);
      expect(view.conversationsLeft, isNull);
    });

    test('then three conversations are estimated from their median', () async {
      // Conversations of 200,000 (120,000 + 80,000), 300,000 and 500,000
      // (two calls of 250,000). The median is 300,000. The period's use is
      // 1,000,000, so 4,000,000 is left, and 4,000,000 / 300,000 rounds
      // down to 13.
      await conversation([120000, 80000], at: DateTime.utc(2026, 11, 3));
      await conversation([300000], at: DateTime.utc(2026, 11, 5));
      await conversation([250000, 250000], at: DateTime.utc(2026, 11, 9));

      final view = await AgentUsageService.view(rawSession, userId, now: _now);

      expect(view.allowanceMicroUsd, _allowance);
      expect(view.usedMicroUsd, 1000000);
      expect(view.conversationsLeft, 13);
    });

    test('then an earlier period still counts as history', () async {
      // A fourth conversation of 100,000 before this period joins the
      // history: the median of 100,000, 200,000, 300,000 and 500,000 is
      // 250,000. It does not count against this period's allowance, so
      // 4,000,000 / 250,000 is 16.
      await conversation([100000], at: DateTime.utc(2026, 10, 20));
      await conversation([120000, 80000], at: DateTime.utc(2026, 11, 3));
      await conversation([300000], at: DateTime.utc(2026, 11, 5));
      await conversation([250000, 250000], at: DateTime.utc(2026, 11, 9));

      final view = await AgentUsageService.view(rawSession, userId, now: _now);

      expect(view.usedMicroUsd, 1000000);
      expect(view.conversationsLeft, 16);
    });

    test('then unmetered and orphaned usage is not a conversation', () async {
      await conversation([120000, 80000], at: DateTime.utc(2026, 11, 3));
      await conversation([300000], at: DateTime.utc(2026, 11, 5));
      // Calls to the user's own provider are recorded at zero, and calls
      // of a deleted conversation have no conversation left.
      final own = await newConversation();
      await record(
        costMicroUsd: 0,
        at: DateTime.utc(2026, 11, 6),
        conversationId: own,
        provider: AgentProvider.byo,
      );
      await record(costMicroUsd: 400000, at: DateTime.utc(2026, 11, 7));

      final view = await AgentUsageService.view(rawSession, userId, now: _now);

      expect(view.conversationsLeft, isNull);
    });

    test(
      'then the estimate reaches zero when the allowance is spent',
      () async {
        await conversation([_allowance], at: DateTime.utc(2026, 11, 3));
        await conversation([1000], at: DateTime.utc(2026, 11, 4));
        await conversation([2000], at: DateTime.utc(2026, 11, 5));

        final view = await AgentUsageService.view(
          rawSession,
          userId,
          now: _now,
        );

        expect(view.usedMicroUsd, greaterThan(_allowance));
        expect(view.conversationsLeft, 0);
      },
    );

    test(
      'then the estimate counts only the newest twenty conversations',
      () async {
        // Twenty cheap conversations after one expensive one: the expensive
        // one falls out of the median window.
        await conversation([2000000], at: DateTime.utc(2026, 11));
        for (
          var hour = 0;
          hour < AgentUsageService.conversationsInMedian;
          hour++
        ) {
          await conversation(
            [10000],
            at: DateTime.utc(2026, 11, 2).add(Duration(hours: hour)),
          );
        }

        final view = await AgentUsageService.view(
          rawSession,
          userId,
          now: _now,
        );

        // Used: 2,000,000 + 20 * 10,000 = 2,200,000, so 2,800,000 is left.
        // The median of the newest twenty is 10,000, so 280 are left.
        expect(view.usedMicroUsd, 2200000);
        expect(view.conversationsLeft, 280);
      },
    );

    test('then a user with their own provider gets no estimate', () async {
      await conversation([100000], at: DateTime.utc(2026, 11, 3));
      await conversation([100000], at: DateTime.utc(2026, 11, 4));
      await conversation([100000], at: DateTime.utc(2026, 11, 5));
      await AgentProviderSettings.db.insertRow(
        rawSession,
        AgentProviderSettings(
          userId: userId,
          baseUrl: 'https://api.example.test/v1',
          model: 'byo-model',
          encryptedApiKey: 'ciphertext',
          nonce: 'nonce',
          keyHint: '1234',
        ),
      );

      final view = await AgentUsageService.view(rawSession, userId, now: _now);

      expect(view.provider, AgentProvider.byo);
      expect(view.conversationsLeft, isNull);
    });
  });
}
