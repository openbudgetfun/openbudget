import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rule_match_provider.g.dart';

/// Finds the matching envelope for a payee based on transaction rules.
///
/// Returns null if no rule matches or the payee has no rule.
@riverpod
Future<String?> ruleMatchEnvelope(
  Ref ref,
  String payeeId,
  String entityId,
) async {
  final client = ref.read(serverpodClientProvider);
  final budgetUuid = UuidValue.fromString(entityId);
  final payeeUuid = UuidValue.fromString(payeeId);
  final envelopeId = await client.transactionRule.findMatchingEnvelope(
    budgetUuid,
    payeeUuid,
  );
  return envelopeId?.toString();
}
