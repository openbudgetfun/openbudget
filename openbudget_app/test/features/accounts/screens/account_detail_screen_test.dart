// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
const _accountId = '00000000-0000-0000-0000-000000000111';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _accountUuid = UuidValue.fromString(_accountId);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000099');

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'OpenBudget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
  createdAt: DateTime(2026),
);

Account _makeAccount() => Account(
  id: _accountUuid,
  name: 'Daily',
  accountType: 'checking',
  balanceCents: 5202000,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  onBudget: true,
  sortOrder: 0,
  isClosed: false,
);

Transaction _makeTransaction() => Transaction(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000211'),
  description: 'Rent',
  amountCents: -280000,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  accountId: _accountUuid,
  transactionDate: DateTime(2026, 9, 3),
  memo: 'September rent',
  cleared: true,
);

BudgetSummary _makeSummary() => BudgetSummary(
  budget: _makeBudget(),
  categories: const [],
  totalIncomeCents: 0,
  totalBudgetedCents: 0,
  readyToAssignCents: 0,
  year: 2026,
  month: 9,
);

Widget _buildSubject() {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts/$_accountId',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Accounts Route'))),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) => AccountDetailScreen(
          budgetId: state.pathParameters['id']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountListProvider.overrideWith(
        (ref, budgetId) async => [_makeAccount()],
      ),
      accountTransactionsProvider.overrideWith(
        (ref, args) async => [_makeTransaction()],
      ),
      payeeListProvider.overrideWith((ref, budgetId) async => const []),
      budgetSummaryProvider.overrideWith(
        (ref, budgetId) async => _makeSummary(),
      ),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AccountDetailScreen', () {
    testWidgets('renders account and transaction content', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('September rent'), findsOneWidget);
    });

    testWidgets('back button navigates to account list route', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Accounts Route'), findsOneWidget);
    });
  });
}
