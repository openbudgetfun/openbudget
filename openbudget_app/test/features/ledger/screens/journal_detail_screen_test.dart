import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_detail_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../ledger_test_data.dart';

/// Pumps a books-entry home that pushes the detail screen for [journalId].
Future<void> _pumpDetail(
  WidgetTester tester,
  FakeLedgerRepository repository,
  String journalId,
) async {
  final container = ProviderContainer(
    overrides: [ledgerRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  final router = GoRouter(
    initialLocation: '/books-entry',
    routes: [
      GoRoute(
        path: '/books-entry',
        builder: (context, _) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => context.pushNamed(
                journalDetailRoute,
                pathParameters: {'id': testBudgetId, 'journalId': journalId},
              ),
              child: const Text('Open detail'),
            ),
          ),
        ),
      ),
      GoRoute(
        name: booksRoute,
        path: '/budgets/:id/books',
        builder: (_, _) => const Scaffold(body: Text('Books stub')),
      ),
      GoRoute(
        name: journalDetailRoute,
        path: journalDetailPath,
        builder: (context, state) => JournalDetailScreen(
          entityId: state.pathParameters['entityId']!,
          journalId: state.pathParameters['journalId']!,
        ),
      ),
      GoRoute(
        name: journalEditRoute,
        path: journalEditPath,
        builder: (_, _) => const Scaffold(body: Text('Editor stub')),
      ),
    ],
  );
  await tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open detail'));
  await tester.pumpAndSettle();
}

void main() {
  group('JournalDetailScreen', () {
    testWidgets('shows a posted journal read-only with a reverse action', (
      tester,
    ) async {
      await _pumpDetail(tester, FakeLedgerRepository(), postedJournalId);

      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('Posted'), findsOneWidget);
      expect(find.text('JB-2026-0001'), findsOneWidget);
      expect(find.text('Client invoice'), findsOneWidget);
      expect(find.byKey(const Key('journal-readonly-note')), findsOneWidget);
      expect(find.byKey(const Key('journal-delete-button')), findsNothing);
      expect(find.byKey(const Key('journal-reverse-button')), findsOneWidget);
    });

    testWidgets('shows the stored lines with per-currency totals', (
      tester,
    ) async {
      await _pumpDetail(tester, FakeLedgerRepository(), postedJournalId);

      expect(find.byKey(const Key('journal-detail-lines')), findsOneWidget);
      expect(find.text('Debit'), findsOneWidget);
      expect(find.text('Credit'), findsOneWidget);
      expect(find.byKey(const Key('journal-detail-line-0')), findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      expect(find.byKey(const Key('journal-detail-line-1')), findsOneWidget);
      expect(find.text('4000'), findsOneWidget);
      expect(find.text('Sales'), findsOneWidget);
      // Each line prints only its own side; totals repeat both.
      expect(find.text('£50.00'), findsNWidgets(4));
      expect(find.byKey(const Key('journal-detail-totals-0')), findsOneWidget);
      expect(find.text('Totals'), findsOneWidget);
    });

    testWidgets('a draft shows its lines with edit and delete actions', (
      tester,
    ) async {
      await _pumpDetail(tester, FakeLedgerRepository(), draftJournalId);

      expect(find.text('Draft'), findsOneWidget);
      expect(find.byKey(const Key('journal-draft-lines-note')), findsNothing);
      expect(find.byKey(const Key('journal-detail-lines')), findsOneWidget);
      expect(find.byKey(const Key('journal-edit-button')), findsOneWidget);
      expect(find.byKey(const Key('journal-delete-button')), findsOneWidget);
      expect(find.byKey(const Key('journal-reverse-button')), findsNothing);
    });

    testWidgets('the edit action opens the draft in the editor', (
      tester,
    ) async {
      await _pumpDetail(tester, FakeLedgerRepository(), draftJournalId);

      await tester.tap(find.byKey(const Key('journal-edit-button')));
      await tester.pumpAndSettle();

      expect(find.text('Editor stub'), findsOneWidget);
    });

    testWidgets('shows a retryable problem panel when lines fail', (
      tester,
    ) async {
      final repository = FakeLedgerRepository(
        linesError: Exception('offline'),
      );
      await _pumpDetail(tester, repository, postedJournalId);

      expect(
        find.byKey(const Key('journal-detail-lines-error')),
        findsOneWidget,
      );
      expect(
        find.text("We couldn't load this journal's lines. Try again."),
        findsOneWidget,
      );

      repository.linesError = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('journal-detail-lines-error')),
        findsNothing,
      );
      expect(find.byKey(const Key('journal-detail-lines')), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
    });

    testWidgets('deletes a draft after confirmation and goes back', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpDetail(tester, repository, draftJournalId);

      await tester.tap(find.byKey(const Key('journal-delete-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-delete-dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('journal-delete-confirm')));
      await tester.pumpAndSettle();

      expect(repository.deletedJournals, [draftJournalId]);
      expect(find.text('Open detail'), findsOneWidget);
    });

    testWidgets('canceling the delete keeps the draft', (tester) async {
      final repository = FakeLedgerRepository();
      await _pumpDetail(tester, repository, draftJournalId);

      await tester.tap(find.byKey(const Key('journal-delete-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.deletedJournals, isEmpty);
    });

    testWidgets('reverses a posted journal with a chosen reversal date', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpDetail(tester, repository, postedJournalId);

      await tester.tap(find.byKey(const Key('journal-reverse-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-reverse-dialog')), findsOneWidget);
      expect(find.textContaining('mirror journal'), findsOneWidget);
      expect(
        find.byKey(const Key('journal-reverse-date')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('journal-reverse-confirm')));
      await tester.pumpAndSettle();

      expect(repository.reversedJournals, hasLength(1));
      expect(repository.reversedJournals.single.journalId, postedJournalId);
    });

    testWidgets('canceling the reversal leaves the journal posted', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpDetail(tester, repository, postedJournalId);

      await tester.tap(find.byKey(const Key('journal-reverse-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.reversedJournals, isEmpty);
    });

    testWidgets('a reversed journal names the mirror journal', (tester) async {
      await _pumpDetail(tester, FakeLedgerRepository(), reversedJournalId);

      expect(find.text('Reversed'), findsOneWidget);
      expect(
        find.text('Reversal of JB-2026-0004'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal-detail-lines')), findsOneWidget);
      expect(find.byKey(const Key('journal-delete-button')), findsNothing);
      expect(find.byKey(const Key('journal-reverse-button')), findsNothing);
    });
  });
}
