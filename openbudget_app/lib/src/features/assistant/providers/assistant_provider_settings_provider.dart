import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_provider_settings_provider.g.dart';

/// The user's own OpenAI-compatible provider, when they have one.
@riverpod
class AssistantProviderSettings extends _$AssistantProviderSettings {
  @override
  Future<AgentProviderSettingsView?> build() =>
      ref.watch(assistantApiProvider).getProviderSettings();

  /// Saves the provider and shows the stored view the server returns.
  Future<AgentProviderSettingsView> save({
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async {
    final saved = await ref
        .read(assistantApiProvider)
        .saveProviderSettings(baseUrl: baseUrl, model: model, apiKey: apiKey);
    if (!ref.mounted) return saved;

    state = AsyncData(saved);
    ref.invalidate(assistantUsageProvider);
    return saved;
  }

  /// Removes the provider so the built-in provider is used again.
  Future<void> remove() async {
    await ref.read(assistantApiProvider).clearProviderSettings();
    if (!ref.mounted) return;

    state = const AsyncData(null);
    ref.invalidate(assistantUsageProvider);
  }
}
