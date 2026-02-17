import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/budgets/budget_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Business logic for managing accounts within a budget.
///
/// All methods verify budget ownership before operating on accounts.
class AccountService {
  static final _log = ObLogger('AccountService');

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
  }) async {
    _log.info('Creating account name=$name type=$accountType budget=$budgetId');
    await BudgetService.getById(session, budgetId: budgetId);

    final account = Account(
      name: name,
      accountType: accountType,
      balanceCents: balanceCents,
      currencyCode: currencyCode,
      budgetId: budgetId,
      onBudget: onBudget,
      sortOrder: sortOrder,
      isClosed: false,
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
}
