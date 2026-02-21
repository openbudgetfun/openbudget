import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DisplayOptionsScreen', () {
    testWidgets('renders theme and balance style choices', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DisplayOptionsScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Display Options'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Balance Style'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Differentiate Without Color'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Hide Amounts'), findsOneWidget);
      expect(find.text('Hide Progress Bars'), findsOneWidget);
    });

    testWidgets('updates providers when selections change', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DisplayOptionsScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Differentiate Without Color'));
      await tester.pumpAndSettle();

      final hideAmountsSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Amounts'),
      );
      hideAmountsSwitch.onChanged?.call(true);
      await tester.pumpAndSettle();

      final hideProgressBarsSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Hide Progress Bars'),
      );
      hideProgressBarsSwitch.onChanged?.call(true);
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(
        container.read(balanceStyleProvider),
        BalanceStyle.differentiateWithoutColor,
      );
      expect(container.read(hideAmountsProvider), isTrue);
      expect(container.read(hideProgressBarsProvider), isTrue);
    });
  });
}
