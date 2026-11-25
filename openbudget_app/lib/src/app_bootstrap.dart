import 'package:flutter/cupertino.dart' show DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/analytics/analytics_provider.dart';
import 'package:openbudget_app/src/config/app_environment.dart';
import 'package:openbudget_app/src/features/auth/apple_sign_in_bootstrap.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/settings/providers/ui_preferences_store.dart';
import 'package:openbudget_app/src/logging/app_logging.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_app/src/routing/app_router.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's strings plus Material, Cupertino and widgets strings in English.
///
/// The app ships one language. `AppLocalizations.localizationsDelegates`
/// would install `flutter_localizations`' global delegates, which carry every
/// language Flutter supports plus every locale's date data (about 300 KB of
/// the web app's startup JavaScript) only to serve English. The default
/// delegates are Flutter's built-in English. Switch back to the global ones
/// when a second language arrives.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  DefaultMaterialLocalizations.delegate,
  DefaultCupertinoLocalizations.delegate,
  DefaultWidgetsLocalizations.delegate,
];

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

  // Neither depends on the other, so they start together and the first
  // frame waits for the slower one, not for both in turn. Native Apple
  // sign-in does not need the web-only Apple defines; PostHog no-ops in
  // debug mode.
  await Future.wait([
    prepareNativeAppleSignIn(),
    container.read(analyticsProvider).init(),
  ]);

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
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            ObWiredScope(child: _DismissKeyboardOnTap(child: child)),
        home: const _AuthBootstrapScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppEnvironment.appTitle,
      theme: OpenBudgetTheme.light,
      darkTheme: OpenBudgetTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          ObWiredScope(child: _DismissKeyboardOnTap(child: child)),
      routerConfig: router,
    );
  }
}

class _DismissKeyboardOnTap extends HookWidget {
  const _DismissKeyboardOnTap({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: (event) {
      final focusedNode = FocusManager.instance.primaryFocus;
      if (focusedNode == null) {
        return;
      }

      final focusedContext = focusedNode.context;
      if (focusedContext == null) {
        return;
      }

      final focusedRenderObject = focusedContext.findRenderObject();
      if (focusedRenderObject is! RenderBox) {
        focusedNode.unfocus();
        return;
      }

      final localOffset = focusedRenderObject.globalToLocal(event.position);
      final isTapInsideFocusedField = focusedRenderObject.paintBounds.contains(
        localOffset,
      );
      if (!isTapInsideFocusedField) {
        focusedNode.unfocus();
      }
    },
    child: child ?? const SizedBox.shrink(),
  );
}

class _AuthBootstrapScreen extends HookWidget {
  const _AuthBootstrapScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
