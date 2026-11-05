import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_client/openbudget_client.dart';

part 'agent_access_state.freezed.dart';

/// A reason an agent-token action did not finish, in terms the screen can
/// explain.
///
/// The server sends these as typed serializable exceptions;
/// [agentAccessFailureFrom] maps them so the presentation layer stays free of
/// transport details.
@freezed
sealed class AgentAccessFailure with _$AgentAccessFailure implements Exception {
  /// The server rejected the request. [message] is the server's explanation.
  const factory AgentAccessFailure.validation({required String message}) =
      AgentAccessValidationFailure;

  /// Anything else. The screen shows a generic explanation.
  const factory AgentAccessFailure.unknown() = AgentAccessUnknownFailure;
}

/// Recognises the agent-token failures the server can send.
///
/// A failure the app already models is passed through so fake APIs and
/// callers can raise the same states directly.
AgentAccessFailure agentAccessFailureFrom(Object error) => switch (error) {
  AgentAccessFailure() => error,
  ValidationException(:final message) => AgentAccessFailure.validation(
    message: message,
  ),
  NotFoundException() ||
  AuthenticationRequiredException() => const AgentAccessFailure.unknown(),
  _ => const AgentAccessFailure.unknown(),
};

/// The token list and any action currently running.
@freezed
abstract class AgentAccessState with _$AgentAccessState {
  const factory AgentAccessState({
    @Default(<AgentAccessTokenView>[]) List<AgentAccessTokenView> tokens,
    @Default(false) bool isCreating,
    UuidValue? revokingId,
    AgentAccessFailure? failure,
  }) = _AgentAccessState;
}
