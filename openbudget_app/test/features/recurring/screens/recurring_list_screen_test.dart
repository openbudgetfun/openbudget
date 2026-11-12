import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart';

const String _entityId = fixtureEntityId;
const String _usdAccountId = '00000000-0000-0000-0000-0000000000f0d1';

GoRouter _router() => GoRouter(
  initialLocation: recurringListPath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: recurringCalendarRoute,
      path: recurringCalendarPath,
      builder: (_, _) => const Scaffold(body: Text('Calendar Route')),
    ),
    GoRoute(
      name: recurringListRoute,
      path: recurringListPath,
      builder: (context, state) =>
          RecurringListScreen(entityId: state.pathParameters['entityId']!),
    ),
  ],
);

class _Harness {
  _Harness(this.client);

  final FakeEndpointClient client;
}

Future<_Harness> _pumpRecurring(
  WidgetTester tester, {
  List<RecurringTransaction>? items,
  List<Account>? accounts,
  bool failToLoad = false,
}) async {
  final list = items ?? [_recurring()];
  final client = FakeEndpointClient()
    ..handle('recurringTransaction', 'list', (_) {
      if (failToLoad) throw StateError('offline');
      return list;
    })
    ..handle('budget', 'getMonth', (_) => testMonthView())
    ..handle('account', 'list', (_) => accounts ?? [testAccount()])
    ..handle('recurringTransaction', 'create', (_) => _recurring())
    ..handle('recurringTransaction', 'update', (_) => _recurring())
    ..handle('recurringTransaction', 'skipOccurrence', (_) => _recurring())
    ..handle('recurringTransaction', 'delete', (_) => _recurring());
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
  return _Harness(client);
}

RecurringTransaction _recurring({
  String id = fixtureRecurringId,
  String accountId = fixtureAccountId,
  String description = 'Rent',
  int amountMinor = -120000,
  RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
  DateTime? nextDate,
  bool isActive = true,
}) => testRecurring(
  id: id,
  accountId: accountId,
  description: description,
  amountMinor: amountMinor,
  frequency: frequency,
  nextDate: nextDate,
  isActive: isActive,
);

