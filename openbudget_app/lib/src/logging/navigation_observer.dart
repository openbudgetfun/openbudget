import 'package:flutter/widgets.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// A [NavigatorObserver] that logs route push/pop/replace events.
class LoggingNavigationObserver extends NavigatorObserver {
  static final _log = ObLogger('Navigation');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.info('Push ${route.settings.name ?? route.runtimeType}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.info('Pop ${route.settings.name ?? route.runtimeType}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log.info(
      'Replace ${oldRoute?.settings.name} -> ${newRoute?.settings.name}',
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.info('Remove ${route.settings.name ?? route.runtimeType}');
  }
}
