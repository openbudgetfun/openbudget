import 'dart:convert';

import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;

/// Business logic for managing budgets.
///
/// All methods require an authenticated session.
class BudgetService {
  /// Returns the authenticated user's ID as a [UuidValue], or throws.
  static UuidValue _requireUserId(Session session) {
    final userIdentifier = session.authenticated?.userIdentifier;
    if (userIdentifier == null) throw AuthenticationRequiredException();
    return UuidValue.fromString(userIdentifier);
  }

  /// Creates a budget owned by the authenticated user.
  static Future<Budget> create(
    Session session, {
    required String name,
    required String currencyCode,
  }) async {
    final userId = _requireUserId(session);

    final budget = Budget(
      name: name,
      currencyCode: currencyCode,
      ownerId: userId,
    );
    return Budget.db.insertRow(session, budget);
  }

  /// Lists all budgets for the authenticated user.
  static Future<List<Budget>> listForUser(Session session) async {
    final userId = _requireUserId(session);

    return Budget.db.find(
      session,
      where: (t) => t.ownerId.equals(userId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Fetches a single budget, verifying ownership.
  static Future<Budget> getById(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final userId = _requireUserId(session);

    final budget = await Budget.db.findById(session, budgetId);
    if (budget == null || budget.ownerId != userId) {
      throw NotFoundException('Budget not found');
    }
    return budget;
  }

  /// Updates a budget, verifying ownership.
  static Future<Budget> update(
    Session session, {
    required UuidValue budgetId,
    String? name,
    String? currencyCode,
  }) async {
    final budget = await getById(session, budgetId: budgetId);

    final updated = budget.copyWith(
      name: name ?? budget.name,
      currencyCode: currencyCode ?? budget.currencyCode,
      updatedAt: DateTime.now(),
    );
    return Budget.db.updateRow(session, updated);
  }

  /// Deletes a budget, verifying ownership.
  static Future<Budget> delete(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final budget = await getById(session, budgetId: budgetId);
    return Budget.db.deleteRow(session, budget);
  }

  /// Exports all data for a budget as a JSON string.
  ///
  /// Gathers budget details, categories, envelopes, accounts, transactions,
  /// payees, and recurring transactions into a single portable JSON document.
  static Future<String> exportData(
    Session session, {
    required UuidValue budgetId,
  }) async {
    final budget = await getById(session, budgetId: budgetId);

    final categories = await Category.db.find(
      session,
      where: (c) => c.budgetId.equals(budgetId),
      orderBy: (c) => c.sortOrder,
    );

    // Gather all envelopes for the budget's categories.
    final categoryIds = categories
        .where((c) => c.id != null)
        .map((c) => c.id!)
        .toList();
    final envelopes = <Envelope>[];
    for (final catId in categoryIds) {
      final envs = await Envelope.db.find(
        session,
        where: (e) => e.categoryId.equals(catId),
      );
      envelopes.addAll(envs);
    }

    final accounts = await Account.db.find(
      session,
      where: (a) => a.budgetId.equals(budgetId),
    );

    final transactions = await Transaction.db.find(
      session,
      where: (t) => t.budgetId.equals(budgetId),
      orderBy: (t) => t.transactionDate,
      orderDescending: true,
    );

    final payees = await Payee.db.find(
      session,
      where: (p) => p.budgetId.equals(budgetId),
    );

    final recurringTransactions = await RecurringTransaction.db.find(
      session,
      where: (r) => r.budgetId.equals(budgetId),
    );

    final allocations = await MonthlyAllocation.db.find(
      session,
      where: (a) => a.budgetId.equals(budgetId),
    );

    final export = <String, dynamic>{
      'exportVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'budget': {
        'id': budget.id?.toString(),
        'name': budget.name,
        'currencyCode': budget.currencyCode,
        'createdAt': budget.createdAt.toIso8601String(),
      },
      'categories': [
        for (final c in categories)
          {
            'id': c.id?.toString(),
            'name': c.name,
            'sortOrder': c.sortOrder,
          },
      ],
      'envelopes': [
        for (final e in envelopes)
          {
            'id': e.id?.toString(),
            'name': e.name,
            'categoryId': e.categoryId.toString(),
            'budgetedAmountCents': e.budgetedAmountCents,
            'spentAmountCents': e.spentAmountCents,
            'currencyCode': e.currencyCode,
          },
      ],
      'accounts': [
        for (final a in accounts)
          {
            'id': a.id?.toString(),
            'name': a.name,
            'accountType': a.accountType,
            'balanceCents': a.balanceCents,
            'onBudget': a.onBudget,
            'isClosed': a.isClosed,
          },
      ],
      'transactions': [
        for (final t in transactions)
          {
            'id': t.id?.toString(),
            'description': t.description,
            'amountCents': t.amountCents,
            'currencyCode': t.currencyCode,
            'transactionDate': t.transactionDate.toIso8601String(),
            'envelopeId': t.envelopeId?.toString(),
            'accountId': t.accountId?.toString(),
            'payeeId': t.payeeId?.toString(),
            'memo': t.memo,
            'cleared': t.cleared,
            'reconciled': t.reconciled,
          },
      ],
      'payees': [
        for (final p in payees)
          {
            'id': p.id?.toString(),
            'name': p.name,
          },
      ],
      'recurringTransactions': [
        for (final r in recurringTransactions)
          {
            'id': r.id?.toString(),
            'description': r.description,
            'amountCents': r.amountCents,
            'currencyCode': r.currencyCode,
            'frequency': r.frequency,
            'nextOccurrence': r.nextOccurrence.toIso8601String(),
            'endDate': r.endDate?.toIso8601String(),
            'isActive': r.isActive,
          },
      ],
      'monthlyAllocations': [
        for (final a in allocations)
          {
            'id': a.id?.toString(),
            'envelopeId': a.envelopeId.toString(),
            'year': a.year,
            'month': a.month,
            'allocatedCents': a.allocatedCents,
            'carryoverCents': a.carryoverCents,
          },
      ],
    };

    return jsonEncode(export);
  }
}
