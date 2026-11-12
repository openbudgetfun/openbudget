import 'dart:convert';

import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

const testEntityId = '00000000-0000-0000-0000-0000000000a401';
const testOwnerId = '00000000-0000-0000-0000-0000000000a402';
const testEnvelopeId = '00000000-0000-0000-0000-0000000000a403';
const testTransactionId = '00000000-0000-0000-0000-0000000000a404';
const testTransactionLineId = '00000000-0000-0000-0000-0000000000a407';

/// Kept for the screens that still spell the id `testBudgetId`.
const String testBudgetId = testEntityId;

Entity testEntity({
  String id = testEntityId,
  String name = 'My Budget',
  String baseCurrencyCode = 'GBP',
  EntityKind kind = EntityKind.individual,
  String countryCode = 'GB',
}) => Entity(
  id: UuidValue.fromString(id),
  name: name,
  kind: kind,
  countryCode: countryCode,
  baseCurrencyCode: baseCurrencyCode,
  timeZone: 'Europe/London',
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 5,
  ownerId: UuidValue.fromString(testOwnerId),
  createdAt: DateTime.utc(2026),
);

TaxProfileRecord taxProfileRecord({
  TaxProfile? profile,
  DateTime? updatedAt,
}) {
  final resolved =
      profile ?? const GbTaxProfile(entityKind: EntityKind.individual);
  return TaxProfileRecord(
    id: UuidValue.fromString('00000000-0000-0000-0000-0000000000a405'),
    entityId: UuidValue.fromString(testEntityId),
    profileJson: jsonEncode(resolved.toJson()),
    createdAt: DateTime.utc(2026),
    updatedAt: updatedAt ?? DateTime.utc(2026, 6),
  );
}

TaxBandSliceView taxBand({
  String label = 'Basic rate',
  int baseMinor = 3770000,
  int rateBasisPoints = 2000,
  int taxMinor = 754000,
}) => TaxBandSliceView(
  label: label,
  baseMinor: baseMinor,
  rateBasisPoints: rateBasisPoints,
  taxMinor: taxMinor,
);

TaxLiabilityView taxLiability({
  String label = 'Income tax',
  int amountMinor = 748000,
  List<TaxBandSliceView>? bands,
}) => TaxLiabilityView(
  label: label,
  amountMinor: amountMinor,
  bands: bands ?? [taxBand()],
);

TaxReportLineView taxLine({
  String label = 'Employment income',
  int amountMinor = 4200000,
  String? code = 'gb.ind.employment',
  String? reportReference = 'SA100 box 1',
  int entryCount = 12,
}) => TaxReportLineView(
  label: label,
  amountMinor: amountMinor,
  code: code,
  reportReference: reportReference,
  entryCount: entryCount,
);

TaxOpportunityView taxOpportunity({
  String id = 'gb.pension_annual_allowance',
  String title = 'Use your pension annual allowance',
  String explanation =
      'Pay into a private pension to get tax relief at your marginal rate.',
  int? estimatedSavingMinor = 120000,
  DateTime? deadline,
  String source =
      'https://www.gov.uk/tax-on-your-private-pension/annual-allowance',
}) => TaxOpportunityView(
  id: id,
  title: title,
  explanation: explanation,
  estimatedSavingMinor: estimatedSavingMinor,
  deadline: deadline,
  source: source,
);

TaxReportView taxReportView({
  String jurisdiction = 'GB',
  int startYear = 2026,
  String yearLabel = '2026/27',
  String currencyCode = 'GBP',
  EntityKind entityKind = EntityKind.individual,
  List<TaxReportLineView>? lines,
  List<TaxLiabilityView>? liabilities,
  int totalLiabilityMinor = 748000,
  int alreadyPaidMinor = 0,
  int balanceDueMinor = 748000,
  List<String>? assumptions,
  List<String>? sources,
  int uncategorizedCount = 0,
  int convertedEntryCount = 0,
  List<TaxOpportunityView>? opportunities,
}) => TaxReportView(
  jurisdiction: jurisdiction,
  startYear: startYear,
  yearLabel: yearLabel,
  yearStart: DateTime.utc(startYear, 4, 6),
  yearEnd: DateTime.utc(startYear + 1, 4, 6),
  entityKind: entityKind,
  currencyCode: currencyCode,
  lines: lines ?? [taxLine()],
  liabilities: liabilities ?? [taxLiability()],
  totalLiabilityMinor: totalLiabilityMinor,
  alreadyPaidMinor: alreadyPaidMinor,
  balanceDueMinor: balanceDueMinor,
  assumptions: assumptions ?? const ['No other income outside OpenBudget.'],
  sources: sources ?? const ['https://www.gov.uk/income-tax-rates'],
  rulesVerifiedOn: DateTime.utc(2026, 4),
  uncategorizedCount: uncategorizedCount,
  convertedEntryCount: convertedEntryCount,
  opportunities: opportunities ?? [taxOpportunity()],
);

TaxReportView refundTaxReport() => taxReportView(
  totalLiabilityMinor: 100000,
  alreadyPaidMinor: 250000,
  balanceDueMinor: -150000,
);

