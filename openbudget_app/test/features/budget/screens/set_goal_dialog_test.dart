import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/set_goal_dialog.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _envelopeId = '00000000-0000-0000-0000-000000000001';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

EnvelopeGoal _makeGoal({int monthlyFundingCents = 120000}) => EnvelopeGoal(
  envelopeId: UuidValue.fromString(_envelopeId),
  goalType: 'monthly_funding',
  targetAmountCents: monthlyFundingCents,
  monthlyFundingCents: monthlyFundingCents,
);

Widget _buildSubject({
  required String currencyCode,
  required EnvelopeGoal goal,
}) => ProviderScope(
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SetGoalDialog(
        envelopeId: _envelopeId,
        budgetId: _budgetUuid.toString(),
        currencyCode: currencyCode,
        existingGoal: goal,
      ),
    ),
  ),
);

void main() {
  testWidgets('shows the stored contribution exactly', (tester) async {
    await tester.pumpWidget(
      _buildSubject(currencyCode: 'USD', goal: _makeGoal()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set aside another 1200.00'), findsOneWidget);
    expect(find.text('1200.00'), findsOneWidget);
  });

  testWidgets('does not add decimals for a zero-decimal currency', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildSubject(
        currencyCode: 'JPY',
        goal: _makeGoal(monthlyFundingCents: 1200),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set aside another 1200'), findsOneWidget);
    expect(find.text('1200'), findsOneWidget);
  });
}
