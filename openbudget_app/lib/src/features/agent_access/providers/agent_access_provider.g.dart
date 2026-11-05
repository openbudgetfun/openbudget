// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_access_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's personal access tokens for external agents.
///
/// Creating and revoking update the row in place before re-reading the list,
/// so a failed refresh never hides a token that already changed on the server.

@ProviderFor(AgentAccessTokens)
final agentAccessTokensProvider = AgentAccessTokensProvider._();

/// The signed-in user's personal access tokens for external agents.
///
/// Creating and revoking update the row in place before re-reading the list,
/// so a failed refresh never hides a token that already changed on the server.
final class AgentAccessTokensProvider
    extends $AsyncNotifierProvider<AgentAccessTokens, AgentAccessState> {
  /// The signed-in user's personal access tokens for external agents.
  ///
  /// Creating and revoking update the row in place before re-reading the list,
  /// so a failed refresh never hides a token that already changed on the server.
  AgentAccessTokensProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentAccessTokensProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentAccessTokensHash();

  @$internal
  @override
  AgentAccessTokens create() => AgentAccessTokens();
}

String _$agentAccessTokensHash() => r'168bf3d07809a15265bbab22cf291e08784476ba';

/// The signed-in user's personal access tokens for external agents.
///
/// Creating and revoking update the row in place before re-reading the list,
/// so a failed refresh never hides a token that already changed on the server.

abstract class _$AgentAccessTokens extends $AsyncNotifier<AgentAccessState> {
  FutureOr<AgentAccessState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AgentAccessState>, AgentAccessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AgentAccessState>, AgentAccessState>,
              AsyncValue<AgentAccessState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
