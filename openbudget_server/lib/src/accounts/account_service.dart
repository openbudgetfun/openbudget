import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/common/currency_validation.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/ledger/ledger_account_linker.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';

/// Owns account lifecycle, its opening balance and its valuations.
///
/// Every read and write crosses [EntityAccess], so an account is visible only
/// to the owner of its entity. Cached balances move only through
/// [AccountBalanceService] (via [TransactionWriter] for transactions), never
/// by assigning [Account.balanceMinor] here.
abstract final class AccountService {
  static EntityChangePublisher _publisher = EntityRealtimeNotifier.notify;

  /// Replaces how committed account changes are delivered. Tests use this to
  /// observe notifications without opening a WebSocket.
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

  /// Creates an account and its opening fact in one transaction.
  ///
  /// A transactions-sourced account receives an `openingBalance` transaction
  /// written by [TransactionWriter], so its stored FX rate and base amount are
  /// real. A valuations-sourced account receives its first valuation and the
  /// cache is recomputed by [AccountBalanceService]. A zero opening keeps the
  /// cache at zero and writes no zero-amount transaction, because every
  /// transaction line must be non-zero; its inputs are still validated.
  static Future<Account> create(
    Session session,
    UuidValue entityId,
    String name,
    AccountKind kind,
    String currencyCode, {
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    UuidValue? institutionId,
    String? note,
  }) async {
    final result = await TransactionWriter.inTransaction(
      session,
      (tx) => _createInTransaction(
        session,
        tx,
        entityId: entityId,
        name: name,
        kind: kind,
        currencyCode: currencyCode,
        balanceSource: balanceSource,
        onBudget: onBudget,
        openingBalanceMinor: openingBalanceMinor,
        openingDate: openingDate,
        institutionId: institutionId,
        note: note,
      ),
    );

    await _notify(session, result.$2, result.$1.id);
    return result.$1;
  }

  /// Creates an account inside the caller's transaction without publishing.
  ///
  /// Wallet connect uses this so a fixed crypto account and its wallet commit
  /// together. Validation is identical to [create]; the caller must publish
  /// the [ChangeScope.accounts] event after its transaction commits.
  static Future<Account> createInTransaction(
    Session session,
    Transaction transaction, {
    required UuidValue entityId,
    required String name,
    required AccountKind kind,
    required String currencyCode,
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    UuidValue? institutionId,
    String? note,
  }) async {
    final result = await _createInTransaction(
      session,
      transaction,
      entityId: entityId,
      name: name,
      kind: kind,
      currencyCode: currencyCode,
      balanceSource: balanceSource,
      onBudget: onBudget,
      openingBalanceMinor: openingBalanceMinor,
      openingDate: openingDate,
      institutionId: institutionId,
      note: note,
    );
    return result.$1;
  }

  static Future<(Account, UuidValue)> _createInTransaction(
    Session session,
    Transaction tx, {
    required UuidValue entityId,
    required String name,
    required AccountKind kind,
    required String currencyCode,
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    UuidValue? institutionId,
    String? note,
  }) async {
    final accountName = _requireName(name);
    final currency = requireSupportedCurrency(currencyCode);
    final source = _requireSource(kind, balanceSource);
    final budgeted = onBudget ?? false;
    _requireBudgetable(kind, source, budgeted);
    _requireMinor(openingBalanceMinor, 'openingBalanceMinor');

    final entity = _requireWritable(
      await EntityAccess.requireOwned(
        session,
        entityId,
        transaction: tx,
        lock: true,
      ),
    );
    await _requireInstitution(session, institutionId, tx);
    final date = openingDate ?? EntityClock.today(entity);
    _requireOpeningDate(source, date, entity);
    final sortOrder = await _nextSortOrder(session, entityId, tx);

    final now = DateTime.now().toUtc();
    var account = await Account.db.insertRow(
      session,
      Account(
        entityId: entityId,
        name: accountName,
        kind: kind,
        currencyCode: currency,
        balanceSource: source,
        onBudget: budgeted,
        institutionId: institutionId,
        note: _normaliseNote(note),
        sortOrder: sortOrder,
        createdAt: now,
        updatedAt: now,
      ),
      transaction: tx,
    );

    // Ledger-mode money accounts mirror into the chart in the same
    // transaction, so a new bank, card or loan account can never exist
    // without its ledger link.
    if (entity.accountingMode == AccountingMode.ledger) {
      account = await LedgerAccountLinker.attachMoneyAccount(
        session,
        tx,
        entity: entity,
        account: account,
        actorId: EntityAccess.userId(session),
      );
    }

    if (openingBalanceMinor != null) {
      if (source == AccountBalanceSource.transactions) {
        if (openingBalanceMinor != 0) {
          await TransactionWriter.create(
            session,
            TransactionInput(
              accountId: account.id!,
              date: date,
              amountMinor: openingBalanceMinor,
              lines: const [],
            ),
            transaction: tx,
            metadata: const TransactionWriteMetadata(
              kind: TransactionKind.openingBalance,
            ),
          );
        }
      } else {
        await AccountValuation.db.insertRow(
          session,
          AccountValuation(
            accountId: account.id!,
            valuationDate: date,
            valueMinor: openingBalanceMinor,
            source: ValuationSource.manual,
          ),
          transaction: tx,
        );
        await AccountBalanceService.refreshValuation(
          session,
          account.id!,
          transaction: tx,
        );
      }

      account = (await Account.db.findById(
        session,
        account.id!,
        transaction: tx,
      ))!;
    }

    return (account, entity.id!);
  }

