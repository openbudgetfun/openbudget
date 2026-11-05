import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_provider_settings_service.dart';
import 'package:openbudget_server/src/agent/agent_usage_service.dart';
import 'package:openbudget_server/src/billing/billing_plan.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// The provider one agent turn uses, already authorised and decrypted.
class AgentProviderSelection {
  const AgentProviderSelection({
    required this.provider,
    required this.endpoint,
    required this.model,
    required this.apiKey,
    this.entitlement,
  });

  final AgentProvider provider;
  final Uri endpoint;
  final String model;
  final String apiKey;

  /// The subscription that funds a metered call, when there is one.
  final Entitlement? entitlement;

  /// Whether this call counts against the included allowance.
  bool get metered => provider == AgentProvider.zen;
}

/// Chooses between the user's own provider and the built-in one.
///
/// A saved BYO provider always wins and never needs a subscription. Without
/// one, the built-in provider needs an active entitlement and enough of the
/// period's allowance; a missing server key fails instead of falling back.
abstract final class AgentProviderResolver {
  /// The built-in OpenAI-compatible completions endpoint.
  static const String zenEndpoint =
      'https://opencode.ai/inference/openai/v1/chat/completions';

  /// The model behind the built-in provider.
  static const String zenModel = 'deepseek-v4.1-flash';

  static const String _zenKeyPassword = 'opencodeZenApiKey';

  /// Resolves the provider for [userId], rechecking the allowance each time.
  static Future<AgentProviderSelection> resolve(
    Session session,
    UuidValue userId,
  ) async {
    final byo = await AgentProviderSettingsService.byoProvider(
      session,
      userId,
    );
    if (byo != null) {
      await AgentEgressGuard.checkResolved(byo.endpoint);
      return AgentProviderSelection(
        provider: AgentProvider.byo,
        endpoint: byo.endpoint,
        model: byo.model,
        apiKey: byo.apiKey,
      );
    }

    final entitlement = await EntitlementService.requireActive(
      session,
      userId,
    );
    final used = await AgentUsageService.meteredMicroUsdSince(
      session,
      userId: userId,
      since: entitlement.currentPeriodStart,
    );
    if (used >= BillingPlan.includedAgentUsageMicroUsd) {
      throw AgentAllowanceExhaustedException();
    }

    final apiKey = session.passwords[_zenKeyPassword]?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw AgentProviderUnavailableException(
        'The built-in agent provider is not configured.',
      );
    }

    return AgentProviderSelection(
      provider: AgentProvider.zen,
      endpoint: Uri.parse(zenEndpoint),
      model: zenModel,
      apiKey: apiKey,
      entitlement: entitlement,
    );
  }
}
