import 'dart:convert';

import 'package:crypto/crypto.dart';
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
import 'package:openbudget_server/src/tax/tax_catalogue_validation.dart';
import 'package:openbudget_server/src/transaction_rules/payee_rule_lookup.dart';
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
/// [inTransaction]. Row locks always follow one hierarchy: the accounts the
/// write touches, in UUID order, then the transaction rows, in UUID order,
/// then any link rows. Every affected account is discovered before the first
/// row lock, so account deletion and a transfer delete can wait on each other
/// without forming a cycle. Each operation then verifies ownership, validates
/// every line, stores a reproducible FX rate, and moves cached balances
/// atomically with the rows.
///
/// Change events are published only after the owning database transaction
/// commits. A caller that passes `transaction:` must have opened it with
/// [inTransaction], so a rolled-back write never emits an event.
abstract final class TransactionWriter {
  /// The largest number of transactions one bulk status or flag change takes.
  ///
  /// A page from `transaction.list` holds at most 200 rows, so a bulk action
  /// covers at most one page.
  static const maxBulkTransactionIds = 200;

  /// The most rows one import accepts in one call.
  ///
  /// One batch of this size fits one database transaction, one account lock
  /// and one insert statement while staying far below PostgreSQL's bind
  /// parameter limit.
  static const maxImportRows = 1000;

  /// The longest `externalId` one import row accepts.
  static const maxImportExternalIdLength = 255;

  static EntityChangePublisher _publisher = EntityRealtimeNotifier.notify;
  static final Expando<_ChangeOutbox> _outboxes = Expando(
    'TransactionWriter.outbox',
  );
  static int _viewBatchQueries = 0;

  /// Counts the relation queries [views] ran since the last reset.
  @visibleForTesting
  static int get debugViewBatchQueryCount => _viewBatchQueries;

  /// Resets [debugViewBatchQueryCount] so a test can prove a page stays
  /// bounded as rows grow.
  @visibleForTesting
  static void resetDebugViewBatchQueryCount() {
    _viewBatchQueries = 0;
  }

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

  /// Builds views for one page of [rows] with one query per relation.
  ///
  /// A page never costs a round trip per row: accounts, lines, payees,
  /// transfers, peer legs and peer accounts each load in one `IN` query. The
  /// caller passes at most one page, so the query count is bounded by the six
  /// relations rather than by the number of transactions.
  static Future<List<TransactionView>> views(
    Session session,
    List<model.Transaction> rows, {
    Transaction? transaction,
  }) async {
    if (rows.isEmpty) return const [];

    _viewBatchQueries++;
    final accountIds = <UuidValue>{
      for (final row in rows) row.accountId,
    };
    final accounts = await Account.db.find(
      session,
      where: (t) => t.id.inSet(accountIds),
      transaction: transaction,
    );
    final accountById = {for (final account in accounts) account.id!: account};
    for (final row in rows) {
      if (!accountById.containsKey(row.accountId)) {
        throw StateError('Transaction account disappeared');
      }
    }

    final ids = {for (final row in rows) row.id!};
    _viewBatchQueries++;
    final lines = await TransactionLine.db.find(
      session,
      where: (t) => t.transactionId.inSet(ids),
      orderByList: (t) => [t.sortOrder, t.id],
      transaction: transaction,
    );
    final linesByTransaction = <UuidValue, List<TransactionLine>>{};
    for (final line in lines) {
      (linesByTransaction[line.transactionId] ??= []).add(line);
    }

    final payeeIds = {
      for (final row in rows)
        if (row.payeeId != null) row.payeeId!,
    };
    final payees = payeeIds.isEmpty
        ? const <Payee>[]
        : await Payee.db.find(
            session,
            where: (t) => t.id.inSet(payeeIds),
            transaction: transaction,
          );
    if (payeeIds.isNotEmpty) _viewBatchQueries++;
    final payeeById = {for (final payee in payees) payee.id!: payee};

    _viewBatchQueries++;
    final transfers = await Transfer.db.find(
      session,
      where: (t) =>
          t.fromTransactionId.inSet(ids) | t.toTransactionId.inSet(ids),
      transaction: transaction,
    );
    final transferByLeg = <UuidValue, Transfer>{};
    for (final transfer in transfers) {
      transferByLeg[transfer.fromTransactionId] = transfer;
      transferByLeg[transfer.toTransactionId] = transfer;
    }
    final peerIds = <UuidValue>{};
    for (final row in rows) {
      final transfer = transferByLeg[row.id];
      if (transfer == null) continue;
      peerIds.add(_peerLegId(transfer, row.id!));
    }

    final peerRows = peerIds.isEmpty
        ? const <model.Transaction>[]
        : await model.Transaction.db.find(
            session,
            where: (t) => t.id.inSet(peerIds),
            transaction: transaction,
          );
    if (peerIds.isNotEmpty) _viewBatchQueries++;
    final rowsById = <UuidValue, model.Transaction>{
      for (final row in rows) row.id!: row,
      for (final peer in peerRows) peer.id!: peer,
    };

    final missingAccountIds = {
      for (final peer in peerRows)
        if (!accountById.containsKey(peer.accountId)) peer.accountId,
    };
    if (missingAccountIds.isNotEmpty) {
      _viewBatchQueries++;
      final peerAccounts = await Account.db.find(
        session,
        where: (t) => t.id.inSet(missingAccountIds),
        transaction: transaction,
      );
      for (final account in peerAccounts) {
        accountById[account.id!] = account;
      }
    }

    return [
      for (final row in rows)
        TransactionView(
          transaction: row,
          lines: linesByTransaction[row.id] ?? const [],
          accountCurrencyCode: accountById[row.accountId]!.currencyCode,
          accountName: accountById[row.accountId]!.name,
          payeeName: row.payeeId == null ? null : payeeById[row.payeeId]?.name,
          transferPeer: _peerView(row, transferByLeg, rowsById, accountById),
        ),
    ];
  }

  /// Creates a header, its lines and the account balance movement atomically.
  ///
  /// [systemOwner] is reserved for a server-owned job acting for a persisted
  /// entity owner. Endpoints leave it null and cross the session's normal
  /// authentication check.
  static Future<TransactionView> create(
    Session session,
    TransactionInput input, {
    Transaction? transaction,
    TransactionWriteMetadata metadata = const TransactionWriteMetadata(),
    SystemEntityOwner? systemOwner,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _create(
        session,
        input,
        joined,
        metadata,
        _requireOutbox(joined),
        systemOwner,
      );
    }
    return _owned(
      session,
      (tx, outbox) =>
          _create(session, input, tx, metadata, outbox, systemOwner),
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

  /// Moves the payee reference on every transaction of [entityId] from
  /// [fromPayeeId] to [toPayeeId], or clears it when [toPayeeId] is null.
  ///
  /// Payee merging and deletion use this narrow seam instead of writing
  /// transaction rows themselves. It follows the writer's lock hierarchy:
  /// every account of the entity is locked in UUID order, then the affected
  /// rows in UUID order. Locking every account stops a concurrent writer from
  /// adding a row that references the source payee between discovery and the
  /// delete. Only `payeeId` and `updatedAt` change. Lines, amounts, FX rate and
  /// date, base totals, status, revision, transfer links and cached balances
  /// stay exactly as they were, so a reconciled or transfer leg accepts the
  /// change and a ledger-mode entity needs no revision or audit. Change events
  /// publish only after the caller's transaction commits.
  ///
  /// The caller locks the entity; this method validates both payees belong to
  /// [entityId] and returns the number of headers whose payee moved.
  static Future<int> reassignPayee(
    Session session, {
    required UuidValue entityId,
    required UuidValue fromPayeeId,
    required UuidValue? toPayeeId,
    required Transaction transaction,
  }) async {
    if (toPayeeId == fromPayeeId) {
      throw ValidationException(
        message: 'Reassigning a payee needs a different destination',
      );
    }

    final outbox = _requireOutbox(transaction);
    final source = await Payee.db.findById(
      session,
      fromPayeeId,
      transaction: transaction,
    );
    if (source == null) {
      throw NotFoundException(message: 'Payee not found');
    }
    if (source.entityId != entityId) {
      throw ForbiddenException(message: 'Payee belongs to another entity');
    }
    if (toPayeeId != null) {
      final destination = await Payee.db.findById(
        session,
        toPayeeId,
        transaction: transaction,
      );
      if (destination == null) {
        throw NotFoundException(message: 'Destination payee not found');
      }
      if (destination.entityId != entityId) {
        throw ForbiddenException(
          message: 'Destination payee belongs to another entity',
        );
      }
    }

    // Lock every account of the entity first, in UUID order, then discover the
    // rows. A writer holds an account before it touches a transaction, so this
    // both keeps the shared hierarchy and stops a new row with the source
    // payee from appearing between discovery and the delete.
    final accounts = await Account.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.id],
      transaction: transaction,
    );
    await _lockSurvivingAccounts(
      session,
      accounts.map((account) => account.id!),
      transaction,
    );

    final discovered = await model.Transaction.db.find(
      session,
      where: (t) => t.entityId.equals(entityId) & t.payeeId.equals(fromPayeeId),
      orderByList: (t) => [t.id],
      transaction: transaction,
    );

    final now = DateTime.now().toUtc();
    var changed = 0;
    for (final header in discovered) {
      final locked = await model.Transaction.db.findById(
        session,
        header.id!,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (locked == null) {
        throw ValidationException(
          message: 'A transaction changed concurrently; retry the payee change',
        );
      }
      if (locked.entityId != entityId) {
        throw ForbiddenException(
          message: 'A transaction belongs to another entity',
        );
      }
      if (locked.payeeId != fromPayeeId) continue;

      final row = await model.Transaction.db.updateRow(
        session,
        locked.copyWith(payeeId: toPayeeId, updatedAt: now),
        transaction: transaction,
      );
      _queueUpdateChanges(
        outbox,
        row,
        oldDate: locked.date,
        oldAccountId: locked.accountId,
      );
      changed++;
    }

    return changed;
  }

  /// Locks, in UUID order, every account a source envelope's lines touch.
  ///
  /// Envelope deletion calls this before it locks the envelope's catalogue
  /// rows. A transaction writer takes its account lock before it touches an
  /// envelope, so taking accounts first keeps both paths in one order and
  /// stops a line writer from holding an account while it waits for the
  /// envelope row.
  static Future<Set<UuidValue>> lockEnvelopeLineAccounts(
    Session session, {
    required UuidValue entityId,
    required UuidValue envelopeId,
    required Transaction transaction,
  }) async {
    final lines = await TransactionLine.db.find(
      session,
      where: (t) => t.envelopeId.equals(envelopeId),
      transaction: transaction,
    );
    if (lines.isEmpty) return const <UuidValue>{};

    final transactionIds = {for (final line in lines) line.transactionId};
    final headers = await model.Transaction.db.find(
      session,
      where: (t) => t.id.inSet(transactionIds),
      transaction: transaction,
    );
    if (headers.length != transactionIds.length) {
      throw ValidationException(
        message: 'An envelope line points at a missing transaction',
      );
    }
    for (final header in headers) {
      if (header.entityId != entityId) {
        throw ForbiddenException(
          message: 'An envelope line belongs to another entity',
        );
      }
    }

    final accountIds = {for (final header in headers) header.accountId};
    final transfers = await Transfer.db.find(
      session,
      where: (t) =>
          t.fromTransactionId.inSet(transactionIds) |
          t.toTransactionId.inSet(transactionIds),
      transaction: transaction,
    );
    for (final transfer in transfers) {
      final peerId = transactionIds.contains(transfer.fromTransactionId)
          ? transfer.toTransactionId
          : transfer.fromTransactionId;
      final peer = await model.Transaction.db.findById(
        session,
        peerId,
        transaction: transaction,
      );
      if (peer == null) {
        throw NotFoundException(message: 'Transfer leg not found');
      }
      await EntityAccess.requireOwned(
        session,
        peer.entityId,
        transaction: transaction,
      );
      accountIds.add(peer.accountId);
    }

    await _lockAccounts(session, accountIds, transaction);
    return accountIds;
  }

  /// Moves every line that codes to [fromEnvelopeId] onto [toEnvelopeId].
  ///
  /// This is the narrow seam envelope deletion uses. Ordinary rows go through
  /// [updateLines], so reconciliation, period locks, ledger revisions, stored
  /// FX/base amounts, balances and audit rules are exactly the app edit path.
  /// A transfer's envelope-bearing leg is recoded in place, because
  /// [updateLines] refuses to touch a transfer leg and a full transfer update
  /// would rewrite the peer's independently editable metadata. The caller
  /// joins this method to a transaction opened by [inTransaction]; change
  /// events publish only after that transaction commits.
  ///
  /// Pass [lockedAccountIds] from [lockEnvelopeLineAccounts] when the caller
  /// has already locked them. A line added on an unlocked account meanwhile
  /// rejects the whole operation with a retryable validation error instead of
  /// locking after the envelope and risking a deadlock.
  ///
  /// Returns the number of transaction headers whose lines moved.
  static Future<int> reassignEnvelopeLines(
    Session session, {
    required UuidValue fromEnvelopeId,
    required UuidValue toEnvelopeId,
    required Transaction transaction,
    Set<UuidValue>? lockedAccountIds,
  }) async {
    if (fromEnvelopeId == toEnvelopeId) {
      throw ValidationException(
        message: 'Reassignment needs a different destination envelope',
      );
    }

    final outbox = _requireOutbox(transaction);
    final source = await Envelope.db.findById(
      session,
      fromEnvelopeId,
      transaction: transaction,
    );
    if (source == null) {
      throw NotFoundException(message: 'Envelope not found');
    }
    final destination = await Envelope.db.findById(
      session,
      toEnvelopeId,
      transaction: transaction,
    );
    if (destination == null) {
      throw NotFoundException(message: 'Destination envelope not found');
    }
    if (destination.entityId != source.entityId) {
      throw ForbiddenException(
        message: 'Destination envelope belongs to another entity',
      );
    }

    final entity = await EntityAccess.requireOwned(
      session,
      source.entityId,
      transaction: transaction,
    );
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects envelope changes',
      );
    }

