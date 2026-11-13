import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_repository.g.dart';

/// The tax API calls the app makes.
///
/// The app depends on this interface rather than the generated client so
/// tests can supply a fake API without a running server.
abstract interface class TaxRepository {
  Future<TaxProfileRecord?> getProfile(String entityId);

  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  });

  Future<List<TaxCategoryView>> listCategories(String entityId);

  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  });

  Future<TransactionView> setLineTax({
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  });

  Future<TaxReportView> getReport(String entityId, int startYear);

  /// The tax-ready summary for any entity, pack country or not.
  ///
  /// A null [startYear] lets the server pick the year containing the
  /// entity's local today.
  Future<TaxSummaryView> getSummary(String entityId, {int? startYear});

  /// A signed link to the summary ZIP; it stops working after ten minutes.
  Future<String> createExportLink(String entityId, {int? startYear});
}

/// The production [TaxRepository], backed by the Serverpod client.
class ServerpodTaxRepository implements TaxRepository {
  const ServerpodTaxRepository(this._client);

  final Client _client;

  @override
  Future<TaxProfileRecord?> getProfile(String entityId) =>
      _client.tax.getProfile(UuidValue.fromString(entityId));

  @override
  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) => _client.tax.saveProfile(
    UuidValue.fromString(entityId),
    jurisdiction,
    entityKind,
    profileJson,
  );

  @override
  Future<List<TaxCategoryView>> listCategories(String entityId) =>
      _client.tax.listCategories(UuidValue.fromString(entityId));

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) => _client.tax.setEnvelopeTaxCategory(
    UuidValue.fromString(envelopeId),
    code: code,
  );

  @override
  Future<TransactionView> setLineTax({
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) => _client.tax.setLineTax(
    UuidValue.fromString(transactionLineId),
    taxCategoryCode: code,
    businessUsePercent: businessUsePercent,
    salesTaxMinor: salesTaxMinor,
  );

  @override
  Future<TaxReportView> getReport(String entityId, int startYear) =>
      _client.tax.getReport(
        UuidValue.fromString(entityId),
        startYear: startYear,
      );

  @override
  Future<TaxSummaryView> getSummary(String entityId, {int? startYear}) =>
      _client.tax.getSummary(
        UuidValue.fromString(entityId),
        startYear: startYear,
      );

  @override
  Future<String> createExportLink(String entityId, {int? startYear}) =>
      _client.tax.createExportLink(
        UuidValue.fromString(entityId),
        startYear: startYear,
      );
}

@riverpod
TaxRepository taxRepository(Ref ref) =>
    ServerpodTaxRepository(ref.watch(serverpodClientProvider));
