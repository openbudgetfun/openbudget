import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject() => MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const DeleteAccountScreen(budgetId: 'test-budget-id'),
    );

  group('DeleteAccountScreen', () {
    testWidgets('renders unavailable state and disables delete action', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsWidgets);
      expect(
        find.textContaining('Account deletion is currently unavailable'),
        findsOneWidget,
      );
      expect(find.text('Confirm Password'), findsNothing);

      final deleteButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Delete Account (Unavailable)'),
      );
      expect(deleteButton.onPressed, isNull);
    });
  });
}
