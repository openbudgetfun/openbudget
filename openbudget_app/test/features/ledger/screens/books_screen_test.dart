import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/screens/books_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../ledger_test_data.dart';

GoRouter _router() => GoRouter(
  initialLocation: '/budgets/$testBudgetId/books',
  routes: [
    GoRoute(
      name: booksRoute,
      path: '/budgets/:id/books',
      builder: (context, state) =>
          BooksScreen(budgetId: state.pathParameters['id']!),
      routes: [
        GoRoute(
          name: journalNewRoute,
          path: 'journals/new',
          builder: (_, _) => const Scaffold(body: Text('Editor stub')),
        ),
        GoRoute(
          name: journalDetailRoute,
          path: 'journals/:journalId',
          builder: (_, _) => const Scaffold(body: Text('Detail stub')),
        ),
      ],
    ),
  ],
);

Future<void> _pumpBooks(WidgetTester tester, FakeLedgerRepository repository) {
  final container = ProviderContainer(
    overrides: [ledgerRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: _router(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  group('BooksScreen', () {
    testWidgets('shows the three tabs', (tester) async {
      await _pumpBooks(tester, FakeLedgerRepository());
      await tester.pumpAndSettle();

      expect(find.text('Journals'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Trial balance'), findsOneWidget);
    });

    group('journals tab', () {
      testWidgets('lists journals newest first with status chips', (
        tester,
      ) async {
        await _pumpBooks(tester, FakeLedgerRepository());
        await tester.pumpAndSettle();

        expect(find.text('JB-2026-0004'), findsOneWidget);
        expect(find.text('JB-2026-0002'), findsOneWidget);
        expect(find.text('Draft'), findsOneWidget);
        expect(find.text('Posted'), findsNWidgets(2));
        expect(find.text('Reversed'), findsOneWidget);
      });

      testWidgets('opens the detail screen when a journal is tapped', (
        tester,
      ) async {
        await _pumpBooks(tester, FakeLedgerRepository());
        await tester.pumpAndSettle();

        await tester.tap(find.text('JB-2026-0001'));
        await tester.pumpAndSettle();

        expect(find.text('Detail stub'), findsOneWidget);
      });

      testWidgets('invites a first journal when none exist', (tester) async {
        await _pumpBooks(tester, FakeLedgerRepository(journals: []));
        await tester.pumpAndSettle();

        expect(find.text('No journals yet'), findsOneWidget);
        await tester.tap(find.text('New journal'));
        await tester.pumpAndSettle();

        expect(find.text('Editor stub'), findsOneWidget);
      });

      testWidgets('shows a problem panel when journals fail to load', (
        tester,
      ) async {
        final repository = FakeLedgerRepository(
          journalsError: Exception('offline'),
        );
        await _pumpBooks(tester, repository);
        await tester.pumpAndSettle();

        expect(find.text("We couldn't load your journals."), findsWidgets);

        repository.journalsError = null;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();

        expect(find.text('JB-2026-0004'), findsOneWidget);
      });
    });

    group('accounts tab', () {
      testWidgets('groups the chart by account type with archived marks', (
        tester,
      ) async {
        await _pumpBooks(tester, FakeLedgerRepository());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        expect(find.text('Assets'), findsOneWidget);
        expect(find.text('Liabilities'), findsOneWidget);
        expect(find.text('Income'), findsOneWidget);
        expect(find.text('Expenses'), findsOneWidget);
        expect(find.text('1000'), findsOneWidget);
        expect(find.text('Bank'), findsOneWidget);
        expect(find.text('4000 Sales'), findsNothing);
        expect(find.text('4000'), findsOneWidget);
        expect(find.text('Sales'), findsOneWidget);
        expect(find.text('Archived'), findsOneWidget);
      });

      testWidgets('shows a problem panel when accounts fail to load', (
        tester,
      ) async {
        await _pumpBooks(
          tester,
          FakeLedgerRepository(accountsError: Exception('offline')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Accounts'));
        await tester.pumpAndSettle();

        expect(
          find.text("We couldn't load your chart of accounts."),
          findsWidgets,
        );
      });
    });

    group('trial balance tab', () {
      testWidgets('renders rows, totals and the balanced indicator', (
        tester,
      ) async {
        await _pumpBooks(tester, FakeLedgerRepository());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trial balance'));
        await tester.pumpAndSettle();

        expect(find.text('As of'), findsOneWidget);
        expect(find.text('Balanced'), findsOneWidget);
        expect(find.text('1000'), findsOneWidget);
        expect(find.text('Bank'), findsOneWidget);
        expect(find.text('£50.00'), findsNWidgets(4));
        expect(find.text('Totals'), findsOneWidget);
      });

      testWidgets('shows the out-of-balance indicator on an unbalanced books', (
        tester,
      ) async {
        await _pumpBooks(
          tester,
          FakeLedgerRepository(
            trialBalanceResult: trialBalanceView(
              totalDebitMinor: 6000,
              rows: [
                trialRow(debitMinor: 6000),
                trialRow(
                  code: '4000',
                  name: 'Sales',
                  type: 'income',
                  debitMinor: 0,
                  creditMinor: 5000,
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trial balance'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('trial-unbalanced-chip')), findsOneWidget);
        expect(find.textContaining('Out of balance'), findsOneWidget);
      });

      testWidgets('changes the as-of date through the picker', (tester) async {
        final repository = FakeLedgerRepository();
        await _pumpBooks(tester, repository);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trial balance'));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('trial-asof-button')));
        await tester.pumpAndSettle();

        await tester.tap(find.text('15').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK').last);
        await tester.pumpAndSettle();

        expect(repository.trialBalanceCalls.last.asOf.day, 15);
      });

      testWidgets('shows a problem panel when the report fails', (
        tester,
      ) async {
        await _pumpBooks(
          tester,
          FakeLedgerRepository(trialBalanceError: Exception('offline')),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trial balance'));
        await tester.pumpAndSettle();

        expect(
          find.text("We couldn't load the trial balance."),
          findsWidgets,
        );
      });
    });

    group('lock date', () {
      testWidgets('shows the stored lock date from the server', (tester) async {
        await _pumpBooks(
          tester,
          FakeLedgerRepository(lock: testLock()),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-lock-banner')), findsOneWidget);
        expect(find.text('Lock date'), findsOneWidget);
        expect(
          find.text(
            DateFormat.yMMMd().format(DateTime.utc(2026, 10, 31)),
          ),
          findsOneWidget,
        );
        expect(find.text('No lock date set'), findsNothing);
      });

      testWidgets('shows that no lock date is set yet', (tester) async {
        await _pumpBooks(tester, FakeLedgerRepository());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-lock-banner')), findsOneWidget);
        expect(find.text('No lock date set'), findsOneWidget);
      });

      testWidgets('the dialog reads the stored date and saving refreshes it', (
        tester,
      ) async {
        final repository = FakeLedgerRepository(lock: testLock());
        await _pumpBooks(tester, repository);
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('books-lock-button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('books-lock-dialog')), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('books-lock-current'))).data,
          DateFormat.yMMMd().format(DateTime.utc(2026, 10, 31)),
        );

        await tester.tap(find.byKey(const Key('books-lock-set')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('20').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK').last);
        await tester.pumpAndSettle();

        expect(repository.lockDates.single.lockDate.day, 20);
        expect(
          tester.widget<Text>(find.byKey(const Key('books-lock-value'))).data,
          DateFormat.yMMMd().format(DateTime.utc(2026, 10, 20)),
        );
        expect(
          find.text(DateFormat.yMMMd().format(DateTime.utc(2026, 10, 31))),
          findsNothing,
        );
      });
    });

    testWidgets('the new journal button opens the editor', (tester) async {
      await _pumpBooks(tester, FakeLedgerRepository());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('books-new-journal')));
      await tester.pumpAndSettle();

      expect(find.text('Editor stub'), findsOneWidget);
    });
  });
}
