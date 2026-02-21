import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AppIconScreen', () {
    testWidgets('renders OpenBudget app icon style options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppIconScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('App Icon'), findsOneWidget);
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Compass'), findsOneWidget);
      expect(find.text('Sprout'), findsOneWidget);
      expect(find.text('Ledger'), findsOneWidget);
      expect(find.text('Arrow'), findsOneWidget);
    });

    testWidgets('updates provider when selecting icon style', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppIconScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Arrow'));
      await tester.pumpAndSettle();

      expect(container.read(appIconStyleProvider), AppIconStyle.v5);
    });
  });
}