  /// Lists every account of one owned entity in display order.
  static Future<List<Account>> list(
    Session session,
    UuidValue entityId,
  ) async {
    await EntityAccess.requireOwned(session, entityId);
    return Account.db.find(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderByList: (t) => [t.sortOrder, t.id],
    );
  }

  /// Lists accounts across every entity the caller owns.
  static Future<List<Account>> listAll(Session session) async {
    final owner = EntityAccess.userId(session);
    final entities = await Entity.db.find(
      session,
      where: (t) => t.ownerId.equals(owner),
      orderByList: (t) => [t.sortOrder, t.id],
    );
    if (entities.isEmpty) return const [];

    final entityIds = {for (final entity in entities) entity.id!};
    final accounts = await Account.db.find(
      session,
      where: (t) => t.entityId.inSet(entityIds),
      orderByList: (t) => [t.sortOrder, t.id],
    );
    final entityOrder = {
      for (var index = 0; index < entities.length; index++)
        entities[index].id!: index,
    };

    return [...accounts]..sort((a, b) {
      final byEntity = entityOrder[a.entityId]!.compareTo(
        entityOrder[b.entityId]!,
      );
      if (byEntity != 0) return byEntity;

      final bySortOrder = a.sortOrder.compareTo(b.sortOrder);
      if (bySortOrder != 0) return bySortOrder;

      return a.id.toString().compareTo(b.id.toString());
    });
  }

  /// Loads one account after checking that the caller owns its entity.
  static Future<Account> get(Session session, UuidValue accountId) async {
    final account = await _findAccount(session, accountId);
    await EntityAccess.requireOwned(session, account.entityId);
    return account;
  }

  /// Loads one owned account by named argument for unported callers.
  static Future<Account> getById(
    Session session, {
    required UuidValue accountId,
  }) => get(session, accountId);

  /// Updates only the metadata the endpoint contract exposes.
  static Future<Account> update(
    Session session,
    UuidValue accountId, {
    String? name,
    AccountKind? kind,
    bool? onBudget,
    UuidValue? institutionId,
    bool clearInstitution = false,
    String? note,
    int? sortOrder,
  }) async {
    final result = await session.db.transaction((tx) async {
      final (entity, account) = await _lockWritableAccount(
        session,
        accountId,
        tx,
      );
      final nextName = name == null ? account.name : _requireName(name);
      final nextKind = kind ?? account.kind;
      final nextOnBudget = onBudget ?? account.onBudget;

      if (nextKind != account.kind) {
        _requireKindChange(account.kind, nextKind);
      }
      _requireBudgetable(nextKind, account.balanceSource, nextOnBudget);

      if (nextOnBudget != account.onBudget &&
          await _hasNonOpeningTransactions(session, accountId, tx)) {
        throw ValidationException(
          message: 'onBudget is fixed once the account has transactions',
        );
      }

      final nextInstitutionId = clearInstitution
          ? null
          : institutionId ?? account.institutionId;
      if (!clearInstitution && institutionId != null) {
        await _requireInstitution(session, institutionId, tx);
      }

      final changed = account.copyWith(
        name: nextName,
        kind: nextKind,
        onBudget: nextOnBudget,
        institutionId: nextInstitutionId,
        note: note == null ? account.note : _normaliseNote(note),
        sortOrder: sortOrder ?? account.sortOrder,
        updatedAt: DateTime.now().toUtc(),
      );
      return (
        await Account.db.updateRow(session, changed, transaction: tx),
        entity.id!,
      );
    });

    await _notify(session, result.$2, accountId);
    return result.$1;
  }

