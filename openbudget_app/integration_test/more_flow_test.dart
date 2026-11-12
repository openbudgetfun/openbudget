import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/screens/rule_list_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);
final UuidValue _payeeUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000203',
);
final UuidValue _envelopeUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000204',
);
final UuidValue _accountUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000206',
);

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/more',
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) =>
            MoreScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: recurringListRoute,
        path: recurringListPath,
        builder: (context, state) =>
            RecurringListScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: recurringCalendarRoute,
        path: recurringCalendarPath,
        builder: (_, _) => const Scaffold(body: Text('Recurring Calendar')),
      ),
      GoRoute(
        name: transactionRulesRoute,
        path: transactionRulesPath,
        builder: (context, state) =>
            RuleListScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: payeeListRoute,
        path: payeeListPath,
        builder: (_, _) => const Scaffold(body: Text('Payees')),
      ),
      GoRoute(
        name: importTransactionsRoute,
        path: importTransactionsPath,
        builder: (_, _) => const Scaffold(body: Text('Import')),
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsPath,
        builder: (_, _) => const Scaffold(body: Text('Settings')),
      ),
    ],
  );

  final recurring = [
    RecurringTransaction(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000207'),
      entityId: _entityUuid,
      accountId: _accountUuid,
      description: 'Rent',
      amountMinor: -250000,
      frequency: RecurrenceFrequency.monthly,
      nextDate: DateTime(2026, 9),
      isActive: true,
    ),
  ];

  final rules = [
    TransactionRule(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000208'),
      entityId: _entityUuid,
      payeeId: _payeeUuid,
      envelopeId: _envelopeUuid,
      enabled: true,
    ),
  ];

  return ProviderScope(
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      taxProfileProvider.overrideWith((ref, id) async => null),
      payeeListProvider.overrideWith(
        (ref, id) async => [
          Payee(id: _payeeUuid, name: 'Landlord', entityId: _entityUuid),
        ],
      ),
      recurringListProvider.overrideWith((ref, id) async => recurring),
      ruleListProvider.overrideWith((ref, id) async => rules),
      budgetMonthCurrencyProvider.overrideWith((ref, id) async => 'USD'),
      budgetMonthGroupsProvider.overrideWith((ref, id) async => const []),
      accountListProvider.overrideWith((ref, id) async => const []),
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MoreScreen)),
    );

    await tester.tap(find.text('Recurring Transactions'));
    await tester.pumpAndSettle();

    expect(find.text('Recurring Transactions'), findsWidgets);

    await tester.tap(find.byKey(RecurringListScreen.addButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(container.exists(serverpodClientProvider), isFalse);
  });

  patrolWidgetTest('navigates from More to rules and opens add rule dialog', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MoreScreen)),
    );

    await tester.tap(find.text('Transaction Rules'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction Rules'), findsWidgets);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(container.exists(serverpodClientProvider), isFalse);
  });
}
