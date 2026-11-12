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
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';

const String _entityId = fixtureEntityId;
const String _jpyAccountId = '00000000-0000-0000-0000-0000000000f0b1';

class _RecordingActions extends TransactionActions {
  TransactionInput? created;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<TransactionView> create({
    required TransactionInput input,
    required String entityId,
  }) async {
    created = input;
    return testTransactionView(
      transaction: testTransaction(
        accountId: input.accountId.toString(),
        amountMinor: input.amountMinor,
      ),
    );
  }
}

GoRouter _router() => GoRouter(
  initialLocation: addIncomePath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: planRoute,
      path: planPath,
      builder: (_, _) => const Scaffold(body: Text('Plan Route')),
    ),
    GoRoute(
      name: addExpenseRoute,
      path: addExpensePath,
      builder: (_, _) => const Scaffold(body: Text('Add Expense Route')),
    ),
    GoRoute(
      name: addIncomeRoute,
      path: addIncomePath,
      builder: (context, state) =>
          AddIncomeScreen(entityId: state.pathParameters['entityId']!),
    ),
  ],
);

Future<_RecordingActions> _pumpIncome(
  WidgetTester tester, {
  List<Account>? accounts,
  List<Payee>? payees,
  bool routed = false,
}) async {
  final actions = _RecordingActions();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      entityDetailProvider.overrideWith((ref, id) async => testEntity()),
      accountListProvider.overrideWith(
        (ref, id) async => accounts ?? [testAccount()],
      ),
      payeeListProvider.overrideWith((ref, id) async => payees ?? const []),
      budgetMonthProvider.overrideWith((ref, id) async => testMonthView()),
      duplicateCheckProvider.overrideWith(
        (ref, args) async => const <TransactionView>[],
      ),
      transactionActionsProvider.overrideWith(() => actions),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    routed
        ? const SizedBox.shrink()
        : const AddIncomeScreen(entityId: _entityId),
    container: container,
    router: routed ? _router() : null,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return actions;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save Transaction'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save Transaction'));
  await tester.pumpAndSettle();
}

void main() {
  group('AddIncomeScreen', () {
    testWidgets('renders a scaffold while the accounts load', (tester) async {
      await tester.pumpApp(
        const AddIncomeScreen(entityId: _entityId),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows the income mode and the transaction title', (
      tester,
    ) async {
      await _pumpIncome(tester);

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Income'), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.inflow,
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('shows the description, amount, payee and memo fields', (
      tester,
    ) async {
      await _pumpIncome(tester, payees: [testPayee()]);

      expect(_field('Description'), findsOneWidget);
      expect(_field('Amount'), findsOneWidget);
      expect(_field('Memo'), findsOneWidget);
      expect(find.text('Add a note (optional)'), findsOneWidget);
      expect(find.text('Payee'), findsOneWidget);
      expect(find.text('No Payee'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Ready to Assign'), findsOneWidget);
      expect(find.text('Current account (GBP)'), findsOneWidget);
    });

    testWidgets('shows today in the date row and opens a date picker', (
      tester,
    ) async {
      await _pumpIncome(tester);
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}'
          '-${now.day.toString().padLeft(2, '0')}';
      expect(find.text(today), findsOneWidget);

      await tester.tap(find.text(today));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('lists the payees in the payee dropdown', (tester) async {
      await _pumpIncome(
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

    testWidgets('saves 12.34 as +1234 minor units', (tester) async {
      final actions = await _pumpIncome(tester, routed: true);

      await tester.enterText(_field('Description'), 'Salary');
      await tester.enterText(_field('Amount'), '12.34');
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(actions.created!.amountMinor, 1234);
      expect(actions.created!.accountId.toString(), fixtureAccountId);
      expect(actions.created!.lines, isEmpty);
      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('refuses an over-precise amount instead of rounding it', (
      tester,
    ) async {
      final actions = await _pumpIncome(tester, routed: true);

      await tester.enterText(_field('Description'), 'Salary');
      await tester.enterText(_field('Amount'), '12.345');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
      await _tapSave(tester);

      expect(actions.created, isNull);
    });

    testWidgets('refuses a negative income amount', (tester) async {
      final actions = await _pumpIncome(tester, routed: true);

      await tester.enterText(_field('Description'), 'Salary');
      await tester.enterText(_field('Amount'), '-12.34');
      await tester.pumpAndSettle();
      await _tapSave(tester);

      expect(actions.created, isNull);
    });

    testWidgets('shows the amount hint in a zero-decimal currency', (
      tester,
    ) async {
      await _pumpIncome(
        tester,
        accounts: [
          testAccount(id: _jpyAccountId, currencyCode: 'JPY'),
        ],
      );

      expect(find.textContaining('¥0'), findsAtLeast(1));
    });

    testWidgets('a zero-decimal amount field refuses a decimal point', (
      tester,
    ) async {
      final actions = await _pumpIncome(
        tester,
        accounts: [
          testAccount(id: _jpyAccountId, currencyCode: 'JPY'),
        ],
        routed: true,
      );

      await tester.enterText(_field('Description'), 'Bonus');
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

      expect(actions.created!.amountMinor, 1500);
    });

    testWidgets('a zero-decimal currency offers no decimal key', (
      tester,
    ) async {
      await _pumpIncome(
        tester,
        accounts: [
          testAccount(id: _jpyAccountId, currencyCode: 'JPY'),
        ],
      );

      final amount = tester.widget<TextField>(_field('Amount'));
      expect(amount.keyboardType.decimal, isFalse);
    });

    testWidgets('cancel goes back to the plan', (tester) async {
      await _pumpIncome(tester, routed: true);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Plan Route'), findsOneWidget);
    });

    testWidgets('the expense chip swaps to the expense form', (tester) async {
      await _pumpIncome(tester, routed: true);

      await tester.tap(find.text('Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Add Expense Route'), findsOneWidget);
    });
  });
}
