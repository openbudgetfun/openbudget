import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Records model usage and answers how much of the allowance it consumed.
abstract final class AgentUsageService {
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

  /// How much of this period's allowance the user has left.
  static Future<AgentUsageView> view(
    Session session,
    UuidValue userId,
  ) async {
    final byo = await AgentProviderSettings.db.findFirstRow(
      session,
      where: (t) => t.userId.equals(userId),
    );
    final entitlement = await EntitlementService.activeFor(session, userId);

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
    );
  }
}
