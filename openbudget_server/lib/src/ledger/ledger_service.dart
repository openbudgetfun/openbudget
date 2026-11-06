import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';

/// Business logic for a budget's double-entry books.
///
/// Every method verifies that the authenticated user owns the budget. The
/// arithmetic and validation rules live in `openbudget_core`; this service
/// enforces ownership, immutability of posted journals, the period lock and
/// the audit trail.
class LedgerService {
  static final _log = ObLogger('LedgerService');

  /// Journal statuses whose lines count toward balances. A `reversed`
  /// journal's own lines stay in the books; its posted reversal journal
  /// undoes them, so both count.
  static const _balanceStatuses = {'posted', 'reversed'};

  /// Turns the ledger on for a budget.
  ///
  /// The budget's tax profile must exist and name a [TaxEntityKind.soleTrader]
  /// or [TaxEntityKind.company]; personal budgets stay envelope-only. Seeds
  /// the chart of accounts from the jurisdiction's template and switches
  /// `accountingMode` to `ledger`. Switching back is not supported.
  static Future<Budget> enableLedger(
    Session session, {
    required UuidValue budgetId,
  }) async {
    _log.info('Enabling ledger for budget=$budgetId');
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    if (AccountingMode.tryParse(budget.accountingMode) ==
        AccountingMode.ledger) {
      throw ValidationException(
        message: 'This budget already keeps its books in the ledger.',
      );
    }

    final profile = await TaxProfileRecord.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
    );
    if (profile == null) {
      throw ValidationException(
        message: 'Set a tax profile before enabling the ledger.',
      );
    }
    final entityKind = _parseEntityKind(profile.entityKind);
    if (entityKind == TaxEntityKind.individual) {
      throw ValidationException(
        message: 'Only sole-trader and company budgets can use the ledger.',
      );
    }
    final jurisdiction = TaxJurisdiction.fromCountryCode(profile.jurisdiction);
    if (jurisdiction == null) {
      throw ValidationException(
        message:
            'No chart of accounts template exists for '
            '${profile.jurisdiction}.',
      );
    }
    final template = LedgerChartTemplate.forBooks(
      jurisdiction: jurisdiction,
      entityKind: entityKind,
    );
    if (template == null) {
      throw ValidationException(
        message:
            'No chart of accounts template exists for '
            '${jurisdiction.countryCode} ${entityKind.name} books.',
      );
    }

    final userId = _requireUserId(session);
    return session.db.transaction((transaction) async {
      for (final seeded in template.accounts) {
        await LedgerAccount.db.insertRow(
          session,
          LedgerAccount(
            budgetId: budgetId,
            code: seeded.code,
            name: seeded.name,
            type: seeded.type.name,
            systemRole: seeded.systemRole?.name,
          ),
          transaction: transaction,
        );
      }
      final updated = await Budget.db.updateRow(
        session,
        budget.copyWith(
          accountingMode: AccountingMode.ledger.name,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: budgetId,
        actor: userId,
        action: 'ledger.enabled',
        payload: {
          'jurisdiction': jurisdiction.countryCode,
          'entityKind': entityKind.name,
          'seededAccountCount': template.accounts.length,
        },
      );
      _log.info(
        'Ledger enabled budget=$budgetId '
        'accounts=${template.accounts.length}',
      );
      return updated;
    });
  }

  /// Lists the budget's ledger accounts.
  ///
  /// Archived accounts are hidden unless [includeArchived] is set.
  static Future<List<LedgerAccount>> listAccounts(
    Session session, {
    required UuidValue budgetId,
    bool includeArchived = false,
  }) async {
    await _requireLedgerBudget(session, budgetId: budgetId);
    return LedgerAccount.db.find(
      session,
      where: (a) => includeArchived
          ? a.budgetId.equals(budgetId)
          : a.budgetId.equals(budgetId) & a.archived.equals(false),
      orderBy: (a) => a.code,
    );
  }

