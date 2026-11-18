import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payee_last_envelope_provider.g.dart';

/// Fetches the last-used envelope ID for a payee in a budget.
///
/// Returns null if the payee has no previous transactions with an envelope.
@riverpod
Future<String?> payeeLastEnvelope(
  Ref ref,
  String payeeId,
  String entityId,
) async {
  final client = ref.read(serverpodClientProvider);
  final payeeUuid = UuidValue.fromString(payeeId);
  final budgetUuid = UuidValue.fromString(entityId);
  final envelopeId = await client.payee.lastUsedEnvelopeId(
    payeeUuid,
    budgetUuid,
  );
  return envelopeId?.toString();
}
