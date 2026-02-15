import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  Widget buildSubject({String budgetId = 'test-budget-1'}) {
    return ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BudgetDetailScreen(budgetId: budgetId),
      ),
    );
  }

  group('BudgetDetailScreen', () {
    testWidgets('renders budget id in header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Budget: test-budget-1'), findsOneWidget);
    });

    testWidgets('renders empty state message', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No Categories Yet'), findsOneWidget);
      expect(
        find.text('Add your first envelope category to start budgeting'),
        findsOneWidget,
      );
    });

    testWidgets('renders add category button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Add Category'), findsOneWidget);
      expect(find.byType(WiredButton), findsOneWidget);
    });
  });
}
