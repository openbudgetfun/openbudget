import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_service.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';

/// A household book with one on-budget checking account and plan envelopes.
class BudgetFixture {
  BudgetFixture._(
    this.book,
    this.account,
    this.categories,
    this.envelopes,
  );

  final BudgetTestBook book;
  final Account account;
  final List<Category> categories;
  final List<Envelope> envelopes;

  UuidValue get entityId => book.entity.id!;

  static Future<BudgetFixture> create(
    Session session, {
    String baseCurrencyCode = 'GBP',
    int envelopeCount = 2,
  }) async {
    final book = await BudgetTestBook.create(
      session,
      baseCurrencyCode: baseCurrencyCode,
    );
    final account = await book.addAccount();
    final categories = <Category>[];
    final envelopes = <Envelope>[];
    for (var index = 0; index < envelopeCount; index++) {
      final category = await Category.db.insertRow(
        session,
        Category(
          id: const Uuid().v7obj(),
          entityId: book.entity.id!,
          name: 'Category $index',
          sortOrder: index,
        ),
      );
      categories.add(category);
      envelopes.add(
        await Envelope.db.insertRow(
          session,
          Envelope(
            id: const Uuid().v7obj(),
            entityId: book.entity.id!,
            categoryId: category.id!,
            name: 'Envelope $index',
            sortOrder: 0,
          ),
        ),
      );
    }
    return BudgetFixture._(book, account, categories, envelopes);
  }

  Session get session => book.session;

  Future<BudgetMonthView> month(int month) =>
      BudgetMonthService.month(session, entityId: entityId, month: month);

  Future<BudgetMonthView> allocate(int month, Map<Envelope, int> amounts) =>
      BudgetService.setAllocations(
        session,
        entityId: entityId,
        month: month,
        allocations: [
          for (final entry in amounts.entries)
            AllocationInput(
              envelopeId: entry.key.id!,
              allocatedMinor: entry.value,
            ),
        ],
      );

  Future<BudgetMonthView> move(
    int month, {
    required int amountMinor,
    Envelope? from,
    Envelope? to,
  }) => BudgetService.moveMoney(
    session,
    entityId: entityId,
    month: month,
    fromEnvelopeId: from?.id,
    toEnvelopeId: to?.id,
    amountMinor: amountMinor,
  );

  Future<TransactionView> income(
    int amountMinor, {
    DateTime? date,
    String description = 'Income',
    UuidValue? accountId,
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: accountId ?? account.id!,
      date: date ?? DateTime.utc(2026, 11),
      amountMinor: amountMinor,
      description: description,
      lines: const [],
    ),
  );

  Future<TransactionView> openingBalance(
    int amountMinor, {
    DateTime? date,
    UuidValue? accountId,
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: accountId ?? account.id!,
      date: date ?? DateTime.utc(2026, 11),
      amountMinor: amountMinor,
      description: 'Opening balance',
      lines: const [],
    ),
    metadata: const TransactionWriteMetadata(
      kind: TransactionKind.openingBalance,
    ),
  );

  Future<TransactionView> spend(
    Envelope envelope,
    int amountMinor, {
    DateTime? date,
    UuidValue? accountId,
    String? fxRate,
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: accountId ?? account.id!,
      date: date ?? DateTime.utc(2026, 11),
      amountMinor: -amountMinor,
      fxRate: fxRate,
      description: envelope.name,
      lines: [
        TransactionLineInput(
          amountMinor: -amountMinor,
          envelopeId: envelope.id,
        ),
      ],
    ),
  );

  Future<TransactionView> splitSpend(
    Map<Envelope, int> lines, {
    DateTime? date,
    UuidValue? accountId,
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: accountId ?? account.id!,
      date: date ?? DateTime.utc(2026, 11),
      amountMinor: -lines.values.fold(0, (sum, amount) => sum + amount),
      description: 'Split',
      lines: [
        for (final entry in lines.entries)
          TransactionLineInput(
            amountMinor: -entry.value,
            envelopeId: entry.key.id,
          ),
      ],
    ),
  );

  Future<TransactionView> refund(
    Envelope envelope,
    int amountMinor, {
    DateTime? date,
    UuidValue? accountId,
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: accountId ?? account.id!,
      date: date ?? DateTime.utc(2026, 11),
      amountMinor: amountMinor,
      description: 'Refund',
      lines: [
        TransactionLineInput(
          amountMinor: amountMinor,
          envelopeId: envelope.id,
        ),
      ],
    ),
  );

