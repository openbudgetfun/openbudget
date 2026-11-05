import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_client/openbudget_client.dart';

void main() {
  group('assistantFailureFrom', () {
    test('passes an assistant failure through unchanged', () {
      const failure = AssistantFailure.allowanceExhausted();

      expect(assistantFailureFrom(failure), same(failure));
    });

    test('recognises an entitlement requirement', () {
      expect(
        assistantFailureFrom(EntitlementRequiredException()),
        const AssistantFailure.entitlementRequired(),
      );
    });

    test('recognises an exhausted allowance', () {
      expect(
        assistantFailureFrom(AgentAllowanceExhaustedException()),
        const AssistantFailure.allowanceExhausted(),
      );
    });

    test('recognises an unavailable provider', () {
      expect(
        assistantFailureFrom(AgentProviderUnavailableException()),
        const AssistantFailure.providerUnavailable(),
      );
    });

    test('keeps the server message for a validation failure', () {
      final failure = assistantFailureFrom(
        ValidationException(message: 'Message must not be empty.'),
      );

      expect(
        failure,
        const AssistantFailure.validation(
          message: 'Message must not be empty.',
        ),
      );
    });

    test('recognises a network failure', () {
      expect(
        assistantFailureFrom(
          const ServerpodClientNetworkException('offline'),
        ),
        const AssistantFailure.network(),
      );
    });

    test('does not guess from an exception name', () {
      expect(
        assistantFailureFrom(Exception('EntitlementRequiredException')),
        const AssistantFailure.unknown(),
      );
    });

    test('falls back to an unknown failure', () {
      expect(
        assistantFailureFrom(StateError('something broke')),
        const AssistantFailure.unknown(),
      );
    });
  });
}
