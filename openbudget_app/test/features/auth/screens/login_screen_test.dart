import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  Widget buildSubject() {
    return ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to OpenBudget'), findsOneWidget);
      expect(find.byType(WiredInput), findsNWidgets(2));
    });

    testWidgets('renders sign-in button', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(WiredButton), findsOneWidget);
    });

    testWidgets('can enter email and password text', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final inputs = find.byType(WiredInput);
      await tester.enterText(inputs.first, 'test@example.com');
      await tester.enterText(inputs.last, 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });
  });
}
