// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/screens/rule_list_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000201',
);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000202');
final _payeeUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000203');
final _envelopeUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000204',
);
final _categoryUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000205',
);

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'OpenBudget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
  createdAt: DateTime(2026),
);

BudgetSummary _makeSummary() {
  final category = Category(
    id: _categoryUuid,
    name: 'Bills',
    budgetId: _budgetUuid,
    sortOrder: 0,
    isHidden: false,
  );
  final envelope = Envelope(
    id: _envelopeUuid,
    name: 'Rent',
    budgetedAmountCents: 0,
    spentAmountCents: 0,
    currencyCode: 'USD',
    categoryId: _categoryUuid,
    sortOrder: 0,
  );

  return BudgetSummary(
    budget: _makeBudget(),
    categories: [
      CategoryWithEnvelopes(
        category: category,
        envelopes: [envelope],
        monthlyEnvelopes: const [],
        totalBudgetedCents: 0,
        totalSpentCents: 0,
        totalAvailableCents: 0,
      ),
    ],
    totalIncomeCents: 0,
    totalBudgetedCents: 0,
    readyToAssignCents: 0,
    year: 2026,
    month: 9,
  );
}

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/more',
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) =>
            MoreScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: recurringListRoute,
        path: recurringListPath,
        builder: (context, state) =>
            RecurringListScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: recurringCalendarRoute,
        path: recurringCalendarPath,
        builder: (_, __) => const Scaffold(body: Text('Recurring Calendar')),
      ),
      GoRoute(
        name: transactionRulesRoute,
        path: transactionRulesPath,
        builder: (context, state) =>
            RuleListScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: payeeListRoute,
        path: payeeListPath,
        builder: (_, __) => const Scaffold(body: Text('Payees')),
      ),
      GoRoute(
        name: importTransactionsRoute,
        path: importTransactionsPath,
        builder: (_, __) => const Scaffold(body: Text('Import')),
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsPath,
        builder: (_, __) => const Scaffold(body: Text('Settings')),
      ),
    ],
  );

  final recurring = [
    RecurringTransaction(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000206'),
      description: 'Rent',
      amountCents: -250000,
      currencyCode: 'USD',
      budgetId: _budgetUuid,
      frequency: 'monthly',
      nextOccurrence: DateTime(2026, 9),
      isActive: true,
    ),
  ];

  final rules = [
    TransactionRule(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000207'),
      budgetId: _budgetUuid,
      payeeId: _payeeUuid,
      targetEnvelopeId: _envelopeUuid,
      enabled: true,
    ),
  ];

  return ProviderScope(
    overrides: [
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
      budgetSummaryProvider.overrideWith((ref, id) async => _makeSummary()),
      payeeListProvider.overrideWith(
        (ref, id) async => [
          Payee(id: _payeeUuid, name: 'Landlord', budgetId: _budgetUuid),
        ],
      ),
      recurringListProvider.overrideWith((ref, id) async => recurring),
      ruleListProvider.overrideWith((ref, id) async => rules),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  patrolWidgetTest('navigates from More to recurring and opens add dialog', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recurring Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Recurring Transactions'), findsWidgets);

    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  patrolWidgetTest('navigates from More to rules and opens add rule dialog', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Transaction Rules'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Rules'), findsWidgets);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
