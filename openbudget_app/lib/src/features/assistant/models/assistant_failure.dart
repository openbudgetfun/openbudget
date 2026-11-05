import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_client/openbudget_client.dart';

part 'assistant_failure.freezed.dart';

/// A reason the assistant could not complete a request, in terms the UI can
/// explain.
///
/// The server sends these as typed serializable exceptions;
/// [assistantFailureFrom] maps them so the presentation layer stays free of
/// transport details.
@freezed
sealed class AssistantFailure with _$AssistantFailure implements Exception {
  /// The user has no OpenBudget Plus subscription and no provider of their
  /// own.
  const factory AssistantFailure.entitlementRequired() =
      AssistantEntitlementRequired;

  /// The included monthly usage for the built-in provider is spent.
  const factory AssistantFailure.allowanceExhausted() =
      AssistantAllowanceExhausted;

  /// Neither the built-in provider nor the user's provider is usable.
  const factory AssistantFailure.providerUnavailable() =
      AssistantProviderUnavailable;

  /// The server rejected the request. [message] is the server's explanation.
  const factory AssistantFailure.validation({required String message}) =
      AssistantValidationFailure;

  /// The device could not reach the server.
  const factory AssistantFailure.network() = AssistantNetworkFailure;

  /// Something else went wrong. The UI shows a general explanation.
  const factory AssistantFailure.unknown() = AssistantUnknownFailure;
}

/// Recognises the assistant failures the server can send.
///
/// A failure the app already models is passed through so fake APIs and
/// callers can raise the same states directly.
AssistantFailure assistantFailureFrom(Object error) => switch (error) {
  AssistantFailure() => error,
  EntitlementRequiredException() =>
    const AssistantFailure.entitlementRequired(),
  AgentAllowanceExhaustedException() =>
    const AssistantFailure.allowanceExhausted(),
  AgentProviderUnavailableException() =>
    const AssistantFailure.providerUnavailable(),
  ValidationException(:final message) => AssistantFailure.validation(
    message: message,
  ),
  ServerpodClientNetworkException() => const AssistantFailure.network(),
  _ => const AssistantFailure.unknown(),
};
