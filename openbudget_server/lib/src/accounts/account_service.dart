import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/institutions/institution_service.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing accounts within a budget.
///
/// All methods verify budget ownership before operating on accounts.
class AccountService {
  static final _log = ObLogger('AccountService');

  static UuidValue _requireUserId(Session session) {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null || userIdentifier.trim().isEmpty) {
      throw AuthenticationRequiredException();
    }
    return UuidValue.fromString(userIdentifier);
  }

  /// Creates an account within a budget, verifying ownership.
  static Future<Account> create(
    Session session, {
    required String name,
    required String accountType,
    required int balanceCents,
    required String currencyCode,
    required UuidValue budgetId,
    required bool onBudget,
    required int sortOrder,
    UuidValue? institutionId,
  }) async {
    _log.info(
      'Creating account name=$name type=$accountType budget=$budgetId institution=$institutionId',
    );

    final userId = _requireUserId(session);
    await BudgetService.getById(session, budgetId: budgetId);

    if (institutionId != null) {
      await InstitutionService.ensureCatalogSeeded(session);
      final institution = await Institution.db.findById(session, institutionId);
      if (institution == null) {
        throw NotFoundException('Institution not found');
      }
    }

    final resolvedSortOrder = sortOrder <= 0
        ? await _nextSortOrder(session, budgetId: budgetId)
        : sortOrder;

    final account = Account(
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      creatorId: userId,
      institutionId: institutionId,
      onBudget: onBudget,
      sortOrder: resolvedSortOrder,
      isClosed: false,
      sourceType: 'manual',
      syncStatus: 'manual',
    );
    final created = await Account.db.insertRow(session, account);
    _log.info('Account created id=${created.id}');
    return created;
  }

  /// Lists all accounts for a budget, verifying ownership.
  static Future<List<Account>> listForBudget(
    Session session, {
    required UuidValue budgetId,
  }) async {
    _log.info('Listing accounts for budget=$budgetId');
    await BudgetService.getById(session, budgetId: budgetId);

    return Account.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
    );
  }

  /// Lists creator-owned reusable accounts (\"My accounts\").
  static Future<List<Account>> listMine(
    Session session, {
    UuidValue? excludeBudgetId,
  }) async {
    final userId = _requireUserId(session);

    final mine = await Account.db.find(
      session,
      where: excludeBudgetId == null
          ? (t) => t.creatorId.equals(userId) & t.isClosed.equals(false)
          : (t) =>
                t.creatorId.equals(userId) &
                t.isClosed.equals(false) &
                t.budgetId.notEquals(excludeBudgetId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    final seenKeys = <String>{};
    final deduped = <Account>[];
    for (final account in mine) {
      final key = _reuseKey(account);
      if (!seenKeys.add(key)) continue;
      deduped.add(account);
    }
    return deduped;
  }

  /// Adds a creator-owned account to another budget the same user owns.
  static Future<Account> addMineToBudget(
    Session session, {
    required UuidValue sourceAccountId,
    required UuidValue budgetId,
  }) async {
    final userId = _requireUserId(session);
    await BudgetService.getById(session, budgetId: budgetId);

    final source = await Account.db.findById(session, sourceAccountId);
    if (source == null || source.creatorId != userId) {
      throw NotFoundException('My account not found');
    }

    if (source.budgetId == budgetId) return source;

    final existingInTarget = await Account.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId) & t.creatorId.equals(userId),
    );
    for (final account in existingInTarget) {
      if (_reuseKey(account) == _reuseKey(source)) return account;
    }

    final created = await Account.db.insertRow(
      session,
      Account(
        name: source.name,
        accountType: source.accountType,
        balanceCents: source.balanceCents,
        currencyCode: source.currencyCode,
        budgetId: budgetId,
        creatorId: userId,
        institutionId: source.institutionId,
        onBudget: source.onBudget,
        sortOrder: await _nextSortOrder(session, budgetId: budgetId),
        isClosed: false,
        sourceType: source.sourceType ?? 'manual',
        externalAccountId: source.externalAccountId,
        lastSyncedAt: source.lastSyncedAt,
        syncStatus: source.syncStatus ?? 'manual',
      ),
    );
    return created;
  }

  /// Fetches a single account, verifying budget ownership.
  static Future<Account> getById(
    Session session, {
    required UuidValue accountId,
  }) async {
    final account = await Account.db.findById(session, accountId);
    if (account == null) {
      throw NotFoundException('Account not found');
    }

    await BudgetService.getById(session, budgetId: account.budgetId);
    return account;
  }

  /// Updates an account, verifying budget ownership.
  static Future<Account> update(
    Session session, {
    required UuidValue accountId,
    String? name,
    String? accountType,
    int? balanceCents,
    bool? onBudget,
    int? sortOrder,
    bool? isClosed,
  }) async {
    _log.info('Updating account id=$accountId');
    final account = await getById(session, accountId: accountId);

    final updated = account.copyWith(
      name: name ?? account.name,
      accountType: accountType ?? account.accountType,
      balanceCents: balanceCents ?? account.balanceCents,
      onBudget: onBudget ?? account.onBudget,
      sortOrder: sortOrder ?? account.sortOrder,
      isClosed: isClosed ?? account.isClosed,
    );
    return Account.db.updateRow(session, updated);
  }

  /// Deletes an account, verifying budget ownership.
  static Future<Account> delete(
    Session session, {
    required UuidValue accountId,
  }) async {
    _log.info('Deleting account id=$accountId');
    final account = await getById(session, accountId: accountId);
    return Account.db.deleteRow(session, account);
  }

  static Future<int> _nextSortOrder(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final last = await Account.db.findFirstRow(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.sortOrder,
      orderDescending: true,
    );
    return (last?.sortOrder ?? -1) + 1;
  }

  static String _reuseKey(Account account) {
    final normalizedName = account.name.trim().toLowerCase();
    final normalizedType = account.accountType.trim().toLowerCase();
    final normalizedCurrency = account.currencyCode.trim().toUpperCase();
    final normalizedExternal = (account.externalAccountId ?? '').trim();
    final normalizedInstitution = account.institutionId?.toString() ?? '';
    return [
      normalizedName,
      normalizedType,
      normalizedCurrency,
      normalizedInstitution,
      normalizedExternal,
    ].join('|');
  }
}