    final lines = await TransactionLine.db.find(
      session,
      where: (t) => t.envelopeId.equals(fromEnvelopeId),
      transaction: transaction,
    );
    if (lines.isEmpty) return 0;

    final transactionIds = {
      for (final line in lines) line.transactionId,
    }.toList()..sort((a, b) => a.uuid.compareTo(b.uuid));
    final headers = await model.Transaction.db.find(
      session,
      where: (t) => t.id.inSet(transactionIds.toSet()),
      transaction: transaction,
    );
    if (headers.length != transactionIds.length) {
      throw ValidationException(
        message: 'An envelope line points at a missing transaction',
      );
    }
    for (final header in headers) {
      if (header.entityId != source.entityId) {
        throw ForbiddenException(
          message: 'An envelope line belongs to another entity',
        );
      }
      if (lockedAccountIds != null &&
          !lockedAccountIds.contains(header.accountId)) {
        throw ValidationException(
          message:
              'Envelope lines changed concurrently; retry the reassignment',
        );
      }
    }

    // Accounts first, in UUID order, exactly like every other writer path.
    if (lockedAccountIds == null) {
      await _lockAccounts(
        session,
        headers.map((header) => header.accountId),
        transaction,
      );
    }

    final headersById = {for (final header in headers) header.id!: header};
    var moved = 0;

    for (final id in transactionIds) {
      final header = headersById[id]!;
      final transfer = await _transferFor(session, id, transaction);

      if (transfer != null) {
        await _reassignTransferEnvelope(
          session,
          header: header,
          transfer: transfer,
          toEnvelopeId: toEnvelopeId,
          transaction: transaction,
          outbox: outbox,
          lockedAccountIds: lockedAccountIds,
        );
      } else {
        final stored = await _lines(session, id, transaction);
        await _updateLines(
          session,
          id,
          [
            for (final line in stored)
              TransactionLineInput(
                amountMinor: line.amountMinor,
                envelopeId: line.envelopeId == fromEnvelopeId
                    ? toEnvelopeId
                    : line.envelopeId,
                ledgerAccountId: line.ledgerAccountId,
                taxCategoryCode: line.taxCategoryCode,
                businessUsePercent: line.businessUsePercent,
                salesTaxMinor: line.salesTaxMinor,
                memo: line.memo,
              ),
          ],
          transaction,
          outbox,
        );
      }

      moved++;
    }