  /// Adds an account to the budget's chart.
  ///
  /// Codes are unique per budget. A [systemRole] may be attached only while
  /// no active account holds that role: there is exactly one active account
  /// per role.
  static Future<LedgerAccount> createAccount(
    Session session, {
    required UuidValue budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) async {
    _log.info('Creating ledger account budget=$budgetId code=$code');
    final budget = await _requireLedgerBudget(session, budgetId: budgetId);
    final userId = _requireUserId(session);

    final trimmedCode = code.trim();
    if (trimmedCode.isEmpty) {
      throw ValidationException(message: 'Account code must not be empty.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ValidationException(message: 'Account name must not be empty.');
    }
    final parsedType = LedgerAccountType.tryParse(type);
    if (parsedType == null) {
      throw ValidationException(message: 'Unknown account type: $type.');
    }
    final parsedRole = systemRole == null
        ? null
        : LedgerSystemRole.tryParse(systemRole);
    if (systemRole != null && parsedRole == null) {
      throw ValidationException(
        message: 'Unknown system role: $systemRole.',
      );
    }
    final normalizedCurrency = currencyCode == null
        ? null
        : requireSupportedCurrency(currencyCode);

    final duplicateCode = await LedgerAccount.db.findFirstRow(
      session,
      where: (a) => a.budgetId.equals(budgetId) & a.code.equals(trimmedCode),
    );
    if (duplicateCode != null) {
      throw ValidationException(
        message: 'Account code $trimmedCode is already in use.',
      );
    }
    if (parsedRole != null) {
      final duplicateRole = await LedgerAccount.db.findFirstRow(
        session,
        where: (a) =>
            a.budgetId.equals(budgetId) &
            a.systemRole.equals(parsedRole.name) &
            a.archived.equals(false),
      );
      if (duplicateRole != null) {
        throw ValidationException(
          message:
              '${parsedRole.name} is already assigned to account '
              '${duplicateRole.code}.',
        );
      }
    }

    final account = await LedgerAccount.db.insertRow(
      session,
      LedgerAccount(
        budgetId: budgetId,
        code: trimmedCode,
        name: trimmedName,
        type: parsedType.name,
        systemRole: parsedRole?.name,
        currencyCode: normalizedCurrency,
        taxCategoryCode: taxCategoryCode,
      ),
    );
    await _writeAudit(
      session,
      budgetId: budget.id!,
      actor: userId,
      action: 'account.created',
      entity: 'ledger_account',
      entityId: account.id,
      payload: {
        'code': account.code,
        'name': account.name,
        'type': account.type,
        'systemRole': account.systemRole,
      },
    );
    return account;
  }

  /// Archives an account so it stops accepting postings.
  ///
  /// System accounts cannot be archived or deleted. An account with posted
  /// lines can only be archived when its posted balance is zero.
  static Future<LedgerAccount> archiveAccount(
    Session session, {
    required UuidValue accountId,
  }) async {
    final account = await LedgerAccount.db.findById(session, accountId);
    if (account == null) {
      throw NotFoundException(message: 'Ledger account not found');
    }
    final budget = await _requireLedgerBudget(
      session,
      budgetId: account.budgetId,
    );
    final userId = _requireUserId(session);

    if (account.systemRole != null) {
      throw ValidationException(
        message:
            'System account ${account.code} cannot be archived or deleted.',
      );
    }

    final postedLines = await JournalLine.db.find(
      session,
      where: (l) => l.ledgerAccountId.equals(accountId),
    );
    final postedLineIds = postedLines.map((line) => line.journalId).toSet();
    var postedNetMinor = 0;
    var hasPostedLines = false;
    if (postedLineIds.isNotEmpty) {
      final postedJournals = await Journal.db.find(
        session,
        where: (j) =>
            j.budgetId.equals(budget.id) & j.status.inSet(_balanceStatuses),
      );
      final postedJournalIds = postedJournals
          .map((journal) => journal.id)
          .toSet();
      for (final line in postedLines) {
        if (!postedJournalIds.contains(line.journalId)) {
          continue;
        }
        hasPostedLines = true;
        postedNetMinor +=
            line.functionalDebitMinor - line.functionalCreditMinor;
      }
    }
    if (hasPostedLines && postedNetMinor != 0) {
      throw ValidationException(
        message:
            'Account ${account.code} has posted lines and a non-zero '
            'balance of $postedNetMinor minor; clear it first.',
      );
    }

    final archived = await LedgerAccount.db.updateRow(
      session,
      account.copyWith(archived: true),
    );
    await _writeAudit(
      session,
      budgetId: budget.id!,
      actor: userId,
      action: 'account.archived',
      entity: 'ledger_account',
      entityId: accountId,
      payload: {'code': account.code, 'postedNetMinor': postedNetMinor},
    );
    return archived;
  }

  /// Saves a draft journal: creates one, or replaces the lines of an
  /// existing draft when [journalId] is given.
  ///
  /// The draft is validated with the core rules before anything is written.
  /// Posted journals are never touched by this path.
  static Future<Journal> saveDraftJournal(
    Session session, {
    required UuidValue budgetId,
    required DateTime date,
    required List<JournalLineInput> lines,
    UuidValue? journalId,
    String reference = '',
    String? narration,
    String source = 'manual',
  }) async {
    _log.info('Saving draft journal budget=$budgetId journal=$journalId');
    final budget = await _requireLedgerBudget(session, budgetId: budgetId);
    final userId = _requireUserId(session);

    final parsedSource = JournalSource.tryParse(source);
    if (parsedSource == null) {
      throw ValidationException(message: 'Unknown journal source: $source.');
    }
    if (parsedSource == JournalSource.reversal) {
      throw ValidationException(
        message:
            'Reversal journals are created by reversing a posted '
            'journal, not saved by hand.',
      );
    }

    final drafts = await _buildDrafts(
      session,
      budget: budget,
      lines: lines,
    );

    return session.db.transaction((transaction) async {
      Journal journal;
      if (journalId == null) {
        journal = await Journal.db.insertRow(
          session,
          Journal(
            budgetId: budgetId,
            date: _calendarDate(date),
            reference: reference,
            narration: narration,
            status: JournalStatus.draft.name,
            source: parsedSource.name,
          ),
          transaction: transaction,
        );
      } else {
        // Lock the row so a concurrent post cannot validate the old lines
        // while this edit replaces them.
        final existing = await Journal.db.findById(
          session,
          journalId,
          transaction: transaction,
          lockMode: LockMode.forUpdate,
        );
        if (existing == null) {
          throw NotFoundException(message: 'Journal not found');
        }
        if (existing.budgetId != budgetId) {
          throw NotFoundException(message: 'Journal not found');
        }
        if (existing.status != JournalStatus.draft.name) {
          throw ValidationException(
            message:
                'Journal ${existing.reference} is ${existing.status} and '
                'immutable; post a reversal instead.',
          );
        }
        await JournalLine.db.deleteWhere(
          session,
          where: (l) => l.journalId.equals(journalId),
          transaction: transaction,
        );
        journal = await Journal.db.updateRow(
          session,
          existing.copyWith(
            date: _calendarDate(date),
            reference: reference,
            narration: narration,
            source: parsedSource.name,
          ),
          transaction: transaction,
        );
      }

      for (var index = 0; index < lines.length; index++) {
        final input = lines[index];
        final draft = drafts[index];
        await JournalLine.db.insertRow(
          session,
          JournalLine(
            journalId: journal.id!,
            ledgerAccountId: input.ledgerAccountId,
            description: input.description,
            debitMinor: draft.debitMinor,
            creditMinor: draft.creditMinor,
            currencyCode: draft.currencyCode,
            functionalDebitMinor: draft.functionalDebitMinor,
            functionalCreditMinor: draft.functionalCreditMinor,
            exchangeRate: draft.exchangeRate,
            rateDate: draft.rateDate,
            rateSource: draft.rateSource,
            taxCode: input.taxCode,
          ),
          transaction: transaction,
        );
      }

      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: budgetId,
        actor: userId,
        action: journalId == null
            ? 'journal.draft_saved'
            : 'journal.draft_updated',
        entity: 'journal',
        entityId: journal.id,
        payload: {
          'reference': journal.reference,
          'date': journal.date.toIso8601String(),
          'lineCount': lines.length,
        },
      );
      return journal;
    });
  }

  /// Deletes a draft journal and its lines.
  ///
  /// Posted and reversed journals are immutable; deleting one throws.
  static Future<void> deleteDraftJournal(
    Session session, {
    required UuidValue journalId,
  }) async {
    final journal = await _getOwnedJournal(session, journalId: journalId);
    final userId = _requireUserId(session);
    if (journal.status != JournalStatus.draft.name) {
      throw ValidationException(
        message:
            'Journal ${journal.reference} is ${journal.status} and cannot '
            'be deleted; post a reversal instead.',
      );
    }

    await session.db.transaction((transaction) async {
      await JournalLine.db.deleteWhere(
        session,
        where: (l) => l.journalId.equals(journalId),
        transaction: transaction,
      );
      await Journal.db.deleteRow(
        session,
        journal,
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: journal.budgetId,
        actor: userId,
        action: 'journal.draft_deleted',
        entity: 'journal',
        entityId: journalId,
        payload: {'reference': journal.reference},
      );
    });
    _log.info('Draft journal deleted journal=$journalId');
  }

  /// Posts a draft journal.
  ///
  /// Re-validates the stored lines with the core validator inside the
  /// posting transaction, refuses dates on or before the period lock, and
  /// stamps `postedAt` with server time. Posting is the only transition out
  /// of `draft`; a posted journal is immutable afterwards.
  static Future<Journal> postJournal(
    Session session, {
    required UuidValue journalId,
  }) async {
    final journal = await _getOwnedJournal(session, journalId: journalId);
    final budget = await _requireLedgerBudget(
      session,
      budgetId: journal.budgetId,
    );
    final userId = _requireUserId(session);
    if (journal.status != JournalStatus.draft.name) {
      throw ValidationException(
        message:
            'Only draft journals can be posted; journal '
            '${journal.reference} is ${journal.status}.',
      );
    }
    await _assertDateOpen(session, budget: budget, date: journal.date);

    return session.db.transaction((transaction) async {
      // Re-read under a row lock: a concurrent post, edit or delete of the
      // same draft waits here, and the date and lines validated below are
      // exactly the ones that get posted.
      final current = await _lockJournal(
        session,
        transaction: transaction,
        journalId: journalId,
      );
      if (current.status != JournalStatus.draft.name) {
        throw ValidationException(
          message:
              'Only draft journals can be posted; journal '
              '${current.reference} is ${current.status}.',
        );
      }
      await _assertDateOpen(session, budget: budget, date: current.date);
      final storedLines = await JournalLine.db.find(
        session,
        where: (l) => l.journalId.equals(journalId),
        transaction: transaction,
      );
      final draft = await _rebuildDraft(
        session,
        budget: budget,
        lines: storedLines,
      );
      _throwIfInvalid(draft);

      final posted = await Journal.db.updateRow(
        session,
        current.copyWith(
          status: JournalStatus.posted.name,
          postedAt: DateTime.now().toUtc(),
          postedBy: userId,
        ),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: budget.id!,
        actor: userId,
        action: 'journal.posted',
        entity: 'journal',
        entityId: journalId,
        payload: {
          'reference': current.reference,
          'date': current.date.toIso8601String(),
          'lineCount': storedLines.length,
          'totalFunctionalDebitMinor': storedLines.fold<int>(
            0,
            (sum, line) => sum + line.functionalDebitMinor,
          ),
        },
      );
      _log.info('Journal posted journal=$journalId');
      return posted;
    });
  }

  /// Reverses a posted journal on [date] by posting a mirror journal.
  ///
  /// Every line swaps debit and credit, so all account balances return to
  /// their pre-journal values. The original journal flips to `reversed` and
  /// stays immutable. The reversal date must be after the period lock.
  static Future<Journal> reverseJournal(
    Session session, {
    required UuidValue journalId,
    required DateTime date,
  }) async {
    final original = await _getOwnedJournal(session, journalId: journalId);
    final budget = await _requireLedgerBudget(
      session,
      budgetId: original.budgetId,
    );
    final userId = _requireUserId(session);
    if (original.status != JournalStatus.posted.name) {
      throw ValidationException(
        message:
            'Only posted journals can be reversed; journal '
            '${original.reference} is ${original.status}.',
      );
    }
    final reversalDate = _calendarDate(date);
    await _assertDateOpen(session, budget: budget, date: reversalDate);

    final storedLines = await JournalLine.db.find(
      session,
      where: (l) => l.journalId.equals(journalId),
    );
    final accounts = await LedgerAccount.db.find(
      session,
      where: (a) => a.budgetId.equals(budget.id),
    );
    final accountById = {
      for (final account in accounts) account.id: account,
    };
    final reversalLines = [
      for (final line in storedLines)
        (
          accountId: line.ledgerAccountId,
          draft: JournalLineDraft(
            accountCode: accountById[line.ledgerAccountId]?.code ?? '',
            description: line.description,
            debitMinor: line.creditMinor,
            creditMinor: line.debitMinor,
            currencyCode: line.currencyCode,
            functionalDebitMinor: line.functionalCreditMinor,
            functionalCreditMinor: line.functionalDebitMinor,
            exchangeRate: line.exchangeRate,
            rateDate: line.rateDate ?? reversalDate,
            rateSource: line.rateSource ?? 'reversal',
            taxCode: line.taxCode,
          ),
        ),
    ];
    final draft = JournalDraft(
      functionalCurrency: budget.currencyCode,
      lines: [for (final line in reversalLines) line.draft],
    );
    _throwIfInvalid(draft);

    final reversalReference = original.reference.isEmpty
        ? 'REV-${original.id}'
        : '${original.reference}-REV';

    return session.db.transaction((transaction) async {
      // Re-read under a row lock so two concurrent reversals of the same
      // journal cannot both pass the status check and reverse it twice.
      final current = await _lockJournal(
        session,
        transaction: transaction,
        journalId: journalId,
      );
      if (current.status != JournalStatus.posted.name) {
        throw ValidationException(
          message:
              'Only posted journals can be reversed; journal '
              '${current.reference} is ${current.status}.',
        );
      }
      final reversal = await Journal.db.insertRow(
        session,
        Journal(
          budgetId: original.budgetId,
          date: reversalDate,
          reference: reversalReference,
          narration:
              'Reversal of ${original.reference.isEmpty ? original.id : original.reference}',
          status: JournalStatus.posted.name,
          source: JournalSource.reversal.name,
          postedAt: DateTime.now().toUtc(),
          postedBy: userId,
          reversalOfJournalId: original.id,
        ),
        transaction: transaction,
      );
      for (final line in reversalLines) {
        await JournalLine.db.insertRow(
          session,
          JournalLine(
            journalId: reversal.id!,
            ledgerAccountId: line.accountId,
            description: line.draft.description,
            debitMinor: line.draft.debitMinor,
            creditMinor: line.draft.creditMinor,
            currencyCode: line.draft.currencyCode,
            functionalDebitMinor: line.draft.functionalDebitMinor,
            functionalCreditMinor: line.draft.functionalCreditMinor,
            exchangeRate: line.draft.exchangeRate,
            rateDate: line.draft.rateDate,
            rateSource: line.draft.rateSource,
            taxCode: line.draft.taxCode,
          ),
          transaction: transaction,
        );
      }
      await Journal.db.updateRow(
        session,
        current.copyWith(status: JournalStatus.reversed.name),
        transaction: transaction,
      );
      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: original.budgetId,
        actor: userId,
        action: 'journal.reversed',
        entity: 'journal',
        entityId: reversal.id,
        payload: {
          'originalJournalId': original.id?.toString(),
          'date': reversalDate.toIso8601String(),
          'reference': reversalReference,
        },
      );
      _log.info('Journal reversed journal=$journalId reversal=${reversal.id}');
      return reversal;
    });
  }

