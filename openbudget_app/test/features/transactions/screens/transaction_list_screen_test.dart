import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';

import '../../../fixtures/budget_month.dart' hide testEntity;
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart';

const String _entityId = fixtureEntityId;

GoRouter _router() => GoRouter(
  initialLocation: transactionListPath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: planRoute,
      path: planPath,
      builder: (_, _) => const Scaffold(body: Text('Plan Route')),
    ),
    GoRoute(
      name: addIncomeRoute,
      path: addIncomePath,
      builder: (_, _) => const Scaffold(body: Text('Income Route')),
    ),
    GoRoute(
      name: addExpenseRoute,
      path: addExpensePath,
      builder: (_, _) => const Scaffold(body: Text('Expense Route')),
    ),
    GoRoute(
      name: createTransferRoute,
      path: createTransferPath,
      builder: (_, _) => const Scaffold(body: Text('Transfer Route')),
    ),
    GoRoute(
      name: transactionListRoute,
      path: transactionListPath,
      builder: (context, state) => TransactionListScreen(
        entityId: state.pathParameters['entityId']!,
      ),
    ),
  ],
);

/// The client every test starts from: a month view, one payee, one account
/// and the given page of transactions.
FakeEndpointClient _client({
  required List<TransactionView> items,
  String? nextCursor,
  BudgetMonthView? monthView,
  FutureOr<TransactionPage> Function(Map<String, dynamic> args)? pageFor,
}) {
  final client = FakeEndpointClient()
    ..handle('entity', 'get', (_) => testEntity())
    ..handle('budget', 'getMonth', (_) => monthView ?? testMonthView())
    ..handle('payee', 'list', (_) => [testPayee()])
    ..handle('account', 'list', (_) => [testAccount()])
    ..handle(
      'transaction',
      'list',
      pageFor ?? (_) => TransactionPage(items: items, nextCursor: nextCursor),
    );
  return client;
}