    return moved;
  }

  /// Creates both legs of a transfer and their link atomically.
  ///
  /// Returns `[from leg, to leg]`. Both accounts belong to the caller and may
  /// sit in different entities or currencies. The entity base moves follow
  /// section 6.3: a transfer inside one entity nets to exactly zero in base,
  /// while a cross-entity transfer converts each leg into its own base.
  static Future<List<TransactionView>> createTransfer(
    Session session,
    TransferInput input, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _createTransfer(session, input, joined, _requireOutbox(joined));
    }
    return _owned(
      session,
      (tx, outbox) => _createTransfer(session, input, tx, outbox),
    );
  }

  /// Replaces both existing legs of a transfer and their link atomically.
  ///
  /// The transaction ids and the link id stay stable. Returns
  /// `[from leg, to leg]` in the input's direction, so a source/destination
  /// swap is just an account change on the same two rows.
  static Future<List<TransactionView>> updateTransfer(
    Session session,
    UuidValue transferId,
    TransferInput input, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _updateTransfer(
        session,
        transferId,
        input,
        joined,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) => _updateTransfer(session, transferId, input, tx, outbox),
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
  /// left behind by a database cascade. The target account and every account a
  /// transfer touches are locked in UUID order before the first transfer row,
  /// so the caller must not already hold an account outside that set. The
  /// usual delete restrictions apply: a reconciled or period-locked leg
  /// rejects the whole account deletion rather than producing a partial
  /// delete.
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

  /// Sets [status] on every listed transaction in one owned transaction.
  ///
  /// Status is metadata: the movement, lines, FX rate, revision and cached
  /// balance stay untouched. `reconciled` cannot be set here, but moving a
  /// reconciled row back to `cleared` or `uncleared` unlocks it.
  ///
  /// A foreign or missing id fails the whole call with a generic
  /// [NotFoundException], so a caller cannot tell another user's transaction
  /// from one that does not exist. Duplicate ids apply once. Empty [ids] is a
  /// no-op. The returned count is the number of rows whose status changed.
  static Future<int> setStatus(
    Session session,
    List<UuidValue> ids,
    TransactionStatus status, {
    Transaction? transaction,
  }) async {
    if (status == TransactionStatus.reconciled) {
      throw ValidationException(
        message: 'Reconciled status is set only by reconciliation',
      );
    }
    final unique = _bulkIds(ids);
    if (unique.isEmpty) return 0;
    final joined = transaction;
    if (joined != null) {
      return _setStatus(
        session,
        unique,
        status,
        joined,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) => _setStatus(session, unique, status, tx, outbox),
    );
  }

  /// Sets or clears [flag] on every listed transaction in one transaction.
  ///
  /// A null [flag] clears the colour. The rules for ownership, duplicates,
  /// empty ids and the returned changed count match [setStatus].
  static Future<int> setFlag(
    Session session,
    List<UuidValue> ids,
    TransactionFlag? flag, {
    Transaction? transaction,
  }) async {
    final unique = _bulkIds(ids);
    if (unique.isEmpty) return 0;
    final joined = transaction;
    if (joined != null) {
      return _setFlag(session, unique, flag, joined, _requireOutbox(joined));
    }
    return _owned(
      session,
      (tx, outbox) => _setFlag(session, unique, flag, tx, outbox),
    );
  }

  /// Reconciles one transactions account against a statement balance.
  ///
  /// Cleared is the signed sum of `cleared` and `reconciled` rows dated on or
  /// before [statementDate]. A non-zero difference with [createAdjustment]
  /// false is a read-only preview: it returns the facts and writes nothing.
  /// With [createAdjustment] true the difference is posted through [create]
  /// as a `balanceAdjustment` dated [statementDate], then every row that is
  /// still cleared on or before that date becomes reconciled. Only rows on
  /// [accountId] change; a transfer peer keeps its status.
  ///
  /// An archived entity rejects every write; a preview, which writes nothing,
  /// is still readable. Because the adjustment is an ordinary create, a closed
  /// account or ledger period lock rejects only the adjustment; a matching
  /// statement still reconciles status metadata. Change events publish only
  /// after the owning transaction commits.
  static Future<ReconcileResult> reconcile(
    Session session,
    UuidValue accountId,
    DateTime statementDate,
    int statementBalanceMinor,
    // The documented reconcile signature keeps createAdjustment positional.
    // ignore: avoid_positional_boolean_parameters
    bool createAdjustment, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _reconcile(
        session,
        accountId,
        statementDate,
        statementBalanceMinor,
        createAdjustment,
        joined,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) => _reconcile(
        session,
        accountId,
        statementDate,
        statementBalanceMinor,
        createAdjustment,
        tx,
        outbox,
      ),
    );
  }

  /// Imports a file of rows into one transactions account.
  ///
  /// The account is locked once and every row follows the ordinary [create]
  /// rules: ownership, account source and state, the civil-date bound, period
  /// locks, safe non-zero amounts, payee rules and the market FX rate. A row
  /// with a validation problem is reported in [ImportResult.errors] as
  /// `"<0-based index>: <reason>"` and skipped; the valid rows commit together
  /// in one database transaction. Ownership, a valuation source, a closed
  /// account and an archived entity fail the whole call before any row is
  /// written.
  ///
  /// A supplied `externalId` is trimmed and must be 1-255 printable
  /// characters. A null one becomes
  /// `csv:<sha256(yyyy-mm-dd|amountMinor|description|n)>`, where n counts
  /// identical rows earlier in this call. That keeps one file deterministic
  /// on retry while several identical rows in one file stay distinct. The
  /// unique `(accountId, externalId)` index makes the insert idempotent: rows
  /// already on the account, repeated ids in the batch and rows a concurrent
  /// import wins are skipped as duplicates without consuming balance.
  ///
  /// Headers insert with `ON CONFLICT DO NOTHING`, so only new rows get lines
  /// and payees. The cached balance moves once by the sum of the inserted
  /// amounts; a valid final balance therefore never fails on an intermediate
  /// per-row step. Imports are ordinary `uncleared` postings: never
  /// reconciled, transferred or given server metadata. Change events publish
  /// after the commit for the inserted rows' distinct months.
  ///
  /// Empty [rows] is a no-op after the account ownership check. A call accepts
  /// at most [maxImportRows] rows.
  static Future<ImportResult> importRows(
    Session session,
    UuidValue accountId,
    List<ImportRow> rows, {
    Transaction? transaction,
  }) {
    final joined = transaction;
    if (joined != null) {
      return _importRows(
        session,
        accountId,
        rows,
        joined,
        _requireOutbox(joined),
      );
    }
    return _owned(
      session,
      (tx, outbox) => _importRows(session, accountId, rows, tx, outbox),
    );
  }

  static Future<ReconcileResult> _reconcile(
    Session session,
    UuidValue accountId,
    DateTime statementDate,
    int statementBalanceMinor,
    bool createAdjustment,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    _requireSafeMinor(statementBalanceMinor, 'statementBalanceMinor');

    final account = await _lockAccount(session, accountId, tx);
    final entity = await EntityAccess.requireOwned(
      session,
      account.entityId,
      transaction: tx,
    );
    _requireReconcileAccount(account);
    _requireStatementDate(entity, statementDate);

    final cleared = await _clearedMinor(session, accountId, statementDate, tx);
    final difference = BigInt.from(statementBalanceMinor) - cleared;
    if (difference.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message:
            'The reconciliation difference exceeds the safe minor-unit range',
      );
    }
    final clearedMinor = cleared.toInt();
    final differenceMinor = difference.toInt();

    if (differenceMinor != 0 && !createAdjustment) {
      return ReconcileResult(
        clearedBalanceMinor: clearedMinor,
        differenceMinor: differenceMinor,
        reconciledCount: 0,
      );
    }

    // A preview above writes nothing, so it stays readable while the entity is
    // archived. Every path below writes the account or a transaction.
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects reconciliation',
      );
    }

    UuidValue? adjustmentTransactionId;
    if (differenceMinor != 0) {
      final adjustment = await _create(
        session,
        TransactionInput(
          accountId: accountId,
          date: statementDate,
          amountMinor: differenceMinor,
          description: 'Reconciliation adjustment',
          status: TransactionStatus.cleared,
          lines: const [],
        ),
        tx,
        const TransactionWriteMetadata(kind: TransactionKind.balanceAdjustment),
        outbox,
        null,
      );
      adjustmentTransactionId = adjustment.transaction.id;
    }

    final reconciled = await _markReconciled(
      session,
      accountId,
      statementDate,
      tx,
    );

    // The adjustment above moved the cached balance, so the account is read
    // again under its lock before the statement date is written.
    final current = await _lockAccount(session, accountId, tx);
    final throughChanged = current.reconciledThroughDate != statementDate;
    if (throughChanged) {
      await Account.db.updateRow(
        session,
        current.copyWith(
          reconciledThroughDate: statementDate,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
    }

    if (throughChanged || reconciled.changed > 0) {
      _queueReconcileChanges(
        outbox,
        entityId: entity.id!,
        accountId: accountId,
        statementMonth: MonthKey.fromDate(statementDate),
        months: reconciled.months,
      );
    }

    return ReconcileResult(
      clearedBalanceMinor: clearedMinor,
      differenceMinor: differenceMinor,
      adjustmentTransactionId: adjustmentTransactionId,
      reconciledCount: reconciled.changed,
    );
  }

  /// The signed cleared and reconciled total through [statementDate].
  static Future<BigInt> _clearedMinor(
    Session session,
    UuidValue accountId,
    DateTime statementDate,
    Transaction transaction,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT COALESCE(SUM("amountMinor"), 0)::text
FROM "transaction"
WHERE "accountId" = @accountId::uuid
  AND status IN ('cleared', 'reconciled')
  AND date <= @statementDate::timestamp''',
      parameters: QueryParameters.named({
        'accountId': accountId.toString(),
        'statementDate': statementDate,
      }),
      transaction: transaction,
    );
    final cleared = BigInt.parse(rows.single.single as String);
    if (cleared.abs() > BigInt.from(maxSafeMinor)) {
      throw ValidationException(
        message: 'The cleared balance exceeds the safe minor-unit range',
      );
    }
    return cleared;
  }

  /// Marks [accountId]'s cleared rows through [statementDate] reconciled and
  /// returns the changed row count with the distinct months it touched.
  static Future<({int changed, List<int> months})> _markReconciled(
    Session session,
    UuidValue accountId,
    DateTime statementDate,
    Transaction transaction,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
UPDATE "transaction"
SET status = 'reconciled', "updatedAt" = now() AT TIME ZONE 'UTC'
WHERE "accountId" = @accountId::uuid
  AND status = 'cleared'
  AND date <= @statementDate::timestamp
RETURNING date''',
      parameters: QueryParameters.named({
        'accountId': accountId.toString(),
        'statementDate': statementDate,
      }),
      transaction: transaction,
    );

    final months = <int>{};
    for (final row in rows) {
      months.add(MonthKey.fromDate(row.first as DateTime));
    }
    return (changed: rows.length, months: months.toList()..sort());
  }

  /// Queues one event per affected month, reusing a scope the adjustment
  /// create already queued.
  static void _queueReconcileChanges(
    _ChangeOutbox outbox, {
    required UuidValue entityId,
    required UuidValue accountId,
    required int statementMonth,
    required List<int> months,
  }) {
    final queued = <String>{
      for (final change in outbox.changes)
        '${change.entityId}|${change.month}|${change.accountId}',
    };

    void queue(int month) {
      final key = '$entityId|$month|$accountId';
      if (!queued.add(key)) return;
      _queueScope(
        outbox,
        entityId: entityId,
        month: month,
        accountId: accountId,
      );
    }

    queue(statementMonth);
    months.forEach(queue);
  }

  static void _requireReconcileAccount(Account account) {
    if (account.balanceSource != AccountBalanceSource.transactions) {
      throw ValidationException(
        message: 'Reconciliation requires a transactions account',
      );
    }
  }

  static void _requireStatementDate(Entity entity, DateTime statementDate) {
    if (!isCivilDate(statementDate)) {
      throw ValidationException(
        message: 'statementDate must be a UTC calendar date',
      );
    }
    if (statementDate.year < 1900) {
      throw ValidationException(
        message: 'statementDate is before the supported calendar range',
      );
    }
    if (statementDate.isAfter(EntityClock.today(entity))) {
      throw ValidationException(
        message: 'statementDate cannot be after the entity today',
      );
    }
  }

  static List<UuidValue> _bulkIds(List<UuidValue> ids) {
    final unique = ids.toSet().toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    if (unique.length > maxBulkTransactionIds) {
      throw ValidationException(
        message:
            'A bulk transaction change accepts at most '
            '$maxBulkTransactionIds ids',
      );
    }
    return unique;
  }

  static Future<int> _setStatus(
    Session session,
    List<UuidValue> ids,
    TransactionStatus status,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final rows = await _lockBulkRows(session, ids, tx);
    final now = DateTime.now().toUtc();
    final changed = <model.Transaction>[];
    for (final row in rows) {
      if (row.status == status) continue;
      await model.Transaction.db.updateRow(
        session,
        row.copyWith(status: status, updatedAt: now),
        transaction: tx,
      );
      changed.add(row);
    }
    _queueUniqueChanges(outbox, changed);
    return changed.length;
  }

  static Future<int> _setFlag(
    Session session,
    List<UuidValue> ids,
    TransactionFlag? flag,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final rows = await _lockBulkRows(session, ids, tx);
    final now = DateTime.now().toUtc();
    final changed = <model.Transaction>[];
    for (final row in rows) {
      if (row.flag == flag) continue;
      await model.Transaction.db.updateRow(
        session,
        row.copyWith(flag: flag, updatedAt: now),
        transaction: tx,
      );
      changed.add(row);
    }
    _queueUniqueChanges(outbox, changed);
    return changed.length;
  }

  /// Discovers every row and owner before taking the first lock, then follows
  /// the writer hierarchy: accounts in UUID order, then transaction rows in
  /// UUID order. A bulk metadata change never takes a transaction row first,
  /// so it cannot deadlock with a delete or a transfer rewrite.
  static Future<List<model.Transaction>> _lockBulkRows(
    Session session,
    List<UuidValue> ids,
    Transaction tx,
  ) async {
    final discovered = await model.Transaction.db.find(
      session,
      where: (t) => t.id.inSet(ids.toSet()),
      transaction: tx,
    );
    if (discovered.length != ids.length) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final byId = {for (final row in discovered) row.id!: row};
    final entityIds = {for (final row in discovered) row.entityId};
    final entities = await Entity.db.find(
      session,
      where: (t) => t.id.inSet(entityIds),
      transaction: tx,
    );
    final entityById = {for (final entity in entities) entity.id!: entity};
    final owner = EntityAccess.userId(session);
    for (final entityId in entityIds) {
      final entity = entityById[entityId];
      if (entity == null || entity.ownerId != owner) {
        throw NotFoundException(message: 'Transaction not found');
      }
    }

    await _lockAccounts(session, {
      for (final row in discovered) row.accountId,
    }, tx);

    final locked = <model.Transaction>[];
    for (final id in ids) {
      final row = await model.Transaction.db.findById(
        session,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) {
        throw NotFoundException(message: 'Transaction not found');
      }
      final before = byId[id]!;
      if (row.accountId != before.accountId ||
          row.entityId != before.entityId) {
        throw ValidationException(
          message: 'The transaction changed concurrently; retry the change',
        );
      }
      locked.add(row);
    }
    return locked;
  }

  static void _queueUniqueChanges(
    _ChangeOutbox outbox,
    Iterable<model.Transaction> rows,
  ) {
    final seen = <String>{};
    for (final row in rows) {
      final month = MonthKey.fromDate(row.date);
      final key = '${row.entityId}|$month|${row.accountId}';
      if (!seen.add(key)) continue;
      _queueChange(outbox, row, month: month);
    }
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
    SystemEntityOwner? systemOwner,
  ) async {
    final account = await _lockAccount(session, input.accountId, tx);
    final entity = await EntityAccess.requireOwned(
      session,
      account.entityId,
      transaction: tx,
      systemOwner: systemOwner,
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
    final discovered = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (discovered == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final entity = await EntityAccess.requireOwned(
      session,
      discovered.entityId,
      transaction: tx,
    );

    // Both accounts, in UUID order, before the row: an edit must never hold a
    // row while waiting for an account that an account delete already owns.
    final accounts = await _lockAccounts(session, {
      discovered.accountId,
      input.accountId,
    }, tx);
    final existing = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (existing == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    if (existing.accountId != discovered.accountId ||
        existing.entityId != discovered.entityId) {
      throw ValidationException(
        message: 'The transaction changed concurrently; retry the edit',
      );
    }

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
    final discovered = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
    );
    if (discovered == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    final entity = await EntityAccess.requireOwned(
      session,
      discovered.entityId,
      transaction: tx,
    );
    final account = await _lockAccount(session, discovered.accountId, tx);
    final existing = await model.Transaction.db.findById(
      session,
      id,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (existing == null) {
      throw NotFoundException(message: 'Transaction not found');
    }
    if (existing.accountId != discovered.accountId) {
      throw ValidationException(
        message: 'The transaction changed concurrently; retry the edit',
      );
    }

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

  static Future<List<TransactionView>> _createTransfer(
    Session session,
    TransferInput input,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    _requirePositiveSafeMinor(input.fromAmountMinor, 'fromAmountMinor');
    final explicitTo = input.toAmountMinor;
    if (explicitTo != null) {
      _requirePositiveSafeMinor(explicitTo, 'toAmountMinor');
    }
    if (input.fromAccountId == input.toAccountId) {
      throw ValidationException(
        message: 'A transfer needs two different accounts',
      );
    }
    if (input.status == TransactionStatus.reconciled) {
      throw ValidationException(
        message: 'Reconciled status is set only by reconciliation',
      );
    }

    final accounts = await _lockAccounts(session, {
      input.fromAccountId,
      input.toAccountId,
    }, tx);
    final fromAccount = accounts[input.fromAccountId]!;
    final toAccount = accounts[input.toAccountId]!;
    final fromEntity = await EntityAccess.requireOwned(
      session,
      fromAccount.entityId,
      transaction: tx,
    );
    final toEntity = fromAccount.entityId == toAccount.entityId
        ? fromEntity
        : await EntityAccess.requireOwned(
            session,
            toAccount.entityId,
            transaction: tx,
          );

    _requireTransferAccount(fromAccount, fromEntity);
    _requireTransferAccount(toAccount, toEntity);
    _requireWritableDate(fromEntity, input.date);
    _requireWritableDate(toEntity, input.date);
    _rejectLockedDate(input.date, await _lockDate(session, fromEntity, tx));
    if (toEntity.id != fromEntity.id) {
      _rejectLockedDate(input.date, await _lockDate(session, toEntity, tx));
    }

    final toAmount = await _transferDestinationAmount(
      session,
      input: input,
      fromAccount: fromAccount,
      toAccount: toAccount,
      transaction: tx,
      storedToAmount: null,
      sameMovement: false,
    );
    await _validateTransferEnvelope(
      session,
      envelopeId: input.envelopeId,
      fromAccount: fromAccount,
      toAccount: toAccount,
      fromEntity: fromEntity,
      transaction: tx,
    );
    final rates = await _resolveTransferRates(
      session,
      fromAccount: fromAccount,
      toAccount: toAccount,
      fromEntity: fromEntity,
      toEntity: toEntity,
      fromAmountMinor: input.fromAmountMinor,
      toAmountMinor: toAmount,
      date: input.date,
      transaction: tx,
    );

    final now = DateTime.now().toUtc();
    var fromRow = model.Transaction(
      id: const Uuid().v7obj(),
      entityId: fromEntity.id!,
      accountId: fromAccount.id!,
      date: input.date,
      amountMinor: -input.fromAmountMinor,
      baseAmountMinor: rates.from.baseAmountMinor,
      fxRate: rates.from.rate,
      fxRateDate: rates.from.rateDate,
      fxRateSource: rates.from.source,
      status: input.status,
      memo: input.memo,
      revision: 0,
      createdAt: now,
      updatedAt: now,
    );
    var toRow = model.Transaction(
      id: const Uuid().v7obj(),
      entityId: toEntity.id!,
      accountId: toAccount.id!,
      date: input.date,
      amountMinor: toAmount,
      baseAmountMinor: rates.to.baseAmountMinor,
      fxRate: rates.to.rate,
      fxRateDate: rates.to.rateDate,
      fxRateSource: rates.to.source,
      status: input.status,
      memo: input.memo,
      revision: 0,
      createdAt: now,
      updatedAt: now,
    );

    fromRow = await model.Transaction.db.insertRow(
      session,
      fromRow,
      transaction: tx,
    );
    toRow = await model.Transaction.db.insertRow(
      session,
      toRow,
      transaction: tx,
    );
    await TransactionLine.db.insert(session, [
      TransactionLine(
        id: const Uuid().v7obj(),
        transactionId: fromRow.id!,
        amountMinor: -input.fromAmountMinor,
        baseAmountMinor: rates.from.baseAmountMinor,
        envelopeId: input.envelopeId,
        sortOrder: 0,
      ),
      TransactionLine(
        id: const Uuid().v7obj(),
        transactionId: toRow.id!,
        amountMinor: toAmount,
        baseAmountMinor: rates.to.baseAmountMinor,
        sortOrder: 0,
      ),
    ], transaction: tx);
    await Transfer.db.insertRow(
      session,
      Transfer(fromTransactionId: fromRow.id!, toTransactionId: toRow.id!),
      transaction: tx,
    );
    await _applyTransferDeltas(session, [
      (fromAccount.id!, -input.fromAmountMinor),
      (toAccount.id!, toAmount),
    ], tx);

    _queueChange(outbox, fromRow);
    _queueChange(outbox, toRow);
    return [
      await _view(session, fromRow, transaction: tx),
      await _view(session, toRow, transaction: tx),
    ];
  }

  /// Moves the envelope on one outflow transfer leg without rewriting either
  /// header.
  ///
  /// A transfer's status, flag, memo, payee and description are per-leg user
  /// choices: ordinary updates edit one leg at a time, and reconciliation only
  /// changes the leg it selected. Recoding the outflow therefore replaces its
  /// line and bumps its ledger revision, while the peer and both headers keep
  /// their metadata, rates, amounts and balances exactly as stored.
  static Future<void> _reassignTransferEnvelope(
    Session session, {
    required model.Transaction header,
    required Transfer transfer,
    required UuidValue toEnvelopeId,
    required Transaction transaction,
    required _ChangeOutbox outbox,
    Set<UuidValue>? lockedAccountIds,
  }) async {
    if (transfer.toTransactionId == header.id) {
      throw ValidationException(
        message: 'A transfer destination leg cannot carry an envelope',
      );
    }
    if (transfer.fromTransactionId != header.id) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the reassignment',
      );
    }

    final peer = await model.Transaction.db.findById(
      session,
      transfer.toTransactionId,
      transaction: transaction,
    );
    if (peer == null) {
      throw NotFoundException(message: 'Transfer leg not found');
    }
    if (lockedAccountIds != null &&
        (!lockedAccountIds.contains(header.accountId) ||
            !lockedAccountIds.contains(peer.accountId))) {
      throw ValidationException(
        message: 'Envelope lines changed concurrently; retry the reassignment',
      );
    }

    // Accounts first, in UUID order, then rows in UUID order, then the link:
    // the hierarchy every writer path follows.
    final accounts = await _lockAccounts(session, {
      header.accountId,
      peer.accountId,
    }, transaction);

    final legIds = [header.id!, peer.id!]
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    final lockedRows = <UuidValue, model.Transaction>{};
    for (final id in legIds) {
      final row = await model.Transaction.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) {
        throw NotFoundException(message: 'Transfer leg not found');
      }
      lockedRows[id] = row;
    }
    final link = await Transfer.db.findById(
      session,
      transfer.id!,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (link == null) {
      throw NotFoundException(message: 'Transfer not found');
    }
    if (link.fromTransactionId != header.id ||
        link.toTransactionId != peer.id) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the reassignment',
      );
    }

    final from = lockedRows[header.id!]!;
    final to = lockedRows[peer.id!]!;
    if (from.accountId != header.accountId || to.accountId != peer.accountId) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the reassignment',
      );
    }

    // Only the movement itself must agree. Status and memo are per-leg: a
    // cleared outflow may legitimately face an uncleared, differently memoed
    // inflow, so recoding never compares them.
    if (from.date != to.date || from.amountMinor >= 0 || to.amountMinor <= 0) {
      throw ValidationException(
        message:
            'The transfer legs are inconsistent; repair the transfer before '
            'reassigning its envelope',
      );
    }

    final fromAccount = accounts[from.accountId]!;
    final toAccount = accounts[to.accountId]!;
    final fromEntity = await EntityAccess.requireOwned(
      session,
      from.entityId,
      transaction: transaction,
    );
    final toEntity = to.entityId == from.entityId
        ? fromEntity
        : await EntityAccess.requireOwned(
            session,
            to.entityId,
            transaction: transaction,
          );
    if (from.entityId != fromAccount.entityId ||
        to.entityId != toAccount.entityId) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the reassignment',
      );
    }
    if (fromEntity.archivedAt != null || toEntity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects transfers',
      );
    }
    if (from.status == TransactionStatus.reconciled ||
        to.status == TransactionStatus.reconciled) {
      throw ValidationException(
        message: 'A reconciled transfer unlocks before money can change',
      );
    }

    _requireTransferAccount(fromAccount, fromEntity);
    _requireTransferAccount(toAccount, toEntity);
    _requireWritableDate(fromEntity, from.date);
    _requireWritableDate(toEntity, to.date);
    _rejectLockedDate(
      from.date,
      await _lockDate(session, fromEntity, transaction),
    );
    if (toEntity.id != fromEntity.id) {
      _rejectLockedDate(
        to.date,
        await _lockDate(session, toEntity, transaction),
      );
    }
    await _validateTransferEnvelope(
      session,
      envelopeId: toEnvelopeId,
      fromAccount: fromAccount,
      toAccount: toAccount,
      fromEntity: fromEntity,
      transaction: transaction,
    );

    final fromLines = await _lines(session, from.id!, transaction);
    final now = DateTime.now().toUtc();
    final ledger = fromEntity.accountingMode == AccountingMode.ledger;
    final updatedFrom = await model.Transaction.db.updateRow(
      session,
      from.copyWith(
        revision: ledger ? from.revision + 1 : from.revision,
        updatedAt: now,
      ),
      transaction: transaction,
    );
    await _replaceTransferLine(
      session,
      from.id!,
      fromLines,
      amountMinor: from.amountMinor,
      baseAmountMinor: from.baseAmountMinor,
      envelopeId: toEnvelopeId,
      transaction: transaction,
    );
    if (ledger) {
      await _writeTransferAudit(
        session,
        fromEntity,
        fromEntity,
        from,
        fromLines,
        transaction,
      );
    }

    _queueChange(outbox, updatedFrom);
  }

  static Future<List<TransactionView>> _updateTransfer(
    Session session,
    UuidValue transferId,
    TransferInput input,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    _requirePositiveSafeMinor(input.fromAmountMinor, 'fromAmountMinor');
    final explicitTo = input.toAmountMinor;
    if (explicitTo != null) {
      _requirePositiveSafeMinor(explicitTo, 'toAmountMinor');
    }
    if (input.fromAccountId == input.toAccountId) {
      throw ValidationException(
        message: 'A transfer needs two different accounts',
      );
    }

    final discoveredLink = await Transfer.db.findById(
      session,
      transferId,
      transaction: tx,
    );
    if (discoveredLink == null) {
      throw NotFoundException(message: 'Transfer not found');
    }
    final discoveredFrom = await model.Transaction.db.findById(
      session,
      discoveredLink.fromTransactionId,
      transaction: tx,
    );
    final discoveredTo = await model.Transaction.db.findById(
      session,
      discoveredLink.toTransactionId,
      transaction: tx,
    );
    if (discoveredFrom == null || discoveredTo == null) {
      throw NotFoundException(message: 'Transfer leg not found');
    }

    // Accounts first, in UUID order, covering both the old and the new legs.
    final accounts = await _lockAccounts(session, {
      discoveredFrom.accountId,
      discoveredTo.accountId,
      input.fromAccountId,
      input.toAccountId,
    }, tx);

    // Then the transaction rows, in UUID order, then the link.
    final legIds = [
      discoveredLink.fromTransactionId,
      discoveredLink.toTransactionId,
    ]..sort((a, b) => a.uuid.compareTo(b.uuid));
    final lockedRows = <UuidValue, model.Transaction>{};
    for (final id in legIds) {
      final row = await model.Transaction.db.findById(
        session,
        id,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) {
        throw NotFoundException(message: 'Transfer leg not found');
      }
      lockedRows[id] = row;
    }
    final link = await Transfer.db.findById(
      session,
      transferId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (link == null) {
      throw NotFoundException(message: 'Transfer not found');
    }
    if (link.fromTransactionId != discoveredLink.fromTransactionId ||
        link.toTransactionId != discoveredLink.toTransactionId) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the edit',
      );
    }

    final oldFrom = lockedRows[link.fromTransactionId]!;
    final oldTo = lockedRows[link.toTransactionId]!;
    for (final row in [oldFrom, oldTo]) {
      if (!accounts.containsKey(row.accountId)) {
        throw ValidationException(
          message: 'The transfer changed concurrently; retry the edit',
        );
      }
    }

    final oldFromAccount = accounts[oldFrom.accountId]!;
    final oldToAccount = accounts[oldTo.accountId]!;
    final newFromAccount = accounts[input.fromAccountId]!;
    final newToAccount = accounts[input.toAccountId]!;
    final oldFromEntity = await EntityAccess.requireOwned(
      session,
      oldFrom.entityId,
      transaction: tx,
    );
    final oldToEntity = oldTo.entityId == oldFrom.entityId
        ? oldFromEntity
        : await EntityAccess.requireOwned(
            session,
            oldTo.entityId,
            transaction: tx,
          );
    if (oldFrom.entityId != oldFromAccount.entityId ||
        oldTo.entityId != oldToAccount.entityId) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the edit',
      );
    }
    if (oldFromEntity.archivedAt != null || oldToEntity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects transfers',
      );
    }
    final newFromEntity = newFromAccount.entityId == oldFromAccount.entityId
        ? oldFromEntity
        : await EntityAccess.requireOwned(
            session,
            newFromAccount.entityId,
            transaction: tx,
          );
    final newToEntity = newToAccount.entityId == oldToAccount.entityId
        ? oldToEntity
        : await EntityAccess.requireOwned(
            session,
            newToAccount.entityId,
            transaction: tx,
          );

    final oldFromLines = await _lines(session, oldFrom.id!, tx);
    final oldToLines = await _lines(session, oldTo.id!, tx);
    final sameMovement =
        input.fromAccountId == oldFrom.accountId &&
        input.toAccountId == oldTo.accountId &&
        input.date == oldFrom.date &&
        input.date == oldTo.date &&
        input.fromAmountMinor == -oldFrom.amountMinor;
    final toAmount = await _transferDestinationAmount(
      session,
      input: input,
      fromAccount: newFromAccount,
      toAccount: newToAccount,
      transaction: tx,
      storedToAmount: oldTo.amountMinor,
      sameMovement: sameMovement,
    );

    final pricingChanged = !sameMovement || toAmount != oldTo.amountMinor;
    final envelopeChanged =
        oldFromLines.length != 1 ||
        oldToLines.length != 1 ||
        input.envelopeId != _singleEnvelope(oldFromLines);
    final material = pricingChanged || envelopeChanged;

    if (input.status == TransactionStatus.reconciled &&
        (oldFrom.status != TransactionStatus.reconciled ||
            oldTo.status != TransactionStatus.reconciled)) {
      throw ValidationException(
        message: 'Reconciled status is set only by reconciliation',
      );
    }
    if (material &&
        (oldFrom.status == TransactionStatus.reconciled ||
            oldTo.status == TransactionStatus.reconciled)) {
      throw ValidationException(
        message: 'A reconciled transfer unlocks before money can change',
      );
    }

    _requireTransferAccount(newFromAccount, newFromEntity);
    _requireTransferAccount(newToAccount, newToEntity);
    _requireWritableDate(newFromEntity, input.date);
    _requireWritableDate(newToEntity, input.date);
    if (material) {
      _rejectLockedDate(
        oldFrom.date,
        await _lockDate(session, oldFromEntity, tx),
      );
      _rejectLockedDate(oldTo.date, await _lockDate(session, oldToEntity, tx));
      _rejectLockedDate(
        input.date,
        await _lockDate(session, newFromEntity, tx),
      );
      if (newToEntity.id != newFromEntity.id) {
        _rejectLockedDate(
          input.date,
          await _lockDate(session, newToEntity, tx),
        );
      }
    }
    await _validateTransferEnvelope(
      session,
      envelopeId: input.envelopeId,
      fromAccount: newFromAccount,
      toAccount: newToAccount,
      fromEntity: newFromEntity,
      transaction: tx,
    );

    final _ResolvedRate fromRate;
    final _ResolvedRate toRate;
    if (pricingChanged) {
      final rates = await _resolveTransferRates(
        session,
        fromAccount: newFromAccount,
        toAccount: newToAccount,
        fromEntity: newFromEntity,
        toEntity: newToEntity,
        fromAmountMinor: input.fromAmountMinor,
        toAmountMinor: toAmount,
        date: input.date,
        transaction: tx,
      );
      fromRate = rates.from;
      toRate = rates.to;
    } else {
      fromRate = _storedRate(oldFrom);
      toRate = _storedRate(oldTo);
    }

    final fromLedger = _isLedgerRevision(
      oldFromEntity,
      newFromEntity,
      material,
    );
    final toLedger = _isLedgerRevision(oldToEntity, newToEntity, material);
    final now = DateTime.now().toUtc();
    var newFrom = oldFrom.copyWith(
      entityId: newFromEntity.id,
      accountId: newFromAccount.id,
      date: input.date,
      amountMinor: -input.fromAmountMinor,
      baseAmountMinor: fromRate.baseAmountMinor,
      fxRate: fromRate.rate,
      fxRateDate: fromRate.rateDate,
      fxRateSource: fromRate.source,
      status: input.status,
      memo: input.memo,
      payeeId: newFromEntity.id == oldFromEntity.id ? oldFrom.payeeId : null,
      revision: fromLedger ? oldFrom.revision + 1 : oldFrom.revision,
      updatedAt: now,
    );
    var newTo = oldTo.copyWith(
      entityId: newToEntity.id,
      accountId: newToAccount.id,
      date: input.date,
      amountMinor: toAmount,
      baseAmountMinor: toRate.baseAmountMinor,
      fxRate: toRate.rate,
      fxRateDate: toRate.rateDate,
      fxRateSource: toRate.source,
      status: input.status,
      memo: input.memo,
      payeeId: newToEntity.id == oldToEntity.id ? oldTo.payeeId : null,
      revision: toLedger ? oldTo.revision + 1 : oldTo.revision,
      updatedAt: now,
    );

    final updatedRows = <UuidValue, model.Transaction>{};
    for (final id in legIds) {
      final row = id == oldFrom.id ? newFrom : newTo;
      updatedRows[id] = await model.Transaction.db.updateRow(
        session,
        row,
        transaction: tx,
      );
    }
    newFrom = updatedRows[oldFrom.id!]!;
    newTo = updatedRows[oldTo.id!]!;

    await _replaceTransferLine(
      session,
      oldFrom.id!,
      oldFromLines,
      amountMinor: -input.fromAmountMinor,
      baseAmountMinor: fromRate.baseAmountMinor,
      envelopeId: input.envelopeId,
      transaction: tx,
    );
    await _replaceTransferLine(
      session,
      oldTo.id!,
      oldToLines,
      amountMinor: toAmount,
      baseAmountMinor: toRate.baseAmountMinor,
      envelopeId: null,
      transaction: tx,
    );
    await _applyTransferDeltas(session, [
      (oldFromAccount.id!, -oldFrom.amountMinor),
      (oldToAccount.id!, -oldTo.amountMinor),
      (newFromAccount.id!, -input.fromAmountMinor),
      (newToAccount.id!, toAmount),
    ], tx);

    if (material && fromLedger) {
      await _writeTransferAudit(
        session,
        oldFromEntity,
        newFromEntity,
        oldFrom,
        oldFromLines,
        tx,
      );
    }
    if (material && toLedger) {
      await _writeTransferAudit(
        session,
        oldToEntity,
        newToEntity,
        oldTo,
        oldToLines,
        tx,
      );
    }

    _queueTransferUpdate(outbox, newFrom, oldFrom);
    _queueTransferUpdate(outbox, newTo, oldTo);
    return [
      await _view(session, newFrom, transaction: tx),
      await _view(session, newTo, transaction: tx),
    ];
  }

  static Future<int> _transferDestinationAmount(
    Session session, {
    required TransferInput input,
    required Account fromAccount,
    required Account toAccount,
    required Transaction transaction,
    required int? storedToAmount,
    required bool sameMovement,
  }) async {
    if (fromAccount.currencyCode == toAccount.currencyCode) {
      final explicit = input.toAmountMinor;
      if (explicit != null && explicit != input.fromAmountMinor) {
        throw ValidationException(
          message: 'A same-currency transfer moves the same amount',
        );
      }
      return input.fromAmountMinor;
    }
    final explicit = input.toAmountMinor;
    if (explicit != null) return explicit;
    // A metadata-only edit keeps the amount that actually moved; it must not
    // re-resolve a market rate that moved or disappeared.
    if (sameMovement && storedToAmount != null) return storedToAmount;
    if (!input.useMarketRate) {
      throw ValidationException(
        message:
            'A cross-currency transfer needs toAmountMinor or useMarketRate',
      );
    }

    final quote = await FxService.rateOn(
      session,
      fromAccount.currencyCode,
      toAccount.currencyCode,
      input.date,
      transaction: transaction,
    );
    if (quote == null) {
      throw FxRateUnavailableException(
        fromCurrencyCode: fromAccount.currencyCode,
        toCurrencyCode: toAccount.currencyCode,
        date: input.date,
      );
    }
    final rate = ExactDecimal.tryParse(quote.rate);
    if (rate == null) {
      throw FxRateUnavailableException(
        fromCurrencyCode: fromAccount.currencyCode,
        toCurrencyCode: toAccount.currencyCode,
        date: input.date,
      );
    }
    final amount = _convert(
      input.fromAmountMinor,
      rate,
      fromAccount.currencyCode,
      toAccount.currencyCode,
    );
    if (amount <= 0) {
      throw ValidationException(
        message: 'The market conversion rounds to a non-positive amount',
      );
    }
    return amount;
  }

  static Future<({_ResolvedRate from, _ResolvedRate to})> _resolveTransferRates(
    Session session, {
    required Account fromAccount,
    required Account toAccount,
    required Entity fromEntity,
    required Entity toEntity,
    required int fromAmountMinor,
    required int toAmountMinor,
    required DateTime date,
    required Transaction transaction,
  }) async {
    final fromLegAmount = -fromAmountMinor;
    if (fromEntity.id == toEntity.id) {
      final baseCurrency = fromEntity.baseCurrencyCode;
      final fromInBase = fromAccount.currencyCode == baseCurrency;
      final toInBase = toAccount.currencyCode == baseCurrency;
      if (fromInBase && toInBase) {
        return (
          from: await _resolveTransferLegRate(
            session,
            fromAccount,
            fromEntity,
            fromLegAmount,
            date,
            transaction,
          ),
          to: await _resolveTransferLegRate(
            session,
            toAccount,
            toEntity,
            toAmountMinor,
            date,
            transaction,
          ),
        );
      }
      if (fromInBase) {
        final from = await _resolveTransferLegRate(
          session,
          fromAccount,
          fromEntity,
          fromLegAmount,
          date,
          transaction,
        );
        return (
          from: from,
          to: _impliedTransferRate(
            account: toAccount,
            entity: fromEntity,
            amountMinor: toAmountMinor,
            signedBaseAmountMinor: -from.baseAmountMinor,
            date: date,
          ),
        );
      }
      if (toInBase) {
        final to = await _resolveTransferLegRate(
          session,
          toAccount,
          toEntity,
          toAmountMinor,
          date,
          transaction,
        );
        return (
          from: _impliedTransferRate(
            account: fromAccount,
            entity: fromEntity,
            amountMinor: fromLegAmount,
            signedBaseAmountMinor: -to.baseAmountMinor,
            date: date,
          ),
          to: to,
        );
      }

      final from = await _resolveTransferLegRate(
        session,
        fromAccount,
        fromEntity,
        fromLegAmount,
        date,
        transaction,
      );
      return (
        from: from,
        to: _impliedTransferRate(
          account: toAccount,
          entity: fromEntity,
          amountMinor: toAmountMinor,
          signedBaseAmountMinor: -from.baseAmountMinor,
          date: date,
        ),
      );
    }

    return (
      from: await _resolveTransferLegRate(
        session,
        fromAccount,
        fromEntity,
        fromLegAmount,
        date,
        transaction,
      ),
      to: await _resolveTransferLegRate(
        session,
        toAccount,
        toEntity,
        toAmountMinor,
        date,
        transaction,
      ),
    );
  }

  static Future<_ResolvedRate> _resolveTransferLegRate(
    Session session,
    Account account,
    Entity entity,
    int amountMinor,
    DateTime date,
    Transaction transaction,
  ) => _resolveRate(
    session,
    account,
    entity,
    TransactionInput(
      accountId: account.id!,
      date: date,
      amountMinor: amountMinor,
      lines: const [],
    ),
    transaction,
  );

  static _ResolvedRate _impliedTransferRate({
    required Account account,
    required Entity entity,
    required int amountMinor,
    required int signedBaseAmountMinor,
    required DateTime date,
  }) {
    final baseAmount = signedBaseAmountMinor.abs();
    final accountAmount = amountMinor.abs();
    if (baseAmount == 0 || accountAmount == 0) {
      throw ValidationException(
        message: 'The transfer conversion rounds to zero',
      );
    }
    final rate = impliedRate(
      fromMinor: accountAmount,
      toMinor: baseAmount,
      fromExponent: _exponent(account.currencyCode),
      toExponent: _exponent(entity.baseCurrencyCode),
    );
    return _ResolvedRate(
      value: rate,
      rate: _formatRate(rate),
      rateDate: date,
      source: FxRateSource.implied,
      baseAmountMinor: signedBaseAmountMinor,
    );
  }

  static _ResolvedRate _storedRate(model.Transaction row) => _ResolvedRate(
    value: _parseRate(row.fxRate),
    rate: row.fxRate,
    rateDate: row.fxRateDate,
    source: row.fxRateSource,
    baseAmountMinor: row.baseAmountMinor,
  );

  static bool _isLedgerRevision(
    Entity oldEntity,
    Entity newEntity,
    bool material,
  ) =>
      material &&
      (oldEntity.accountingMode == AccountingMode.ledger ||
          newEntity.accountingMode == AccountingMode.ledger);

  static UuidValue? _singleEnvelope(List<TransactionLine> lines) =>
      lines.length == 1 ? lines.single.envelopeId : null;

  static Future<void> _replaceTransferLine(
    Session session,
    UuidValue transactionId,
    List<TransactionLine> existing, {
    required int amountMinor,
    required int baseAmountMinor,
    required UuidValue? envelopeId,
    required Transaction transaction,
  }) async {
    if (existing.length == 1) {
      await TransactionLine.db.updateRow(
        session,
        TransactionLine(
          id: existing.single.id,
          transactionId: transactionId,
          amountMinor: amountMinor,
          baseAmountMinor: baseAmountMinor,
          envelopeId: envelopeId,
          sortOrder: 0,
        ),
        transaction: transaction,
      );
      return;
    }

    await TransactionLine.db.deleteWhere(
      session,
      where: (t) => t.transactionId.equals(transactionId),
      transaction: transaction,
    );
    await TransactionLine.db.insert(
      session,
      _lineRows(transactionId, [
        _BuiltLine(
          amountMinor: amountMinor,
          baseAmountMinor: baseAmountMinor,
          envelopeId: envelopeId,
          ledgerAccountId: null,
          taxCategoryCode: null,
          businessUsePercent: null,
          salesTaxMinor: null,
          memo: null,
          sortOrder: 0,
        ),
      ]),
      transaction: transaction,
    );
  }

  static Future<void> _validateTransferEnvelope(
    Session session, {
    required UuidValue? envelopeId,
    required Account fromAccount,
    required Account toAccount,
    required Entity fromEntity,
    required Transaction transaction,
  }) async {
    if (envelopeId == null) return;

    if (!fromAccount.onBudget) {
      throw ValidationException(
        message: 'An off-budget transfer cannot use an envelope',
      );
    }
    if (toAccount.onBudget && toAccount.entityId == fromAccount.entityId) {
      throw ValidationException(
        message: 'An internal transfer cannot use an envelope',
      );
    }
    final envelope = await Envelope.db.findById(
      session,
      envelopeId,
      transaction: transaction,
    );
    if (envelope == null) {
      throw NotFoundException(message: 'Envelope not found');
    }
    if (envelope.entityId != fromEntity.id) {
      throw ForbiddenException(message: 'Envelope belongs to another entity');
    }
  }

  static Future<void> _applyTransferDeltas(
    Session session,
    Iterable<(UuidValue, int)> deltas,
    Transaction transaction,
  ) async {
    final combined = <UuidValue, int>{};
    for (final (accountId, delta) in deltas) {
      combined.update(
        accountId,
        (existing) => existing + delta,
        ifAbsent: () => delta,
      );
    }

    final ordered = combined.keys.toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    for (final accountId in ordered) {
      final delta = combined[accountId]!;
      if (delta == 0) continue;
      await AccountBalanceService.applyDelta(
        session,
        accountId,
        delta,
        transaction: transaction,
      );
    }
  }

  static Future<void> _writeTransferAudit(
    Session session,
    Entity oldEntity,
    Entity newEntity,
    model.Transaction before,
    List<TransactionLine> lines,
    Transaction transaction,
  ) async {
    if (oldEntity.accountingMode != AccountingMode.ledger &&
        newEntity.accountingMode != AccountingMode.ledger) {
      return;
    }
    final entity = oldEntity.accountingMode == AccountingMode.ledger
        ? oldEntity
        : newEntity;
    await _writeAudit(
      session,
      entity.id!,
      AuditAction.transactionEdited,
      before.id!,
      {
        'before': {
          'transaction': before.toJson(),
          'lines': lines.map((line) => line.toJson()).toList(),
        },
      },
      transaction,
    );
  }

  static void _requirePositiveSafeMinor(int amount, String field) {
    if (amount <= 0 || amount > maxSafeMinor) {
      throw ValidationException(
        message: '$field must be positive and within the safe minor-unit range',
      );
    }
  }

  static void _requireTransferAccount(Account account, Entity entity) {
    _requireTransactionAccount(account);
    if (account.closedAt != null) {
      throw ValidationException(message: 'A closed account rejects transfers');
    }
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects transfers',
      );
    }
  }

  static void _queueTransferUpdate(
    _ChangeOutbox outbox,
    model.Transaction row,
    model.Transaction before,
  ) {
    final newMonth = MonthKey.fromDate(row.date);
    final newAccountId = row.accountId;
    final oldMonth = MonthKey.fromDate(before.date);
    final oldAccountId = before.accountId;

    _queueChange(outbox, row, month: newMonth, accountId: newAccountId);
    final unchanged =
        before.entityId == row.entityId &&
        oldMonth == newMonth &&
        oldAccountId == newAccountId;
    if (unchanged) return;

    _queueScope(
      outbox,
      entityId: before.entityId,
      month: oldMonth,
      accountId: oldAccountId,
    );
  }

  static Future<void> _deleteTransfersForAccount(
    Session session,
    UuidValue accountId,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final discovered = await _transfersTouching(session, accountId, tx);

    // The target and the peer accounts are known before the first row lock,
    // so every account is taken in UUID order ahead of the transfer rows. A
    // peer that another deletion already removed is skipped: its transfers
    // went with it.
    final accounts = await _lockSurvivingAccounts(session, {
      accountId,
      ...discovered.accountIds,
    }, tx);

    // Re-read under the account locks. Holding the target account's row lock
    // stops a writer from adding a leg, so the set can only shrink.
    final current = await _transfersTouching(session, accountId, tx);
    final missing = current.accountIds.difference(accounts.keys.toSet());
    if (missing.isNotEmpty) {
      // A transfer committed after discovery while this delete waited for the
      // target account lock. Locking its peer now would break UUID order and
      // risk a deadlock, so roll the whole delete back with a domain outcome.
      throw ValidationException(
        message:
            'A transfer was created while the account was being deleted; '
            'retry the delete',
      );
    }

    for (final id in current.legIds) {
      await _delete(session, id, tx, outbox);
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
    final otherLegId = transfer == null ? null : _peerLegId(transfer, id);

    final rows = <UuidValue, model.Transaction>{id: existing};
    if (otherLegId != null) {
      final other = await model.Transaction.db.findById(
        session,
        otherLegId,
        transaction: tx,
      );
      if (other == null) {
        throw NotFoundException(message: 'Transfer leg not found');
      }
      rows[otherLegId] = other;
    }

    // Accounts first, in UUID order, then the rows: the hierarchy every writer
    // shares, so a delete never holds one account while waiting for the peer.
    final accounts = await _lockAccounts(
      session,
      rows.values.map((row) => row.accountId),
      tx,
    );

    final orderedIds = rows.keys.toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    final lockedRows = <UuidValue, model.Transaction>{};
    for (final transactionId in orderedIds) {
      final row = await model.Transaction.db.findById(
        session,
        transactionId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row == null) {
        throw NotFoundException(
          message: transfer == null
              ? 'Transaction not found'
              : 'Transfer leg not found',
        );
      }
      if (row.accountId != rows[transactionId]!.accountId) {
        throw ValidationException(
          message: 'The transaction changed concurrently; retry the delete',
        );
      }
      lockedRows[transactionId] = row;
    }

    final lockedTransfer = await _transferFor(session, id, tx);
    final lockedOtherLegId = lockedTransfer == null
        ? null
        : _peerLegId(lockedTransfer, id);
    if (lockedOtherLegId != otherLegId) {
      throw ValidationException(
        message: 'The transfer changed concurrently; retry the delete',
      );
    }

    final entities = <UuidValue, Entity>{};
    for (final row in lockedRows.values) {
      entities[row.entityId] = await EntityAccess.requireOwned(
        session,
        row.entityId,
        transaction: tx,
      );
    }

    for (final row in lockedRows.values) {
      if (row.status == TransactionStatus.reconciled) {
        throw ValidationException(
          message: 'A reconciled transaction unlocks before deletion',
        );
      }
      final entity = entities[row.entityId]!;
      _rejectLockedDate(row.date, await _lockDate(session, entity, tx));
      final account = accounts[row.accountId]!;
      _requireTransactionAccount(account);
    }

    for (final row in lockedRows.values) {
      await AccountBalanceService.applyDelta(
        session,
        row.accountId,
        -row.amountMinor,
        transaction: tx,
      );
    }

    for (final row in lockedRows.values) {
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
    for (final row in lockedRows.values) {
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
      final envelopeId = await PayeeRuleLookup.enabledEnvelope(
        session,
        entityId: entity.id!,
        payeeId: payeeId,
        transaction: transaction,
      );
      if (envelopeId != null) {
        resolved[0] = resolved[0].copyWith(envelopeId: envelopeId);
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
      TaxCatalogueValidation.requireCode(entity, taxCode);
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

  static TransferPeerView? _peerView(
    model.Transaction row,
    Map<UuidValue, Transfer> transferByLeg,
    Map<UuidValue, model.Transaction> rowsById,
    Map<UuidValue, Account> accountById,
  ) {
    final transfer = transferByLeg[row.id];
    if (transfer == null) return null;
    final peerId = _peerLegId(transfer, row.id!);
    final peer = rowsById[peerId];
    final peerAccount = peer == null ? null : accountById[peer.accountId];
    if (peer == null || peerAccount == null) return null;
    return TransferPeerView(
      transferId: transfer.id!,
      transactionId: peer.id!,
      accountId: peer.accountId,
      accountName: peerAccount.name,
      entityId: peer.entityId,
      amountMinor: peer.amountMinor,
      currencyCode: peerAccount.currencyCode,
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

  /// Locks every listed account that still exists, in UUID order.
  ///
  /// Account deletion uses this for the peers of its transfers: a peer removed
  /// by another deletion took its transfers with it, so it is skipped instead
  /// of failing the surviving account's delete.
  static Future<Map<UuidValue, Account>> _lockSurvivingAccounts(
    Session session,
    Iterable<UuidValue> ids,
    Transaction transaction,
  ) async {
    final ordered = ids.toSet().toList()
      ..sort((a, b) => a.uuid.compareTo(b.uuid));
    final accounts = <UuidValue, Account>{};
    for (final id in ordered) {
      final account = await Account.db.findById(
        session,
        id,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (account != null) accounts[id] = account;
    }
    return accounts;
  }

  /// Reads the transfers touching [accountId] and every account they use.
  static Future<({List<UuidValue> legIds, Set<UuidValue> accountIds})>
  _transfersTouching(
    Session session,
    UuidValue accountId,
    Transaction tx,
  ) async {
    final rows = await session.db.unsafeQuery(
      '''
SELECT DISTINCT
  tf."fromTransactionId"::text AS "transactionId",
  leg."accountId"::text AS "accountId"
FROM transfer tf
JOIN "transaction" leg
  ON leg.id IN (tf."fromTransactionId", tf."toTransactionId")
WHERE EXISTS (
  SELECT 1
  FROM "transaction" own
  WHERE own.id IN (tf."fromTransactionId", tf."toTransactionId")
    AND own."accountId" = @accountId::uuid
)
ORDER BY 1, 2''',
      parameters: QueryParameters.named({'accountId': accountId.toString()}),
      transaction: tx,
    );

    final legIds = <UuidValue>{};
    final accountIds = <UuidValue>{};
    for (final row in rows) {
      legIds.add(UuidValue.fromString(row[0] as String));
      accountIds.add(UuidValue.fromString(row[1] as String));
    }

    return (
      legIds: legIds.toList()..sort((a, b) => a.uuid.compareTo(b.uuid)),
      accountIds: accountIds,
    );
  }

  static UuidValue _peerLegId(Transfer transfer, UuidValue id) =>
      transfer.fromTransactionId == id
      ? transfer.toTransactionId
      : transfer.fromTransactionId;

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

    final name = _normalisePayeeName(input.payeeName);
    if (name == null) return null;
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
      throw ValidationException(message: 'date must be a UTC calendar date');
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

  /// Stores the exact value without insignificant trailing zeros.
  static String _formatRate(ExactDecimal rate) {
    final text = rate.toString();
    if (!text.contains('.')) return text;
    final trimmed = text.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
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

  static String? _normalisePayeeName(String? name) {
    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  static void _queueChange(
    _ChangeOutbox outbox,
    model.Transaction row, {
    UuidValue? accountId,
    int? month,
  }) {
    _queueScope(
      outbox,
      entityId: row.entityId,
      month: month ?? MonthKey.fromDate(row.date),
      accountId: accountId ?? row.accountId,
    );
  }

  static void _queueScope(
    _ChangeOutbox outbox, {
    required UuidValue entityId,
    required int month,
    required UuidValue accountId,
  }) {
    outbox.changes.add(
      _PendingChange(entityId: entityId, month: month, accountId: accountId),
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

  static final _externalIdControlCharacters = RegExp(r'[\x00-\x1F\x7F]');

  static Future<ImportResult> _importRows(
    Session session,
    UuidValue accountId,
    List<ImportRow> rows,
    Transaction tx,
    _ChangeOutbox outbox,
  ) async {
    final account = await _lockAccount(session, accountId, tx);
    final entity = await EntityAccess.requireOwned(
      session,
      account.entityId,
      transaction: tx,
    );
    if (rows.isEmpty) {
      return _importResult(rowCount: 0, insertedCount: 0, errors: const {});
    }
    if (rows.length > maxImportRows) {
      throw ValidationException(
        message: 'An import accepts at most $maxImportRows rows',
      );
    }

    _requireTransactionAccount(account);
    if (account.closedAt != null) {
      throw ValidationException(
        message: 'A closed account rejects imported transactions',
      );
    }
    if (entity.archivedAt != null) {
      throw ValidationException(message: 'An archived entity rejects imports');
    }

    // Account-level currency problems fail every row the same way, so they
    // are whole-call failures like an unsupported account in `create`.
    _exponent(account.currencyCode);
    _exponent(entity.baseCurrencyCode);
    final lockDate = await _lockDate(session, entity, tx);

    final derivedCounts = <String, int>{};
    final errors = <int, String>{};
    final pending = <_PendingImportRow>[];
    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final derivedKey =
          '${_civilDateKey(row.date)}|${row.amountMinor}|${row.description}';
      final identicalEarlier = derivedCounts[derivedKey] ?? 0;
      derivedCounts[derivedKey] = identicalEarlier + 1;

      try {
        pending.add(
          _PendingImportRow(
            index: index,
            row: row,
            externalId: _importExternalId(row, identicalEarlier),
          ),
        );
      } on ValidationException catch (error) {
        errors[index] = error.message;
      }
    }

    // A row already on the account is a duplicate even when its payload would
    // no longer validate, so a retried file stays idempotent after a period
    // lock or a rate gap. This is a snapshot only; the unique index decides a
    // concurrent race at insert time.
    final existing = await _existingExternalIds(
      session,
      account.id!,
      pending.map((row) => row.externalId),
      tx,
    );

    final reserved = <String>{};
    final accepted = <_ImportCandidate>[];
    final payeesByName = <String, Payee?>{};
    for (final row in pending) {
      if (existing.contains(row.externalId)) continue;
      if (!reserved.add(row.externalId)) continue;

      try {
        accepted.add(
          await _validateImportRow(
            session,
            pending: row,
            account: account,
            entity: entity,
            lockDate: lockDate,
            payeesByName: payeesByName,
            transaction: tx,
          ),
        );
        // A rejected row never claims its id, so a later row with the same id
        // can still be the one that inserts.
      } on ValidationException catch (error) {
        reserved.remove(row.externalId);
        errors[row.index] = error.message;
      } on NotFoundException catch (error) {
        reserved.remove(row.externalId);
        errors[row.index] = error.message;
      } on ForbiddenException catch (error) {
        reserved.remove(row.externalId);
        errors[row.index] = error.message;
      } on FxRateUnavailableException catch (error) {
        reserved.remove(row.externalId);
        errors[row.index] = error.message;
      }
    }

    if (accepted.isEmpty) {
      return _importResult(
        rowCount: rows.length,
        insertedCount: 0,
        errors: errors,
      );
    }

    final now = DateTime.now().toUtc();
    final ids = {
      for (final candidate in accepted)
        candidate.externalId: const Uuid().v7obj(),
    };
    final headers = [
      for (final candidate in accepted)
        model.Transaction(
          id: ids[candidate.externalId],
          entityId: entity.id!,
          accountId: account.id!,
          date: candidate.date,
          amountMinor: candidate.amountMinor,
          baseAmountMinor: candidate.rate.baseAmountMinor,
          fxRate: candidate.rate.rate,
          fxRateDate: candidate.rate.rateDate,
          fxRateSource: candidate.rate.source,
          status: TransactionStatus.uncleared,
          payeeId: candidate.payee?.id,
          description: candidate.description,
          memo: candidate.memo,
          externalId: candidate.externalId,
          createdAt: now,
          updatedAt: now,
        ),
    ];
    // ignoreConflicts emits ON CONFLICT DO NOTHING and returns only the rows
    // this call inserted. The only realistic conflict is the unique
    // (accountId, externalId) index, because every id here is fresh. A row
    // another import already committed is absent, so it gets no lines, payee,
    // balance movement or event.
    final inserted = await model.Transaction.db.insert(
      session,
      headers,
      transaction: tx,
      ignoreConflicts: true,
    );
    if (inserted.isEmpty) {
      return _importResult(
        rowCount: rows.length,
        insertedCount: 0,
        errors: errors,
      );
    }

    final insertedById = {for (final row in inserted) row.id!: row};
    final insertedCandidates = [
      for (final candidate in accepted)
        if (insertedById.containsKey(ids[candidate.externalId])) candidate,
    ];

    // Payees are created only for headers that actually inserted, and only
    // after the conflict check, so a rejected or duplicate row never leaves a
    // payee behind.
    final payees = await _upsertImportPayees(
      session,
      entity,
      {
        for (final candidate in insertedCandidates)
          if (candidate.payeeName != null) candidate.payeeName!,
      },
      tx,
    );
    final payeeUpdates = <model.Transaction>[];
    for (final candidate in insertedCandidates) {
      final payeeName = candidate.payeeName;
      if (payeeName == null) continue;
      final payee = payees[payeeName];
      if (payee == null) {
        throw StateError('Import payee upsert did not produce a row');
      }
      final row = insertedById[ids[candidate.externalId]]!;
      payeeUpdates.add(row.copyWith(payeeId: payee.id));
    }
    if (payeeUpdates.isNotEmpty) {
      await model.Transaction.db.update(
        session,
        payeeUpdates,
        transaction: tx,
      );
    }

    final lineRows = [
      for (final candidate in insertedCandidates)
        ..._lineRows(ids[candidate.externalId]!, candidate.lines),
    ];
    if (lineRows.isNotEmpty) {
      await TransactionLine.db.insert(session, lineRows, transaction: tx);
    }

    var insertedSum = BigInt.zero;
    for (final candidate in insertedCandidates) {
      insertedSum += BigInt.from(candidate.amountMinor);
    }
    // Bounded rows and safe amounts keep the sum inside int64. One delta is
    // the contract: the final balance, not an intermediate per-row step, is
    // what must stay in range.
    await AccountBalanceService.applyDelta(
      session,
      account.id!,
      insertedSum.toInt(),
      transaction: tx,
    );

    _queueUniqueChanges(outbox, inserted);
    return _importResult(
      rowCount: rows.length,
      insertedCount: inserted.length,
      errors: errors,
    );
  }

  static Future<_ImportCandidate> _validateImportRow(
    Session session, {
    required _PendingImportRow pending,
    required Account account,
    required Entity entity,
    required DateTime? lockDate,
    required Map<String, Payee?> payeesByName,
    required Transaction transaction,
  }) async {
    final row = pending.row;
    _requireNonZeroSafeMinor(row.amountMinor);
    final date = _requireWritableDate(entity, row.date);
    _rejectLockedDate(date, lockDate);

    final payeeName = _normalisePayeeName(row.payeeName);
    final payee = await _cachedImportPayee(
      session,
      entity,
      payeeName,
      payeesByName,
      transaction,
    );

    final input = TransactionInput(
      accountId: account.id!,
      date: date,
      amountMinor: row.amountMinor,
      payeeId: payee?.id,
      description: row.description,
      memo: row.memo,
      status: TransactionStatus.uncleared,
      lines: const [],
    );
    final rate = await _resolveRate(
      session,
      account,
      entity,
      input,
      transaction,
    );
    final lines = await _buildLines(
      session,
      account: account,
      entity: entity,
      input: input,
      payeeId: payee?.id,
      rate: rate.value,
      baseAmountMinor: rate.baseAmountMinor,
      transaction: transaction,
    );

    return _ImportCandidate(
      externalId: pending.externalId,
      date: date,
      amountMinor: row.amountMinor,
      description: row.description,
      memo: row.memo,
      payee: payee,
      payeeName: payee == null ? payeeName : null,
      rate: rate,
      lines: lines,
    );
  }

  static Future<Payee?> _cachedImportPayee(
    Session session,
    Entity entity,
    String? name,
    Map<String, Payee?> cache,
    Transaction transaction,
  ) async {
    if (name == null) return null;
    if (cache.containsKey(name)) return cache[name];

    final payee = await Payee.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entity.id) & t.name.equals(name),
      transaction: transaction,
    );
    cache[name] = payee;
    return payee;
  }

  static Future<Set<String>> _existingExternalIds(
    Session session,
    UuidValue accountId,
    Iterable<String> externalIds,
    Transaction transaction,
  ) async {
    final ids = externalIds.toSet();
    if (ids.isEmpty) return const {};

    final rows = await model.Transaction.db.find(
      session,
      where: (t) => t.accountId.equals(accountId) & t.externalId.inSet(ids),
      transaction: transaction,
    );
    return {
      for (final row in rows)
        if (row.externalId != null) row.externalId!,
    };
  }

  /// Trims and validates a supplied id, or derives the file id for a null one.
  static String _importExternalId(ImportRow row, int identicalEarlier) {
    final supplied = row.externalId;
    if (supplied != null) {
      final trimmed = supplied.trim();
      if (trimmed.isEmpty) {
        throw ValidationException(message: 'externalId must not be blank');
      }
      if (trimmed.length > maxImportExternalIdLength) {
        throw ValidationException(
          message:
              'externalId must be at most '
              '$maxImportExternalIdLength characters',
        );
      }
      if (_externalIdControlCharacters.hasMatch(trimmed)) {
        throw ValidationException(
          message: 'externalId must not contain control characters',
        );
      }
      return trimmed;
    }

    final key =
        '${_civilDateKey(row.date)}|${row.amountMinor}|'
        '${row.description}|$identicalEarlier';
    return 'csv:${sha256.convert(utf8.encode(key))}';
  }

  static Future<Map<String, Payee>> _upsertImportPayees(
    Session session,
    Entity entity,
    Set<String> names,
    Transaction transaction,
  ) async {
    if (names.isEmpty) return const {};

    final now = DateTime.now().toUtc();
    await Payee.db.insert(
      session,
      [
        for (final name in names)
          Payee(
            id: const Uuid().v7obj(),
            entityId: entity.id!,
            name: name,
            createdAt: now,
          ),
      ],
      transaction: transaction,
      ignoreConflicts: true,
    );
    final rows = await Payee.db.find(
      session,
      where: (t) => t.entityId.equals(entity.id) & t.name.inSet(names),
      transaction: transaction,
    );
    return {for (final payee in rows) payee.name: payee};
  }

  static ImportResult _importResult({
    required int rowCount,
    required int insertedCount,
    required Map<int, String> errors,
  }) {
    final indexes = errors.keys.toList()..sort();
    return ImportResult(
      insertedCount: insertedCount,
      // Everything neither inserted nor rejected is a duplicate, including a
      // row a concurrent import won at the unique index.
      skippedDuplicateCount: rowCount - insertedCount - errors.length,
      errors: [for (final index in indexes) '$index: ${errors[index]}'],
    );
  }

  /// Rejects a zero amount, and a value outside the safe minor range.
  static void _requireNonZeroSafeMinor(int amount) {
    if (amount == 0) {
      throw ValidationException(message: 'amountMinor must not be zero');
    }
    _requireSafeMinor(amount, 'amountMinor');
  }

  static String _civilDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
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

final class _PendingImportRow {
  const _PendingImportRow({
    required this.index,
    required this.row,
    required this.externalId,
  });

  final int index;
  final ImportRow row;
  final String externalId;
}

final class _ImportCandidate {
  const _ImportCandidate({
    required this.externalId,
    required this.date,
    required this.amountMinor,
    required this.description,
    required this.memo,
    required this.payee,
    required this.payeeName,
    required this.rate,
    required this.lines,
  });

  final String externalId;
  final DateTime date;
  final int amountMinor;
  final String description;
  final String? memo;
  final Payee? payee;
  final String? payeeName;
  final _ResolvedRate rate;
  final List<_BuiltLine> lines;
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
