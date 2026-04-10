import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildSubject() => ProviderScope(
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RegisterScreen(),
      ),
    );

  group('RegisterScreen', () {
    group('step 0 - email', () {
      testWidgets('shows Create Account title', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Create Account'), findsOneWidget);
      });

      testWidgets('shows email step subtitle', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Enter your email to get started'), findsOneWidget);
      });

      testWidgets('shows person add icon', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
      });

      testWidgets('shows email text field', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Email'), findsOneWidget);
        expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      });

      testWidgets('shows Send Verification Code button', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Send Verification Code'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
      });

      testWidgets('shows sign-in link', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Already have an account? Sign In'), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });

      testWidgets('shows step indicator with 3 dots', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        // Step indicator has 3 AnimatedContainer widgets.
        expect(find.byType(AnimatedContainer), findsNWidgets(3));
      });

      testWidgets('can enter email text', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        final emailField = find.byType(TextField);
        await tester.enterText(emailField, 'user@example.com');
        await tester.pump();

        expect(find.text('user@example.com'), findsOneWidget);
      });

      testWidgets('email field has email keyboard type', (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.emailAddress);
      });

      testWidgets('does not show verification code or password fields', (
        tester,
      ) async {
        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.text('Verification Code'), findsNothing);
        expect(find.text('Verify Code'), findsNothing);
        expect(find.text('Password'), findsNothing);
        expect(find.text('Confirm Password'), findsNothing);
        expect(find.text('Create Account'), findsOneWidget);
      });
    });
  });
}