  /// The independent right-hand side of the section 6.4 invariant.
  Future<int> onBudgetBookBalance(int month, {UuidValue? entityId}) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT COALESCE(SUM(l."baseAmountMinor"), 0)::text AS balance
FROM "transaction" t
JOIN account a ON a.id = t."accountId" AND a."onBudget"
JOIN transaction_line l ON l."transactionId" = t.id
LEFT JOIN transfer tf
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
LEFT JOIN "transaction" peer
  ON peer.id = CASE WHEN tf."fromTransactionId" = t.id
    THEN tf."toTransactionId" ELSE tf."fromTransactionId" END
LEFT JOIN account pa ON pa.id = peer."accountId"
WHERE t."entityId" = @entityId::uuid
  AND t."date" < @firstDayOfNextMonth::timestamp
  AND NOT COALESCE(pa."onBudget" AND peer."entityId" = t."entityId", false)''',
      parameters: QueryParameters.named({
        'entityId': (entityId ?? this.entityId).toString(),
        'firstDayOfNextMonth': BudgetValidation.firstDayOfNextMonth(month),
      }),
    );
    return int.parse(rows.single.single as String);
  }

  /// Asserts the zero-sum invariant and the row/summary agreement.
  Future<void> expectInvariant(
    BudgetMonthView view, {
    UuidValue? entityId,
  }) async {
    final summary = view.summary;
    expect(
      BudgetValidation.checkedSum(
            summary.availableMinor,
            summary.readyToAssignMinor,
            'Invariant',
          ) +
          summary.assignedInFutureMinor,
      await onBudgetBookBalance(view.month, entityId: entityId),
    );
    expect(
      summary.availableMinor,
      view.envelopes.fold<int>(
        0,
        (sum, row) => sum + row.availableMinor,
      ),
    );
    expect(
      summary.allocatedMinor,
      view.envelopes.fold<int>(
        0,
        (sum, row) => sum + row.allocatedMinor,
      ),
    );
    expect(
      summary.activityMinor,
      view.envelopes.fold<int>(0, (sum, row) => sum + row.activityMinor),
    );
  }
}

/// The independent balance of one envelope month from stored facts.
Future<int> envelopeActivity(
  Session session, {
  required UuidValue entityId,
  required int month,
  required UuidValue envelopeId,
}) async {
  final rows = await session.db.unsafeQuery(
    '''
SELECT COALESCE(SUM(l."baseAmountMinor"), 0)::text AS activity
FROM "transaction" t
JOIN transaction_line l ON l."transactionId" = t.id
WHERE t."entityId" = @entityId::uuid
  AND l."envelopeId" = @envelopeId::uuid
  AND t."date" >= @firstDay::timestamp
  AND t."date" < @nextFirstDay::timestamp''',
    parameters: QueryParameters.named({
      'entityId': entityId.toString(),
      'envelopeId': envelopeId.toString(),
      'firstDay': DateTime.utc(month ~/ 100, month % 100),
      'nextFirstDay': BudgetValidation.firstDayOfNextMonth(month),
    }),
  );
  return int.parse(rows.single.single as String);
}

/// Inserts one transaction header and line without writer overhead.
Future<void> seedTransaction(
  Session session, {
  required UuidValue entityId,
  required UuidValue accountId,
  required DateTime date,
  required int amountMinor,
  required int baseAmountMinor,
  UuidValue? envelopeId,
  TransactionKind kind = TransactionKind.standard,
}) async {
  final id = const Uuid().v7obj();
  await model.Transaction.db.insertRow(
    session,
    model.Transaction(
      id: id,
      entityId: entityId,
      accountId: accountId,
      date: date,
      amountMinor: amountMinor,
      baseAmountMinor: baseAmountMinor,
      fxRate: '1',
      fxRateDate: date,
      fxRateSource: FxRateSource.identity,
      kind: kind,
      description: 'Seeded',
    ),
  );
  await TransactionLine.db.insertRow(
    session,
    TransactionLine(
      transactionId: id,
      amountMinor: amountMinor,
      baseAmountMinor: baseAmountMinor,
      envelopeId: envelopeId,
    ),
  );
}

/// Inserts a bulk of transaction headers and lines without writer overhead.
Future<void> seedTransactionRows(
  Session session, {
  required UuidValue entityId,
  required UuidValue accountId,
  required List<
    ({
      DateTime date,
      int amountMinor,
      int baseAmountMinor,
      UuidValue? envelopeId,
    })
  >
  rows,
}) async {
  final headers = <model.Transaction>[];
  final lines = <TransactionLine>[];
  for (final row in rows) {
    final headerId = const Uuid().v7obj();
    headers.add(
      model.Transaction(
        id: headerId,
        entityId: entityId,
        accountId: accountId,
        date: row.date,
        amountMinor: row.amountMinor,
        baseAmountMinor: row.baseAmountMinor,
        fxRate: '1',
        fxRateDate: row.date,
        fxRateSource: FxRateSource.identity,
        description: 'Seeded',
      ),
    );
    lines.add(
      TransactionLine(
        transactionId: headerId,
        amountMinor: row.amountMinor,
        baseAmountMinor: row.baseAmountMinor,
        envelopeId: row.envelopeId,
      ),
    );
  }
  await model.Transaction.db.insert(session, headers);
  await TransactionLine.db.insert(session, lines);
}