  /// Replaces the display order of every account in one owned entity.
  static Future<List<Account>> reorder(
    Session session,
    UuidValue entityId,
    List<UuidValue> accountIds,
  ) async {
    final result = await session.db.transaction((tx) async {
      final entity = _requireWritable(
        await EntityAccess.requireOwned(
          session,
          entityId,
          transaction: tx,
          lock: true,
        ),
      );
      // Sorted by id so the account lock set follows the same UUID order as
      // every other multi-account writer.
      final accounts = await Account.db.find(
        session,
        where: (t) => t.entityId.equals(entityId),
        orderByList: (t) => [t.id],
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      _requireExactAccountSet(accounts, accountIds);

      final byId = {for (final account in accounts) account.id!: account};
      final now = DateTime.now().toUtc();
      final ordered = <Account>[];
      for (var index = 0; index < accountIds.length; index++) {
        final account = byId[accountIds[index]]!;
        ordered.add(
          await Account.db.updateRow(
            session,
            account.copyWith(sortOrder: index, updatedAt: now),
            transaction: tx,
          ),
        );
      }
      return (ordered, entity.id!);
    });

    await _notify(session, result.$2, null);
    return result.$1;
  }

  /// Closes an account only when its cached balance is exactly zero.
  static Future<Account> close(Session session, UuidValue accountId) =>
      _setClosed(session, accountId, closed: true);

  /// Reopens a closed account.
  static Future<Account> reopen(Session session, UuidValue accountId) =>
      _setClosed(session, accountId, closed: false);

  /// Deletes an owned account, its transactions and its valuations.
  ///
  /// Every transfer that touches the account is removed through
  /// [TransactionWriter], which deletes both legs and reverses the surviving
  /// peer's cached balance. The writer locks every account a transfer touches
  /// in UUID order before any transfer row, so the target account is locked
  /// with its peers instead of being pinned first and then waiting on them.
  /// A ledger account with journal lines protects the account from deletion,
  /// as section 7.1 requires.
  static Future<void> delete(Session session, UuidValue accountId) async {
    final result = await TransactionWriter.inTransaction(session, (tx) async {
      final discovered = await Account.db.findById(
        session,
        accountId,
        transaction: tx,
      );
      if (discovered == null) {
        throw NotFoundException(message: 'Account not found');
      }
      await EntityAccess.requireOwned(
        session,
        discovered.entityId,
        transaction: tx,
      );
      await _requireJournalFree(session, discovered, tx);

      await TransactionWriter.deleteTransfersForAccount(
        session,
        accountId,
        transaction: tx,
      );

      final (entity, account) = await _lockWritableAccount(
        session,
        accountId,
        tx,
      );
      await _requireJournalFree(session, account, tx);
      await Account.db.deleteRow(session, account, transaction: tx);
      return entity.id!;
    });

    await _notify(session, result, accountId);
    await _publisher(session, result, ChangeScope.transactions);
  }

  /// Returns the cached and cleared balances of one owned account.
  static Future<AccountBalancesView> getBalances(
    Session session,
    UuidValue accountId,
  ) async {
    final account = await get(session, accountId);
    final rows = await session.db.unsafeQuery(
      '''
SELECT
  COALESCE(SUM(CASE WHEN status IN ('cleared', 'reconciled')
    THEN "amountMinor" ELSE 0 END), 0)::bigint AS cleared,
  COALESCE(SUM(CASE WHEN status = 'uncleared'
    THEN "amountMinor" ELSE 0 END), 0)::bigint AS uncleared
FROM "transaction" WHERE "accountId" = @accountId::uuid''',
      parameters: QueryParameters.named({'accountId': accountId.toString()}),
    );
    final row = rows.first;

    return AccountBalancesView(
      accountId: accountId,
      currencyCode: account.currencyCode,
      balanceMinor: account.balanceMinor,
      clearedMinor: row[0] as int,
      unclearedMinor: row[1] as int,
      reportedBalanceMinor: account.reportedBalanceMinor,
      reportedBalanceAt: account.reportedBalanceAt,
      reconciledThroughDate: account.reconciledThroughDate,
    );
  }

  /// Lists valuations newest-first.
  static Future<List<AccountValuation>> listValuations(
    Session session,
    UuidValue accountId,
  ) async {
    final account = await get(session, accountId);
    return AccountValuation.db.find(
      session,
      where: (t) => t.accountId.equals(account.id),
      orderByList: (t) => [t.valuationDate.desc(), t.id.desc()],
    );
  }

  /// Upserts one manual valuation and recomputes the cached balance.
  static Future<AccountValuation> setValuation(
    Session session,
    UuidValue accountId,
    DateTime valuationDate,
    int valueMinor, {
    String? note,
  }) async {
    final result = await AccountValuationService.set(
      session,
      accountId,
      valuationDate,
      valueMinor,
      note: note,
    );
    await _notify(session, result.$2, accountId);
    return result.$1;
  }

  /// Deletes one valuation and falls back to the previous date or zero.
  static Future<void> deleteValuation(
    Session session,
    UuidValue valuationId,
  ) async {
    final result = await AccountValuationService.delete(session, valuationId);
    await _notify(session, result.$1, result.$2);
  }

  static Future<Account> _setClosed(
    Session session,
    UuidValue accountId, {
    required bool closed,
  }) async {
    final result = await session.db.transaction((tx) async {
      final (entity, account) = await _lockWritableAccount(
        session,
        accountId,
        tx,
      );
      if (closed && account.balanceMinor != 0) {
        throw ValidationException(
          message: 'An account closes only at a zero balance',
        );
      }
      if (closed == (account.closedAt != null)) {
        return (account, entity.id!);
      }

      final changed = await Account.db.updateRow(
        session,
        account.copyWith(
          closedAt: closed ? DateTime.now().toUtc() : null,
          updatedAt: DateTime.now().toUtc(),
        ),
        transaction: tx,
      );
      return (changed, entity.id!);
    });

    await _notify(session, result.$2, accountId);
    return result.$1;
  }

  static Future<Account> _findAccount(
    Session session,
    UuidValue accountId,
  ) async {
    final account = await Account.db.findById(session, accountId);
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    return account;
  }

  static Future<(Entity, Account)> _lockWritableAccount(
    Session session,
    UuidValue accountId,
    Transaction tx,
  ) async {
    final account = await Account.db.findById(
      session,
      accountId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (account == null) {
      throw NotFoundException(message: 'Account not found');
    }
    final entity = _requireWritable(
      await EntityAccess.requireOwned(
        session,
        account.entityId,
        transaction: tx,
      ),
    );
    return (entity, account);
  }

  static String _requireName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      throw ValidationException(message: 'Name is required');
    }
    return name;
  }

