// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_provider_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's own OpenAI-compatible provider, when they have one.

@ProviderFor(AssistantProviderSettings)
final assistantProviderSettingsProvider = AssistantProviderSettingsProvider._();

/// The user's own OpenAI-compatible provider, when they have one.
final class AssistantProviderSettingsProvider
    extends
        $AsyncNotifierProvider<
          AssistantProviderSettings,
          AgentProviderSettingsView?
        > {
  /// The user's own OpenAI-compatible provider, when they have one.
  AssistantProviderSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assistantProviderSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assistantProviderSettingsHash();

  @$internal
  @override
  AssistantProviderSettings create() => AssistantProviderSettings();
}

String _$assistantProviderSettingsHash() =>
    r'4e8472dd88ea46c93734b0a68c5f8e61c3866dc2';

/// The user's own OpenAI-compatible provider, when they have one.

abstract class _$AssistantProviderSettings
    extends $AsyncNotifier<AgentProviderSettingsView?> {
  FutureOr<AgentProviderSettingsView?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AgentProviderSettingsView?>,
              AgentProviderSettingsView?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AgentProviderSettingsView?>,
                AgentProviderSettingsView?
              >,
              AsyncValue<AgentProviderSettingsView?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
