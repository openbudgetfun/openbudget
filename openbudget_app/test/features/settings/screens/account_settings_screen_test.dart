import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/screens/account_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-id';

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/budgets/$budgetId/more/settings/account-settings',
      routes: [
        GoRoute(
          name: accountSettingsRoute,
          path: accountSettingsPath,
          builder: (context, state) =>
              AccountSettingsScreen(budgetId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              name: deleteAccountRoute,
              path: 'delete',
              builder: (context, state) =>
                  DeleteAccountScreen(budgetId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  group('AccountSettingsScreen', () {
    testWidgets('renders read-only account settings and disables mutations', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Account settings are read-only in this build'),
        findsOneWidget,
      );

      final firstNameField = tester.widget<TextField>(find.byType(TextField));
      expect(firstNameField.enabled, isFalse);

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save (Unavailable)'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.scrollUntilVisible(
        find.text('Change Email & Password'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final changeEmailButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Change Email & Password'),
      );
      expect(changeEmailButton.onPressed, isNull);

      await tester.scrollUntilVisible(
        find.text('Set Up'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      final twoStepButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Set Up'),
      );
      expect(twoStepButton.onPressed, isNull);
    });

    testWidgets('navigates to delete account status page', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Delete Account'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsWidgets);
      expect(
        find.textContaining(
          'Account deletion is currently unavailable in this build',
        ),
        findsOneWidget,
      );
    });
  });
}
