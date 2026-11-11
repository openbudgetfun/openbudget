import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/ledger/ledger_account_linker.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for an entity's double-entry books.
///
/// Every method crosses [EntityAccess], so a journal, ledger account or lock
/// is visible only to the owner of its entity. The arithmetic and posting
/// invariants live in `openbudget_core`; this service owns entity
/// serialization, immutability of posted journals, the period lock and the
/// audit trail.
///
/// Manual journals deliberately do not move [Account.balanceMinor] and do not
/// write [Transaction] rows. The ledger is authoritative once
/// `JournalPoster` exists; until then the bank cache and single-entry
/// projection stay a separate unit.
abstract final class LedgerService {
  static final _log = ObLogger('LedgerService');

  /// Structural accounts a manual journal may not code to.
  ///
  /// The ledger skill requires a party and a document reference for these
  /// controls. The reset model has neither yet (documents arrive in a later
  /// unit), so every manual line to one is rejected rather than silently
  /// bypassing the control invariant.
  static const _controlRoles = <LedgerSystemRole>{
    LedgerSystemRole.accountsReceivable,
    LedgerSystemRole.accountsPayable,
    LedgerSystemRole.vatControl,
    LedgerSystemRole.payrollLiabilities,
  };

  /// Sources a caller may choose. System-owned sources are created only by
  /// the service that owns them.
  static const _callerSources = <JournalSource>{
    JournalSource.manual,
    JournalSource.opening,
    JournalSource.imported,
  };

  static const _maxPageLimit = 200;
  static const _defaultPageLimit = 100;
  static const _cursorPattern = r'^[A-Za-z0-9_-]+$';
  static const _cursorDatePattern = r'^\d{4}-\d{2}-\d{2}$';

  /// Turns the ledger on for a sole-trader or company entity.
  ///
  /// Seeds the chart from the country and entity-kind template in
  /// `openbudget_core`, creates one mirror account per transactions-sourced
  /// money account, links both sides through `account.ledgerAccountId`, and
  /// switches `accountingMode` to ledger. The whole change is atomic and
  /// idempotent: a retry or a concurrent second call returns the already
  /// enabled entity without seeding a second chart.
  static Future<Entity> enableLedger(
    Session session,
    UuidValue entityId,
  ) async {
    final actorId = EntityAccess.userId(session);
    final result = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      if (entity.accountingMode == AccountingMode.ledger) {
        return (entity: entity, changed: false);
      }
      if (entity.kind == EntityKind.individual) {
        throw ValidationException(
          message: 'Only sole-trader and company entities can use the ledger.',
        );
      }
      final jurisdiction = TaxJurisdiction.fromCountryCode(entity.countryCode);
      final template = jurisdiction == null
          ? null
          : LedgerChartTemplate.forBooks(
              jurisdiction: jurisdiction,
              entityKind: entity.kind,
            );
      if (template == null) {
        throw ValidationException(
          message:
              'No chart of accounts template exists for '
              '${entity.countryCode} ${entity.kind.name} books.',
        );
      }

      final seeded = <LedgerAccount>[];
      for (final account in template.accounts) {
        seeded.add(
          await LedgerAccount.db.insertRow(
            session,
            LedgerAccount(
              entityId: entity.id!,
              code: account.code,
              name: account.name,
              type: account.type,
              systemRole: account.systemRole,
            ),
            transaction: transaction,
          ),
        );
      }

      // Lock the money accounts in UUID order, as every multi-account writer
      // does, then assign codes in display order.
      final lockedAccounts = await Account.db.find(
        session,
        where: (t) =>
            t.entityId.equals(entity.id) &
            t.balanceSource.equals(AccountBalanceSource.transactions),
        orderByList: (t) => [t.id],
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final orderedAccounts = [...lockedAccounts]
        ..sort((a, b) {
          final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
          if (bySortOrder != 0) return bySortOrder;
          return a.id.toString().compareTo(b.id.toString());
        });

      var linked = 0;
      for (final account in orderedAccounts) {
        if (account.ledgerAccountId != null) continue;
        await LedgerAccountLinker.attachMoneyAccount(
          session,
          transaction,
          entity: entity,
          account: account,
          actorId: actorId,
        );
        linked++;
      }

      final now = DateTime.now().toUtc();
      final updated = await Entity.db.updateRow(
        session,
        entity.copyWith(accountingMode: AccountingMode.ledger, updatedAt: now),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.ledgerEnabled,
        subjectType: AuditSubject.entity,
        subjectId: entity.id,
        payload: {
          'before': {
            'accountingMode': entity.accountingMode.name,
            'kind': entity.kind.name,
            'countryCode': entity.countryCode,
            'baseCurrencyCode': entity.baseCurrencyCode,
          },
          'after': {
            'accountingMode': AccountingMode.ledger.name,
            'seededAccountCount': seeded.length,
            'linkedMoneyAccountCount': linked,
          },
        },
      );
      _log.info(
        'Ledger enabled entity=${entity.id} '
        'accounts=${seeded.length} linked=$linked',
      );
      return (entity: updated, changed: true);
    });

