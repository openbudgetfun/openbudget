import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

const fixtureEntityId = '00000000-0000-0000-0000-0000000000f001';
const fixtureCategoryId = '00000000-0000-0000-0000-0000000000f002';
const fixtureEnvelopeId = '00000000-0000-0000-0000-0000000000f003';
const fixtureAccountId = '00000000-0000-0000-0000-0000000000f004';
const fixtureOwnerId = '00000000-0000-0000-0000-0000000000f005';

Entity testEntity({
  String id = fixtureEntityId,
  String name = 'Test Entity',
  EntityKind kind = EntityKind.individual,
  String countryCode = 'GB',
  String baseCurrencyCode = 'GBP',
  AccountingMode accountingMode = AccountingMode.envelope,
}) => Entity(
  id: UuidValue.fromString(id),
  name: name,
  kind: kind,
  countryCode: countryCode,
  baseCurrencyCode: baseCurrencyCode,
  timeZone: 'Europe/London',
  accountingMode: accountingMode,
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 5,
  ownerId: UuidValue.fromString(fixtureOwnerId),
  createdAt: DateTime.utc(2026),
);

BudgetMonthSummary testMonthSummary({
  int month = 202611,
  int incomeMinor = 300000,
  int uncategorizedMinor = 0,
  int fxDifferenceMinor = 0,
  int allocatedMinor = 250000,
  int activityMinor = -120000,
  int overspentLastMonthMinor = 0,
  int assignedInFutureMinor = 0,
  int readyToAssignMinor = 50000,
  int availableMinor = 50000,
}) => BudgetMonthSummary(
  month: month,
  incomeMinor: incomeMinor,
  uncategorizedMinor: uncategorizedMinor,
  fxDifferenceMinor: fxDifferenceMinor,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  overspentLastMonthMinor: overspentLastMonthMinor,
  assignedInFutureMinor: assignedInFutureMinor,
  readyToAssignMinor: readyToAssignMinor,
  availableMinor: availableMinor,
);

Category testCategory({
  String id = fixtureCategoryId,
  String entityId = fixtureEntityId,
  String name = 'Living',
  int sortOrder = 0,
  bool isHidden = false,
}) => Category(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  name: name,
  sortOrder: sortOrder,
  isHidden: isHidden,
);

Envelope testEnvelope({
  String id = fixtureEnvelopeId,
  String entityId = fixtureEntityId,
  String categoryId = fixtureCategoryId,
  String name = 'Groceries',
  int sortOrder = 0,
  bool isHidden = false,
  String? taxCategoryCode,
}) => Envelope(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  categoryId: UuidValue.fromString(categoryId),
  name: name,
  sortOrder: sortOrder,
  isHidden: isHidden,
  taxCategoryCode: taxCategoryCode,
);

EnvelopeMonthView testEnvelopeRow({
  String envelopeId = fixtureEnvelopeId,
  String categoryId = fixtureCategoryId,
  String envelopeName = 'Groceries',
  String entityId = fixtureEntityId,
  int carryoverMinor = 0,
  int allocatedMinor = 0,
  int activityMinor = 0,
  int? availableMinor,
  int goalUnderfundedMinor = 0,
  EnvelopeGoal? goal,
  bool isHidden = false,
}) => EnvelopeMonthView(
  envelope: testEnvelope(
    id: envelopeId,
    entityId: entityId,
    categoryId: categoryId,
    name: envelopeName,
    isHidden: isHidden,
  ),
  goal: goal,
  carryoverMinor: carryoverMinor,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  availableMinor:
      availableMinor ?? carryoverMinor + allocatedMinor + activityMinor,
  goalUnderfundedMinor: goalUnderfundedMinor,
);

/// The server's month view, as the plan, reports and forms consume it.
BudgetMonthView testMonthView({
  String entityId = fixtureEntityId,
  int month = 202611,
  String currencyCode = 'GBP',
  BudgetMonthSummary? summary,
  List<Category>? categories,
  List<EnvelopeMonthView>? envelopes,
}) {
  final resolvedEnvelopes =
      envelopes ?? [testEnvelopeRow(allocatedMinor: 250000)];
  final resolvedCategories =
      categories ??
      [
        testCategory(),
      ];
  return BudgetMonthView(
    entityId: UuidValue.fromString(entityId),
    month: month,
    currencyCode: currencyCode,
    summary: summary ?? testMonthSummary(month: month),
    categories: resolvedCategories,
    envelopes: resolvedEnvelopes,
  );
}

Account testAccount({
  String id = fixtureAccountId,
  String entityId = fixtureEntityId,
  String name = 'Current account',
  AccountKind kind = AccountKind.checking,
  String currencyCode = 'GBP',
  int balanceMinor = 100000,
  bool onBudget = true,
  AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
  DateTime? closedAt,
}) => Account(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  name: name,
  kind: kind,
  currencyCode: currencyCode,
  balanceSource: balanceSource,
  balanceMinor: balanceMinor,
  onBudget: onBudget,
  closedAt: closedAt,
);
