import 'package:flutter/foundation.dart';

/// PostHog configuration resolved from compile-time environment variables.
///
/// Pass API key/host via `--dart-define`:
/// ```sh
/// flutter run --dart-define=POSTHOG_API_KEY=phc_... --dart-define=POSTHOG_HOST=https://us.i.posthog.com
/// ```
class PosthogConfig {
  const PosthogConfig._();

  /// PostHog project API key.
  static const apiKey = String.fromEnvironment('POSTHOG_API_KEY');

  /// PostHog host URL.
  static const host = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );

  /// PostHog is enabled only in release mode with a non-empty API key.
  static bool get isEnabled => !kDebugMode && apiKey.isNotEmpty;
}