    if (result.changed) {
      await EntityRealtimeNotifier.notify(
        session,
        entityId,
        ChangeScope.entity,
      );
    }
    return result.entity;
  }

  /// Lists the entity's ledger accounts.
  ///
  /// Archived accounts are hidden unless [includeArchived] is set.
  static Future<List<LedgerAccount>> listAccounts(
    Session session,
    UuidValue entityId, {
    bool includeArchived = false,
  }) async {
    await _requireLedgerEntity(session, entityId);
    return LedgerAccount.db.find(
      session,
      where: (a) => includeArchived
          ? a.entityId.equals(entityId)
          : a.entityId.equals(entityId) & a.archivedAt.equals(null),
      orderByList: (a) => [a.code, a.id],
    );
  }

  /// Adds an account to the entity's chart.
  ///
  /// Codes and structural roles are unique per entity. A [systemRole] makes
  /// the account structural: it cannot be archived, and only one active
  /// account may hold it.
  static Future<LedgerAccount> createAccount(
    Session session,
    UuidValue entityId,
    String code,
    String name,
    LedgerAccountType type, {
    LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) async {
    final actorId = EntityAccess.userId(session);
    final result = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);

      final trimmedCode = _requireText(code, 'Account code');
      final trimmedName = _requireText(name, 'Account name');
      final currency = currencyCode == null
          ? null
          : requireSupportedCurrency(currencyCode);

      final duplicateCode = await LedgerAccount.db.findFirstRow(
        session,
        where: (a) => a.entityId.equals(entityId) & a.code.equals(trimmedCode),
        transaction: transaction,
      );
      if (duplicateCode != null) {
        throw ValidationException(
          message: 'Account code $trimmedCode is already in use.',
        );
      }
      if (systemRole != null) {
        final duplicateRole = await LedgerAccount.db.findFirstRow(
          session,
          where: (a) =>
              a.entityId.equals(entityId) & a.systemRole.equals(systemRole),
          transaction: transaction,
        );
        if (duplicateRole != null) {
          throw ValidationException(
            message:
                '${systemRole.name} is already assigned to account '
                '${duplicateRole.code}.',
          );
        }
      }

      final account = await LedgerAccount.db.insertRow(
        session,
        LedgerAccount(
          entityId: entityId,
          code: trimmedCode,
          name: trimmedName,
          type: type,
          systemRole: systemRole,
          currencyCode: currency,
          taxCategoryCode: taxCategoryCode,
        ),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.ledgerAccountCreated,
        subjectType: AuditSubject.ledgerAccount,
        subjectId: account.id,
        payload: {
          'before': null,
          'after': {
            'code': account.code,
            'name': account.name,
            'type': account.type.name,
            'systemRole': account.systemRole?.name,
            'currencyCode': account.currencyCode,
            'taxCategoryCode': account.taxCategoryCode,
          },
        },
      );
      return account;
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
    return result;
  }

  /// Archives a non-structural account so it stops accepting postings.
  ///
  /// Its lines and balances stay in the books. Structural accounts carry a
  /// system role and are never archived.
  static Future<LedgerAccount> archiveAccount(
    Session session,
    UuidValue accountId,
  ) async {
    final actorId = EntityAccess.userId(session);
    final initial = await LedgerAccount.db.findById(session, accountId);
    if (initial == null) {
      throw NotFoundException(message: 'Ledger account not found');
    }

    final result = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        initial.entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);

      final account = await LedgerAccount.db.findById(
        session,
        accountId,
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      if (account == null || account.entityId != entity.id) {
        throw NotFoundException(message: 'Ledger account not found');
      }
      if (account.systemRole != null) {
        throw ValidationException(
          message:
              'Structural account ${account.code} cannot be archived or '
              'deleted.',
        );
      }
      if (account.archivedAt != null) {
        return (account: account, changed: false);
      }

      final now = DateTime.now().toUtc();
      final archived = await LedgerAccount.db.updateRow(
        session,
        account.copyWith(archivedAt: now),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.ledgerAccountArchived,
        subjectType: AuditSubject.ledgerAccount,
        subjectId: accountId,
        payload: {
          'before': {
            'code': account.code,
            'name': account.name,
            'type': account.type.name,
            'systemRole': account.systemRole?.name,
            'currencyCode': account.currencyCode,
            'archivedAt': null,
          },
          'after': {
            'code': archived.code,
            'archivedAt': now.toIso8601String(),
          },
        },
      );
      return (account: archived, changed: true);
    });

    if (result.changed) {
      await EntityRealtimeNotifier.notify(
        session,
        initial.entityId,
        ChangeScope.ledger,
      );
    }
    return result.account;
  }

  /// Saves a draft journal: creates one, or replaces the lines of an existing
  /// draft when [journalId] is given.
  ///
  /// The draft is validated with the core posting invariants before anything
  /// is written. Posted journals are never touched by this path. A draft in
  /// a period on or before the lock date cannot be created, edited or
  /// deleted.
  static Future<Journal> saveDraftJournal(
    Session session,
    UuidValue entityId,
    DateTime date,
    List<JournalLineInput> lines, {
    UuidValue? journalId,
    String reference = '',
    String? narration,
    JournalSource source = JournalSource.manual,
  }) async {
    _requireCivilDate(date, 'date');
    EntityAccess.userId(session);
    _requireCallerSource(source);
    final trimmedReference = reference.trim();
    final trimmedNarration = _normaliseOptional(narration);

    final result = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);
      final lock = await _readLock(session, entity, transaction);
      _rejectLockedDate(date, lock);

      Journal? existing;
      if (journalId != null) {
        existing = await Journal.db.findById(
          session,
          journalId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (existing == null || existing.entityId != entityId) {
          throw NotFoundException(message: 'Journal not found');
        }
        if (existing.status != JournalStatus.draft) {
          throw ValidationException(
            message:
                'Journal ${existing.reference} is ${existing.status.name} '
                'and immutable; post a reversal instead.',
          );
        }
        _rejectLockedDate(existing.date, lock);
      }

      final drafts = await _buildDrafts(
        session,
        transaction,
        entity: entity,
        journalDate: date,
        lines: lines,
      );

      final now = DateTime.now().toUtc();
      final Journal journal;
      if (existing == null) {
        journal = await Journal.db.insertRow(
          session,
          Journal(
            entityId: entityId,
            date: date,
            reference: trimmedReference,
            narration: trimmedNarration,
            status: JournalStatus.draft,
            source: source,
            createdAt: now,
          ),
          transaction: transaction,
        );
      } else {
        await JournalLine.db.deleteWhere(
          session,
          where: (l) => l.journalId.equals(existing!.id),
          transaction: transaction,
        );
        journal = await Journal.db.updateRow(
          session,
          existing.copyWith(
            date: date,
            reference: trimmedReference,
            narration: trimmedNarration,
            source: source,
          ),
          transaction: transaction,
        );
      }

      for (final line in drafts) {
        await JournalLine.db.insertRow(
          session,
          JournalLine(
            journalId: journal.id!,
            ledgerAccountId: line.account.id!,
            description: line.description,
            debitMinor: line.debitMinor,
            creditMinor: line.creditMinor,
            currencyCode: line.currencyCode,
            baseDebitMinor: line.baseDebitMinor,
            baseCreditMinor: line.baseCreditMinor,
            fxRate: line.fxRate,
            fxRateDate: line.fxRateDate,
            fxRateSource: line.fxRateSource,
            taxCode: line.taxCode,
          ),
          transaction: transaction,
        );
      }
      return journal;
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
    return result;
  }

  /// Deletes a draft journal and its lines.
  ///
  /// Posted and reversed journals are immutable; deleting one throws.
  static Future<void> deleteDraftJournal(
    Session session,
    UuidValue journalId,
  ) async {
    EntityAccess.userId(session);
    final initial = await _loadJournal(session, journalId);
    final entityId = initial.entityId;

    await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);
      final journal = await _lockJournal(
        session,
        transaction,
        entityId: entityId,
        journalId: journalId,
      );
      if (journal.status != JournalStatus.draft) {
        throw ValidationException(
          message:
              'Journal ${journal.reference} is ${journal.status.name} and '
              'cannot be deleted; post a reversal instead.',
        );
      }
      _rejectLockedDate(
        journal.date,
        await _readLock(session, entity, transaction),
      );
      await JournalLine.db.deleteWhere(
        session,
        where: (l) => l.journalId.equals(journalId),
        transaction: transaction,
      );
      await Journal.db.deleteRow(session, journal, transaction: transaction);
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
  }

  /// Posts a draft journal.
  ///
  /// Re-validates the stored lines with the core invariants inside the posting
  /// transaction, refuses dates on or before the period lock, and stamps
  /// `postedAt` and `postedBy` with server facts. Posting is the only
  /// transition out of `draft`; a posted journal is immutable afterwards.
  static Future<Journal> postJournal(
    Session session,
    UuidValue journalId,
  ) async {
    final actorId = EntityAccess.userId(session);
    final initial = await _loadJournal(session, journalId);
    final entityId = initial.entityId;

    final posted = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);
      final journal = await _lockJournal(
        session,
        transaction,
        entityId: entityId,
        journalId: journalId,
      );
      if (journal.status != JournalStatus.draft) {
        throw ValidationException(
          message:
              'Only draft journals can be posted; journal '
              '${journal.reference} is ${journal.status.name}.',
        );
      }
      _rejectLockedDate(
        journal.date,
        await _readLock(session, entity, transaction),
      );

      final storedLines = await JournalLine.db.find(
        session,
        where: (l) => l.journalId.equals(journalId),
        orderBy: (l) => l.id,
        transaction: transaction,
      );
      final drafts = await _draftsFromStored(
        session,
        transaction,
        entity: entity,
        journalDate: journal.date,
        lines: storedLines,
      );

      final now = DateTime.now().toUtc();
      final updated = await Journal.db.updateRow(
        session,
        journal.copyWith(
          status: JournalStatus.posted,
          postedAt: now,
          postedBy: actorId,
        ),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.journalPosted,
        subjectType: AuditSubject.journal,
        subjectId: journalId,
        payload: {
          'before': {
            'status': journal.status.name,
            'postedAt': null,
            'postedBy': null,
            'reference': journal.reference,
            'date': journal.date.toIso8601String(),
            'lineCount': storedLines.length,
          },
          'after': {
            'status': updated.status.name,
            'postedAt': now.toIso8601String(),
            'postedBy': actorId.toString(),
            'totalBaseDebitMinor': drafts.fold<int>(
              0,
              (sum, line) => sum + line.baseDebitMinor,
            ),
          },
        },
      );
      return updated;
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
    _log.info('Journal posted journal=$journalId');
    return posted;
  }

  /// Reverses a posted journal on [date] by posting a mirror journal.
  ///
  /// Every line swaps debit and credit, including the base pair, while
  /// keeping the original stored rate, rate date and rate source. The
  /// original journal flips to `reversed` and stays immutable: its dates,
  /// amounts and lines never change. The reversal date must be after the
  /// period lock.
  static Future<Journal> reverseJournal(
    Session session,
    UuidValue journalId,
    DateTime date,
  ) async {
    _requireCivilDate(date, 'date');
    final actorId = EntityAccess.userId(session);
    final initial = await _loadJournal(session, journalId);
    final entityId = initial.entityId;

    final reversal = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);
      final journal = await _lockJournal(
        session,
        transaction,
        entityId: entityId,
        journalId: journalId,
      );
      if (journal.status != JournalStatus.posted) {
        throw ValidationException(
          message:
              'Only posted journals can be reversed; journal '
              '${journal.reference} is ${journal.status.name}.',
        );
      }
      final existingReversal = await Journal.db.findFirstRow(
        session,
        where: (j) => j.reversalOfJournalId.equals(journalId),
        transaction: transaction,
      );
      if (existingReversal != null) {
        throw ValidationException(
          message:
              'Journal ${journal.reference} is already reversed by '
              '${existingReversal.reference}.',
        );
      }
      _rejectLockedDate(
        date,
        await _readLock(session, entity, transaction),
      );

      final storedLines = await JournalLine.db.find(
        session,
        where: (l) => l.journalId.equals(journalId),
        orderBy: (l) => l.id,
        transaction: transaction,
      );
      final accounts = await LedgerAccount.db.find(
        session,
        where: (a) => a.entityId.equals(entityId),
        transaction: transaction,
      );
      final codeById = {
        for (final account in accounts) account.id: account.code,
      };
      final reversalLines = [
        for (final line in storedLines)
          (
            source: line,
            draft: JournalLineDraft(
              accountCode: codeById[line.ledgerAccountId] ?? '',
              description: line.description,
              debitMinor: line.creditMinor,
              creditMinor: line.debitMinor,
              currencyCode: line.currencyCode,
              functionalDebitMinor: line.baseCreditMinor,
              functionalCreditMinor: line.baseDebitMinor,
              exchangeRate: line.fxRate,
              rateDate: line.fxRateDate,
              rateSource: line.fxRateSource.name,
              taxCode: line.taxCode,
            ),
          ),
      ];
      _throwIfInvalid(
        JournalDraft(
          functionalCurrency: entity.baseCurrencyCode,
          lines: [for (final line in reversalLines) line.draft],
          source: JournalSource.reversal,
        ),
      );

      final now = DateTime.now().toUtc();
      final reference = journal.reference.isEmpty
          ? 'REV-${journal.id}'
          : '${journal.reference}-REV';
      final created = await Journal.db.insertRow(
        session,
        Journal(
          entityId: entityId,
          date: date,
          reference: reference,
          narration:
              'Reversal of '
              '${journal.reference.isEmpty ? journal.id : journal.reference}',
          status: JournalStatus.posted,
          source: JournalSource.reversal,
          postedAt: now,
          postedBy: actorId,
          reversalOfJournalId: journal.id,
          createdAt: now,
        ),
        transaction: transaction,
      );
      for (final entry in reversalLines) {
        final line = entry.draft;
        await JournalLine.db.insertRow(
          session,
          JournalLine(
            journalId: created.id!,
            ledgerAccountId: entry.source.ledgerAccountId,
            description: line.description,
            debitMinor: line.debitMinor,
            creditMinor: line.creditMinor,
            currencyCode: line.currencyCode,
            baseDebitMinor: line.functionalDebitMinor,
            baseCreditMinor: line.functionalCreditMinor,
            fxRate: line.exchangeRate,
            fxRateDate: line.rateDate,
            fxRateSource: entry.source.fxRateSource,
            taxCode: line.taxCode,
          ),
          transaction: transaction,
        );
      }
      await Journal.db.updateRow(
        session,
        journal.copyWith(status: JournalStatus.reversed),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.journalReversed,
        subjectType: AuditSubject.journal,
        subjectId: created.id,
        payload: {
          'before': {
            'originalJournalId': journal.id?.toString(),
            'originalStatus': journal.status.name,
            'originalReference': journal.reference,
            'originalDate': journal.date.toIso8601String(),
            'originalPostedAt': journal.postedAt?.toIso8601String(),
            'originalPostedBy': journal.postedBy?.toString(),
            'lineCount': storedLines.length,
          },
          'after': {
            'reversalJournalId': created.id?.toString(),
            'reversalDate': date.toIso8601String(),
            'originalStatus': JournalStatus.reversed.name,
          },
        },
      );
      _log.info(
        'Journal reversed journal=$journalId reversal=${created.id}',
      );
      return created;
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
    return reversal;
  }

  /// Lists one bounded page of the entity's journals.
  ///
  /// Rows come newest first by `(date desc, id desc)`. Both date bounds are
  /// inclusive. [limit] is capped at 200. The opaque [cursor] is base64url of
  /// `yyyy-mm-dd|uuid`, matching the transaction list contract, and continues
  /// after that row.
  static Future<List<Journal>> listJournals(
    Session session,
    UuidValue entityId, {
    DateTime? fromDate,
    DateTime? toDate,
    int limit = _defaultPageLimit,
    String? cursor,
  }) async {
    _requirePageLimit(limit);
    _requireOptionalCivilDate(fromDate, 'fromDate');
    _requireOptionalCivilDate(toDate, 'toDate');
    if (fromDate != null && toDate != null && fromDate.isAfter(toDate)) {
      throw ValidationException(
        message: 'fromDate must not be after toDate',
      );
    }
    final decoded = _decodeCursor(cursor);
    await _requireLedgerEntity(session, entityId);

    return Journal.db.find(
      session,
      where: (j) {
        var filter = j.entityId.equals(entityId);
        if (fromDate != null) filter = filter & (j.date >= fromDate);
        if (toDate != null) filter = filter & (j.date <= toDate);
        if (decoded != null) {
          filter =
              filter &
              ((j.date < decoded.date) |
                  (j.date.equals(decoded.date) & (j.id < decoded.id)));
        }
        return filter;
      },
      orderByList: (j) => [j.date.desc(), j.id.desc()],
      limit: limit,
    );
  }

  /// Lists one journal's lines in insertion order.
  static Future<List<JournalLine>> listJournalLines(
    Session session,
    UuidValue journalId,
  ) async {
    final journal = await _loadJournal(session, journalId);
    await _requireLedgerEntity(session, journal.entityId);
    return JournalLine.db.find(
      session,
      where: (l) => l.journalId.equals(journalId),
      orderBy: (l) => l.id,
    );
  }

  /// The entity's period lock, or null when no lock date has been set.
  static Future<LedgerPeriodLock?> getLockDate(
    Session session,
    UuidValue entityId,
  ) async {
    await _requireLedgerEntity(session, entityId);
    return LedgerPeriodLock.db.findFirstRow(
      session,
      where: (l) => l.entityId.equals(entityId),
    );
  }

  /// Sets or moves the entity's period lock.
  ///
  /// Posting, reversing, or creating, editing or deleting a draft dated on or
  /// before the lock date is rejected. Moving the lock is owner-controlled
  /// and audited with the previous date.
  static Future<LedgerPeriodLock> setLockDate(
    Session session,
    UuidValue entityId,
    DateTime lockDate,
  ) async {
    _requireCivilDate(lockDate, 'lockDate');
    final actorId = EntityAccess.userId(session);

    final lock = await session.db.transaction((transaction) async {
      final entity = await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: transaction,
        lock: true,
      );
      _requireWritable(entity);
      _requireLedger(entity);
      final existing = await LedgerPeriodLock.db.findFirstRow(
        session,
        where: (l) => l.entityId.equals(entityId),
        transaction: transaction,
        lockMode: LockMode.forUpdate,
      );
      final now = DateTime.now().toUtc();
      final saved = existing == null
          ? await LedgerPeriodLock.db.insertRow(
              session,
              LedgerPeriodLock(
                entityId: entityId,
                lockDate: lockDate,
                setBy: actorId,
                setAt: now,
              ),
              transaction: transaction,
            )
          : await LedgerPeriodLock.db.updateRow(
              session,
              existing.copyWith(
                lockDate: lockDate,
                setBy: actorId,
                setAt: now,
              ),
              transaction: transaction,
            );
      await _writeAudit(
        session,
        transaction: transaction,
        entity: entity,
        actorId: actorId,
        action: AuditAction.lockSet,
        subjectType: AuditSubject.periodLock,
        subjectId: saved.id,
        payload: {
          'before': {'lockDate': existing?.lockDate.toIso8601String()},
          'after': {'lockDate': lockDate.toIso8601String()},
          'setBy': actorId.toString(),
          'setAt': now.toIso8601String(),
        },
      );
      return saved;
    });

    await EntityRealtimeNotifier.notify(
      session,
      entityId,
      ChangeScope.ledger,
    );
    return lock;
  }

  /// Computes the trial balance through [asOf] over posted journals.
  ///
  /// One indexed aggregate groups base debits and credits per account; no
  /// financial history is loaded into Dart. A result whose debits differ from
  /// its credits is a hard error and throws instead of returning a report
  /// labelled "difference". The entity and aggregate run under one
  /// repeatable-read snapshot so the currency and figures agree.
  static Future<TrialBalanceView> trialBalance(
    Session session,
    UuidValue entityId,
    DateTime asOf,
  ) async {
    _requireCivilDate(asOf, 'asOf');
    return session.db.transaction(
      (transaction) async {
        final entity = await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: transaction,
        );
        _requireLedger(entity);
        final rows = await session.db.unsafeQuery(
          _trialBalanceSql,
          parameters: QueryParameters.named({
            'entityId': entityId.toString(),
            'asOf': asOf,
          }),
          transaction: transaction,
        );

        var totalDebit = 0;
        var totalCredit = 0;
        final views = <TrialBalanceRowView>[];
        for (final row in rows) {
          final debit = row[5] as int;
          final credit = row[6] as int;
          totalDebit += debit;
          totalCredit += credit;
          final typeName = row[3] as String;
          final type = LedgerAccountType.values.asNameMap()[typeName];
          if (type == null) {
            throw StateError(
              'Persisted ledger account type "$typeName" is not valid.',
            );
          }
          final roleName = row[4] as String?;
          final role = roleName == null
              ? null
              : LedgerSystemRole.values.asNameMap()[roleName];
          if (roleName != null && role == null) {
            throw StateError(
              'Persisted ledger system role "$roleName" is not valid.',
            );
          }
          views.add(
            TrialBalanceRowView(
              ledgerAccountId: UuidValue.fromString(row[0] as String),
              accountCode: row[1] as String,
              accountName: row[2] as String,
              accountType: type,
              systemRole: role,
              debitMinor: debit,
              creditMinor: credit,
              netMinor: debit - credit,
            ),
          );
        }
        if (totalDebit != totalCredit) {
          throw ValidationException(
            message:
                'Trial balance is out by ${totalDebit - totalCredit} minor; '
                'the books do not balance.',
          );
        }
        final net = views.fold<int>(0, (sum, row) => sum + row.netMinor);
        if (net != 0) {
          throw ValidationException(
            message: 'Trial balance nets to $net minor, not zero.',
          );
        }

        return TrialBalanceView(
          entityId: entityId,
          currencyCode: entity.baseCurrencyCode,
          asOf: asOf,
          rows: views,
          totalDebitMinor: totalDebit,
          totalCreditMinor: totalCredit,
        );
      },
      settings: const TransactionSettings(
        isolationLevel: IsolationLevel.repeatableRead,
      ),
    );
  }

  /// Lists one bounded page of the entity's audit trail, newest first.
  ///
  /// Rows order by `(createdAt desc, id desc)` so equal server timestamps
  /// still have one stable order. [before] is exclusive, and [limit] is
  /// capped at 200.
  static Future<List<AuditEvent>> listAuditEvents(
    Session session,
    UuidValue entityId, {
    DateTime? before,
    int? limit,
  }) async {
    final pageSize = limit ?? _defaultPageLimit;
    _requirePageLimit(pageSize);
    await _requireLedgerEntity(session, entityId);
    final cutoff = before?.toUtc();
    return AuditEvent.db.find(
      session,
      where: (e) => cutoff == null
          ? e.entityId.equals(entityId)
          : e.entityId.equals(entityId) & (e.createdAt < cutoff),
      orderByList: (e) => [e.createdAt.desc(), e.id.desc()],
      limit: pageSize,
    );
  }

  // -- Helpers ---------------------------------------------------------------

  static Future<Entity> _requireLedgerEntity(
    Session session,
    UuidValue entityId,
  ) async {
    final entity = await EntityAccess.requireOwned(session, entityId);
    _requireLedger(entity);
    return entity;
  }

  static void _requireLedger(Entity entity) {
    if (entity.accountingMode != AccountingMode.ledger) {
      throw ValidationException(
        message:
            'This entity is in envelope mode; enable the ledger on it '
            'first.',
      );
    }
  }

  static void _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects new ledger writes.',
      );
    }
  }

  static void _requireCallerSource(JournalSource source) {
    if (!_callerSources.contains(source)) {
      throw ValidationException(
        message:
            'Journal source ${source.name} is posted by its owning service, '
            'not by a caller.',
      );
    }
  }

  static String _requireText(String raw, String field) {
    final text = raw.trim();
    if (text.isEmpty) {
      throw ValidationException(message: '$field must not be empty.');
    }
    return text;
  }

  static String? _normaliseOptional(String? raw) {
    final text = raw?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  static void _requireCivilDate(DateTime date, String field) {
    if (!isCivilDate(date)) {
      throw ValidationException(
        message: '$field must be a UTC calendar date.',
      );
    }
    if (date.year < 1900) {
      throw ValidationException(
        message: '$field is before the supported calendar range.',
      );
    }
  }

  static void _requireOptionalCivilDate(DateTime? date, String field) {
    if (date != null) _requireCivilDate(date, field);
  }

  static void _requirePageLimit(int limit) {
    if (limit < 1 || limit > _maxPageLimit) {
      throw ValidationException(
        message: 'limit must be between 1 and $_maxPageLimit',
      );
    }
  }

  static void _requireSafeAmount(int amount, String field) {
    if (amount < 0) {
      throw ValidationException(message: '$field must not be negative.');
    }
    if (amount > maxSafeMinor) {
      throw ValidationException(
        message: '$field exceeds the safe minor-unit range.',
      );
    }
  }

  static Future<LedgerPeriodLock?> _readLock(
    Session session,
    Entity entity,
    Transaction transaction,
  ) => LedgerPeriodLock.db.findFirstRow(
    session,
    where: (l) => l.entityId.equals(entity.id),
    transaction: transaction,
  );

  static void _rejectLockedDate(DateTime date, LedgerPeriodLock? lock) {
    if (lock == null) return;
    if (!date.isAfter(lock.lockDate)) {
      throw ValidationException(
        message:
            'The period on or before '
            '${_civilText(lock.lockDate)} is locked; use an open date.',
      );
    }
  }

  static String _civilText(DateTime date) =>
      date.toIso8601String().substring(0, 10);

  /// Loads a journal for its entity id after authenticating and checking
  /// ownership. The later write transaction re-reads it under a lock.
  static Future<Journal> _loadJournal(
    Session session,
    UuidValue journalId,
  ) async {
    EntityAccess.userId(session);
    final journal = await Journal.db.findById(session, journalId);
    if (journal == null) {
      throw NotFoundException(message: 'Journal not found');
    }
    await EntityAccess.requireOwned(session, journal.entityId);
    return journal;
  }

  static Future<Journal> _lockJournal(
    Session session,
    Transaction transaction, {
    required UuidValue entityId,
    required UuidValue journalId,
  }) async {
    final journal = await Journal.db.findById(
      session,
      journalId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (journal == null || journal.entityId != entityId) {
      throw NotFoundException(message: 'Journal not found');
    }
    return journal;
  }

  /// Validates caller lines against the entity's chart and base currency.
  static Future<List<_ValidatedLine>> _buildDrafts(
    Session session,
    Transaction transaction, {
    required Entity entity,
    required DateTime journalDate,
    required List<JournalLineInput> lines,
  }) async {
    final chart = await LedgerAccount.db.find(
      session,
      where: (a) => a.entityId.equals(entity.id),
      transaction: transaction,
    );
    final accountById = {for (final account in chart) account.id: account};

    final stored = <_StoredLine>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final account = accountById[line.ledgerAccountId];
      if (account == null) {
        throw ValidationException(
          message:
              'Line ${index + 1} references an account outside this entity.',
        );
      }
      stored.add(
        _StoredLine(
          lineIndex: index,
          account: account,
          description: _normaliseOptional(line.description),
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: line.currencyCode,
          baseDebitMinor: line.baseDebitMinor,
          baseCreditMinor: line.baseCreditMinor,
          fxRate: line.fxRate,
          fxRateDate: line.fxRateDate,
          fxRateSource: line.fxRateSource,
          taxCode: _normaliseOptional(line.taxCode),
        ),
      );
    }
    return _validatedLines(
      entity: entity,
      journalDate: journalDate,
      lines: stored,
    );
  }

  /// Re-validates the stored lines at posting, including the archived and
  /// control-account guards that may have changed since the draft was saved.
  static Future<List<_ValidatedLine>> _draftsFromStored(
    Session session,
    Transaction transaction, {
    required Entity entity,
    required DateTime journalDate,
    required List<JournalLine> lines,
  }) async {
    final chart = await LedgerAccount.db.find(
      session,
      where: (a) => a.entityId.equals(entity.id),
      transaction: transaction,
    );
    final accountById = {for (final account in chart) account.id: account};

    final stored = <_StoredLine>[];
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final account = accountById[line.ledgerAccountId];
      if (account == null) {
        throw ValidationException(
          message:
              'Line ${index + 1} references an account outside this entity.',
        );
      }
      stored.add(
        _StoredLine(
          lineIndex: index,
          account: account,
          description: line.description,
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: line.currencyCode,
          baseDebitMinor: line.baseDebitMinor,
          baseCreditMinor: line.baseCreditMinor,
          fxRate: line.fxRate,
          fxRateDate: line.fxRateDate,
          fxRateSource: line.fxRateSource,
          taxCode: line.taxCode,
        ),
      );
    }
    return _validatedLines(
      entity: entity,
      journalDate: journalDate,
      lines: stored,
    );
  }

  /// Runs the full per-line validation and the core journal invariants.
  ///
  /// Returns rows whose currency, rate and rate date are normalized for
  /// persistence, so the stored line reproduces exactly what was validated.
  static List<_ValidatedLine> _validatedLines({
    required Entity entity,
    required DateTime journalDate,
    required List<_StoredLine> lines,
  }) {
    final drafts = <JournalLineDraft>[];
    final validated = <_ValidatedLine>[];
    for (final line in lines) {
      final label = 'Line ${line.lineIndex + 1} (${line.account.code})';
      _requireSafeAmount(line.debitMinor, '$label debitMinor');
      _requireSafeAmount(line.creditMinor, '$label creditMinor');
      _requireSafeAmount(line.baseDebitMinor, '$label baseDebitMinor');
      _requireSafeAmount(line.baseCreditMinor, '$label baseCreditMinor');

      if (line.account.archivedAt != null) {
        throw ValidationException(
          message:
              'Account ${line.account.code} is archived and takes no '
              'new lines.',
        );
      }
      final role = line.account.systemRole;
      if (role != null && _controlRoles.contains(role)) {
        throw ValidationException(
          message:
              'Manual journals cannot post to control account '
              '${line.account.code} (${role.name}). Post through an invoice '
              'or bill once documents exist.',
        );
      }

      final currency = requireSupportedCurrency(line.currencyCode);
      final rate = ExactDecimal.tryParse(line.fxRate);
      if (rate == null) {
        throw ValidationException(
          message:
              '$label has exchange rate "${line.fxRate}", which is not a '
              'positive decimal string.',
        );
      }
      final fxRateDate = line.fxRateDate ?? journalDate;
      _requireCivilDate(fxRateDate, '$label fxRateDate');
      if (fxRateDate.isAfter(journalDate)) {
        throw ValidationException(
          message: '$label has a rate date after the journal date.',
        );
      }
      if (line.fxRateSource == FxRateSource.identity) {
        if (currency != entity.baseCurrencyCode || !rate.isOne) {
          throw ValidationException(
            message:
                '$label uses the identity rate for $currency; identity is '
                'only valid for ${entity.baseCurrencyCode} at rate 1.',
          );
        }
      } else if (currency == entity.baseCurrencyCode) {
        throw ValidationException(
          message:
              '$label is in the base currency and must use the identity '
              'rate.',
        );
      }

      final storedRate = rate.isOne ? '1' : line.fxRate.trim();
      drafts.add(
        JournalLineDraft(
          accountCode: line.account.code,
          description: line.description,
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: currency,
          functionalDebitMinor: line.baseDebitMinor,
          functionalCreditMinor: line.baseCreditMinor,
          exchangeRate: storedRate,
          rateDate: fxRateDate,
          rateSource: line.fxRateSource.name,
          taxCode: line.taxCode,
        ),
      );
      validated.add(
        _ValidatedLine(
          account: line.account,
          description: line.description,
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: currency,
          baseDebitMinor: line.baseDebitMinor,
          baseCreditMinor: line.baseCreditMinor,
          fxRate: storedRate,
          fxRateDate: fxRateDate,
          fxRateSource: line.fxRateSource,
          taxCode: line.taxCode,
        ),
      );
    }

    final draft = JournalDraft(
      functionalCurrency: entity.baseCurrencyCode,
      lines: drafts,
    );
    _throwIfInvalid(draft);
    return validated;
  }

  /// Runs core validation plus the per-currency check for mixed journals.
  ///
  /// The core rule balances a single transaction currency natively. A manual
  /// journal that uses one currency on both sides must balance that currency
  /// too, even when other currencies make up the base total.
  static void _throwIfInvalid(JournalDraft draft) {
    final issues = [...draft.validate()];
    final debitByCurrency = <String, int>{};
    final creditByCurrency = <String, int>{};
    for (final line in draft.lines) {
      debitByCurrency.update(
        line.currencyCode,
        (value) => value + line.debitMinor,
        ifAbsent: () => line.debitMinor,
      );
      creditByCurrency.update(
        line.currencyCode,
        (value) => value + line.creditMinor,
        ifAbsent: () => line.creditMinor,
      );
    }
    final alreadyFlagged = issues.any(
      (issue) => issue.code == 'unbalancedTransactionCurrency',
    );
    if (!alreadyFlagged) {
      for (final currency in debitByCurrency.keys) {
        final debit = debitByCurrency[currency]!;
        final credit = creditByCurrency[currency] ?? 0;
        if (debit > 0 && credit > 0 && debit != credit) {
          issues.add(
            LedgerValidationIssue(
              'unbalancedTransactionCurrency',
              'Lines in $currency do not balance: $debit Dr vs $credit Cr.',
            ),
          );
        }
      }
    }
    if (issues.isNotEmpty) {
      throw ValidationException(
        message: issues.map((issue) => issue.toString()).join('; '),
      );
    }
  }

  static Future<void> _writeAudit(
    Session session, {
    required Transaction transaction,
    required Entity entity,
    required UuidValue actorId,
    required AuditAction action,
    required AuditSubject? subjectType,
    required UuidValue? subjectId,
    required Map<String, Object?> payload,
  }) => AuditEvent.db.insertRow(
    session,
    AuditEvent(
      entityId: entity.id!,
      actorId: actorId,
      action: action,
      subjectType: subjectType,
      subjectId: subjectId,
      payloadJson: jsonEncode(payload),
      createdAt: DateTime.now().toUtc(),
    ),
    transaction: transaction,
  );

  static _JournalCursor? _decodeCursor(String? raw) {
    if (raw == null) return null;
    if (raw.isEmpty ||
        raw.length > 128 ||
        !RegExp(_cursorPattern).hasMatch(raw)) {
      throw ValidationException(message: 'Invalid journal cursor');
    }

    final String decoded;
    try {
      decoded = utf8.decode(base64Url.decode(base64Url.normalize(raw)));
    } on FormatException {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    if (decoded.length != 47 || decoded[10] != '|') {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    final dateText = decoded.substring(0, 10);
    if (!RegExp(_cursorDatePattern).hasMatch(dateText)) {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    final year = int.parse(dateText.substring(0, 4));
    final month = int.parse(dateText.substring(5, 7));
    final day = int.parse(dateText.substring(8, 10));
    if (year < 1900 || month < 1 || month > 12 || day < 1 || day > 31) {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    final UuidValue id;
    try {
      id = UuidValue.withValidation(decoded.substring(11));
    } on FormatException {
      throw ValidationException(message: 'Invalid journal cursor');
    }
    return _JournalCursor(date, id);
  }

  static const _trialBalanceSql = '''
SELECT
  la.id::text AS ledger_account_id,
  la.code AS code,
  la.name AS name,
  la.type AS type,
  la."systemRole" AS system_role,
  SUM(jl."baseDebitMinor")::bigint AS debit,
  SUM(jl."baseCreditMinor")::bigint AS credit
FROM journal_line jl
JOIN journal j ON j.id = jl."journalId"
JOIN ledger_account la ON la.id = jl."ledgerAccountId"
WHERE j."entityId" = @entityId::uuid
  AND j.status IN ('posted', 'reversed')
  AND j.date <= @asOf::timestamp
GROUP BY la.id, la.code, la.name, la.type, la."systemRole"
ORDER BY la.code, la.id
''';
}

/// One validated line, ready to persist or re-validate.
final class _StoredLine {
  const _StoredLine({
    required this.lineIndex,
    required this.account,
    required this.description,
    required this.debitMinor,
    required this.creditMinor,
    required this.currencyCode,
    required this.baseDebitMinor,
    required this.baseCreditMinor,
    required this.fxRate,
    required this.fxRateDate,
    required this.fxRateSource,
    required this.taxCode,
  });

  final int lineIndex;
  final LedgerAccount account;
  final String? description;
  final int debitMinor;
  final int creditMinor;
  final String currencyCode;
  final int baseDebitMinor;
  final int baseCreditMinor;
  final String fxRate;
  final DateTime? fxRateDate;
  final FxRateSource fxRateSource;
  final String? taxCode;
}

final class _JournalCursor {
  const _JournalCursor(this.date, this.id);

  final DateTime date;
  final UuidValue id;
}

/// A line whose currency, rate and rate date are normalized and validated.
final class _ValidatedLine {
  const _ValidatedLine({
    required this.account,
    required this.description,
    required this.debitMinor,
    required this.creditMinor,
    required this.currencyCode,
    required this.baseDebitMinor,
    required this.baseCreditMinor,
    required this.fxRate,
    required this.fxRateDate,
    required this.fxRateSource,
    required this.taxCode,
  });

  final LedgerAccount account;
  final String? description;
  final int debitMinor;
  final int creditMinor;
  final String currencyCode;
  final int baseDebitMinor;
  final int baseCreditMinor;
  final String fxRate;
  final DateTime fxRateDate;
  final FxRateSource fxRateSource;
  final String? taxCode;
}
