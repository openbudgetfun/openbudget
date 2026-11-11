import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:serverpod/serverpod.dart';

/// Publishes one committed change event through Serverpod's message bus.
typedef EntityChangePublisher = Future<void> Function(
  Session session,
  UuidValue entityId,
  ChangeScope scope, {
  int? month,
  UuidValue? accountId,
});

/// Server-owned facts that a normal [TransactionInput] must not be able to
/// forge. Account opening and recurring posting will supply these when they
/// are ported; ordinary app and import writes leave them at their defaults.
class TransactionWriteMetadata {
  /// Creates metadata for one transaction write.
  const TransactionWriteMetadata({
    this.kind = TransactionKind.standard,
    this.externalId,
    this.recurringTransactionId,
  });

  /// What the movement represents beyond an ordinary posting.
  final TransactionKind kind;

  /// Provider id for imported rows, unique per account.
  final String? externalId;

  /// The schedule that produced the row, when one did.
  final UuidValue? recurringTransactionId;
}

/// The only writer of `transaction`, `transaction_line` and `transfer` rows.
///
/// Every operation either owns a database transaction or joins one opened by
/// [inTransaction]. It locks accounts in UUID order, verifies ownership and
/// the account's balance source, validates every line, stores a reproducible
/// FX rate, and moves cached balances atomically with the rows.
///
/// Change events are published only after the owning database transaction
/// commits. A caller that passes `transaction:` must have opened it with
/// [inTransaction], so a rolled-back write never emits an event.
abstract final class TransactionWriter {
  static EntityChangePublisher _publisher = EntityRealtimeNotifier.notify;
  static final Expando<_ChangeOutbox> _outboxes = Expando(
    'TransactionWriter.outbox',
  );

  /// Replaces how committed events are delivered. Tests use this to observe
  /// notifications without opening a WebSocket.
  @visibleForTesting
  static EntityChangePublisher get debugPublisher => _publisher;

  @visibleForTesting
  static set debugPublisher(EntityChangePublisher publisher) {
    _publisher = publisher;
  }

  /// Restores the production message bus after a test replacement.
  @visibleForTesting
  static void resetForTests() {
    _publisher = EntityRealtimeNotifier.notify;
  }

  /// Runs [body] inside one database transaction and publishes the changes it
  /// queued only after that transaction commits.
  ///
  /// Future callers that need several writer calls atomically pass the
  /// [Transaction] this opens as `transaction:`. Joining a transaction that
  /// was not opened here is rejected, because the writer cannot know when it
  /// commits and will not emit a change before then.
  static Future<T> inTransaction<T>(
    Session session,
    Future<T> Function(Transaction transaction) body,
  ) => _run(session, (transaction, _) => body(transaction));

  /// Reads one transaction and its lines after checking entity ownership.
  static Future<TransactionView> get(
    Session session,
    UuidValue id, {
    Transaction? transaction,
  }) async {
    final row = await model.Transaction.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (row == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    await EntityAccess.requireOwned(
      session,
      row.entityId,
      transaction: transaction,
    );
    return _view(session, row, transaction: transaction);
  }

  /// Creates a header, its lines and the account balance movement atomically.
  static Future<TransactionView> create(
    Session session,
    TransactionInput input, {
    Transaction? transaction,
    TransactionWriteMetadata metadata = const TransactionWriteMetadata(),
  }) {
    final joined = transaction;
    if (joined != null) {
      return _create(
        session,
        input,
        joined,
        metadata,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) => _create(session, input, tx, metadata, outbox),
    );
  }

  /// Replaces a transaction and its lines, moving cached balances exactly.
  static Future<TransactionView> update(
    Session session,
    UuidValue id,
    TransactionInput input, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _update(session, id, input, joined, _requireOutbox(joined));
    }
    return _owned(
      session,
      (tx, outbox) => _update(session, id, input, tx, outbox),
    );
  }

