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

Account _makeAccount({
  String name = 'Daily',
  String accountType = 'checking',
  int balanceCents = 5202000,
  bool onBudget = true,
  bool isClosed = false,
}) => Account(
  id: _accountUuid,
  name: name,
  accountType: accountType,
  balanceCents: balanceCents,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  onBudget: onBudget,
  sortOrder: 0,
  isClosed: isClosed,
);

Transaction _makeTransaction({
  required String id,
  required String description,
  required int amountCents,
  DateTime? transactionDate,
  String? memo,
  bool cleared = false,
  bool reconciled = false,
}) => Transaction(
  id: UuidValue.fromString(id),
  description: description,
  amountCents: amountCents,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  accountId: _accountUuid,
  transactionDate: transactionDate ?? DateTime(2026, 9, 3),
  memo: memo,
  cleared: cleared,
  reconciled: reconciled,
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

Widget _buildSubject({List<Transaction>? transactions, Account? account}) {
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
        (ref, budgetId) async => [account ?? _makeAccount()],
      ),
      accountTransactionsProvider.overrideWith(
        (ref, args) async =>
            transactions ??
            [
              _makeTransaction(
                id: '00000000-0000-0000-0000-000000000211',
                description: 'Rent',
                amountCents: -280000,
                memo: 'September rent',
              ),
              _makeTransaction(
                id: '00000000-0000-0000-0000-000000000212',
                description: 'Payroll',
                amountCents: 300000,
                transactionDate: DateTime(2026, 9, 2),
                reconciled: true,
              ),
            ],
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
      expect(find.text('Payroll'), findsOneWidget);
    });

    testWidgets('back button navigates to account list route', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Accounts Route'), findsOneWidget);
    });

    testWidgets('menu toggle hides reconciled rows', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Payroll'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Reconciled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Payroll'), findsNothing);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('uncleared shortcut filters to uncleared transactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          transactions: [
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000211',
              description: 'Rent',
              amountCents: -280000,
            ),
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000212',
              description: 'Gym',
              amountCents: -8000,
              cleared: true,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);

      await tester.tap(find.textContaining('uncleared transactions'));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Gym'), findsNothing);
    });

    testWidgets('reconcile menu opens balance match prompt', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reconcile'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Does this match your bank balance'),
        findsOneWidget,
      );
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('edit account opens full-screen form fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Account'));
      await tester.pumpAndSettle();

      expect(find.text('Account Nickname'), findsOneWidget);
      expect(find.text('Account Notes'), findsOneWidget);
      expect(find.text('Working Balance'), findsWidgets);
      expect(find.text('Link an Account (Unavailable)'), findsOneWidget);
    });

    testWidgets('loan account renders overview and activity tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(
            name: 'Loan',
            accountType: 'other',
            balanceCents: -125,
            onBudget: false,
          ),
          transactions: [
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000311',
              description: 'Payment from Daily',
              amountCents: 50000,
            ),
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000312',
              description: 'Initial Balance',
              amountCents: -50000,
              transactionDate: DateTime(2026, 9),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Loan Payoff Overview'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Create Target'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Create Target'), findsOneWidget);

      await tester.tap(find.text('Create Target'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '400');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Target'), findsOneWidget);
      expect(find.text(r'$400.00'), findsWidgets);

      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      expect(find.text('Payment from Daily'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
    });
  });
}
