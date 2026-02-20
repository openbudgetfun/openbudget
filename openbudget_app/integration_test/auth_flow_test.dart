import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Widget _buildAuthApp() {
  final router = GoRouter(
    initialLocation: loginPath,
    routes: [
      GoRoute(path: loginPath, builder: (_, __) => const LoginScreen()),
      GoRoute(path: registerPath, builder: (_, __) => const RegisterScreen()),
    ],
  );

  return ProviderScope(
    overrides: [authProvider.overrideWithValue(const Unauthenticated())],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login screen renders on auth flow launch', (tester) async {
    await tester.pumpWidget(_buildAuthApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome to OpenBudget'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('login flow can navigate to register screen', (tester) async {
    await tester.pumpWidget(_buildAuthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Send Verification Code'), findsOneWidget);
  });

  testWidgets('register flow can navigate back to login screen', (
    tester,
  ) async {
    await tester.pumpWidget(_buildAuthApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Already have an account? Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to OpenBudget'), findsOneWidget);
  });
}
