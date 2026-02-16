import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

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
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Without provider overrides, it shows loading or the app title
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
