import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_editor_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../ledger_test_data.dart';

GoRouter _router({String? journalId}) => GoRouter(
  initialLocation: '/books-entry',
  routes: [
    GoRoute(
      path: '/books-entry',
      builder: (context, _) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.pushNamed(
              journalId == null ? journalNewRoute : journalEditRoute,
              pathParameters: {
                'id': testBudgetId,
                'journalId': ?journalId,
              },
            ),
            child: const Text('Open editor'),
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
      name: journalNewRoute,
      path: journalNewPath,
      builder: (context, state) =>
          JournalEditorScreen(budgetId: state.pathParameters['id']!),
    ),
    GoRoute(
      name: journalEditRoute,
      path: journalEditPath,
      builder: (context, state) => JournalEditorScreen(
        budgetId: state.pathParameters['id']!,
        journalId: state.pathParameters['journalId'],
      ),
    ),
  ],
);

Future<void> _pumpEditor(
  WidgetTester tester,
  FakeLedgerRepository repository, {
  String? journalId,
  bool settle = true,
}) async {
  final container = ProviderContainer(
    overrides: [
      ledgerRepositoryProvider.overrideWithValue(repository),
      budgetDetailProvider.overrideWith((ref, id) async => testBudget()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: _router(journalId: journalId),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open editor'));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // The loading panel animates forever, so the caller pumps frames
    // instead of waiting for the tree to settle.
    await tester.pump();
    await tester.pump();
  }
}

/// The totals card sits below the fold on the 800x600 test surface because
/// the two line cards fill the screen first.
Future<void> _scrollToTotals(WidgetTester tester) => tester.scrollUntilVisible(
  find.byKey(const Key('journal-totals')),
  200,
  scrollable: find
      .byWidgetPredicate(
        (widget) => widget is Scrollable && widget.axis == Axis.vertical,
      )
      .first,
);

/// Selects [accountLabel] in the account dropdown of line [lineIndex].
///
/// Later lines start below the fold on the 800x600 test surface, so the
/// card is scrolled into view before the dropdown opens.
Future<void> _pickAccount(
  WidgetTester tester,
  int lineIndex,
  String accountLabel,
) async {
  final dropdown = find.byKey(Key('journal-line-account-$lineIndex'));
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(accountLabel).last);
  await tester.pumpAndSettle();
}

Future<void> _markCredit(WidgetTester tester, int lineIndex) async {
  final side = find.byKey(Key('journal-line-side-$lineIndex'));
  await tester.ensureVisible(side);
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: side, matching: find.text('Credit')),
  );
  await tester.pumpAndSettle();
}

/// Fills the two default lines into a balanced £50.00 journal.
Future<void> _fillBalanced(WidgetTester tester) async {
  await _pickAccount(tester, 0, '1000 Bank');
  await tester.enterText(
    find.byKey(const Key('journal-line-amount-0')),
    '50.00',
  );
  await _pickAccount(tester, 1, '4000 Sales');
  await _markCredit(tester, 1);
  await tester.ensureVisible(
    find.byKey(const Key('journal-line-amount-1')),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('journal-line-amount-1')),
    '50.00',
  );
  await tester.pumpAndSettle();
}

