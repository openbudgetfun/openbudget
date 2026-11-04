import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Extension on [WidgetTester] to pump a widget wrapped with
/// [ProviderScope] and the OpenBudget theme.
extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a [ProviderScope] and [MaterialApp] using
  /// [OpenBudgetTheme.light].
  ///
  /// Optionally pass a [container] for provider overrides, a [router]
  /// for GoRouter-based navigation, and [localizationsDelegates] /
  /// [supportedLocales] for i18n support.
  Future<void> pumpApp(
    Widget widget, {
    ProviderContainer? container,
    GoRouter? router,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    Iterable<Locale>? supportedLocales,
  }) {
    final Widget app;

    if (router != null) {
      app = MaterialApp.router(
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales ?? const [Locale('en')],
        builder: _wiredScope,
        routerConfig: router,
      );
    } else {
      app = MaterialApp(
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales ?? const [Locale('en')],
        builder: _wiredScope,
        home: widget,
      );
    }

    if (container != null) {
      return pumpWidget(
        UncontrolledProviderScope(container: container, child: app),
      );
    }

    return pumpWidget(ProviderScope(child: app));
  }
}

/// Installs the Skribble theme the app installs, so hand-drawn components
/// render in tests exactly as they do in the app.
Widget _wiredScope(BuildContext context, Widget? child) =>
    ObWiredScope(child: child ?? const SizedBox.shrink());
