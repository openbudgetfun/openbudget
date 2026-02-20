// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000001');

Budget _makeBudget({String name = 'My Budget', String currencyCode = 'USD'}) {
  return Budget(name: name, currencyCode: currencyCode, ownerId: _ownerUuid);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SettingsScreen', () {
    testWidgets('renders loading indicator while budget loads', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state when budget fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) => throw Exception('Could not load settings'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load settings'), findsOneWidget);
    });

    testWidgets('renders settings title in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders budget name in settings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(name: 'Family Budget'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Family Budget'), findsOneWidget);
      expect(find.text('Budget Name'), findsOneWidget);
    });

    testWidgets('renders currency code in settings', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(currencyCode: 'EUR'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
    });

    testWidgets('renders theme selector with system option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
            themeModeProvider.overrideWithValue(ThemeMode.system),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('renders theme selector with light option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
            themeModeProvider.overrideWithValue(ThemeMode.system),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('renders theme selector with dark option', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
            themeModeProvider.overrideWithValue(ThemeMode.system),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('renders export budget button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Export Budget may be off-screen; scroll to reveal it.
      await tester.scrollUntilVisible(
        find.text('Export Budget'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Export Budget'), findsOneWidget);
    });

    testWidgets('renders logout button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Sign Out button is near the bottom; scroll to reveal it.
      await tester.scrollUntilVisible(
        find.text('Sign Out'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('renders version text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The version text is at the bottom of a scrollable list.
      await tester.scrollUntilVisible(
        find.text('OpenBudget v1.0.0'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('OpenBudget v1.0.0'), findsOneWidget);
    });

    testWidgets('renders appearance section title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('APPEARANCE'), findsOneWidget);
    });
  });
}
