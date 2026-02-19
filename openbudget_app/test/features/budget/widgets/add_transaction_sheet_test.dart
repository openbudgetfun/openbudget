import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

  Widget buildSubject() {
    return MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        // Render the sheet directly as a child instead of via
        // showModalBottomSheet to avoid layout overflow in tests.
        body: AddTransactionSheet(budgetId: budgetId),
      ),
    );
  }

  group('AddTransactionSheet', () {
    testWidgets('renders title and three action tiles', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('renders action icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('renders three action cards', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 3 action tiles = 3 Card widgets
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('renders chevron trailing icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
    });
  });
}
