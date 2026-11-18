import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _categoryId = '00000000-0000-0000-0000-000000000101';
const _envelopeId = '00000000-0000-0000-0000-000000000102';

BudgetMonthView _makeMonthView() => testMonthView(
  categories: [testCategory(id: _categoryId, name: 'Bills')],
  envelopes: [
    testEnvelopeRow(
      envelopeId: _envelopeId,
      categoryId: _categoryId,
      envelopeName: 'Utilities',
      allocatedMinor: 6000,
      goal: EnvelopeGoal(
        entityId: UuidValue.fromString(fixtureEntityId),
        envelopeId: UuidValue.fromString(_envelopeId),
        kind: EnvelopeGoalKind.monthlyFunding,
        amountMinor: 6000,
      ),
      note: 'Auto-pay every month',
    ),
  ],
);

void main() {
  testWidgets('renders full-screen category detail sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          budgetMonthProvider(fixtureEntityId).overrideWith(
            (ref) async => _makeMonthView(),
          ),
        ],
        child: MaterialApp(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryDetailScreen(
            entityId: fixtureEntityId,
            categoryId: _categoryId,
            envelopeId: _envelopeId,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Utilities'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
    expect(find.text('Target'), findsOneWidget);
    expect(find.text('Amount to Assign This Month'), findsOneWidget);
    expect(find.text('Assigned So Far'), findsOneWidget);
    expect(find.text('To Go'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Delete Category'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Snooze for this month'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Tax category'), findsOneWidget);
    expect(find.text('Rename Category'), findsOneWidget);
    expect(find.text('Hide Category'), findsOneWidget);
    expect(find.text('Delete Category'), findsOneWidget);
  });
}