void main() {
  group('JournalEditorScreen', () {
    testWidgets('starts empty with validation issues and disabled buttons', (
      tester,
    ) async {
      await _pumpEditor(tester, FakeLedgerRepository());

      expect(find.text('New journal'), findsOneWidget);
      await _scrollToTotals(tester);
      expect(find.byKey(const Key('journal-totals')), findsOneWidget);
      expect(find.text('Debits'), findsOneWidget);
      expect(find.text('Credits'), findsOneWidget);
      expect(find.text('Difference'), findsOneWidget);
      expect(find.text('0.00'), findsNWidgets(3));
      expect(
        find.text('Line 1 needs a positive amount on one side.'),
        findsOneWidget,
      );
      expect(
        find.text('Line 2 needs a positive amount on one side.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal-balanced-chip')), findsNothing);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const Key('journal-save-draft')),
            )
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('journal-post-button')))
            .onPressed,
        isNull,
      );
    });

    testWidgets('goes balanced when debits match credits', (tester) async {
      await _pumpEditor(tester, FakeLedgerRepository());

      await _fillBalanced(tester);
      await _scrollToTotals(tester);

      expect(find.text('50.00'), findsNWidgets(4));
      expect(find.text('0.00'), findsOneWidget);
      expect(find.byKey(const Key('journal-balanced-chip')), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const Key('journal-save-draft')),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('journal-post-button')))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('shows the difference when the sides do not match', (
      tester,
    ) async {
      await _pumpEditor(tester, FakeLedgerRepository());

      await _pickAccount(tester, 0, '1000 Bank');
      await tester.enterText(
        find.byKey(const Key('journal-line-amount-0')),
        '50.00',
      );
      await _pickAccount(tester, 1, '4000 Sales');
      await _markCredit(tester, 1);
      await tester.enterText(
        find.byKey(const Key('journal-line-amount-1')),
        '40.00',
      );
      await tester.pumpAndSettle();
      await _scrollToTotals(tester);

      expect(find.text('Out of balance by £10.00'), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const Key('journal-save-draft')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('rejects amounts with too much precision', (tester) async {
      await _pumpEditor(tester, FakeLedgerRepository());

      await _fillBalanced(tester);
      await tester.enterText(
        find.byKey(const Key('journal-line-amount-0')),
        '50.001',
      );
      await tester.pumpAndSettle();
      await _scrollToTotals(tester);

      expect(
        find.text('Line 1 needs a positive amount on one side.'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const Key('journal-save-draft')),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('adds and removes lines', (tester) async {
      await _pumpEditor(tester, FakeLedgerRepository());

      await tester.scrollUntilVisible(
        find.byKey(const Key('journal-add-line')),
        200,
        scrollable: find
            .byWidgetPredicate(
              (widget) => widget is Scrollable && widget.axis == Axis.vertical,
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('journal-add-line')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-line-account-2')), findsOneWidget);
      expect(find.byKey(const Key('journal-line-remove-2')), findsOneWidget);

      await tester.tap(find.byKey(const Key('journal-line-remove-2')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-line-account-2')), findsNothing);
      expect(find.byKey(const Key('journal-line-account-1')), findsOneWidget);
      expect(find.byKey(const Key('journal-line-remove-1')), findsNothing);
    });

    testWidgets('saves a draft with one-sided lines in the budget currency', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpEditor(tester, repository);

      await tester.enterText(
        find.byKey(const Key('journal-reference-field')),
        'JB-2026-0099',
      );
      await tester.enterText(
        find.byKey(const Key('journal-narration-field')),
        'Client invoice',
      );
      await _fillBalanced(tester);
      await tester.tap(find.byKey(const Key('journal-save-draft')));
      await tester.pumpAndSettle();

      expect(repository.savedDrafts, hasLength(1));
      final saved = repository.savedDrafts.single;
      expect(saved.reference, 'JB-2026-0099');
      expect(saved.narration, 'Client invoice');
      expect(saved.source, 'manual');
      expect(saved.lines, hasLength(2));
      expect(saved.lines.first.debitMinor, 5000);
      expect(saved.lines.first.creditMinor, 0);
      expect(saved.lines.first.currencyCode, 'GBP');
      expect(saved.lines.first.exchangeRate, '1');
      expect(saved.lines.first.functionalDebitMinor, 5000);
      expect(saved.lines.last.creditMinor, 5000);
      expect(repository.postedJournals, isEmpty);
    });

    testWidgets('posts through a confirmation that posting is permanent', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpEditor(tester, repository);

      await _fillBalanced(tester);
      await tester.tap(find.byKey(const Key('journal-post-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-post-dialog')), findsOneWidget);
      expect(find.textContaining('cannot be edited'), findsOneWidget);

      await tester.tap(find.byKey(const Key('journal-post-confirm')));
      await tester.pumpAndSettle();

      expect(repository.savedDrafts, hasLength(1));
      expect(repository.postedJournals, hasLength(1));
    });

    testWidgets('canceling the post confirmation saves nothing', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpEditor(tester, repository);

      await _fillBalanced(tester);
      await tester.tap(find.byKey(const Key('journal-post-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.savedDrafts, isEmpty);
      expect(repository.postedJournals, isEmpty);
    });

    testWidgets('shows the server message when the save is rejected', (
      tester,
    ) async {
      await _pumpEditor(
        tester,
        FakeLedgerRepository(
          saveError: ValidationException(message: 'Books are locked.'),
        ),
      );

      await _fillBalanced(tester);
      await tester.tap(find.byKey(const Key('journal-save-draft')));
      await tester.pumpAndSettle();

      expect(find.text('Books are locked.'), findsOneWidget);
    });

    testWidgets('reopening a draft fills the rows and re-save replaces it', (
      tester,
    ) async {
      final repository = FakeLedgerRepository();
      await _pumpEditor(
        tester,
        repository,
        journalId: draftJournalId,
      );

      expect(find.text('Edit draft'), findsOneWidget);
      expect(find.byKey(const Key('journal-lines-loading')), findsNothing);
      expect(find.text('JB-2026-0002'), findsOneWidget);
      expect(find.text('Not finished'), findsOneWidget);
      expect(
        find.text(DateFormat.yMMMd().format(DateTime.utc(2026, 5, 14))),
        findsOneWidget,
      );
      expect(
        tester
            .widget<DropdownButtonFormField<String>>(
              find.byKey(const Key('journal-line-account-0')),
            )
            .initialValue,
        bankAccountId,
      );
      expect(
        tester
            .widget<SegmentedButton<bool>>(
              find.byKey(const Key('journal-line-side-0')),
            )
            .selected,
        {true},
      );
      expect(
        tester
            .widget<SegmentedButton<bool>>(
              find.byKey(const Key('journal-line-side-1')),
            )
            .selected,
        {false},
      );
      await _scrollToTotals(tester);
      expect(find.text('50.00'), findsNWidgets(4));
      expect(find.byKey(const Key('journal-balanced-chip')), findsOneWidget);

      await tester.tap(find.byKey(const Key('journal-save-draft')));
      await tester.pumpAndSettle();

      expect(repository.savedDrafts, hasLength(1));
      final saved = repository.savedDrafts.single;
      expect(saved.journalId, draftJournalId);
      expect(saved.reference, 'JB-2026-0002');
      expect(saved.narration, 'Not finished');
      expect(saved.lines, hasLength(2));
      expect(saved.lines.first.debitMinor, 5000);
      expect(saved.lines.last.creditMinor, 5000);
    });

    testWidgets('shows a loading state while the draft lines load', (
      tester,
    ) async {
      final repository = FakeLedgerRepository()
        ..linesCompleter = Completer<List<JournalLine>>();
      await _pumpEditor(
        tester,
        repository,
        journalId: draftJournalId,
        settle: false,
      );

      expect(find.byKey(const Key('journal-lines-loading')), findsOneWidget);
      expect(find.byKey(const Key('journal-line-account-0')), findsNothing);

      repository.linesCompleter!.complete(
        testJournalLines(journalId: draftJournalId),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-lines-loading')), findsNothing);
      expect(
        find.byKey(const Key('journal-line-account-0')),
        findsOneWidget,
      );
      await _scrollToTotals(tester);
      expect(find.text('50.00'), findsNWidgets(4));
    });

    testWidgets('shows a retryable problem panel when lines fail to load', (
      tester,
    ) async {
      final repository = FakeLedgerRepository(
        linesError: Exception('offline'),
      );
      await _pumpEditor(tester, repository, journalId: draftJournalId);

      expect(find.byKey(const Key('journal-lines-error')), findsOneWidget);
      expect(
        find.text("We couldn't load this journal's lines. Try again."),
        findsOneWidget,
      );
      expect(find.byKey(const Key('journal-line-account-0')), findsNothing);

      repository.linesError = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('journal-lines-error')), findsNothing);
      expect(
        find.byKey(const Key('journal-line-account-0')),
        findsOneWidget,
      );
    });
  });
}
