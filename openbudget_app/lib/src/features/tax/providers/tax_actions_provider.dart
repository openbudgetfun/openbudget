import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_actions_provider.g.dart';

/// Writes tax profiles and per-line categorisation, then refreshes what
/// they change. Line tax goes through `tax.setLineTax`, which posts a
/// transaction revision, so the plan and books follow.
@Riverpod(keepAlive: true)
class TaxActions extends _$TaxActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) async {
    state = const AsyncValue.loading();
    try {
      final record = await ref
          .read(taxRepositoryProvider)
          .saveProfile(
            entityId: entityId,
            jurisdiction: jurisdiction,
            entityKind: entityKind,
            profileJson: profileJson,
          );
      if (ref.mounted) {
        ref
          ..invalidate(taxProfileProvider(entityId))
          ..invalidate(taxCategoriesProvider(entityId))
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
    required String entityId,
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
          ..invalidate(budgetMonthProvider)
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

  Future<TransactionView> setLineTax({
    required String entityId,
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) async {
    state = const AsyncValue.loading();
    try {
      final view = await ref
          .read(taxRepositoryProvider)
          .setLineTax(
            transactionLineId: transactionLineId,
            code: code,
            businessUsePercent: businessUsePercent,
            salesTaxMinor: salesTaxMinor,
          );
      if (ref.mounted) {
        ref
          ..invalidate(transactionPagesProvider(entityId))
          ..invalidate(taxReportProvider);
        state = const AsyncValue.data(null);
      }
      return view;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }
}
