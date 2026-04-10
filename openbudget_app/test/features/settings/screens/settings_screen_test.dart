// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000001');

Budget _makeBudget({String name = 'My Budget', String currencyCode = 'USD'}) => Budget(name: name, currencyCode: currencyCode, ownerId: _ownerUuid);

Widget _materialShell() => MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const SettingsScreen(budgetId: _budgetId),
  );

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SettingsScreen', () {
    testWidgets('renders loading indicator while budget loads', (tester) async {
      await tester.pumpWidget(ProviderScope(child: _materialShell()));
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
          child: _materialShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load settings'), findsOneWidget);
    });

    testWidgets('renders plan section and plan actions', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(name: 'Family Plan'),
            ),
          ],
          child: _materialShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current Plan'), findsOneWidget);
      expect(find.text('Family Plan'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Plan Settings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Plan Settings'), findsOneWidget);
      expect(find.text('New Plan'), findsOneWidget);
      expect(find.text('Open Plan'), findsOneWidget);
      expect(find.text('Make a Fresh Start'), findsOneWidget);
    });

    testWidgets('renders quick-access, app, and account sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith(
              (ref, budgetId) async => _makeBudget(),
            ),
          ],
          child: _materialShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.text('Recurring Transactions'), findsOneWidget);
      expect(find.text('Payees'), findsOneWidget);
      expect(find.text('Transaction Rules'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('App Icon'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('App Icon'), findsOneWidget);
      expect(find.text('Display Options'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Manage Bank Connections'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -550));
      await tester.pumpAndSettle();

      expect(find.text('Misc'), findsOneWidget);
      expect(find.text('Write a Review'), findsOneWidget);
      expect(find.text('Send in Diagnostics'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });
  });
}
