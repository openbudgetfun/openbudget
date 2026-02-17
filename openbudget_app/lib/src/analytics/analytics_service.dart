import 'package:openbudget_app/src/analytics/posthog_config.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// Thin wrapper around PostHog analytics.
///
/// All methods are no-ops when PostHog is disabled (debug mode or missing
/// API key).
class AnalyticsService {
  AnalyticsService() : _posthog = Posthog();

  final Posthog _posthog;

  /// Initializes the PostHog SDK. Must be called before any other method.
  Future<void> init() async {
    if (!PosthogConfig.isEnabled) return;

    final config = PostHogConfig(PosthogConfig.apiKey)
      ..host = PosthogConfig.host
      ..debug = false;
    await _posthog.setup(config);
  }

  /// Captures a screen view event.
  Future<void> screen(String screenName) async {
    if (!PosthogConfig.isEnabled) return;
    await _posthog.screen(screenName: screenName);
  }

  /// Captures a custom event.
  Future<void> capture(
    String eventName, {
    Map<String, Object>? properties,
  }) async {
    if (!PosthogConfig.isEnabled) return;
    await _posthog.capture(eventName: eventName, properties: properties);
  }

  /// Identifies a user.
  Future<void> identify(
    String userId, {
    Map<String, Object>? userProperties,
  }) async {
    if (!PosthogConfig.isEnabled) return;
    await _posthog.identify(userId: userId, userProperties: userProperties);
  }

  /// Resets the user identity (e.g., on logout).
  Future<void> reset() async {
    if (!PosthogConfig.isEnabled) return;
    await _posthog.reset();
  }
}
