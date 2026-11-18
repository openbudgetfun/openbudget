import 'dart:convert';

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

/// Round-trips an exception the way Serverpod sends it to a client.
Object? _roundTrip(SerializableException exception) {
  final protocol = Protocol();
  final wire = jsonDecode(protocol.encodeWithType(exception));
  return protocol.deserializeByClassName(wire as Map<String, dynamic>);
}

void main() {
  group('Given a server error sent to the client', () {
    test('then its type and message survive the wire', () {
      final decoded = _roundTrip(
        ValidationException(message: 'Amount must be positive'),
      );

      expect(decoded, isA<ValidationException>());
      expect(
        (decoded! as ValidationException).message,
        'Amount must be positive',
      );
    });

    test('then a default message is used when none is given', () {
      final decoded = _roundTrip(EntitlementRequiredException());

      expect(
        (decoded! as EntitlementRequiredException).message,
        'OpenBudget Plus is required',
      );
    });

    test('then every app-facing error is serializable', () {
      final errors = <SerializableException>[
        AuthenticationRequiredException(),
        NotFoundException(),
        ForbiddenException(),
        ValidationException(),
        TaxRulesUnavailableException(),
        FxRateUnavailableException(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: DateTime.utc(2026, 2, 2),
        ),
        EntitlementRequiredException(),
        BillingRailUnavailableException(),
        BillingProviderException(provider: 'stripe', details: 'status 502'),
        AgentAllowanceExhaustedException(),
        AgentProviderUnavailableException(),
        AgentProviderException(),
      ];

      for (final error in errors) {
        expect(_roundTrip(error).runtimeType, error.runtimeType);
      }
    });
  });
}
