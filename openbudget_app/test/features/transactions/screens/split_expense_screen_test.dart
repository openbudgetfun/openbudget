import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/split_transaction_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/split_expense_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
final _budgetUuid = UuidValue.fromString(_entityId);

class _RecordingSplitActions extends SplitTransactionActions {
  int? totalAmountMinor;
  List<SplitItem>? splits;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<List<Transaction>> createSplit({
    required String description,
    required int totalAmountMinor,
    required String currencyCode,
    required String entityId,
    required DateTime date,
    required List<SplitItem> splits,
  }) async {
    this.totalAmountMinor = totalAmountMinor;
    this.splits = splits;
    return [
      Transaction(
        description: description,
        amountMinor: totalAmountMinor,
        currencyCode: currencyCode,
        entityId: _budgetUuid,
        transactionDate: date,
        cleared: false,
        reconciled: false,
      ),
    ];
  }
}

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'Budget',
  currencyCode: 'USD',
  ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
  createdAt: DateTime(2026),
);

BudgetSummary _makeSummary() => BudgetSummary(
  budget: _makeBudget(),
  categories: const [],
  totalIncomeMinor: 0,
  totalBudgetedMinor: 0,
  readyToAssignMinor: 0,
  year: 2026,
  month: 2,
);

Widget _buildSubject({required SplitTransactionActions actions}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/split',
    routes: [
      GoRoute(
        name: planRoute,
        path: planPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Plan Route'))),
      ),
      GoRoute(
        path: '/budgets/:id/split',
        builder: (context, state) =>
            SplitExpenseScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      splitTransactionActionsProvider.overrideWith(() => actions),
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
      budgetSummaryProvider.overrideWith((ref, id) async => _makeSummary()),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

/// Field order: description, total amount, then each split row's amount and
/// memo, so split amounts are at indexes 2 and 4.
Future<void> _enterAmounts(
  WidgetTester tester, {
  required String total,
  required String first,
  required String second,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'Lunch');
  await tester.enterText(fields.at(1), total);
  await tester.enterText(fields.at(2), first);
  await tester.enterText(fields.at(4), second);
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save Transaction'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save Transaction'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('saves split amounts as exact minor units', (tester) async {
    final actions = _RecordingSplitActions();
    await tester.pumpWidget(_buildSubject(actions: actions));
    await tester.pumpAndSettle();

    await _enterAmounts(tester, total: '12.34', first: '6.17', second: '6.17');
    await _tapSave(tester);

    expect(actions.totalAmountMinor, -1234);
    expect(
      actions.splits?.map((split) => split.amountMinor).toList(),
      [617, 617],
    );
  });

  testWidgets('refuses an over-precise amount instead of rounding it', (
    tester,
  ) async {
    final actions = _RecordingSplitActions();
    await tester.pumpWidget(_buildSubject(actions: actions));
    await tester.pumpAndSettle();

    await _enterAmounts(
      tester,
      total: '12.345',
      first: '6.17',
      second: '6.17',
    );

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );

    await _tapSave(tester);

    expect(actions.totalAmountMinor, isNull);
  });

  testWidgets('refuses an over-precise split line', (tester) async {
    final actions = _RecordingSplitActions();
    await tester.pumpWidget(_buildSubject(actions: actions));
    await tester.pumpAndSettle();

    await _enterAmounts(
      tester,
      total: '12.34',
      first: '6.175',
      second: '6.17',
    );

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );

    await _tapSave(tester);

    expect(actions.totalAmountMinor, isNull);
  });

  testWidgets('refuses negative split amounts', (tester) async {
    final actions = _RecordingSplitActions();
    await tester.pumpWidget(_buildSubject(actions: actions));
    await tester.pumpAndSettle();

    await _enterAmounts(
      tester,
      total: '12.34',
      first: '-6.17',
      second: '6.17',
    );

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );

    await _tapSave(tester);

    expect(actions.totalAmountMinor, isNull);
  });
}
