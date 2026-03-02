import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/analytics/analytics_provider.dart';
import 'package:openbudget_app/src/config/app_environment.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/logging/app_logging.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/app_router.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> runOpenBudgetApp(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.flavor = flavor;

  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      uiPreferencesStoreProvider.overrideWithValue(
        SharedPrefsUiPreferencesStore(preferences),
      ),
    ],
  );

  initAppLogging();

  // Initialize PostHog analytics (no-ops in debug mode).
  await container.read(analyticsProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const OpenBudgetApp(),
    ),
  );
}

class OpenBudgetApp extends HookConsumerWidget {
  const OpenBudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    if (authState is AuthRestoring) {
      return MaterialApp(
        title: AppEnvironment.appTitle,
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const _AuthBootstrapScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppEnvironment.appTitle,
      theme: OpenBudgetTheme.light,
      darkTheme: OpenBudgetTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

class _AuthBootstrapScreen extends StatelessWidget {
  const _AuthBootstrapScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