  /// Lists one journal's lines, oldest first.
  ///
  /// Line ids are UUIDv7, so ordering by id follows insertion time. Line
  /// order carries no accounting meaning; it only lets an editor show the
  /// lines roughly as they were entered.
  static Future<List<JournalLine>> listJournalLines(
    Session session, {
    required UuidValue journalId,
  }) async {
    final journal = await _getOwnedJournal(session, journalId: journalId);
    await _requireLedgerBudget(session, budgetId: journal.budgetId);
    return JournalLine.db.find(
      session,
      where: (l) => l.journalId.equals(journalId),
      orderBy: (l) => l.id,
    );
  }

  /// The budget's period lock, or null when no lock date has been set.
  static Future<LedgerPeriodLock?> getLockDate(
    Session session, {
    required UuidValue budgetId,
  }) async {
    await _requireLedgerBudget(session, budgetId: budgetId);
    return LedgerPeriodLock.db.findFirstRow(
      session,
      where: (l) => l.budgetId.equals(budgetId),
    );
  }

  /// Lists the budget's journals between the optional dates, newest first.
  ///
  /// Both bounds are inclusive calendar dates.
  static Future<List<Journal>> listJournals(
    Session session, {
    required UuidValue budgetId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await _requireLedgerBudget(session, budgetId: budgetId);
    return Journal.db.find(
      session,
      where: (j) {
        var filter = j.budgetId.equals(budgetId);
        final from = fromDate == null ? null : _calendarDate(fromDate);
        final to = toDate == null ? null : _calendarDate(toDate);
        if (from != null) {
          filter = filter & (j.date >= from);
        }
        if (to != null) {
          filter = filter & (j.date <= to);
        }
        return filter;
      },
      orderBy: (j) => j.date.desc(),
    );
  }

  /// Sets or moves the budget's period lock.
  ///
  /// Posting or reversing into a date on or before the lock date is
  /// rejected. Moving the lock is allowed and audited.
  static Future<LedgerPeriodLock> setLockDate(
    Session session, {
    required UuidValue budgetId,
    required DateTime lockDate,
  }) async {
    final budget = await _requireLedgerBudget(session, budgetId: budgetId);
    final userId = _requireUserId(session);
    final normalized = _calendarDate(lockDate);
    _log.info('Setting lock date budget=${budget.id} date=$normalized');

    return session.db.transaction((transaction) async {
      final existing = await LedgerPeriodLock.db.findFirstRow(
        session,
        where: (l) => l.budgetId.equals(budgetId),
        transaction: transaction,
      );
      final lock = existing == null
          ? await LedgerPeriodLock.db.insertRow(
              session,
              LedgerPeriodLock(
                budgetId: budgetId,
                lockDate: normalized,
                setBy: userId,
              ),
              transaction: transaction,
            )
          : await LedgerPeriodLock.db.updateRow(
              session,
              existing.copyWith(lockDate: normalized),
              transaction: transaction,
            );
      await _writeAudit(
        session,
        transaction: transaction,
        budgetId: budgetId,
        actor: userId,
        action: 'lock.set',
        payload: {
          'lockDate': normalized.toIso8601String(),
          'previousLockDate': existing?.lockDate.toIso8601String(),
        },
      );
      return lock;
    });
  }

  /// Computes the trial balance through [asOf] over posted journals.
  ///
  /// Returns rows per account with debit, credit and net totals. A trial
  /// balance that does not balance is a hard error and throws instead of
  /// returning a report labelled "difference".
  static Future<TrialBalanceView> trialBalance(
    Session session, {
    required UuidValue budgetId,
    required DateTime asOf,
  }) async {
    final budget = await _requireLedgerBudget(session, budgetId: budgetId);
    final asOfDay = _calendarDate(asOf);

    /// Journals whose lines count toward balances. A `reversed` journal's
    /// own lines stay in the books; its posted reversal journal undoes them.
    final postedJournals = await Journal.db.find(
      session,
      where: (j) =>
          j.budgetId.equals(budgetId) &
          j.status.inSet(_balanceStatuses) &
          (j.date <= asOfDay),
    );
    final journalIds = postedJournals.map((journal) => journal.id!).toSet();

    final lines = journalIds.isEmpty
        ? const <JournalLine>[]
        : await JournalLine.db.find(
            session,
            where: (l) => l.journalId.inSet(journalIds),
          );

    final accounts = await LedgerAccount.db.find(
      session,
      where: (a) => a.budgetId.equals(budgetId),
    );
    final accountById = {
      for (final account in accounts) account.id: account,
    };
    final accountByCode = {
      for (final account in accounts) account.code: account,
    };

    final trialBalance = computeTrialBalance([
      for (final line in lines)
        TrialBalanceEntry(
          accountCode: accountById[line.ledgerAccountId]?.code ?? '',
          functionalDebitMinor: line.functionalDebitMinor,
          functionalCreditMinor: line.functionalCreditMinor,
        ),
    ]);
    if (!trialBalance.isBalanced) {
      throw ValidationException(
        message:
            'Trial balance is out by '
            '${trialBalance.totalDebitMinor - trialBalance.totalCreditMinor} '
            'minor; the books do not balance.',
      );
    }

    return TrialBalanceView(
      budgetId: budgetId,
      currencyCode: budget.currencyCode,
      asOf: asOfDay,
      rows: [
        for (final row in trialBalance.rows)
          TrialBalanceRowView(
            accountCode: row.accountCode,
            accountName: accountByCode[row.accountCode]?.name ?? '',
            accountType:
                accountByCode[row.accountCode]?.type ??
                LedgerAccountType.asset.name,
            systemRole: accountByCode[row.accountCode]?.systemRole,
            debitMinor: row.debitMinor,
            creditMinor: row.creditMinor,
            netMinor: row.netMinor,
          ),
      ],
      totalDebitMinor: trialBalance.totalDebitMinor,
      totalCreditMinor: trialBalance.totalCreditMinor,
    );
  }

  // -- Helpers ---------------------------------------------------------------

  static UuidValue _requireUserId(Session session) {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) {
      throw AuthenticationRequiredException();
    }
    return UuidValue.fromString(userIdentifier);
  }

