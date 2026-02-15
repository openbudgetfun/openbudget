import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
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
    testWidgets('renders budget name input and currency selector', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Create Budget'), findsOneWidget);
      expect(find.byType(WiredInput), findsOneWidget);
      expect(find.byType(WiredCombo), findsOneWidget);
    });

    testWidgets('renders create button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Create'), findsOneWidget);
      expect(find.byType(WiredButton), findsOneWidget);
    });

    testWidgets('can enter budget name', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(WiredInput), 'My Budget');

      expect(find.text('My Budget'), findsOneWidget);
    });
  });
}
