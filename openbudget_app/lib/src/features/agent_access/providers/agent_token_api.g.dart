// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_token_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The agent-token calls used by the Agent access feature.

@ProviderFor(agentTokenApi)
final agentTokenApiProvider = AgentTokenApiProvider._();

/// The agent-token calls used by the Agent access feature.

final class AgentTokenApiProvider
    extends $FunctionalProvider<AgentTokenApi, AgentTokenApi, AgentTokenApi>
    with $Provider<AgentTokenApi> {
  /// The agent-token calls used by the Agent access feature.
  AgentTokenApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentTokenApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentTokenApiHash();

  @$internal
  @override
  $ProviderElement<AgentTokenApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AgentTokenApi create(Ref ref) {
    return agentTokenApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentTokenApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentTokenApi>(value),
    );
  }
}

String _$agentTokenApiHash() => r'115732adec3386d18db143b0c31a23b1854e2e47';
