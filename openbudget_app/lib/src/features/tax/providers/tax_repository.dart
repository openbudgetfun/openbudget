import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tax_repository.g.dart';

/// The tax API calls the app makes.
///
/// The app depends on this interface rather than the generated client so
/// tests can supply a fake API without a running server.
abstract interface class TaxRepository {
  Future<TaxProfileRecord?> getProfile(String budgetId);

  Future<TaxProfileRecord> saveProfile({
    required String budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    String? linkedBudgetId,
  });

  Future<List<TaxCategoryView>> listCategories(String budgetId);

  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  });

  Future<Transaction> setTransactionTax({
    required String transactionId,
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  });

  Future<TaxReportView> getReport(String budgetId, int startYear);
}

/// The production [TaxRepository], backed by the Serverpod client.
class ServerpodTaxRepository implements TaxRepository {
  const ServerpodTaxRepository(this._client);

  final Client _client;

  @override
  Future<TaxProfileRecord?> getProfile(String budgetId) =>
      _client.tax.getProfile(UuidValue.fromString(budgetId));

  @override
  Future<TaxProfileRecord> saveProfile({
    required String budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    String? linkedBudgetId,
  }) => _client.tax.saveProfile(
    UuidValue.fromString(budgetId),
    jurisdiction,
    entityKind,
    profileJson,
    linkedBudgetId: linkedBudgetId == null
        ? null
        : UuidValue.fromString(linkedBudgetId),
  );

  @override
  Future<List<TaxCategoryView>> listCategories(String budgetId) =>
      _client.tax.listCategories(UuidValue.fromString(budgetId));

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) => _client.tax.setEnvelopeTaxCategory(
    UuidValue.fromString(envelopeId),
    code: code,
  );

  @override
  Future<Transaction> setTransactionTax({
    required String transactionId,
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) => _client.tax.setTransactionTax(
    UuidValue.fromString(transactionId),
    code: code,
    businessUsePercent: businessUsePercent,
    salesTaxCents: salesTaxCents,
  );

  @override
  Future<TaxReportView> getReport(String budgetId, int startYear) =>
      _client.tax.getReport(
        UuidValue.fromString(budgetId),
        startYear: startYear,
      );
}

@riverpod
TaxRepository taxRepository(Ref ref) =>
    ServerpodTaxRepository(ref.watch(serverpodClientProvider));