Future<void> _pumpList(WidgetTester tester, FakeEndpointClient client) async {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: _router(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
}

TransactionView _expense({
  String id = fixtureTransactionId,
  String description = 'Groceries',
  int amountMinor = -1234,
  DateTime? date,
  TransactionStatus status = TransactionStatus.uncleared,
  TransactionFlag? flag,
  String? memo,
}) => testTransactionView(
  transaction: testTransaction(
    id: id,
    date: date,
    description: description,
    amountMinor: amountMinor,
    status: status,
    flag: flag,
    memo: memo,
  ),
);

void main() {
  group('TransactionListScreen', () {
    testWidgets('shows a loading panel while the first page loads', (
      tester,
    ) async {
      final completer = Completer<TransactionPage>();
      final client = _client(items: const [], pageFor: (_) => completer.future);
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);
      await tester.pumpApp(
        const SizedBox.shrink(),
        container: container,
        router: _router(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pump();

      expect(find.text('Loading transactions'), findsOneWidget);

      completer.complete(TransactionPage(items: const []));
      await tester.pumpAndSettle();
    });

    testWidgets('shows the title, a back action and the empty state', (
      tester,
    ) async {
      await _pumpList(tester, _client(items: const []));

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byKey(transactionListEmptyKey), findsOneWidget);
      expect(find.text('No transactions yet'), findsOneWidget);
    });

    testWidgets('shows the rows and the result count', (tester) async {
      await _pumpList(
        tester,
        _client(
          items: [
            _expense(),
            _expense(
              id: '00000000-0000-0000-0000-0000000000f111',
              description: 'Salary',
              amountMinor: 200000,
            ),
          ],
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('2 results'), findsOneWidget);
      expect(find.text('-£12.34'), findsOneWidget);
      expect(find.text('£2,000.00'), findsOneWidget);
    });

    testWidgets('shows the base amount for a foreign-currency row', (
      tester,
    ) async {
      await _pumpList(
        tester,
        _client(
          items: [
            testTransactionView(
              transaction: testTransaction(amountMinor: -5000),
              accountCurrencyCode: 'USD',
              accountName: 'Dollar account',
            ),
          ],
        ),
      );

      expect(find.text(r'-$50.00'), findsOneWidget);
      expect(find.text('≈ -£50.00 in base currency'), findsOneWidget);
    });

    testWidgets('shows a date group header', (tester) async {
      await _pumpList(
        tester,
        _client(items: [_expense(date: DateTime.now())]),
      );

      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows memo, envelope and status chips on a row', (
      tester,
    ) async {
      await _pumpList(
        tester,
        _client(
          items: [
            _expense(
              memo: 'Weekly shop',
              status: TransactionStatus.cleared,
              flag: TransactionFlag.red,
            ),
          ],
          monthView: testMonthView(
            envelopes: [testEnvelopeRow(envelopeName: 'Food')],
          ),
        ),
      );

      expect(find.text('Weekly shop'), findsOneWidget);
      expect(find.text('Cleared'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);
      expect(find.textContaining('Food'), findsOneWidget);
    });

    testWidgets('shows the problem panel and retries the page', (
      tester,
    ) async {
      var attempts = 0;
      final client = _client(
        items: const [],
        pageFor: (_) {
          attempts++;
          if (attempts == 1) throw StateError('offline');
          return TransactionPage(items: [_expense()]);
        },
      );
      await _pumpList(tester, client);

      expect(find.text('Could not load transactions'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('searches through the query and shows no results', (
      tester,
    ) async {
      final client = _client(items: [_expense()]);
      await _pumpList(tester, client);

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'Search description or memo...',
        ),
        'rent',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('No matching transactions'), findsOneWidget);
      final query =
          client.callsTo('transaction', 'list').last.args['query']
              as TransactionQuery;
      expect(query.search, 'rent');
    });

    testWidgets('the clear button resets the search', (tester) async {
      await _pumpList(tester, _client(items: [_expense()]));

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'Search description or memo...',
        ),
        'rent',
      );
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('transaction-search-clear')), findsOneWidget);

      await tester.tap(find.byKey(const Key('transaction-search-clear')));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('filters by income and by expense', (tester) async {
      await _pumpList(
        tester,
        _client(
          items: [
            _expense(),
            _expense(
              id: '00000000-0000-0000-0000-0000000000f111',
              description: 'Salary',
              amountMinor: 200000,
            ),
          ],
        ),
      );

      await tester.tap(find.widgetWithText(FilterChip, 'Income'));
      await tester.pumpAndSettle();
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Groceries'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'Expense'));
      await tester.pumpAndSettle();
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      await tester.tap(find.widgetWithText(FilterChip, 'All'));
      await tester.pumpAndSettle();
      expect(find.text('1 result'), findsNothing);
      expect(find.text('2 results'), findsOneWidget);
    });

    testWidgets('the status chip sends a status query', (tester) async {
      final client = _client(items: [_expense()]);
      await _pumpList(tester, client);

      await tester.drag(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is ListView &&
                  widget.scrollDirection == Axis.horizontal,
            )
            .first,
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Status'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cleared').last);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      final query =
          client.callsTo('transaction', 'list').last.args['query']
              as TransactionQuery;
      expect(query.status, TransactionStatus.cleared);
    });

    testWidgets('the flag chip opens the flag picker', (tester) async {
      final client = _client(items: [_expense()]);
      await _pumpList(tester, client);

      await tester.tap(find.widgetWithText(FilterChip, 'Flagged'));
      await tester.pumpAndSettle();

      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
    });

    testWidgets('shows the app bar actions only when rows exist', (
      tester,
    ) async {
      await _pumpList(tester, _client(items: [_expense()]));

      expect(find.byTooltip('Sort by'), findsOneWidget);
      expect(find.byTooltip('Assign Envelope'), findsOneWidget);
      expect(find.byTooltip('Copy as CSV'), findsOneWidget);
    });

    testWidgets('the FAB opens the add transaction sheet', (tester) async {
      await _pumpList(tester, _client(items: [_expense()]));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);

      await tester.tap(find.text('Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Expense Route'), findsOneWidget);
    });

    testWidgets('the sheet opens the transfer form', (tester) async {
      await _pumpList(tester, _client(items: [_expense()]));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Route'), findsOneWidget);
    });

    testWidgets('selection mode selects, deselects and closes', (
      tester,
    ) async {
      await _pumpList(
        tester,
        _client(
          items: [
            _expense(),
            _expense(
              id: '00000000-0000-0000-0000-0000000000f112',
              description: 'Coffee',
              amountMinor: -450,
            ),
          ],
        ),
      );

      await tester.tap(find.byTooltip('Assign Envelope'));
      await tester.pumpAndSettle();

      expect(find.text('0 selected'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));

      await tester.tap(find.byTooltip('Select All'));
      await tester.pumpAndSettle();
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Deselect All'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('the bulk bar appears once a row is selected and delete asks '
        'first', (tester) async {
      final client = _client(items: [_expense()]);
      await _pumpList(tester, client);

      await tester.tap(find.byTooltip('Assign Envelope'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byKey(const Key('bulk-delete-button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bulk-delete-button')));
      await tester.pumpAndSettle();

      expect(find.text('Delete Transactions'), findsOneWidget);
      expect(
        find.text('Delete 1 transaction? This cannot be undone.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Delete Transactions'), findsNothing);
      expect(client.callsTo('transaction', 'delete'), isEmpty);
    });

    testWidgets('the sort menu lists every order', (tester) async {
      await _pumpList(tester, _client(items: [_expense()]));

      await tester.tap(find.byTooltip('Sort by'));
      await tester.pumpAndSettle();

      expect(find.text('Date (newest first)'), findsOneWidget);
      expect(find.text('Date (oldest first)'), findsOneWidget);
      expect(find.text('Amount (highest first)'), findsOneWidget);
      expect(find.text('Amount (lowest first)'), findsOneWidget);
      expect(find.text('Description (A-Z)'), findsOneWidget);
    });

    testWidgets('tapping the status glyph clears the transaction', (
      tester,
    ) async {
      final client = _client(items: [_expense()])
        ..handle('transaction', 'setStatus', (_) => 1);
      await _pumpList(tester, client);

      await tester.tap(find.byTooltip('Uncleared'));
      await tester.pumpAndSettle();

      final call = client.callsTo('transaction', 'setStatus').single;
      expect(call.args['status'], TransactionStatus.cleared);
      expect(
        [
          for (final id in call.args['transactionIds'] as List<UuidValue>)
            id.toString(),
        ],
        [fixtureTransactionId],
      );
    });

    testWidgets('long-pressing a row flags it', (tester) async {
      final client = _client(items: [_expense()])
        ..handle('transaction', 'setFlag', (_) => 1);
      await _pumpList(tester, client);

      await tester.longPress(find.text('Groceries'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Red'));
      await tester.pumpAndSettle();

      final call = client.callsTo('transaction', 'setFlag').single;
      expect(call.args['flag'], TransactionFlag.red);
    });

    testWidgets('swiping a row asks before deleting it', (tester) async {
      final items = [_expense()];
      final client =
          _client(
            items: const [],
            pageFor: (_) => TransactionPage(items: List.of(items)),
          )..handle('transaction', 'delete', (_) {
            items.clear();
            return null;
          });
      await _pumpList(tester, client);

      await tester.drag(find.text('Groceries'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsNWidgets(2));
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(client.callsTo('transaction', 'delete'), hasLength(1));
    });

    testWidgets('loads the next page from the cursor', (tester) async {
      var calls = 0;
      final client = _client(
        items: const [],
        pageFor: (_) {
          calls++;
          if (calls == 1) {
            return TransactionPage(
              items: [_expense()],
              nextCursor: 'cursor-2',
            );
          }
          return TransactionPage(
            items: [
              _expense(
                id: '00000000-0000-0000-0000-0000000000f112',
                description: 'Coffee',
                amountMinor: -450,
              ),
            ],
          );
        },
      );
      await _pumpList(tester, client);

      await tester.tap(find.text('Load more'));
      await tester.pumpAndSettle();

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Load more'), findsNothing);
      final query =
          client.callsTo('transaction', 'list').last.args['query']
              as TransactionQuery;
      expect(query.cursor, 'cursor-2');
    });

    testWidgets('opens the edit dialog from a row', (tester) async {
      final client = _client(items: [_expense()])
        ..handle('transaction', 'update', (_) => testTransactionView());
      await _pumpList(tester, client);

      await tester.tap(find.text('Groceries'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsOneWidget);
    });
  });
}
