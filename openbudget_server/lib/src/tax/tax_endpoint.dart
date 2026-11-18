import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/export/tax_export_service.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for tax profiles, line coding, envelope defaults, reports,
/// the filing calendar and tax-ready summaries.
///
/// Every method requires authentication and delegates to [TaxService], which
/// owns the entity boundary and the write rules.
class TaxEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the entity's canonical tax profile, or null when none is set.
  Future<TaxProfileRecord?> getProfile(
    Session session,
    UuidValue entityId,
  ) => TaxService.getProfile(session, entityId: entityId);

  /// Creates or replaces the entity's tax profile.
  ///
  /// [jurisdiction] and [entityKind] are kept for the documented §7.1 surface,
  /// but they are redundant assertions: the entity's country and kind are the
  /// source of truth and always rewrite the stored profile, and a conflicting
  /// value rejects. The personal-business link is set on the entity, not here.
  Future<TaxProfileRecord> saveProfile(
    Session session,
    UuidValue entityId,
    String jurisdiction,
    String entityKind,
    String profileJson,
  ) => TaxService.saveProfile(
    session,
    entityId: entityId,
    jurisdiction: jurisdiction,
    entityKind: entityKind,
    profileJson: profileJson,
  );

  /// Lists the tax categories available to the entity's kind.
  Future<List<TaxCategoryView>> listCategories(
    Session session,
    UuidValue entityId,
  ) => TaxService.listCategories(session, entityId: entityId);

  /// Sets or clears the default tax category on an envelope.
  ///
  /// A null or blank [code] clears the default, matching the existing surface.
  Future<Envelope> setEnvelopeTaxCategory(
    Session session,
    UuidValue envelopeId, {
    String? code,
  }) => TaxService.setEnvelopeTaxCategory(
    session,
    envelopeId: envelopeId,
    code: code,
  );

  /// Sets or clears one transaction line's tax treatment.
  ///
  /// Null leaves a field unchanged; [clearTaxCategoryCode] clears only the
  /// category. The write uses the transaction writer's rules, so reconciled
  /// rows, period locks, transfers and ledger revisions behave exactly as an
  /// ordinary line edit.
  Future<TransactionView> setLineTax(
    Session session,
    UuidValue transactionLineId, {
    String? taxCategoryCode,
    bool? clearTaxCategoryCode,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) => TaxService.setLineTax(
    session,
    transactionLineId: transactionLineId,
    taxCategoryCode: taxCategoryCode,
    clearTaxCategoryCode: clearTaxCategoryCode,
    businessUsePercent: businessUsePercent,
    salesTaxMinor: salesTaxMinor,
  );

  /// Computes the entity's tax report for the year starting in [startYear].
  ///
  /// When [startYear] is null the tax year containing the entity's local today
  /// is used.
  Future<TaxReportView> getReport(
    Session session,
    UuidValue entityId, {
    int? startYear,
  }) => TaxService.report(
    session,
    entityId: entityId,
    startYear: startYear,
  );

  /// Lists the entity's upcoming filing and payment deadlines, soonest
  /// first.
  ///
  /// Covers the entity's local today to a year ahead. An entity whose
  /// country has no rule pack gets an empty list.
  Future<List<TaxDeadlineView>> listDeadlines(
    Session session,
    UuidValue entityId,
  ) => TaxService.listDeadlines(session, entityId: entityId);

  /// Builds the entity's tax-ready summary for the year starting in
  /// [startYear].
  ///
  /// When [startYear] is null the year containing the entity's local today
  /// is used. Every country is served: a pack country uses its pack's tax
  /// year, any other country its universal tax year, and a company its own
  /// financial year.
  Future<TaxSummaryView> getSummary(
    Session session,
    UuidValue entityId, {
    int? startYear,
  }) => TaxSummaryService.build(
    session,
    entityId: entityId,
    startYear: startYear,
  );

  /// Creates a short-lived signed download link for the entity's tax
  /// summary export for the year starting in [startYear].
  ///
  /// When [startYear] is null the year containing the entity's local today
  /// is used. The link carries only opaque ids, the year and an expiry
  /// inside its HMAC token — no name, email or entity name — and stops
  /// working after ten minutes. The app opens it with `url_launcher`.
  Future<String> createExportLink(
    Session session,
    UuidValue entityId, {
    int? startYear,
  }) => TaxExportService.createExportLink(
    session,
    entityId: entityId,
    startYear: startYear,
  );
}