void main() {
  group('RecurringListScreen', () {
    testWidgets('renders the loading panel while the schedule loads', (
      tester,
    ) async {
      await tester.pumpApp(
        const RecurringListScreen(entityId: _entityId),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pump();

      expect(find.text('Fetching the schedule…'), findsOneWidget);
    });

    testWidgets('renders the problem panel when loading fails', (
      tester,
    ) async {
      await _pumpRecurring(tester, failToLoad: true);

      expect(
        find.text('Could not load recurring transactions'),
        findsOneWidget,
      );
    });

    testWidgets('renders the empty state with an add action', (tester) async {
      await _pumpRecurring(tester, items: const []);

      expect(find.text('No Recurring Transactions'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Add Recurring'),
        findsOneWidget,
      );
    });

    testWidgets('lists the descriptions, frequency and next date', (
      tester,
    ) async {
      await _pumpRecurring(
        tester,
        items: [
          _recurring(),
          _recurring(
            id: '00000000-0000-0000-0000-0000000000f0d2',
            description: 'Salary',
            amountMinor: 250000,
            frequency: RecurrenceFrequency.yearly,
            nextDate: DateTime.utc(2027, 2, 2),
          ),
        ],
      );

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.textContaining('Monthly'), findsOneWidget);
      expect(find.textContaining('Yearly'), findsOneWidget);
      expect(find.textContaining('2026-11-15'), findsOneWidget);
      expect(find.textContaining('2027-02-02'), findsOneWidget);
    });

    testWidgets('shows the title, add and calendar actions', (tester) async {
      final harness = await _pumpRecurring(tester);

      expect(find.text('Recurring Transactions'), findsOneWidget);
      expect(find.byKey(RecurringListScreen.addButtonKey), findsOneWidget);
      expect(find.byKey(RecurringListScreen.calendarButtonKey), findsOneWidget);

      await tester.tap(find.byKey(RecurringListScreen.calendarButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Calendar Route'), findsOneWidget);
      expect(
        harness.client.callsTo('recurringTransaction', 'list'),
        hasLength(1),
      );
    });

    testWidgets('toggles a schedule through update', (tester) async {
      final harness = await _pumpRecurring(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final call = harness.client
          .callsTo('recurringTransaction', 'update')
          .single;
      expect(call.args['isActive'], isFalse);
    });

    testWidgets('shows the paused chip for an inactive schedule', (
      tester,
    ) async {
      await _pumpRecurring(tester, items: [_recurring(isActive: false)]);

      expect(find.text('Paused'), findsOneWidget);
    });

    testWidgets('shows the summary card and filter chips', (tester) async {
      await _pumpRecurring(tester);

      expect(find.text('Scheduled totals'), findsOneWidget);
      expect(find.text('1 recurring transaction'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Expense'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Income'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Due now'), findsOneWidget);
    });

    testWidgets('shows a multi-currency total per account currency', (
      tester,
    ) async {
      await _pumpRecurring(
        tester,
        items: [
          _recurring(),
          _recurring(
            id: '00000000-0000-0000-0000-0000000000f0d3',
            description: 'Streaming',
            amountMinor: -1500,
          ),
          _recurring(
            id: '00000000-0000-0000-0000-0000000000f0d4',
            accountId: _usdAccountId,
            description: 'US bill',
            amountMinor: -5000,
          ),
        ],
        accounts: [
          testAccount(),
          testAccount(
            id: _usdAccountId,
            name: 'Dollar account',
            currencyCode: 'USD',
          ),
        ],
      );

      expect(find.text(r'GBP £1,215.00 · USD $50.00'), findsOneWidget);
    });

    testWidgets('filters by expense and income', (tester) async {
      await _pumpRecurring(
        tester,
        items: [
          _recurring(),
          _recurring(
            id: '00000000-0000-0000-0000-0000000000f0d2',
            description: 'Salary',
            amountMinor: 250000,
          ),
        ],
      );

      await tester.tap(find.widgetWithText(ChoiceChip, 'Expense'));
      await tester.pumpAndSettle();
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Salary'), findsNothing);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
      await tester.pumpAndSettle();
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Rent'), findsNothing);
    });

    testWidgets('shows a skip action on a due schedule', (tester) async {
      final harness = await _pumpRecurring(
        tester,
        items: [
          _recurring(
            nextDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );

      expect(find.text('Due now'), findsWidgets);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(
        harness.client.callsTo('recurringTransaction', 'skipOccurrence'),
        hasLength(1),
      );
    });

    testWidgets('deletes a schedule after confirmation', (tester) async {
      final harness = await _pumpRecurring(tester);

      await tester.drag(find.text('Rent'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ObFilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(
        harness.client
            .callsTo('recurringTransaction', 'delete')
            .single
            .args['recurringTransactionId']
            .toString(),
        fixtureRecurringId,
      );
    });

    testWidgets('the add dialog works from the empty state', (tester) async {
      await _pumpRecurring(tester, items: const []);

      await tester.tap(find.text('Add Recurring'));
      await tester.pumpAndSettle();

      expect(find.text('Add Recurring Transaction'), findsOneWidget);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> && widget.labelText == 'Account',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current account').last, findsOneWidget);
    });

    group('add recurring amount entry', () {
      Future<void> openAddDialog(WidgetTester tester) async {
        await tester.tap(find.byKey(RecurringListScreen.addButtonKey));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is ObDropdown<String> && widget.labelText == 'Account',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Current account').last);
        await tester.pumpAndSettle();
      }

      testWidgets('saves 12.34 as 1234 minor units', (tester) async {
        final harness = await _pumpRecurring(tester);
        await openAddDialog(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Description'),
          'Gym',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Amount (GBP)'),
          '12.34',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
        await tester.pumpAndSettle();

        final call = harness.client
            .callsTo('recurringTransaction', 'create')
            .single;
        expect(call.args['amountMinor'], -1234);
        expect(call.args['description'], 'Gym');
        expect(call.args['frequency'], RecurrenceFrequency.monthly);
        expect(call.args['accountId'].toString(), fixtureAccountId);
      });

      testWidgets('refuses an over-precise amount instead of rounding it', (
        tester,
      ) async {
        final harness = await _pumpRecurring(tester);
        await openAddDialog(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Description'),
          'Gym',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Amount (GBP)'),
          '12.345',
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Enter a valid amount with at most 2 decimal places'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(
          harness.client.callsTo('recurringTransaction', 'create'),
          isEmpty,
        );
      });

      testWidgets('refuses a negative recurring amount', (tester) async {
        final harness = await _pumpRecurring(tester);
        await openAddDialog(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Description'),
          'Gym',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Amount (GBP)'),
          '-12.34',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(
          harness.client.callsTo('recurringTransaction', 'create'),
          isEmpty,
        );
      });

      testWidgets('saves an income schedule as a positive amount', (
        tester,
      ) async {
        final harness = await _pumpRecurring(tester);
        await openAddDialog(tester);

        await tester.enterText(
          find.widgetWithText(TextField, 'Description'),
          'Salary',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Amount (GBP)'),
          '2500',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(SegmentedButton<bool>),
            matching: find.text('Income'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(
          harness.client
              .callsTo('recurringTransaction', 'create')
              .single
              .args['amountMinor'],
          250000,
        );
      });
    });
  });
}
