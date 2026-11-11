import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
final _budgetUuid = UuidValue.fromString(_entityId);

class _RecordingTransactionActions extends TransactionActions {
  int? updatedAmountMinor;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<Transaction> updateTransaction({
    required String transactionId,
    required String entityId,
    String? description,
    int? amountMinor,
    String? envelopeId,
    String? payeeId,
    DateTime? transactionDate,
    String? memo,
  }) async {
    updatedAmountMinor = amountMinor;
    return Transaction(
      description: description ?? '',
      amountMinor: amountMinor ?? 0,
      currencyCode: 'USD',
      entityId: _budgetUuid,
      transactionDate: transactionDate ?? DateTime(2026),
    );
  }
}

Transaction _makeTransaction({int amountMinor = -1234}) => Transaction(
  id: UuidValue.fromString('00000000-0000-0000-0000-000000000010'),
  description: 'Coffee',
  amountMinor: amountMinor,
  currencyCode: 'USD',
  entityId: _budgetUuid,
  transactionDate: DateTime(2026, 2),
);

Widget _buildSubject({
  required Transaction transaction,
  required TransactionActions actions,
}) => ProviderScope(
  overrides: [
    transactionActionsProvider.overrideWith(() => actions),
    payeeListProvider.overrideWith((ref, entityId) async => const <Payee>[]),
    budgetSummaryProvider.overrideWith(
      (ref, entityId) async => BudgetSummary(
        budget: Budget(
          id: _budgetUuid,
          name: 'Budget',
          currencyCode: 'USD',
          ownerId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000099',
          ),
          createdAt: DateTime(2026),
        ),
        categories: const [],
        totalIncomeMinor: 0,
        totalBudgetedMinor: 0,
        readyToAssignMinor: 0,
        year: 2026,
        month: 2,
      ),
    ),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: EditTransactionDialog(
        transaction: transaction,
        entityId: _entityId,
        currencyCode: 'USD',
      ),
    ),
  ),
);

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the stored amount without floating point drift', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSubject(
        transaction: _makeTransaction(),
        actions: _RecordingTransactionActions(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12.34'), findsOneWidget);
  });

  testWidgets('saves 12.34 as 1234 minor units', (tester) async {
    final actions = _RecordingTransactionActions();
    await tester.pumpWidget(
      _buildSubject(transaction: _makeTransaction(), actions: actions),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '12.34');
    await tester.pumpAndSettle();
    await _save(tester);

    expect(actions.updatedAmountMinor, -1234);
  });

  testWidgets('refuses an over-precise amount instead of rounding it', (
    tester,
  ) async {
    final actions = _RecordingTransactionActions();
    await tester.pumpWidget(
      _buildSubject(transaction: _makeTransaction(), actions: actions),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '12.345');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );

    await _save(tester);

    expect(actions.updatedAmountMinor, isNull);
  });

  testWidgets('refuses a negative amount', (tester) async {
    final actions = _RecordingTransactionActions();
    await tester.pumpWidget(
      _buildSubject(transaction: _makeTransaction(), actions: actions),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Amount'), '-12.34');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );

    await _save(tester);

    expect(actions.updatedAmountMinor, isNull);
  });
}
