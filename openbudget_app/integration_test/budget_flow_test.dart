import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/routing/app_router.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolWidgetTest('create budget screen renders onboarding layout', ($) async {
    final tester = $.tester;
    final router = GoRouter(
      initialLocation: createBudgetPath,
      routes: [
        GoRoute(
          path: createBudgetPath,
          builder: (_, __) => const CreateBudgetScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: ThemeData.light(useMaterial3: true),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome, new OpenBudgeter!'), findsOneWidget);
    expect(find.text('Plan Currency'), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  patrolWidgetTest(
    'unauthenticated user is redirected to login from create budget',
    ($) async {
      final tester = $.tester;
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(const Unauthenticated()),
          budgetListProvider.overrideWith((ref) async => const []),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const OpenBudgetApp(),
        ),
      );
      await tester.pumpAndSettle();

      router.go(createBudgetPath);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-openbudget-mark')), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    },
  );
}
