import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rule_actions_provider.g.dart';

/// Provides mutation operations for transaction rules.
@riverpod
class RuleActions extends _$RuleActions {
  @override
  FutureOr<void> build() {}

  /// Creates a new transaction rule.
  Future<TransactionRule> createRule({
    required String budgetId,
    required String payeeId,
    required String targetEnvelopeId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      final rule = await client.transactionRule.create(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(payeeId),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(targetEnvelopeId),
      );
      if (ref.mounted) {
        ref.invalidate(ruleListProvider(budgetId));
      }
      return rule;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Toggles a rule's enabled state.
  Future<TransactionRule> toggleRule({
    required String ruleId,
    required bool enabled,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      final rule = await client.transactionRule.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(ruleId),
        enabled: enabled,
      );
      if (ref.mounted) {
        ref.invalidate(ruleListProvider(budgetId));
      }
      return rule;
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  /// Deletes a transaction rule.
  Future<void> deleteRule({
    required String ruleId,
    required String budgetId,
  }) async {
    final client = ref.read(serverpodClientProvider);
    try {
      await client.transactionRule.delete(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(ruleId),
      );
      if (ref.mounted) {
        ref.invalidate(ruleListProvider(budgetId));
      }
    } on Exception catch (e, st) {
      if (ref.mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }
}
