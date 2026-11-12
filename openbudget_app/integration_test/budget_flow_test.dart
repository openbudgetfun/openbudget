import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_app/src/routing/app_router.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolWidgetTest('create entity screen renders onboarding layout', ($) async {
    final tester = $.tester;
    final router = GoRouter(
      initialLocation: createEntityPath,
      routes: [
        GoRoute(path: createEntityPath, builder: (_, _) => const CreateEntityScreen()),
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

    expect(find.text('Create your books'), findsOneWidget);
    expect(find.text('What are these books for?'), findsOneWidget);
    expect(find.text('Country'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.text('Plan Currency'), findsOneWidget);
    expect(find.text('British Pound (GBP)'), findsOneWidget);
    expect(find.text('Time zone'), findsOneWidget);
    expect(find.text('Europe/London'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  patrolWidgetTest(
    'unauthenticated user is redirected to login from create entity',
    ($) async {
      final tester = $.tester;
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(const Unauthenticated()),
          entityListProvider.overrideWith((ref) async => const []),
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

      router.go(createEntityPath);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-openbudget-mark')), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    },
  );
}
