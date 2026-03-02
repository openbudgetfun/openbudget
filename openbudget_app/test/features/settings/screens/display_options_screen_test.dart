import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  final ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000441');

  Budget makeBudget({
    String currencyCode = 'USD',
    String? displayCurrencyCode,
  }) {
    return Budget(
      name: "Alex's Plan",
      currencyCode: currencyCode,
      displayCurrencyCode: displayCurrencyCode,
      ownerId: ownerId,
    );
  }

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('DisplayOptionsScreen', () {
    testWidgets('renders theme and balance style choices', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => makeBudget(),
            ),
          ],
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
      expect(find.text('Appearance'), findsNWidgets(2));
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Balance Style'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Differentiate Without Color'), findsOneWidget);
      expect(find.text('Display Currency'), findsWidgets);
      expect(find.text('Privacy'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Hide Amounts'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Hide Amounts'), findsOneWidget);
      expect(find.text('Hide Progress Bars'), findsOneWidget);
    });

    testWidgets('updates providers when selections change', (tester) async {
      final container = ProviderContainer(
        overrides: [
          budgetDetailProvider.overrideWith(
            (ref, budgetId) async => makeBudget(),
          ),
        ],
      );
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

      final themeSwitch = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Appearance'),
      );
      themeSwitch.onChanged?.call(true);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Differentiate Without Color'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Hide Amounts'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
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

    testWidgets('selecting explicit display currency updates budget', (
      tester,
    ) async {
      String? capturedBudgetId;
      String? capturedDisplayCurrencyCode;
      bool? capturedClearFlag;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => makeBudget(),
            ),
            updateDisplayCurrencyProvider.overrideWith(
              (ref) =>
                  ({
                    required String budgetId,
                    required bool clearDisplayCurrencyCode,
                    String? displayCurrencyCode,
                  }) async {
                    capturedBudgetId = budgetId;
                    capturedDisplayCurrencyCode = displayCurrencyCode;
                    capturedClearFlag = clearDisplayCurrencyCode;
                  },
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DisplayOptionsScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Display Currency'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('British Pound (GBP)'));
      await tester.pumpAndSettle();

      expect(capturedBudgetId, 'test-budget-id');
      expect(capturedDisplayCurrencyCode, 'GBP');
      expect(capturedClearFlag, isFalse);
    });

    testWidgets('selecting default display currency clears override', (
      tester,
    ) async {
      String? capturedDisplayCurrencyCode;
      bool? capturedClearFlag;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => makeBudget(displayCurrencyCode: 'GBP'),
            ),
            updateDisplayCurrencyProvider.overrideWith(
              (ref) =>
                  ({
                    required String budgetId,
                    required bool clearDisplayCurrencyCode,
                    String? displayCurrencyCode,
                  }) async {
                    capturedDisplayCurrencyCode = displayCurrencyCode;
                    capturedClearFlag = clearDisplayCurrencyCode;
                  },
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DisplayOptionsScreen(budgetId: 'test-budget-id'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Display Currency'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Match Plan Currency (Default)'));
      await tester.pumpAndSettle();

      expect(capturedDisplayCurrencyCode, isNull);
      expect(capturedClearFlag, isTrue);
    });
  });
}