  /// Replaces only the lines, using the header's stored rate and base total.
  static Future<TransactionView> updateLines(
    Session session,
    UuidValue id,
    List<TransactionLineInput> lines, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _updateLines(session, id, lines, joined, _requireOutbox(joined));
    }
    return _owned(
      session,
      (tx, outbox) => _updateLines(session, id, lines, tx, outbox),
    );
  }

  /// Deletes a transaction, both legs of a transfer, and their balances.
  static Future<void> delete(
    Session session,
    UuidValue id, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _delete(session, id, joined, _requireOutbox(joined));
    }
    return _owned(session, (tx, outbox) => _delete(session, id, tx, outbox));
  }

  /// Deletes every transfer touching [accountId], both legs.
  ///
  /// Account deletion uses this before removing the account row so a surviving
  /// peer's cached balance is reversed through the writer instead of being
  /// left behind by a database cascade. The usual delete restrictions apply:
  /// a reconciled or period-locked leg rejects the whole account deletion
  /// rather than producing a partial delete.
  static Future<void> deleteTransfersForAccount(
    Session session,
    UuidValue accountId, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _deleteTransfersForAccount(
        session,
        accountId,
        joined,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) =>
          _deleteTransfersForAccount(session, accountId, tx, outbox),
    );
  }

  static Future<T> _owned<T>(
    Session session,
    Future<T> Function(Transaction transaction, _ChangeOutbox outbox) body,
  ) => _run(session, body);

  /// Owns the commit boundary shared by every public write.
  static Future<T> _run<T>(
    Session session,
    Future<T> Function(Transaction transaction, _ChangeOutbox outbox) body,
  ) async {
    final outbox = _ChangeOutbox();
    final result = await session.db.transaction((transaction) async {
      _outboxes[transaction] = outbox;
      try {
        return await body(transaction, outbox);
      } finally {
        _outboxes[transaction] = null;
      }
    });
    await outbox.publish(session);
    return result;
  }

  static _ChangeOutbox _requireOutbox(Transaction transaction) {
    final outbox = _outboxes[transaction];
    if (outbox == null) {
      throw StateError(
        'Join a caller transaction through TransactionWriter.inTransaction '
        'so change events publish only after it commits.',
      );
    }
    return outbox;
  }

  static Future<TransactionView> _create(
    Session session,
    TransactionInput input,
    Transaction tx,
    TransactionWriteMetadata metadata,
    _ChangeOutbox outbox,
  ) async {
    final account = await _lockAccount(session, input.accountId, tx);
    final entity = await EntityAccess.requireOwned(
      session,
      account.entityId,
      transaction: tx,
    );
    _requireTransactionAccount(account);
    if (account.closedAt != null) {
      throw ValidationException(
        message: 'A closed account rejects new transactions',
      );
    }
    _requireSafeMinor(input.amountMinor, 'amountMinor');
    final date = _requireWritableDate(entity, input.date);
    _rejectLockedDate(date, await _lockDate(session, entity, tx));

    final payee = await _resolvePayee(session, entity, input, tx);
    final rate = await _resolveRate(session, account, entity, input, tx);
    final lines = await _buildLines(
      session,
      account: account,
      entity: entity,
      input: input,
      payeeId: payee?.id,
      rate: rate.value,
      baseAmountMinor: rate.baseAmountMinor,
      transaction: tx,
    );

    final now = DateTime.now().toUtc();
    var row = model.Transaction(
      id: const Uuid().v7obj(),
      entityId: entity.id!,
      accountId: account.id!,
      date: date,
      amountMinor: input.amountMinor,
      baseAmountMinor: rate.baseAmountMinor,
      fxRate: rate.rate,
      fxRateDate: rate.rateDate,
      fxRateSource: rate.source,
      kind: metadata.kind,
      status: input.status,
      flag: input.flag,
      payeeId: payee?.id,
      description: input.description,
      memo: input.memo,
      externalId: metadata.externalId,
      recurringTransactionId: metadata.recurringTransactionId,
      revision: 0,
      createdAt: now,
      updatedAt: now,
    );
    row = await model.Transaction.db.insertRow(session, row, transaction: tx);
    await TransactionLine.db.insert(
      session,
      _lineRows(row.id!, lines),
      transaction: tx,
    );
    await AccountBalanceService.applyDelta(
      session,
      account.id!,
      input.amountMinor,
      transaction: tx,
    );

    _queueChange(outbox, row);
    return _view(session, row, transaction: tx);
  }

  static Future<TransactionView> _update(
    Session session,
    UuidValue id,
    TransactionInput input,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final existing = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (existing == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final entity = await EntityAccess.requireOwned(
      session,
      existing.entityId,
      transaction: tx,
    );
    final accounts = await _lockAccounts(
      session,
      {existing.accountId, input.accountId},
      tx,
    );
    final oldAccount = accounts[existing.accountId]!;
    final newAccount = accounts[input.accountId]!;
    _requireTransactionAccount(oldAccount);
    _requireTransactionAccount(newAccount);
    await EntityAccess.requireOwned(
      session,
      newAccount.entityId,
      transaction: tx,
    );
    if (newAccount.entityId != existing.entityId) {
      throw ValidationException(
        message: 'A transaction can move only between accounts of one entity',
      );
    }
    if (newAccount.id != oldAccount.id && newAccount.closedAt != null) {
      throw ValidationException(
        message: 'A closed account rejects moved transactions',
      );
    }

    final storedLines = await _lines(session, id, tx);
    final linesChanged =
        input.lines.isNotEmpty && !_sameLineInputs(input.lines, storedLines);
    final rateChanged =
        input.fxRate != null &&
        _rateTextDiffers(input.fxRate!, existing.fxRate);

    // Rate resolution is driven only by edits that change the movement or the
    // rate itself. A line-only edit is coding: it keeps the stored rate, rate
    // date, rate source and base total, and reuses them for the replacement
    // lines, so it never re-prices history when market data moves or vanishes.
    final rateAffected =
        input.date != existing.date ||
        input.amountMinor != existing.amountMinor ||
        input.accountId != existing.accountId ||
        rateChanged;
    final material = rateAffected || linesChanged;

    if (existing.status == TransactionStatus.reconciled && material) {
      throw ValidationException(
        message: 'A reconciled transaction unlocks before money can change',
      );
    }

    final transfer = await _transferFor(session, id, tx);
    if (transfer != null && material) {
      throw ValidationException(
        message: 'A transfer leg changes only through updateTransfer',
      );
    }

    if (material) {
      final lockDate = await _lockDate(session, entity, tx);
      _rejectLockedDate(existing.date, lockDate);
      _rejectLockedDate(input.date, lockDate);
    }

    final date = _requireWritableDate(entity, input.date);
    _requireSafeMinor(input.amountMinor, 'amountMinor');

    final payee = await _resolvePayee(session, entity, input, tx);
    final _ResolvedRate rate;
    if (rateAffected) {
      rate = await _resolveRate(session, newAccount, entity, input, tx);
    } else {
      rate = _ResolvedRate(
        value: _parseRate(existing.fxRate),
        rate: existing.fxRate,
        rateDate: existing.fxRateDate,
        source: existing.fxRateSource,
        baseAmountMinor: existing.baseAmountMinor,
      );
    }

    final replacement = material
        ? await _buildLines(
            session,
            account: newAccount,
            entity: entity,
            input: input,
            payeeId: payee?.id,
            rate: rate.value,
            baseAmountMinor: rate.baseAmountMinor,
            transaction: tx,
          )
        : null;

    final ledgerRevision =
        entity.accountingMode == AccountingMode.ledger && material;
    final now = DateTime.now().toUtc();
    var row = existing.copyWith(
      accountId: input.accountId,
      date: date,
      amountMinor: input.amountMinor,
      baseAmountMinor: rate.baseAmountMinor,
      fxRate: rate.rate,
      fxRateDate: rate.rateDate,
      fxRateSource: rate.source,
      status: input.status,
      flag: input.flag,
      payeeId: payee?.id,
      description: input.description,
      memo: input.memo,
      revision: ledgerRevision ? existing.revision + 1 : existing.revision,
      updatedAt: now,
    );
    row = await model.Transaction.db.updateRow(session, row, transaction: tx);

    if (replacement != null) {
      await TransactionLine.db.deleteWhere(
        session,
        where: (t) => t.transactionId.equals(id),
        transaction: tx,
      );
      await TransactionLine.db.insert(
        session,
        _lineRows(id, replacement),
        transaction: tx,
      );
    }

    if (oldAccount.id == newAccount.id) {
      // One net delta keeps a metadata-only edit at the safe balance limit
      // from ever exceeding it on the way to an unchanged result.
      await AccountBalanceService.applyDelta(
        session,
        oldAccount.id!,
        input.amountMinor - existing.amountMinor,
        transaction: tx,
      );
    } else {
      await AccountBalanceService.applyDelta(
        session,
        oldAccount.id!,
        -existing.amountMinor,
        transaction: tx,
      );
      await AccountBalanceService.applyDelta(
        session,
        newAccount.id!,
        input.amountMinor,
        transaction: tx,
      );
    }

    if (ledgerRevision) {
      await _writeAudit(
        session,
        entity.id!,
        AuditAction.transactionEdited,
        id,
        {
          'before': {
            'transaction': existing.toJson(),
            'lines': storedLines.map((line) => line.toJson()).toList(),
          },
        },
        tx,
      );
    }

    _queueUpdateChanges(
      outbox,
      row,
      oldDate: existing.date,
      oldAccountId: existing.accountId,
    );
    return _view(session, row, transaction: tx);
  }

  static Future<TransactionView> _updateLines(
    Session session,
    UuidValue id,
    List<TransactionLineInput> lines,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final existing = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (existing == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final entity = await EntityAccess.requireOwned(
      session,
      existing.entityId,
      transaction: tx,
    );
    final account = await _lockAccount(session, existing.accountId, tx);
    _requireTransactionAccount(account);
    final storedLines = await _lines(session, id, tx);
    if (existing.status == TransactionStatus.reconciled &&
        (lines.isEmpty || !_sameLineInputs(lines, storedLines))) {
      throw ValidationException(
        message: 'A reconciled transaction unlocks before its lines change',
      );
    }
    if (await _transferFor(session, id, tx) != null) {
      throw ValidationException(
        message: 'A transfer leg changes only through updateTransfer',
      );
    }
    _rejectLockedDate(existing.date, await _lockDate(session, entity, tx));

    if (lines.isNotEmpty && _sameLineInputs(lines, storedLines)) {
      return _view(session, existing, transaction: tx);
    }
    final rate = _ResolvedRate(
      value: _parseRate(existing.fxRate),
      rate: existing.fxRate,
      rateDate: existing.fxRateDate,
      source: existing.fxRateSource,
      baseAmountMinor: existing.baseAmountMinor,
    );
    final replacement = await _buildLines(
      session,
      account: account,
      entity: entity,
      input: TransactionInput(
        accountId: existing.accountId,
        date: existing.date,
        amountMinor: existing.amountMinor,
        lines: lines,
      ),
      payeeId: existing.payeeId,
      rate: rate.value,
      baseAmountMinor: rate.baseAmountMinor,
      transaction: tx,
    );

    await TransactionLine.db.deleteWhere(
      session,
      where: (t) => t.transactionId.equals(id),
      transaction: tx,
    );
    await TransactionLine.db.insert(
      session,
      _lineRows(id, replacement),
      transaction: tx,
    );

    final ledger = entity.accountingMode == AccountingMode.ledger;
    var row = existing.copyWith(
      revision: ledger ? existing.revision + 1 : existing.revision,
      updatedAt: DateTime.now().toUtc(),
    );
    row = await model.Transaction.db.updateRow(session, row, transaction: tx);
    if (ledger) {
      await _writeAudit(
        session,
        entity.id!,
        AuditAction.transactionEdited,
        id,
        {
          'before': {
            'transaction': existing.toJson(),
            'lines': storedLines.map((line) => line.toJson()).toList(),
          },
        },
        tx,
      );
    }

    _queueChange(outbox, row);
    return _view(session, row, transaction: tx);
  }

  static Future<void> _deleteTransfersForAccount(
    Session session,
    UuidValue accountId,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT DISTINCT tf."fromTransactionId"::text AS "transactionId"
FROM transfer tf
JOIN "transaction" t
  ON t.id IN (tf."fromTransactionId", tf."toTransactionId")
WHERE t."accountId" = @accountId::uuid
ORDER BY 1''',
      parameters: QueryParameters.named({'accountId': accountId.toString()}),
      transaction: tx,
    );

    for (final row in rows) {
      await _delete(
        session,
        UuidValue.fromString(row.first as String),
        tx,
        outbox,
      );
    }
  }

  static Future<void> _delete(
    Session session,
    UuidValue id,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final existing = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (existing == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final transfer = await _transferFor(session, id, tx);
    final otherLegId = transfer == null
        ? null
        : transfer.fromTransactionId == id
        ? transfer.toTransactionId
        : transfer.fromTransactionId;
    final ids = {id, ?otherLegId}.toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));

    final rows = <UuidValue, model.Transaction>{};
    for (final transactionId in ids) {
      final row = await model.Transaction.db.findById(
        session,
        transactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) {
        throw NotFoundException(message: 'Transfer leg not found');
      }
      rows[transactionId] = row;
    }

    final entities = <UuidValue, Entity>{};
    for (final row in rows.values) {
      entities[row.entityId] = await EntityAccess.requireOwned(
        session,
        row.entityId,
        transaction: tx,
      );
    }
    final accounts = await _lockAccounts(
      session,
      rows.values.map((row) => row.accountId),
      tx,
    );

    for (final row in rows.values) {
      if (row.status == TransactionStatus.reconciled) {
        throw ValidationException(
          message: 'A reconciled transaction unlocks before deletion',
        );
      }
      final entity = entities[row.entityId]!;
      _rejectLockedDate(
        row.date,
        await _lockDate(session, entity, tx),
      );
      final account = accounts[row.accountId]!;
      _requireTransactionAccount(account);
    }

    for (final row in rows.values) {
      await AccountBalanceService.applyDelta(
        session,
        row.accountId,
        -row.amountMinor,
        transaction: tx,
      );
    }

    for (final row in rows.values) {
      final entity = entities[row.entityId]!;
      if (entity.accountingMode == AccountingMode.ledger) {
        final lines = await _lines(session, row.id!, tx);
        await _writeAudit(
          session,
          entity.id!,
          AuditAction.transactionDeleted,
          row.id!,
          {
            'before': {
              'transaction': row.toJson(),
              'lines': lines.map((line) => line.toJson()).toList(),
            },
          },
          tx,
        );
      }
    }

    if (transfer != null) {
      await Transfer.db.deleteRow(session, transfer, transaction: tx);
    }
    for (final row in rows.values) {
      await model.Transaction.db.deleteRow(session, row, transaction: tx);
      _queueChange(outbox, row);
    }
  }

  static Future<_ResolvedRate> _resolveRate(
    Session session,
    Account account,
    Entity entity,
    TransactionInput input,
    Transaction transaction,
  ) async {
    final accountCurrency = account.currencyCode;
    final baseCurrency = entity.baseCurrencyCode;
    if (accountCurrency == baseCurrency) {
      return _ResolvedRate(
        value: ExactDecimal.one,
        rate: '1',
        rateDate: input.date,
        source: FxRateSource.identity,
        baseAmountMinor: input.amountMinor,
      );
    }

    final manual = input.fxRate?.trim();
    if (manual != null && manual.isNotEmpty) {
      final value = _parseRate(manual);
      return _ResolvedRate(
        value: value,
        rate: value.toString(),
        rateDate: input.date,
        source: FxRateSource.manual,
        baseAmountMinor: _convert(
          input.amountMinor,
          value,
          accountCurrency,
          baseCurrency,
        ),
      );
    }

    final quote = await FxService.rateOn(
      session,
      accountCurrency,
      baseCurrency,
      input.date,
      transaction: transaction,
    );
    if (quote == null) {
      throw FxRateUnavailableException(
        fromCurrencyCode: accountCurrency,
        toCurrencyCode: baseCurrency,
        date: input.date,
      );
    }
    final value = ExactDecimal.tryParse(quote.rate);
    if (value == null) {
      throw FxRateUnavailableException(
        fromCurrencyCode: accountCurrency,
        toCurrencyCode: baseCurrency,
        date: input.date,
      );
    }
    return _ResolvedRate(
      value: value,
      rate: value.toString(),
      rateDate: quote.rateDate,
      source: quote.source,
      baseAmountMinor: _convert(
        input.amountMinor,
        value,
        accountCurrency,
        baseCurrency,
      ),
    );
  }

  static Future<List<_BuiltLine>> _buildLines(
    Session session, {
    required Account account,
    required Entity entity,
    required TransactionInput input,
    required UuidValue? payeeId,
    required ExactDecimal rate,
    required int baseAmountMinor,
    required Transaction transaction,
  }) async {
    final inputs = input.lines.isEmpty
        ? [TransactionLineInput(amountMinor: input.amountMinor)]
        : input.lines;
    final resolved = [
      for (final line in inputs)
        TransactionLineInput(
          amountMinor: line.amountMinor,
          envelopeId: line.envelopeId,
          ledgerAccountId: line.ledgerAccountId,
          taxCategoryCode: line.taxCategoryCode,
          businessUsePercent: line.businessUsePercent,
          salesTaxMinor: line.salesTaxMinor,
          memo: line.memo,
        ),
    ];

    if (resolved.length == 1 &&
        resolved.single.envelopeId == null &&
        account.onBudget &&
        input.amountMinor < 0 &&
        payeeId != null) {
      final rule = await TransactionRule.db.findFirstRow(
        session,
        where: (t) =>
            t.entityId.equals(entity.id) &
            t.payeeId.equals(payeeId) &
            t.enabled.equals(true),
        transaction: transaction,
      );
      if (rule != null) {
        resolved[0] = resolved[0].copyWith(envelopeId: rule.envelopeId);
      }
    }

    var sum = BigInt.zero;
    for (final line in resolved) {
      _requireSafeMinor(line.amountMinor, 'line.amountMinor');
      sum += BigInt.from(line.amountMinor);
    }
    if (sum != BigInt.from(input.amountMinor)) {
      throw ValidationException(
        message: 'Transaction lines must sum exactly to amountMinor',
      );
    }

    final envelopes = <UuidValue, Envelope>{};
    final ledgerAccounts = <UuidValue, LedgerAccount>{};
    for (final line in resolved) {
      await _validateLine(
        session,
        account: account,
        entity: entity,
        line: line,
        envelopes: envelopes,
        ledgerAccounts: ledgerAccounts,
        transaction: transaction,
      );
    }

    final List<int> baseAmounts;
    try {
      baseAmounts = splitBaseAmounts(
        lineAmounts: [for (final line in resolved) line.amountMinor],
        baseTotal: baseAmountMinor,
        rate: rate,
        fromExponent: _exponent(account.currencyCode),
        toExponent: _exponent(entity.baseCurrencyCode),
      );
      // The split helper reports an out-of-range residue with RangeError;
      // this boundary turns it into the contract's ValidationException.
      // ignore: avoid_catching_errors
    } on RangeError {
      throw ValidationException(
        message: 'A converted line exceeds the safe minor-unit range',
      );
    }

    final built = <_BuiltLine>[];
    for (var index = 0; index < resolved.length; index++) {
      final line = resolved[index];
      final lineBase = baseAmounts[index];
      if (line.amountMinor == 0 && lineBase == 0) {
        throw ValidationException(
          message: 'Every line needs a non-zero amount',
        );
      }
      built.add(
        _BuiltLine(
          amountMinor: line.amountMinor,
          baseAmountMinor: lineBase,
          envelopeId: line.envelopeId,
          ledgerAccountId: line.ledgerAccountId,
          taxCategoryCode: _normaliseTaxCode(line.taxCategoryCode),
          businessUsePercent: line.businessUsePercent,
          salesTaxMinor: line.salesTaxMinor,
          memo: line.memo,
          sortOrder: index,
        ),
      );
    }
    return built;
  }

  static Future<void> _validateLine(
    Session session, {
    required Account account,
    required Entity entity,
    required TransactionLineInput line,
    required Map<UuidValue, Envelope> envelopes,
    required Map<UuidValue, LedgerAccount> ledgerAccounts,
    required Transaction transaction,
  }) async {
    final envelopeId = line.envelopeId;
    if (envelopeId != null) {
      final envelope =
          envelopes[envelopeId] ??
          await Envelope.db.findById(
            session,
            envelopeId,
            transaction: transaction,
          );
      if (envelope == null) {
        throw NotFoundException(message: 'Envelope not found');
      }
      if (envelope.entityId != entity.id) {
        throw ForbiddenException(message: 'Envelope belongs to another entity');
      }
      if (!account.onBudget) {
        throw ValidationException(
          message: 'An off-budget account cannot use envelopes',
        );
      }
      envelopes[envelopeId] = envelope;
    }

    final ledgerAccountId = line.ledgerAccountId;
    if (ledgerAccountId != null) {
      if (entity.accountingMode != AccountingMode.ledger) {
        throw ValidationException(
          message: 'Ledger coding is allowed only in ledger mode',
        );
      }
      final ledger =
          ledgerAccounts[ledgerAccountId] ??
          await LedgerAccount.db.findById(
            session,
            ledgerAccountId,
            transaction: transaction,
          );
      if (ledger == null) {
        throw NotFoundException(message: 'Ledger account not found');
      }
      if (ledger.entityId != entity.id) {
        throw ForbiddenException(
          message: 'Ledger account belongs to another entity',
        );
      }
      if (ledger.archivedAt != null) {
        throw ValidationException(
          message: 'An archived ledger account rejects new lines',
        );
      }
      if (account.ledgerAccountId == ledgerAccountId) {
        throw ValidationException(
          message: 'A transaction cannot code to its own ledger account',
        );
      }
      ledgerAccounts[ledgerAccountId] = ledger;
    }

    final businessUsePercent = line.businessUsePercent;
    if (businessUsePercent != null &&
        (businessUsePercent < 0 || businessUsePercent > 100)) {
      throw ValidationException(
        message: 'businessUsePercent must be between 0 and 100',
      );
    }

    final salesTaxMinor = line.salesTaxMinor;
    if (salesTaxMinor != null && salesTaxMinor != 0) {
      if (line.amountMinor == 0 ||
          salesTaxMinor.sign != line.amountMinor.sign ||
          salesTaxMinor.abs() > line.amountMinor.abs()) {
        throw ValidationException(
          message: 'salesTaxMinor must share the line sign and fit inside it',
        );
      }
    }

    final taxCode = _normaliseTaxCode(line.taxCategoryCode);
    if (taxCode != null) {
      _validateTaxCode(entity, taxCode);
    }
  }

  static void _validateTaxCode(Entity entity, String code) {
    final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
    if (jurisdiction == null) {
      throw ValidationException(
        message: 'No tax catalog exists for ${entity.countryCode}',
      );
    }
    final category = TaxRules.forJurisdiction(jurisdiction).category(code);
    if (category == null || !category.entityKinds.contains(entity.kind)) {
      throw ValidationException(message: 'Unknown tax category "$code"');
    }
  }

  static Future<List<TransactionLine>> _lines(
    Session session,
    UuidValue transactionId,
    Transaction? transaction,
  ) => TransactionLine.db.find(
    session,
    where: (t) => t.transactionId.equals(transactionId),
    orderByList: (t) => [t.sortOrder, t.id],
    transaction: transaction,
  );

  static List<TransactionLine> _lineRows(
    UuidValue transactionId,
    List<_BuiltLine> lines,
  ) => [
    for (final line in lines)
      TransactionLine(
        id: const Uuid().v7obj(),
        transactionId: transactionId,
        amountMinor: line.amountMinor,
        baseAmountMinor: line.baseAmountMinor,
        envelopeId: line.envelopeId,
        ledgerAccountId: line.ledgerAccountId,
        taxCategoryCode: line.taxCategoryCode,
        businessUsePercent: line.businessUsePercent,
        salesTaxMinor: line.salesTaxMinor,
        memo: line.memo,
        sortOrder: line.sortOrder,
      ),
  ];

  static Future<TransactionView> _view(
    Session session,
    model.Transaction row, {
    Transaction? transaction,
  }) async {
    final account = await Account.db.findById(
      session,
      row.accountId,
      transaction: transaction,
    );
    if (account == null) {
      throw StateError('Transaction account disappeared');
    }
    final lines = await _lines(session, row.id!, transaction);
    final payee = row.payeeId == null
        ? null
        : await Payee.db.findById(
            session,
            row.payeeId!,
            transaction: transaction,
          );

    TransferPeerView? peer;
    final transfer = await _transferFor(session, row.id!, transaction);
    if (transfer != null) {
      final otherId = transfer.fromTransactionId == row.id
          ? transfer.toTransactionId
          : transfer.fromTransactionId;
      final other = await model.Transaction.db.findById(
        session,
        otherId,
        transaction: transaction,
      );
      final otherAccount = other == null
          ? null
          : await Account.db.findById(
              session,
              other.accountId,
              transaction: transaction,
            );
      if (other != null && otherAccount != null) {
        peer = TransferPeerView(
          transferId: transfer.id!,
          transactionId: other.id!,
          accountId: other.accountId,
          accountName: otherAccount.name,
          entityId: other.entityId,
          amountMinor: other.amountMinor,
          currencyCode: otherAccount.currencyCode,
        );
      }
    }

    return TransactionView(
      transaction: row,
      lines: lines,
      accountCurrencyCode: account.currencyCode,
      accountName: account.name,
      payeeName: payee?.name,
      transferPeer: peer,
    );
  }

  static Future<Transfer?> _transferFor(
    Session session,
    UuidValue transactionId,
    Transaction? transaction,
  ) => Transfer.db.findFirstRow(
    session,
    where: (t) =>
        t.fromTransactionId.equals(transactionId) |
        t.toTransactionId.equals(transactionId),
    transaction: transaction,
  );

  static Future<Account> _lockAccount(
    Session session,
    UuidValue id,
    Transaction transaction,
  ) async {
    final account = await Account.db.findById(
      session,
      id,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    return account;
  }

  static Future<Map<UuidValue, Account>> _lockAccounts(
    Session session,
    Iterable<UuidValue> ids,
    Transaction transaction,
  ) async {
    final ordered = ids.toSet().toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    final accounts = <UuidValue, Account>{};
    for (final id in ordered) {
      accounts[id] = await _lockAccount(session, id, transaction);
    }
    return accounts;
  }

  static Future<Payee?> _resolvePayee(
    Session session,
    Entity entity,
    TransactionInput input,
    Transaction transaction,
  ) async {
    final payeeId = input.payeeId;
    if (payeeId != null) {
      final payee = await Payee.db.findById(
        session,
        payeeId,
        transaction: transaction,
      );
      if (payee == null) {
        throw NotFoundException(message: 'Payee not found');
      }
      if (payee.entityId != entity.id) {
        throw ForbiddenException(message: 'Payee belongs to another entity');
      }
      return payee;
    }

    final name = input.payeeName?.trim();
    if (name == null || name.isEmpty) return null;
    await session.db.unsafeExecute(
      'INSERT INTO payee ("entityId", name, "createdAt") '
      'VALUES (@entityId::uuid, @name, now()) '
      'ON CONFLICT ("entityId", name) DO NOTHING',
      parameters: QueryParameters.named({
        'entityId': entity.id!.toString(),
        'name': name,
      }),
      transaction: transaction,
    );
    final payee = await Payee.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entity.id) & t.name.equals(name),
      transaction: transaction,
    );
    if (payee == null) {
      throw StateError('Payee upsert did not produce a row');
    }
    return payee;
  }

  static Future<DateTime?> _lockDate(
    Session session,
    Entity entity,
    Transaction transaction,
  ) async {
    if (entity.accountingMode != AccountingMode.ledger) return null;
    final lock = await LedgerPeriodLock.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entity.id),
      transaction: transaction,
    );
    return lock?.lockDate;
  }

  static Future<void> _writeAudit(
    Session session,
    UuidValue entityId,
    AuditAction action,
    UuidValue transactionId,
    Map<String, Object?> payload,
    Transaction transaction,
  ) => AuditEvent.db.insertRow(
    session,
    AuditEvent(
      entityId: entityId,
      actorId: EntityAccess.userId(session),
      action: action,
      subjectType: AuditSubject.transaction,
      subjectId: transactionId,
      payloadJson: jsonEncode(payload),
    ),
    transaction: transaction,
  );

  static DateTime _requireWritableDate(Entity entity, DateTime date) {
    if (!isCivilDate(date)) {
      throw ValidationException(
        message: 'date must be a UTC calendar date',
      );
    }
    if (date.year < 1900) {
      throw ValidationException(
        message: 'date is before the supported calendar range',
      );
    }
    final tomorrow = EntityClock.today(entity).add(const Duration(days: 1));
    if (date.isAfter(tomorrow)) {
      throw ValidationException(
        message:
            'A transaction cannot be dated after the entity today plus one',
      );
    }
    return date;
  }

  static void _rejectLockedDate(DateTime date, DateTime? lockDate) {
    if (lockDate != null && !date.isAfter(lockDate)) {
      throw ValidationException(
        message: 'The entity period lock rejects this date',
      );
    }
  }

  static void _requireTransactionAccount(Account account) {
    if (account.balanceSource != AccountBalanceSource.transactions) {
      throw StateError('Transaction writes require a transactions account');
    }
  }

  static void _requireSafeMinor(int amount, String field) {
    if (amount.abs() > maxSafeMinor) {
      throw ValidationException(
        message: '$field exceeds the safe minor-unit range',
      );
    }
  }

  static int _exponent(String currencyCode) {
    final currency = CurrencyCode.tryParse(currencyCode);
    if (currency == null) {
      throw ValidationException(
        message: 'Unsupported currency "$currencyCode"',
      );
    }
    return currency.decimals;
  }

  static int _convert(
    int amountMinor,
    ExactDecimal rate,
    String fromCurrencyCode,
    String toCurrencyCode,
  ) {
    try {
      return convertMinorUnits(
        amountMinor: amountMinor,
        exchangeRate: rate,
        transactionExponent: _exponent(fromCurrencyCode),
        functionalExponent: _exponent(toCurrencyCode),
      );
      // The conversion helper reports an out-of-range result with RangeError;
      // this boundary turns it into the contract's ValidationException.
      // ignore: avoid_catching_errors
    } on RangeError {
      throw ValidationException(
        message: 'Converted amount exceeds the safe minor-unit range',
      );
    }
  }

  static ExactDecimal _parseRate(String raw) {
    final rate = ExactDecimal.tryParse(raw);
    if (rate == null) {
      throw ValidationException(
        message: 'FX rate must be a positive exact decimal',
      );
    }
    return rate;
  }

  /// Compares two exact decimals as rational numbers, so `"0.8"` and `"0.80"`
  /// are the same rate rather than a re-pricing edit.
  static bool _rateTextDiffers(String raw, String stored) {
    final rate = _parseRate(raw);
    final previous = _parseRate(stored);
    return rate.numerator * previous.denominator !=
        previous.numerator * rate.denominator;
  }

  static bool _sameLineInputs(
    List<TransactionLineInput> inputs,
    List<TransactionLine> stored,
  ) {
    if (inputs.length != stored.length) return false;
    for (var index = 0; index < inputs.length; index++) {
      final input = inputs[index];
      final line = stored[index];
      if (input.amountMinor != line.amountMinor ||
          input.envelopeId != line.envelopeId ||
          input.ledgerAccountId != line.ledgerAccountId ||
          _normaliseTaxCode(input.taxCategoryCode) != line.taxCategoryCode ||
          input.businessUsePercent != line.businessUsePercent ||
          input.salesTaxMinor != line.salesTaxMinor ||
          input.memo != line.memo) {
        return false;
      }
    }
    return true;
  }

  static String? _normaliseTaxCode(String? code) {
    final trimmed = code?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static void _queueChange(
    _ChangeOutbox outbox,
    model.Transaction row, {
    UuidValue? accountId,
    int? month,
  }) {
    outbox.changes.add(
      _PendingChange(
        entityId: row.entityId,
        month: month ?? MonthKey.fromDate(row.date),
        accountId: accountId ?? row.accountId,
      ),
    );
  }

  /// Queues the scopes an edit touched: the row's new month and account, and
  /// its old month and account when either moved. Observers of a month or
  /// account that did not change are not notified.
  static void _queueUpdateChanges(
    _ChangeOutbox outbox,
    model.Transaction row, {
    required DateTime oldDate,
    required UuidValue oldAccountId,
  }) {
    final newMonth = MonthKey.fromDate(row.date);
    final oldMonth = MonthKey.fromDate(oldDate);
    final newAccountId = row.accountId;

    _queueChange(outbox, row, month: newMonth, accountId: newAccountId);

    final unchanged = oldMonth == newMonth && oldAccountId == newAccountId;
    if (unchanged) return;

    _queueChange(outbox, row, month: oldMonth, accountId: oldAccountId);
  }
}

final class _ResolvedRate {
  const _ResolvedRate({
    required this.value,
    required this.rate,
    required this.rateDate,
    required this.source,
    required this.baseAmountMinor,
  });

  final ExactDecimal value;
  final String rate;
  final DateTime rateDate;
  final FxRateSource source;
  final int baseAmountMinor;
}

final class _BuiltLine {
  const _BuiltLine({
    required this.amountMinor,
    required this.baseAmountMinor,
    required this.envelopeId,
    required this.ledgerAccountId,
    required this.taxCategoryCode,
    required this.businessUsePercent,
    required this.salesTaxMinor,
    required this.memo,
    required this.sortOrder,
  });

  final int amountMinor;
  final int baseAmountMinor;
  final UuidValue? envelopeId;
  final UuidValue? ledgerAccountId;
  final String? taxCategoryCode;
  final int? businessUsePercent;
  final int? salesTaxMinor;
  final String? memo;
  final int sortOrder;
}

final class _PendingChange {
  const _PendingChange({
    required this.entityId,
    required this.month,
    required this.accountId,
  });

  final UuidValue entityId;
  final int month;
  final UuidValue accountId;
}

final class _ChangeOutbox {
  final List<_PendingChange> changes = [];

  Future<void> publish(Session session) async {
    for (final change in changes) {
      await TransactionWriter._publisher(
        session,
        change.entityId,
        ChangeScope.transactions,
        month: change.month,
        accountId: change.accountId,
      );
    }
  }
}
