import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';

const String _entityId = fixtureEntityId;

class _RecordingActions extends TransactionActions {
  TransactionInput? updated;
  String? updatedId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<TransactionView> update({
    required String transactionId,
    required TransactionInput input,
    required String entityId,
  }) async {
    updated = input;
    updatedId = transactionId;
    return testTransactionView(
      transaction: testTransaction(amountMinor: input.amountMinor),
    );
  }
}

Future<_RecordingActions> _pumpDialog(
  WidgetTester tester, {
  required TransactionView view,
  List<Payee> payees = const [],
}) async {
  final actions = _RecordingActions();
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      payeeListProvider.overrideWith((ref, entityId) async => payees),
      budgetMonthProvider.overrideWith((ref, id) async => testMonthView()),
      transactionActionsProvider.overrideWith(() => actions),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    Scaffold(
      body: EditTransactionDialog(view: view, entityId: _entityId),
    ),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return actions;
}

Finder _field(String label) => find.widgetWithText(TextField, label);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(ObFilledButton, 'Save'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the stored amount without floating point drift', (
    tester,
  ) async {
    await _pumpDialog(
      tester,
      view: testTransactionView(transaction: testTransaction()),
    );

    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(_field('Amount'), findsOneWidget);
    final amount = tester.widget<TextField>(_field('Amount'));
    expect(amount.controller!.text, '12.34');
  });

  testWidgets('saves 12.34 as -1234 minor units on the transaction', (
    tester,
  ) async {
    final actions = await _pumpDialog(
      tester,
      view: testTransactionView(
        transaction: testTransaction(),
        payeeName: 'Tesco',
      ),
      payees: [testPayee()],
    );

    await tester.enterText(_field('Amount'), '12.34');
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(actions.updatedId, fixtureTransactionId);
    expect(actions.updated!.amountMinor, -1234);
    expect(actions.updated!.description, 'Groceries');
    expect(actions.updated!.fxRate, '1');
    expect(
      actions.updated!.lines.single.envelopeId.toString(),
      fixtureEnvelopeId,
    );
  });

  testWidgets('refuses an over-precise amount instead of rounding it', (
    tester,
  ) async {
    final actions = await _pumpDialog(
      tester,
      view: testTransactionView(transaction: testTransaction()),
    );

    await tester.enterText(_field('Amount'), '12.345');
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid amount with at most 2 decimal places'),
      findsOneWidget,
    );
    await _tapSave(tester);

    expect(actions.updated, isNull);
  });

  testWidgets('refuses a negative amount', (tester) async {
    final actions = await _pumpDialog(
      tester,
      view: testTransactionView(transaction: testTransaction()),
    );

    await tester.enterText(_field('Amount'), '-12.34');
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(actions.updated, isNull);
  });

  testWidgets('an income transaction has no envelope picker and stays income', (
    tester,
  ) async {
    final actions = await _pumpDialog(
      tester,
      view: testTransactionView(
        transaction: testTransaction(amountMinor: 1234),
      ),
    );

    expect(find.text('Envelope'), findsNothing);
    await tester.enterText(_field('Amount'), '12.34');
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(actions.updated!.amountMinor, 1234);
  });

  testWidgets('a split transaction hides the single-envelope picker', (
    tester,
  ) async {
    final header = testTransaction();
    await _pumpDialog(
      tester,
      view: testTransactionView(
        transaction: header,
        lines: [
          testLine(
            transaction: header,
            id: '00000000-0000-0000-0000-0000000000f201',
            amountMinor: -617,
          ),
          testLine(
            transaction: header,
            id: '00000000-0000-0000-0000-0000000000f202',
            amountMinor: -617,
            envelopeId: fixtureEnvelopeId2,
          ),
        ],
      ),
    );

    expect(find.text('Envelope'), findsNothing);
    expect(find.text('Tax category'), findsNWidgets(2));
    expect(find.text('Not set'), findsNWidgets(2));
  });

  testWidgets('assigns the chosen envelope to the single line', (tester) async {
    final header = testTransaction();
    final actions = await _pumpDialog(
      tester,
      view: testTransactionView(
        transaction: header,
        lines: [testLine(transaction: header)],
      ),
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is ObDropdown<String> && widget.labelText == 'Envelope',
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Living / Groceries').last);
    await tester.pumpAndSettle();
    await _tapSave(tester);

    expect(
      actions.updated!.lines.single.envelopeId.toString(),
      fixtureEnvelopeId,
    );
  });

  testWidgets('shows the stored payee in the payee picker', (tester) async {
    await _pumpDialog(
      tester,
      view: testTransactionView(
        transaction: testTransaction(payeeId: fixturePayeeId),
        payeeName: 'Tesco',
      ),
      payees: [testPayee()],
    );

    expect(find.text('Tesco'), findsOneWidget);
  });

  testWidgets('cancel closes the dialog without updating', (tester) async {
    final actions = _RecordingActions();
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        payeeListProvider.overrideWith((ref, entityId) async => const []),
        budgetMonthProvider.overrideWith((ref, id) async => testMonthView()),
        transactionActionsProvider.overrideWith(() => actions),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => EditTransactionDialog(
                  view: testTransactionView(
                    transaction: testTransaction(),
                  ),
                  entityId: _entityId,
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
      container: container,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTransactionDialog), findsOneWidget);

    await tester.tap(find.widgetWithText(ObTextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(actions.updated, isNull);
    expect(find.byType(EditTransactionDialog), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });
}
