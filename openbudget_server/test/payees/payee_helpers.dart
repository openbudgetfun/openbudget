import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';

/// Rows and assertions the payee and rule suites share.
extension PayeeBook on BudgetTestBook {
  /// Inserts a payee in [entity] instead of this book's default entity.
  Future<Payee> addPayeeIn(Entity entity, {String name = 'Corner shop'}) =>
      Payee.db.insertRow(
        session,
        Payee(id: const Uuid().v7obj(), entityId: entity.id!, name: name),
      );

  /// Writes one ordinary transaction through the only writer.
  Future<TransactionView> addTransaction({
    required Account account,
    required DateTime date,
    int amountMinor = -1000,
    Payee? payee,
    List<TransactionLineInput> lines = const [],
    TransactionStatus status = TransactionStatus.uncleared,
    String? fxRate,
    String description = '',
  }) => TransactionWriter.create(
    session,
    TransactionInput(
      accountId: account.id!,
      date: date,
      amountMinor: amountMinor,
      payeeId: payee?.id,
      fxRate: fxRate,
      description: description,
      status: status,
      lines: lines,
    ),
  );

  /// Inserts a recurring schedule, optionally tied to a payee.
  Future<RecurringTransaction> addPayeeRecurring({
    required Account account,
    Payee? payee,
    Envelope? envelope,
    String description = 'Rent',
    int amountMinor = -1000,
    DateTime? nextDate,
  }) => RecurringTransaction.db.insertRow(
    session,
    RecurringTransaction(
      entityId: entity.id!,
      accountId: account.id!,
      payeeId: payee?.id,
      envelopeId: envelope?.id,
      description: description,
      amountMinor: amountMinor,
      frequency: RecurrenceFrequency.monthly,
      nextDate: nextDate ?? DateTime.utc(2026, 12),
    ),
  );

  /// Creates a transfer and gives its outflow leg a payee as metadata.
  Future<({model.Transaction from, model.Transaction to, Transfer link})>
  addTransferWithPayee({
    required Account from,
    required Account to,
    required DateTime date,
    required Envelope envelope,
    required Payee payee,
    int amountMinor = -5000,
  }) async {
    final views = await TransactionWriter.createTransfer(
      session,
      TransferInput(
        fromAccountId: from.id!,
        toAccountId: to.id!,
        date: date,
        fromAmountMinor: amountMinor.abs(),
        toAmountMinor: amountMinor.abs(),
        envelopeId: envelope.id,
      ),
    );
    final fromLeg = views.first.transaction;
    await TransactionWriter.update(
      session,
      fromLeg.id!,
      TransactionInput(
        accountId: from.id!,
        date: date,
        amountMinor: amountMinor,
        payeeId: payee.id,
        lines: const [],
      ),
    );

    final storedFrom = await transaction(fromLeg.id!);
    final storedTo = await transaction(views.last.transaction.id!);
    if (storedFrom == null || storedTo == null) {
      throw StateError('Transfer leg disappeared');
    }
    final link = await Transfer.db.findFirstRow(
      session,
      where: (t) => t.fromTransactionId.equals(storedFrom.id),
    );
    if (link == null) throw StateError('Transfer link disappeared');

    return (from: storedFrom, to: storedTo, link: link);
  }

  /// Reloads one persisted header.
  Future<model.Transaction> reloadTransaction(UuidValue id) async {
    final row = await transaction(id);
    if (row == null) throw StateError('Transaction disappeared');
    return row;
  }

  /// Loads one transaction's lines in stored order.
  Future<List<TransactionLine>> linesOf(UuidValue transactionId) =>
      TransactionLine.db.find(
        session,
        where: (t) => t.transactionId.equals(transactionId),
        orderBy: (t) => t.sortOrder,
      );

  /// Counts the payees in [entity].
  Future<int> payeeCount(UuidValue entityId) => Payee.db.count(
    session,
    where: (t) => t.entityId.equals(entityId),
  );

  /// Counts the rules for [payeeId].
  Future<int> ruleCount(UuidValue payeeId) => TransactionRule.db.count(
    session,
    where: (t) => t.payeeId.equals(payeeId),
  );
}

/// Asserts a call rejects an unauthenticated session before touching data.
Future<void> expectAuthenticationRequired(Future<Object?> Function() call) =>
    expectLater(call(), throwsA(isA<AuthenticationRequiredException>()));
