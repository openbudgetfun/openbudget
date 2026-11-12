import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

EnvelopeMonthView _rowWithGoal({required int amountMinor}) => testEnvelopeRow(
  goal: EnvelopeGoal(
    entityId: UuidValue.fromString(fixtureEntityId),
    envelopeId: UuidValue.fromString(fixtureEnvelopeId),
    kind: EnvelopeGoalKind.monthlyFunding,
    amountMinor: amountMinor,
  ),
);

Widget _buildSubject({
  required String currencyCode,
  required EnvelopeMonthView monthEnvelope,
}) => ProviderScope(
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SetGoalDialog(
        monthEnvelope: monthEnvelope,
        entityId: fixtureEntityId,
        currencyCode: currencyCode,
        month: 202611,
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the stored contribution exactly', (tester) async {
    await tester.pumpWidget(
      _buildSubject(
        currencyCode: 'USD',
        monthEnvelope: _rowWithGoal(amountMinor: 120000),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(r'Set aside another $1,200.00'), findsOneWidget);
    // The editable field carries the parsed amount with currency decimals.
    expect(find.text('1200.00'), findsOneWidget);
  });

  testWidgets('does not add decimals for a zero-decimal currency', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSubject(
        currencyCode: 'JPY',
        monthEnvelope: _rowWithGoal(amountMinor: 1200),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set aside another ¥1,200'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);
  });
}
