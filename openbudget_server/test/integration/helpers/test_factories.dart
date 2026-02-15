import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Creates a deterministic test [Budget] instance.
Budget createTestBudget({
  required UuidValue ownerId,
  String name = 'Test Budget',
  String currencyCode = 'USD',
}) => Budget(name: name, currencyCode: currencyCode, ownerId: ownerId);

/// Creates a deterministic test [Category] instance.
Category createTestCategory({
  required UuidValue budgetId,
  String name = 'Test Category',
  int sortOrder = 0,
}) => Category(name: name, budgetId: budgetId, sortOrder: sortOrder);

/// Creates a deterministic test [Envelope] instance.
Envelope createTestEnvelope({
  required UuidValue categoryId,
  String name = 'Test Envelope',
  int budgetedAmountCents = 10000,
  int spentAmountCents = 0,
  String currencyCode = 'USD',
}) => Envelope(
  name: name,
  categoryId: categoryId,
  budgetedAmountCents: budgetedAmountCents,
  spentAmountCents: spentAmountCents,
  currencyCode: currencyCode,
);

/// Creates a deterministic test [Transaction] instance.
Transaction createTestTransaction({
  required UuidValue budgetId,
  String description = 'Test Transaction',
  int amountCents = -2500,
  String currencyCode = 'USD',
  UuidValue? envelopeId,
  DateTime? transactionDate,
}) => Transaction(
  description: description,
  amountCents: amountCents,
  currencyCode: currencyCode,
  budgetId: budgetId,
  envelopeId: envelopeId,
  transactionDate: transactionDate ?? DateTime.utc(2026, 1, 15),
);
