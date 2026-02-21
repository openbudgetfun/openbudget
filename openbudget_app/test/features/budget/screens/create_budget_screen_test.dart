import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CreateBudgetScreen(),
      ),
    );
  }

  group('CreateBudgetScreen', () {
    testWidgets('renders welcome onboarding layout', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Welcome, new YNABer!'), findsOneWidget);
      expect(find.text('Plan Currency'), findsOneWidget);
      expect(find.text('US Dollar'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('renders personalize action button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Personalize Your Plan'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('opens currency selector from plan currency row', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Plan Currency'));
      await tester.tap(find.text('Plan Currency'));
      await tester.pumpAndSettle();

      expect(find.text('US Dollar (USD)'), findsWidgets);
    });
  });
}
