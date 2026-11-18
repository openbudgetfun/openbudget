import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import 'budget_month.dart';

/// Fixture ids shared by the transaction tests.
const fixtureTransactionId = '00000000-0000-0000-0000-0000000000f101';
const fixturePayeeId = '00000000-0000-0000-0000-0000000000f102';
const fixtureSecondPayeeId = '00000000-0000-0000-0000-0000000000f103';
const fixtureEnvelopeId2 = '00000000-0000-0000-0000-0000000000f104';
const fixtureAccountId2 = '00000000-0000-0000-0000-0000000000f105';
const fixtureRecurringId = '00000000-0000-0000-0000-0000000000f106';
const fixtureRuleId = '00000000-0000-0000-0000-0000000000f107';

/// A payee owned by [entityId].
Payee testPayee({
  String id = fixturePayeeId,
  String entityId = fixtureEntityId,
  String name = 'Tesco',
}) => Payee(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  name: name,
);

/// One transaction in [accountId], with the base amount and FX facts the
/// entity model requires.
Transaction testTransaction({
  String id = fixtureTransactionId,
  String entityId = fixtureEntityId,
  String accountId = fixtureAccountId,
  DateTime? date,
  int amountMinor = -1234,
  int? baseAmountMinor,
  String fxRate = '1',
  FxRateSource fxRateSource = FxRateSource.identity,
  DateTime? fxRateDate,
  TransactionStatus status = TransactionStatus.uncleared,
  TransactionFlag? flag,
  String? payeeId,
  String description = 'Groceries',
  String? memo,
}) {
  final when = date ?? DateTime.utc(2026, 11, 8);
  return Transaction(
    id: UuidValue.fromString(id),
    entityId: UuidValue.fromString(entityId),
    accountId: UuidValue.fromString(accountId),
    date: when,
    amountMinor: amountMinor,
    baseAmountMinor: baseAmountMinor ?? amountMinor,
    fxRate: fxRate,
    fxRateDate: fxRateDate ?? when,
    fxRateSource: fxRateSource,
    status: status,
    flag: flag,
    payeeId: payeeId == null ? null : UuidValue.fromString(payeeId),
    description: description,
    memo: memo,
  );
}

/// One line of [transaction], allocated to [envelopeId] by default.
TransactionLine testLine({
  required Transaction transaction,
  String? id,
  int? amountMinor,
  String envelopeId = fixtureEnvelopeId,
}) => TransactionLine(
  id: id == null ? null : UuidValue.fromString(id),
  transactionId: transaction.id!,
  amountMinor: amountMinor ?? transaction.amountMinor,
  baseAmountMinor: amountMinor ?? transaction.baseAmountMinor,
  envelopeId: UuidValue.fromString(envelopeId),
);

/// A transaction with everything a list row or dialog shows.
TransactionView testTransactionView({
  Transaction? transaction,
  List<TransactionLine>? lines,
  String accountCurrencyCode = 'GBP',
  String accountName = 'Current account',
  String? payeeName,
  TransferPeerView? transferPeer,
}) {
  final header = transaction ?? testTransaction();
  return TransactionView(
    transaction: header,
    lines: lines ?? [testLine(transaction: header)],
    accountCurrencyCode: accountCurrencyCode,
    accountName: accountName,
    payeeName: payeeName,
    transferPeer: transferPeer,
  );
}

/// The server's market quote between two currencies on a date.
FxQuoteView testFxQuote({
  String fromCurrencyCode = 'USD',
  String toCurrencyCode = 'GBP',
  String rate = '0.7891',
  DateTime? rateDate,
  FxRateSource source = FxRateSource.market,
  bool isStale = false,
}) => FxQuoteView(
  fromCurrencyCode: fromCurrencyCode,
  toCurrencyCode: toCurrencyCode,
  rate: rate,
  rateDate: rateDate ?? DateTime.utc(2026, 11, 8),
  source: source,
  isStale: isStale,
);

/// One scheduled recurring transaction in [accountId].
RecurringTransaction testRecurring({
  String id = fixtureRecurringId,
  String entityId = fixtureEntityId,
  String accountId = fixtureAccountId,
  String description = 'Rent',
  int amountMinor = -120000,
  RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
  DateTime? nextDate,
  DateTime? endDate,
  bool isActive = true,
}) => RecurringTransaction(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  accountId: UuidValue.fromString(accountId),
  description: description,
  amountMinor: amountMinor,
  frequency: frequency,
  nextDate: nextDate ?? DateTime.utc(2026, 11, 15),
  endDate: endDate,
  isActive: isActive,
);

/// One payee-to-envelope rule.
TransactionRule testRule({
  String id = fixtureRuleId,
  String entityId = fixtureEntityId,
  String payeeId = fixturePayeeId,
  String envelopeId = fixtureEnvelopeId,
  bool enabled = true,
}) => TransactionRule(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(entityId),
  payeeId: UuidValue.fromString(payeeId),
  envelopeId: UuidValue.fromString(envelopeId),
  enabled: enabled,
);
