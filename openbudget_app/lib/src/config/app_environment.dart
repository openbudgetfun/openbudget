enum AppFlavor { dev, prod }

class AppEnvironment {
  static AppFlavor flavor = AppFlavor.prod;

  static bool get isDev => flavor == AppFlavor.dev;

  static String get appTitle => isDev ? 'OpenBudget Dev' : 'OpenBudget';

  static String get apiUrl {
    const overrideApiUrl = String.fromEnvironment('API_URL');
    if (overrideApiUrl.isNotEmpty) {
      return _withTrailingSlash(overrideApiUrl);
    }

    return isDev
        ? _withTrailingSlash('https://api-staging.openbudget.app')
        : _withTrailingSlash('https://api.openbudget.app');
  }

  static String _withTrailingSlash(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