  static String? _normaliseNote(String? raw) {
    final note = raw?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  static AccountBalanceSource _requireSource(
    AccountKind kind,
    AccountBalanceSource? requested,
  ) {
    final source = requested ?? kind.defaultBalanceSource;
    if (!kind.allowedBalanceSources.contains(source)) {
      throw ValidationException(
        message: '${kind.name} accounts cannot use ${source.name} balances',
      );
    }
    return source;
  }

  static void _requireBudgetable(
    AccountKind kind,
    AccountBalanceSource source,
    bool onBudget,
  ) {
    if (!onBudget) return;
    if (!kind.canBeOnBudget) {
      throw ValidationException(
        message: '${kind.name} accounts cannot be on budget',
      );
    }
    if (source != AccountBalanceSource.transactions) {
      throw ValidationException(
        message: 'An on-budget account needs transaction-sourced balances',
      );
    }
  }

  static void _requireKindChange(AccountKind current, AccountKind next) {
    final sameLiability = current.isLiability == next.isLiability;
    final sameSources =
        current.allowedBalanceSources.length ==
            next.allowedBalanceSources.length &&
        current.allowedBalanceSources.containsAll(next.allowedBalanceSources);
    if (!sameLiability || !sameSources) {
      throw ValidationException(
        message:
            'An account kind changes only within one liability and source '
            'group',
      );
    }
  }

  static Future<void> _requireInstitution(
    Session session,
    UuidValue? institutionId,
    Transaction tx,
  ) async {
    if (institutionId == null) return;
    final institution = await Institution.db.findById(
      session,
      institutionId,
      transaction: tx,
    );
    if (institution == null) {
      throw NotFoundException(message: 'Institution not found');
    }
  }

  static Future<bool> _hasNonOpeningTransactions(
    Session session,
    UuidValue accountId,
    Transaction tx,
  ) async {
    final rows = await session.db.unsafeQuery(
      'SELECT 1 FROM "transaction" '
      "WHERE \"accountId\" = @accountId::uuid AND kind <> 'openingBalance' "
      'LIMIT 1',
      parameters: QueryParameters.named({'accountId': accountId.toString()}),
      transaction: tx,
    );
    return rows.isNotEmpty;
  }

  static Future<void> _requireJournalFree(
    Session session,
    Account account,
    Transaction tx,
  ) async {
    final ledgerAccountId = account.ledgerAccountId;
    if (ledgerAccountId == null) return;

    final rows = await session.db.unsafeQuery(
      'SELECT 1 FROM journal_line '
      'WHERE "ledgerAccountId" = @ledgerAccountId::uuid LIMIT 1',
      parameters: QueryParameters.named({
        'ledgerAccountId': ledgerAccountId.toString(),
      }),
      transaction: tx,
    );
    if (rows.isNotEmpty) {
      throw ValidationException(
        message: 'A ledger account with journal lines cannot be deleted',
      );
    }
  }

  static Future<int> _nextSortOrder(
    Session session,
    UuidValue entityId,
    Transaction tx,
  ) async {
    final last = await Account.db.findFirstRow(
      session,
      where: (t) => t.entityId.equals(entityId),
      orderBy: (t) => t.sortOrder.desc(),
      transaction: tx,
    );
    return (last?.sortOrder ?? -1) + 1;
  }

  static Entity _requireWritable(Entity entity) {
    if (entity.archivedAt != null) {
      throw ValidationException(
        message: 'An archived entity rejects account changes',
      );
    }
    return entity;
  }

  static void _requireExactAccountSet(
    List<Account> accounts,
    List<UuidValue> accountIds,
  ) {
    final requested = accountIds.toSet();
    if (requested.length != accountIds.length) {
      throw ValidationException(
        message: 'reorder rejects duplicate account ids',
      );
    }

    final owned = {for (final account in accounts) account.id!};
    if (requested.length != owned.length || !requested.containsAll(owned)) {
      throw ValidationException(
        message: 'reorder needs every account of the entity exactly once',
      );
    }
  }

  static void _requireMinor(int? amount, String field) {
    if (amount != null && (amount < -maxSafeMinor || amount > maxSafeMinor)) {
      throw ValidationException(
        message: '$field exceeds the safe minor-unit range',
      );
    }
  }

  static void _requireOpeningDate(
    AccountBalanceSource source,
    DateTime date,
    Entity entity,
  ) {
    if (!isCivilDate(date) || date.year < 1900) {
      throw ValidationException(
        message: 'openingDate must be a UTC calendar date',
      );
    }

    final today = EntityClock.today(entity);
    final latest = source == AccountBalanceSource.valuations
        ? today
        : today.add(const Duration(days: 1));
    if (date.isAfter(latest)) {
      throw ValidationException(
        message: 'openingDate is after the account source allows',
      );
    }
  }

  static Future<void> _notify(
    Session session,
    UuidValue entityId,
    UuidValue? accountId,
  ) => _publisher(
    session,
    entityId,
    ChangeScope.accounts,
    accountId: accountId,
  );
}
