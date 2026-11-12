import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart' as fake;

const String _entityId = fixtureEntityId;
const String _usdAccountId = '00000000-0000-0000-0000-0000000000f0a1';
const String _jpyAccountId = '00000000-0000-0000-0000-0000000000f0a2';

/// Captures the input the form submits.
class _RecordingActions extends TransactionActions {
  TransactionInput? created;
  String? createdEntityId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<TransactionView> create({
    required TransactionInput input,
    required String entityId,
  }) async {
    created = input;
    createdEntityId = entityId;
    return testTransactionView(
      transaction: testTransaction(
        accountId: input.accountId.toString(),
        amountMinor: input.amountMinor,
      ),
    );
  }
}

GoRouter _router() => GoRouter(
  initialLocation: addExpensePath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: planRoute,
      path: planPath,
      builder: (_, _) => const Scaffold(body: Text('Plan Route')),
    ),
    GoRoute(
      name: addIncomeRoute,
      path: addIncomePath,
      builder: (_, _) => const Scaffold(body: Text('Add Income Route')),
    ),
    GoRoute(
      name: addExpenseRoute,
      path: addExpensePath,
      builder: (context, state) =>
          AddExpenseScreen(entityId: state.pathParameters['entityId']!),
    ),
  ],
);

/// Pumps the expense form over stubbed providers.
Future<_RecordingActions> _pumpExpense(
  WidgetTester tester, {
  List<Account>? accounts,
  List<Payee>? payees,
  BudgetMonthView? monthView,
  FxQuoteView? quote,
  Exception? quoteError,
  List<TransactionView> duplicates = const [],
  bool routed = false,
}) async {
  final actions = _RecordingActions();
  final container = ProviderContainer(
    // Failed quotes stay failed instead of retrying on a timer.
    retry: (_, _) => null,
    overrides: [
      entityDetailProvider.overrideWith(
        (ref, id) async => testEntity(),
      ),
      accountListProvider.overrideWith(
        (ref, id) async => accounts ?? [testAccount()],
      ),
      payeeListProvider.overrideWith((ref, id) async => payees ?? const []),
      budgetMonthProvider.overrideWith(
        (ref, id) async => monthView ?? testMonthView(),
      ),
      duplicateCheckProvider.overrideWith(
        (ref, args) async => duplicates,
      ),
      serverpodClientProvider.overrideWithValue(
        fake.FakeEndpointClient()..handle('fxRate', 'quote', (_) {
          if (quoteError != null) throw quoteError;
          return quote ?? testFxQuote();
        }),
      ),
      transactionActionsProvider.overrideWith(() => actions),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    routed
        ? const SizedBox.shrink()
        : const AddExpenseScreen(entityId: _entityId),
    container: container,
    router: routed ? _router() : null,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return actions;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _enterLine(WidgetTester tester, int index, String text) async {
  final field = find.byKey(ValueKey('line-amount-$index'));
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

Future<void> _tapBelowFold(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save Transaction'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save Transaction'));
  await tester.pumpAndSettle();
}

void main() {
  group('AddExpenseScreen', () {
    testWidgets('renders a scaffold while the accounts load', (tester) async {
      await tester.pumpApp(
        const AddExpenseScreen(entityId: _entityId),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows the transaction title, expense mode and cancel', (
      tester,
    ) async {
      await _pumpExpense(tester, routed: true);

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Expense'), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.outflow,
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('shows description, amount, payee, envelope and memo fields', (
      tester,
    ) async {
      await _pumpExpense(tester, payees: [testPayee()]);

      expect(_field('Description'), findsOneWidget);
      expect(_field('Amount'), findsOneWidget);
      expect(_field('Memo'), findsOneWidget);
      expect(find.text('Add a note (optional)'), findsOneWidget);
      expect(find.text('Payee'), findsOneWidget);
      expect(find.text('No Payee'), findsOneWidget);
      expect(find.text('Unassigned'), findsNWidgets(2));
    });

    testWidgets('lists the entity payees in the payee dropdown', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        payees: [
          testPayee(),
          testPayee(id: fixtureSecondPayeeId, name: 'Coffee Shop'),
        ],
      );

      await tester.tap(find.text('No Payee'));
      await tester.pumpAndSettle();

      expect(find.text('Tesco'), findsOneWidget);
      expect(find.text('Coffee Shop'), findsOneWidget);
    });

    testWidgets('list the month envelopes under their category', (
      tester,
    ) async {
      await _pumpExpense(tester);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> && widget.labelText == 'Unassigned',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Living / Groceries'), findsOneWidget);
    });

    testWidgets('saves 12.34 as -1234 minor units on the account', (
      tester,
    ) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Coffee');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(actions.created, isNotNull);
      expect(actions.created!.amountMinor, -1234);
      expect(actions.created!.accountId.toString(), fixtureAccountId);
      expect(actions.createdEntityId, _entityId);
      expect(actions.created!.fxRate, isNull);
      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('refuses an over-precise amount instead of rounding it', (
      tester,
    ) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Coffee');
      await tester.enterText(_field('Amount'), '12.345');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);

      expect(actions.created, isNull);
    });

    testWidgets('refuses a negative expense amount', (tester) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Coffee');
      await tester.enterText(_field('Amount'), '-12.34');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);

      expect(actions.created, isNull);
    });

    testWidgets('shows the amount hint in a zero-decimal currency', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _jpyAccountId,
            currencyCode: 'JPY',
          ),
        ],
        monthView: testMonthView(currencyCode: 'JPY'),
      );

      expect(find.textContaining('-¥0'), findsAtLeast(1));
    });

    testWidgets('a zero-decimal amount field refuses a decimal point', (
      tester,
    ) async {
      final actions = await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _jpyAccountId,
            currencyCode: 'JPY',
          ),
        ],
        monthView: testMonthView(currencyCode: 'JPY'),
        routed: true,
      );

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '1500.5');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 0 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);
      expect(actions.created, isNull);

      await tester.enterText(_field('Amount'), '1500');
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(actions.created!.amountMinor, -1500);
    });

    testWidgets('a currency with decimals offers the decimal key', (
      tester,
    ) async {
      await _pumpExpense(tester);
      final pounds = tester.widget<TextField>(_field('Amount'));
      expect(pounds.keyboardType.decimal, isTrue);
    });

    testWidgets('a zero-decimal currency offers no decimal key', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _jpyAccountId,
            currencyCode: 'JPY',
          ),
        ],
        monthView: testMonthView(currencyCode: 'JPY'),
      );
      final yen = tester.widget<TextField>(_field('Amount'));
      expect(yen.keyboardType.decimal, isFalse);
    });

    testWidgets('shows a duplicate warning when similar transactions exist', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        duplicates: [testTransactionView()],
      );

      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await tester.ensureVisible(_field('Description'));
      await tester.pumpAndSettle();
      await tester.tap(_field('Description'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Description'), 'Groceries');
      await tester.pumpAndSettle();

      expect(
        find.text('Possible duplicate: 1 similar transaction found'),
        findsOneWidget,
      );
    });

    testWidgets('cancel goes back to the plan', (tester) async {
      await _pumpExpense(tester, routed: true);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('the income chip swaps to the income form', (tester) async {
      await _pumpExpense(tester, routed: true);

      await tester.tap(find.text('Add Income'));
      await tester.pumpAndSettle();

      expect(find.text('Add Income Route'), findsOneWidget);
    });

    testWidgets('shows the live FX line for a foreign account', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _usdAccountId,
            currencyCode: 'USD',
          ),
        ],
        quote: testFxQuote(
          // The quote's own rate date, not the transaction date.
          rateDate: DateTime.utc(2026, 11, 6),
        ),
      );

      await tester.enterText(_field('Amount'), '100');
      await tester.pumpAndSettle();

      final line = find.textContaining('1 USD = 0.7891 GBP');
      expect(line, findsOneWidget);
      final text = tester.widget<Text>(line).data!;
      expect(text, contains('≈ £78.91'));
      expect(text, contains('6 Nov 2026'));
      expect(text, contains('market'));
      expect(find.widgetWithText(TextButton, 'Set rate'), findsOneWidget);
    });

    testWidgets('the manual rate sheet carries the typed rate', (
      tester,
    ) async {
      final actions = await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _usdAccountId,
            currencyCode: 'USD',
          ),
        ],
        routed: true,
      );

      await tester.enterText(_field('Amount'), '100');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Set rate'));
      await tester.pumpAndSettle();

      expect(find.text('Use your own rate'), findsOneWidget);
      expect(find.text('1 USD = ? GBP'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Exchange rate'),
        '0',
      );
      await tester.tap(find.text('Use this rate'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a positive rate, e.g. 0.79'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Exchange rate'),
        '0.8',
      );
      await tester.tap(find.text('Use this rate'));
      await tester.pumpAndSettle();
      expect(find.text('Use your own rate'), findsNothing);

      await tester.enterText(_field('Description'), 'Coffee');
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(actions.created!.fxRate, '0.8');
      expect(actions.created!.amountMinor, -10000);
    });

    testWidgets('a missing rate explains itself and opens the rate sheet', (
      tester,
    ) async {
      await _pumpExpense(
        tester,
        accounts: [
          testAccount(
            id: _usdAccountId,
            currencyCode: 'USD',
          ),
        ],
        quoteError: FxRateUnavailableException(
          message: 'No USD to GBP rate for 8 Nov 2026',
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          date: DateTime.utc(2026, 11, 8),
        ),
      );

      await tester.enterText(_field('Amount'), '100');
      await tester.pumpAndSettle();

      expect(find.text('No USD to GBP rate for 8 Nov 2026'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Set rate'));
      await tester.pumpAndSettle();

      expect(find.text('Use your own rate'), findsOneWidget);
      expect(find.text('No USD to GBP rate for 8 Nov 2026'), findsWidgets);
    });
  });

  group('the expense lines editor (replaces the deleted split screen)', () {
    testWidgets('splits an amount into exact minor units', (tester) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();

      await _tapBelowFold(tester, find.text('Split into lines'));

      expect(find.text('Lines'), findsOneWidget);
      expect(find.byKey(const ValueKey('line-amount-0')), findsOneWidget);

      await _tapBelowFold(tester, find.text('Add a line'));
      expect(find.byKey(const ValueKey('line-amount-1')), findsOneWidget);

      await _enterLine(tester, 0, '6.17');
      await _enterLine(tester, 1, '6.17');

      await _tapSave(tester);

      expect(actions.created, isNotNull);
      expect(
        [for (final line in actions.created!.lines) line.amountMinor],
        [-617, -617],
      );
      expect(
        actions.created!.lines.fold<int>(
          0,
          (sum, line) => sum + line.amountMinor,
        ),
        actions.created!.amountMinor,
      );
    });

    testWidgets('will not save while the lines do not sum exactly', (
      tester,
    ) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapBelowFold(tester, find.text('Split into lines'));

      await _tapBelowFold(tester, find.text('Add a line'));

      await _enterLine(tester, 0, '6.17');

      expect(find.text('£6.17 left to allocate'), findsOneWidget);
      await _tapSave(tester);
      expect(actions.created, isNull);

      await _enterLine(tester, 1, '6.16');
      expect(find.text('£0.01 left to allocate'), findsOneWidget);
      await _tapSave(tester);
      expect(actions.created, isNull);

      await _enterLine(tester, 1, '6.17');
      expect(find.textContaining('left to allocate'), findsNothing);
      await _tapSave(tester);
      expect(actions.created, isNotNull);
    });

    testWidgets('refuses an over-precise line instead of rounding it', (
      tester,
    ) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapBelowFold(tester, find.text('Split into lines'));

      await _enterLine(tester, 0, '12.345');

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);
      expect(actions.created, isNull);

      await _enterLine(tester, 0, '12.34');
      await _tapSave(tester);

      expect(actions.created, isNotNull);
      expect(
        [for (final line in actions.created!.lines) line.amountMinor],
        [-1234],
      );
    });

    testWidgets('refuses a negative line', (tester) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapBelowFold(tester, find.text('Split into lines'));

      await _enterLine(tester, 0, '-12.34');

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);

      expect(actions.created, isNull);
    });

    testWidgets('assigns a line to an envelope', (tester) async {
      final actions = await _pumpExpense(tester, routed: true);

      await tester.enterText(_field('Description'), 'Lunch');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapBelowFold(tester, find.text('Split into lines'));

      await _tapBelowFold(
        tester,
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tester.tap(find.text('Living / Groceries').last);
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(
        actions.created!.lines.single.envelopeId.toString(),
        fixtureEnvelopeId,
      );
    });
  });
}
