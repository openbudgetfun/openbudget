import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// API surface for tax profiles, categorisation, and reports.
///
/// All methods require authentication and check budget ownership.
class TaxEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the budget's tax profile, or null when none is set.
  Future<TaxProfileRecord?> getProfile(
    Session session,
    UuidValue budgetId,
  ) async => TaxService.getProfile(session, budgetId: budgetId);

  /// Creates or replaces the budget's tax profile.
  Future<TaxProfileRecord> saveProfile(
    Session session,
    UuidValue budgetId,
    String jurisdiction,
    String entityKind,
    String profileJson, {
    UuidValue? linkedBudgetId,
  }) async {
    final profile = await TaxService.saveProfile(
      session,
      budgetId: budgetId,
      jurisdiction: jurisdiction,
      entityKind: entityKind,
      profileJson: profileJson,
      linkedBudgetId: linkedBudgetId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return profile;
  }

  /// Lists the tax categories available to the budget's entity kind.
  Future<List<TaxCategoryView>> listCategories(
    Session session,
    UuidValue budgetId,
  ) async => TaxService.listCategories(session, budgetId: budgetId);

  /// Sets or clears the default tax category on an envelope.
  Future<Envelope> setEnvelopeTaxCategory(
    Session session,
    UuidValue envelopeId, {
    String? code,
  }) async {
    final envelope = await TaxService.setEnvelopeTaxCategory(
      session,
      envelopeId: envelopeId,
      code: code,
    );
    await BudgetRealtimeNotifier.notifyEnvelopeChanged(session, envelopeId);
    return envelope;
  }

  /// Sets or clears a transaction's tax treatment.
  Future<Transaction> setTransactionTax(
    Session session,
    UuidValue transactionId, {
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) async {
    final transaction = await TaxService.setTransactionTax(
      session,
      transactionId: transactionId,
      code: code,
      businessUsePercent: businessUsePercent,
      salesTaxCents: salesTaxCents,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(transaction.budgetId);
    return transaction;
  }

  /// Computes the budget's tax report for the year starting in [startYear].
  ///
  /// When [startYear] is null the tax year containing today is used.
  Future<TaxReportView> getReport(
    Session session,
    UuidValue budgetId, {
    int? startYear,
  }) async =>
      TaxService.report(session, budgetId: budgetId, startYear: startYear);
}
