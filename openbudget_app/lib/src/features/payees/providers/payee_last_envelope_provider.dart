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
  String budgetId,
) async {
  final client = ref.read(serverpodClientProvider);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final payeeUuid = UuidValue.fromString(payeeId);
  // Serverpod API requires UuidValue which is experimental in uuid package.
  // ignore: experimental_member_use
  final budgetUuid = UuidValue.fromString(budgetId);
  final envelopeId = await client.payee.lastUsedEnvelopeId(
    payeeUuid,
    budgetUuid,
  );
  return envelopeId?.toString();
}
