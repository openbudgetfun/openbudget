import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Records model usage and answers how much of the allowance it consumed.
abstract final class AgentUsageService {
  /// Metered conversations the user needs before the usage view estimates how
  /// many are left (docs/money-guide.md, section 9.3).
  static const int minConversationsForEstimate = 3;

  /// How many of the user's most recent metered conversations the median
  /// reads, so the estimate follows how they use the guide now.
  static const int conversationsInMedian = 20;

  /// Total metered spend since [since], in micro-dollars.
  ///
  /// Only the built-in provider is metered; BYO calls are recorded at zero
  /// and never count against the included allowance.
  static Future<int> meteredMicroUsdSince(
    Session session, {
    required UuidValue userId,
    required DateTime since,
  }) async {
    final rows = await AgentUsageRecord.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.provider.equals(AgentProvider.zen) &
          (t.createdAt >= since.toUtc()),
    );
    return rows.fold<int>(
      0,
      (total, row) => total + row.costMicroUsd,
    );
  }

  /// Persists the usage of one call and returns the stored row.
  static Future<AgentUsageRecord> record(
    Session session, {
    required UuidValue userId,
    required UuidValue conversationId,
    required AgentProvider provider,
    required String model,
    required ChatCompletionUsage usage,
  }) {
    final costMicroUsd = provider == AgentProvider.zen ? usage.costMicroUsd : 0;
    return AgentUsageRecord.db.insertRow(
      session,
      AgentUsageRecord(
        userId: userId,
        conversationId: conversationId,
        provider: provider,
        model: model,
        promptTokens: usage.promptTokens,
        cachedTokens: usage.cachedTokens,
        completionTokens: usage.completionTokens,
        costMicroUsd: costMicroUsd,
      ),
    );
  }

  /// The total metered cost of each of the user's most recent conversations,
  /// newest first, at most [conversationsInMedian] of them.
  ///
  /// A conversation the user deleted keeps its usage rows without a
  /// conversation, so it no longer counts.
  static Future<List<int>> recentConversationCostsMicroUsd(
    Session session,
    UuidValue userId,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT SUM("costMicroUsd")::bigint
FROM agent_usage_record
WHERE "userId" = @userId::uuid
  AND "provider" = @provider
  AND "conversationId" IS NOT NULL
GROUP BY "conversationId"
ORDER BY MAX("createdAt") DESC, "conversationId" DESC
LIMIT @limit
''',
      parameters: QueryParameters.named({
        'userId': userId.toString(),
        'provider': AgentProvider.zen.name,
        'limit': conversationsInMedian,
      }),
    );
    return [for (final row in rows) row.first! as int];
  }

  /// About how many typical conversations [remainingMicroUsd] covers, or null
  /// when the user has had fewer than [minConversationsForEstimate] or the
  /// typical conversation costs nothing.
  ///
  /// "Typical" is the median of [conversationCostsMicroUsd]. With an even
  /// count it is the mean of the two middle costs, rounded down. The result
  /// rounds down too, so the estimate never promises more than is left.
  static int? conversationsLeft({
    required List<int> conversationCostsMicroUsd,
    required int remainingMicroUsd,
  }) {
    final count = conversationCostsMicroUsd.length;
    if (count < minConversationsForEstimate) return null;

    final sorted = [...conversationCostsMicroUsd]..sort();
    final median = count.isOdd
        ? sorted[count ~/ 2]
        : (sorted[count ~/ 2 - 1] + sorted[count ~/ 2]) ~/ 2;
    if (median <= 0) return null;
    return remainingMicroUsd <= 0 ? 0 : remainingMicroUsd ~/ median;
  }

  /// How much of this period's allowance the user has left.
  ///
  /// [now] picks the subscription period; leave it out to use the clock.
  static Future<AgentUsageView> view(
    Session session,
    UuidValue userId, {
    DateTime? now,
  }) async {
    final byo = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    final entitlement = await EntitlementService.activeFor(
      session,
      userId,
      now: now,
    );

    if (byo != null) {
      return AgentUsageView(
        provider: AgentProvider.byo,
        allowanceMicroUsd: 0,
        usedMicroUsd: 0,
        periodEnd: entitlement?.currentPeriodEnd,
      );
    }

    final since = entitlement?.currentPeriodStart ?? DateTime.utc(1970);
    final used = await meteredMicroUsdSince(
      session,
      userId: userId,
      since: since,
    );
    return AgentUsageView(
      provider: AgentProvider.zen,
      allowanceMicroUsd: BillingPlan.includedAgentUsageMicroUsd,
      usedMicroUsd: used,
      periodEnd: entitlement?.currentPeriodEnd,
      conversationsLeft: conversationsLeft(
        conversationCostsMicroUsd: await recentConversationCostsMicroUsd(
          session,
          userId,
        ),
        remainingMicroUsd: BillingPlan.includedAgentUsageMicroUsd - used,
      ),
    );
  }
}
