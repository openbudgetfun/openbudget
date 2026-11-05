import 'package:openbudget_app/src/features/agent_access/models/agent_access_state.dart';
import 'package:openbudget_app/src/features/agent_access/providers/agent_token_api.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent_access_provider.g.dart';

final _log = ObLogger('AgentAccess');

/// The signed-in user's personal access tokens for external agents.
///
/// Creating and revoking update the row in place before re-reading the list,
/// so a failed refresh never hides a token that already changed on the server.
@riverpod
class AgentAccessTokens extends _$AgentAccessTokens {
  @override
  Future<AgentAccessState> build() async {
    final tokens = await ref.watch(agentTokenApiProvider).listAccessTokens();
    return AgentAccessState(tokens: tokens);
  }

  /// Creates a token and returns its secret.
  ///
  /// The returned [AgentAccessTokenCreated.token] is the only chance to show
  /// the secret; the server stores only its hash. A rejected request records a
  /// failure and returns null.
  Future<AgentAccessTokenCreated?> create({
    required String name,
    required bool canPropose,
  }) async {
    final current = state.value;
    if (current == null || current.isCreating) return null;
    state = AsyncData(current.copyWith(isCreating: true, failure: null));

    final AgentAccessTokenCreated created;
    try {
      created = await ref
          .read(agentTokenApiProvider)
          .createAccessToken(name: name, canPropose: canPropose);
    } on Object catch (error, stackTrace) {
      _recordFailure(
        error,
        stackTrace,
        base: current.copyWith(isCreating: false),
      );
      return null;
    }

    if (ref.mounted) {
      state = AsyncData(
        current.copyWith(
          tokens: [created.view, ...current.tokens],
          isCreating: false,
        ),
      );
    }
    await _refresh();
    return created;
  }

  /// Revokes a token and refreshes the list.
  ///
  /// Returns whether the server accepted the revocation.
  Future<bool> revoke(UuidValue id) async {
    final current = state.value;
    if (current == null || current.revokingId != null) return false;
    state = AsyncData(current.copyWith(revokingId: id, failure: null));

    final AgentAccessTokenView revoked;
    try {
      revoked = await ref.read(agentTokenApiProvider).revokeAccessToken(id);
    } on Object catch (error, stackTrace) {
      _recordFailure(
        error,
        stackTrace,
        base: current.copyWith(revokingId: null),
      );
      return false;
    }

    if (ref.mounted) {
      state = AsyncData(
        current.copyWith(
          tokens: [
            for (final token in current.tokens)
              if (token.id == revoked.id) revoked else token,
          ],
          revokingId: null,
        ),
      );
    }
    await _refresh();
    return true;
  }

  /// Clears the last failure after the screen has shown its message.
  void clearFailure() {
    final current = state.value;
    if (current == null || current.failure == null) return;
    state = AsyncData(current.copyWith(failure: null));
  }

  /// Re-reads the list after a successful action.
  ///
  /// A failed refresh keeps the row the action already updated: the change
  /// reached the server, and a newly created secret must still reach the
  /// person who asked for it.
  Future<void> _refresh() async {
    if (!ref.mounted) return;
    try {
      final tokens = await ref.read(agentTokenApiProvider).listAccessTokens();
      if (!ref.mounted) return;
      state = AsyncData(AgentAccessState(tokens: tokens));
    } on Object catch (error, stackTrace) {
      _log.warning(
        'refresh.failed error=${error.runtimeType}',
        error,
        stackTrace,
      );
    }
  }

  void _recordFailure(
    Object error,
    StackTrace stackTrace, {
    required AgentAccessState base,
  }) {
    _log.warning(
      'action.failed error=${error.runtimeType}',
      error,
      stackTrace,
    );
    if (!ref.mounted) return;
    state = AsyncData(base.copyWith(failure: agentAccessFailureFrom(error)));
  }
}
