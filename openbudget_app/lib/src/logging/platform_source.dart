import 'package:flutter/foundation.dart';

/// Detects the current platform and returns a source identifier for logging.
///
/// Examples: `flutter:ios-simulator`, `flutter:web`, `flutter:macos`.
String detectPlatformSource() {
  if (kIsWeb) return 'flutter:web';

  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS =>
      kDebugMode ? 'flutter:ios-simulator' : 'flutter:ios-device',
    TargetPlatform.android =>
      kDebugMode ? 'flutter:android-emulator' : 'flutter:android-device',
    TargetPlatform.macOS => 'flutter:macos',
    TargetPlatform.windows => 'flutter:windows',
    TargetPlatform.linux => 'flutter:linux',
    TargetPlatform.fuchsia => 'flutter:fuchsia',
  };
}
