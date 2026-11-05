import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_actions_provider.g.dart';

/// Writes tax profiles and categorisation, then refreshes what they change.
@Riverpod(keepAlive: true)
class TaxActions extends _$TaxActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<TaxProfileRecord> saveProfile({
    required String budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    String? linkedBudgetId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await ref
          .read(taxRepositoryProvider)
          .saveProfile(
            budgetId: budgetId,
            jurisdiction: jurisdiction,
            entityKind: entityKind,
            profileJson: profileJson,
            linkedBudgetId: linkedBudgetId,
          );
      if (ref.mounted) {
        ref
          ..invalidate(taxProfileProvider(budgetId))
          ..invalidate(taxCategoriesProvider(budgetId))
          ..invalidate(taxReportProvider);
        state = const AsyncValue.data(null);
      }
      return record;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<Envelope> setEnvelopeTaxCategory({
    required String budgetId,
    required String envelopeId,
    String? code,
  }) async {
    state = const AsyncValue.loading();
    try {
      final envelope = await ref
          .read(taxRepositoryProvider)
          .setEnvelopeTaxCategory(envelopeId: envelopeId, code: code);
      if (ref.mounted) {
        ref
          ..invalidate(budgetSummaryProvider(budgetId))
          ..invalidate(budgetMonthlySummaryProvider(budgetId))
          ..invalidate(taxReportProvider);
        state = const AsyncValue.data(null);
      }
      return envelope;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<Transaction> setTransactionTax({
    required String budgetId,
    required String transactionId,
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) async {
    state = const AsyncValue.loading();
    try {
      final transaction = await ref
          .read(taxRepositoryProvider)
          .setTransactionTax(
            transactionId: transactionId,
            code: code,
            businessUsePercent: businessUsePercent,
            salesTaxCents: salesTaxCents,
          );
      if (ref.mounted) {
        ref
          ..invalidate(transactionListProvider(budgetId))
          ..invalidate(budgetSummaryProvider(budgetId))
          ..invalidate(taxReportProvider);
        state = const AsyncValue.data(null);
      }
      return transaction;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }
}