TaxCategoryView taxCategory({
  String code = 'gb.ind.employment',
  String label = 'Employment income',
  String kind = 'income',
  String? reportReference = 'SA100 box 1',
  String? description = 'Pay and taxable benefits from employment.',
}) => TaxCategoryView(
  code: code,
  label: label,
  kind: kind,
  reportReference: reportReference,
  description: description,
);

List<TaxCategoryView> testCategories() => [
  taxCategory(),
  taxCategory(
    code: 'gb.se.office_costs',
    label: 'Office costs',
    kind: 'expense',
    reportReference: 'SA103F box 20',
  ),
  taxCategory(
    code: 'gb.ind.pension_contributions',
    label: 'Pension contributions',
    kind: 'relief',
  ),
];

/// A transaction view whose line carries the tax coding the fake records.
TransactionView taxTransactionView({
  String? taxCategoryCode,
  int? businessUsePercent,
  int? salesTaxMinor,
}) => TransactionView(
  transaction: Transaction(
    id: UuidValue.fromString(testTransactionId),
    entityId: UuidValue.fromString(testEntityId),
    accountId: UuidValue.fromString('00000000-0000-0000-0000-0000000000a408'),
    date: DateTime.utc(2026, 5),
    amountMinor: -4250,
    baseAmountMinor: -4250,
    fxRateDate: DateTime.utc(2026, 5),
    description: 'Train ticket',
  ),
  lines: [
    TransactionLine(
      id: UuidValue.fromString(testTransactionLineId),
      transactionId: UuidValue.fromString(testTransactionId),
      amountMinor: -4250,
      baseAmountMinor: -4250,
      taxCategoryCode: taxCategoryCode,
      businessUsePercent: businessUsePercent,
      salesTaxMinor: salesTaxMinor,
    ),
  ],
  accountCurrencyCode: 'GBP',
  accountName: 'Current account',
);

/// An in-memory [TaxRepository] for widget and provider tests.
class FakeTaxRepository implements TaxRepository {
  FakeTaxRepository({
    this.profile,
    this.categories,
    Map<int, TaxReportView>? reports,
    this.defaultReport,
    this.profileError,
    this.categoriesError,
    this.reportError,
    this.saveError,
    this.envelopeError,
    this.lineError,
  }) : reports = reports ?? {};

  TaxProfileRecord? profile;
  List<TaxCategoryView>? categories;
  final Map<int, TaxReportView> reports;
  TaxReportView? defaultReport;
  Exception? profileError;
  Exception? categoriesError;
  Exception? reportError;
  Exception? saveError;
  Exception? envelopeError;
  Exception? lineError;

  final List<({String entityId, int startYear})> reportCalls = [];
  final List<
    ({
      String entityId,
      String jurisdiction,
      String entityKind,
      String profileJson,
    })
  >
  savedProfiles = [];
  final List<({String envelopeId, String? code})> envelopeUpdates = [];
  final List<
    ({
      String transactionLineId,
      String? code,
      int? businessUsePercent,
      int? salesTaxMinor,
    })
  >
  lineUpdates = [];

  @override
  Future<TaxProfileRecord?> getProfile(String entityId) async {
    if (profileError != null) throw profileError!;
    return profile;
  }

  @override
  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) async {
    if (saveError != null) throw saveError!;
    savedProfiles.add((
      entityId: entityId,
      jurisdiction: jurisdiction,
      entityKind: entityKind,
      profileJson: profileJson,
    ));
    final record = TaxProfileRecord(
      id: UuidValue.fromString('00000000-0000-0000-0000-0000000000a499'),
      entityId: UuidValue.fromString(entityId),
      profileJson: profileJson,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026, 7),
    );
    profile = record;
    return record;
  }

  @override
  Future<List<TaxCategoryView>> listCategories(String entityId) async {
    if (categoriesError != null) throw categoriesError!;
    return categories ?? testCategories();
  }

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) async {
    if (envelopeError != null) throw envelopeError!;
    envelopeUpdates.add((envelopeId: envelopeId, code: code));
    return Envelope(
      id: UuidValue.fromString(envelopeId),
      entityId: UuidValue.fromString(testEntityId),
      categoryId: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000000a406',
      ),
      name: 'Rent',
      sortOrder: 0,
      taxCategoryCode: code,
    );
  }

  @override
  Future<TransactionView> setLineTax({
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) async {
    if (lineError != null) throw lineError!;
    lineUpdates.add((
      transactionLineId: transactionLineId,
      code: code,
      businessUsePercent: businessUsePercent,
      salesTaxMinor: salesTaxMinor,
    ));
    return taxTransactionView(
      taxCategoryCode: code,
      businessUsePercent: businessUsePercent,
      salesTaxMinor: salesTaxMinor,
    );
  }

  @override
  Future<TaxReportView> getReport(String entityId, int startYear) async {
    reportCalls.add((entityId: entityId, startYear: startYear));
    if (reportError != null) throw reportError!;
    return reports[startYear] ??
        defaultReport ??
        taxReportView(startYear: startYear);
  }
}

String testProfileJson(TaxProfile profile) => jsonEncode(profile.toJson());