  /// Loads a journal after verifying the caller owns its budget.
  static Future<Journal> _getOwnedJournal(
    Session session, {
    required UuidValue journalId,
  }) async {
    final journal = await Journal.db.findById(session, journalId);
    if (journal == null) {
      throw NotFoundException(message: 'Journal not found');
    }
    await BudgetService.getById(session, budgetId: journal.budgetId);
    return journal;
  }

  /// Re-reads a journal inside [transaction] with a row lock, so concurrent
  /// writers to the same journal wait until the transaction ends.
  static Future<Journal> _lockJournal(
    Session session, {
    required Transaction transaction,
    required UuidValue journalId,
  }) async {
    final journal = await Journal.db.findById(
      session,
      journalId,
      transaction: transaction,
      lockMode: LockMode.forUpdate,
    );
    if (journal == null) {
      throw NotFoundException(message: 'Journal not found');
    }
    return journal;
  }

  /// Loads the budget for an owned budgetId and requires ledger mode.
  static Future<Budget> _requireLedgerBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final budget = await BudgetService.getById(session, budgetId: budgetId);
    if (AccountingMode.tryParse(budget.accountingMode) !=
        AccountingMode.ledger) {
      throw ValidationException(
        message:
            'This budget is in envelope mode; enable the ledger on it '
            'first.',
      );
    }
    return budget;
  }

  /// Rejects [date] when it falls on or before the budget's lock date.
  static Future<void> _assertDateOpen(
    Session session, {
    required Budget budget,
    required DateTime date,
  }) async {
    final lock = await LedgerPeriodLock.db.findFirstRow(
      session,
      where: (l) => l.budgetId.equals(budget.id),
    );
    if (lock == null) {
      return;
    }
    if (!_calendarDate(date).isAfter(_calendarDate(lock.lockDate))) {
      throw ValidationException(
        message:
            'The period on or before ${_calendarDate(lock.lockDate).toIso8601String().substring(0, 10)} '
            'is locked; post or reverse into an open period instead.',
      );
    }
  }

  /// Validates [lines] against the budget's accounts and functional
  /// currency, returning the checked core drafts in input order.
  static Future<List<JournalLineDraft>> _buildDrafts(
    Session session, {
    required Budget budget,
    required List<JournalLineInput> lines,
  }) async {
    final accounts = await LedgerAccount.db.find(
      session,
      where: (a) => a.budgetId.equals(budget.id),
    );
    final accountById = {
      for (final account in accounts) account.id: account,
    };

    final drafts = <JournalLineDraft>[];
    for (final line in lines) {
      final account = accountById[line.ledgerAccountId];
      if (account == null) {
        throw ValidationException(
          message: 'Line references an account outside this budget.',
        );
      }
      if (account.archived) {
        throw ValidationException(
          message:
              'Account ${account.code} is archived and takes no new '
              'lines.',
        );
      }
      final normalizedCurrency = requireSupportedCurrency(line.currencyCode);
      if (line.rateDate == null || line.rateSource == null) {
        throw ValidationException(
          message: 'Every line needs the exchange rate date and source.',
        );
      }
      drafts.add(
        JournalLineDraft(
          accountCode: account.code,
          description: line.description,
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: normalizedCurrency,
          functionalDebitMinor: line.functionalDebitMinor,
          functionalCreditMinor: line.functionalCreditMinor,
          exchangeRate: line.exchangeRate,
          rateDate: line.rateDate!,
          rateSource: line.rateSource!,
          taxCode: line.taxCode,
        ),
      );
    }

    final draft = JournalDraft(
      functionalCurrency: budget.currencyCode,
      lines: drafts,
    );
    _throwIfInvalid(draft);
    return drafts;
  }

  /// Rebuilds a core draft from stored lines for re-validation at posting.
  static Future<JournalDraft> _rebuildDraft(
    Session session, {
    required Budget budget,
    required List<JournalLine> lines,
  }) async {
    final accounts = await LedgerAccount.db.find(
      session,
      where: (a) => a.budgetId.equals(budget.id),
    );
    final accountById = {
      for (final account in accounts) account.id: account,
    };

    final drafts = <JournalLineDraft>[];
    for (final line in lines) {
      final account = accountById[line.ledgerAccountId];
      if (account == null) {
        throw ValidationException(
          message: 'Line references an account outside this budget.',
        );
      }
      if (account.archived) {
        throw ValidationException(
          message:
              'Account ${account.code} is archived and takes no new '
              'lines.',
        );
      }
      drafts.add(
        JournalLineDraft(
          accountCode: account.code,
          description: line.description,
          debitMinor: line.debitMinor,
          creditMinor: line.creditMinor,
          currencyCode: line.currencyCode,
          functionalDebitMinor: line.functionalDebitMinor,
          functionalCreditMinor: line.functionalCreditMinor,
          exchangeRate: line.exchangeRate,
          rateDate: line.rateDate ?? _calendarDate(DateTime.now()),
          rateSource: line.rateSource ?? 'stored',
          taxCode: line.taxCode,
        ),
      );
    }
    return JournalDraft(
      functionalCurrency: budget.currencyCode,
      lines: drafts,
    );
  }

  static void _throwIfInvalid(JournalDraft draft) {
    final issues = draft.validate();
    if (issues.isNotEmpty) {
      throw ValidationException(
        message: issues.map((issue) => issue.toString()).join('; '),
      );
    }
  }

  static Future<void> _writeAudit(
    Session session, {
    required UuidValue budgetId,
    required UuidValue actor,
    required String action,
    Transaction? transaction,
    String? entity,
    UuidValue? entityId,
    Object? payload,
  }) async {
    await LedgerAuditEvent.db.insertRow(
      session,
      LedgerAuditEvent(
        budgetId: budgetId,
        actor: actor,
        action: action,
        entity: entity,
        entityId: entityId,
        payloadJson: jsonEncode(payload ?? {}),
      ),
      transaction: transaction,
    );
  }

  static DateTime _calendarDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static TaxEntityKind _parseEntityKind(String name) {
    for (final kind in TaxEntityKind.values) {
      if (kind.name == name) {
        return kind;
      }
    }
    throw ValidationException(message: 'Unknown entity kind: $name.');
  }
}
