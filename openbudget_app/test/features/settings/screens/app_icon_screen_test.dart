import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
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
      expect(find.text('Paper'), findsOneWidget);
      expect(find.text('Night'), findsOneWidget);
      expect(find.text('Ink'), findsOneWidget);
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

      await tester.tap(find.text('Ink'));
      await tester.pumpAndSettle();

      expect(container.read(appIconStyleProvider), AppIconStyle.ink);
    });

    testWidgets('previews each style as its tile, whatever the theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            darkTheme: OpenBudgetTheme.dark,
            themeMode: ThemeMode.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AppIconScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final (label, variant) in [
        ('Paper', ObMarkVariant.paper),
        ('Night', ObMarkVariant.night),
        ('Ink', ObMarkVariant.ink),
      ]) {
        final mark = tester.widget<ObMark>(
          find.descendant(
            of: find.widgetWithText(ListTile, label),
            matching: find.byType(ObMark),
          ),
        );
        expect(mark.variant, variant, reason: label);
        expect(mark.tile, isTrue, reason: label);
      }
    });
  });
}
