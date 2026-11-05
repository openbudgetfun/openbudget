import 'package:flutter/foundation.dart';
import 'package:openbudget_app/src/features/plus/models/plus_config.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_platform_provider.g.dart';

/// The current platform, injectable so tests can pin iOS, web or macOS.
@Riverpod(keepAlive: true)
PlusPlatform plusPlatform(Ref ref) =>
    resolvePlusPlatform(isWeb: kIsWeb, platform: defaultTargetPlatform);

/// The RevenueCat public key for this platform, or an empty string when the
/// build has none. An empty key leaves the store rail unavailable.
@Riverpod(keepAlive: true)
String revenueCatApiKey(Ref ref) => switch (ref.watch(plusPlatformProvider)) {
  PlusPlatform.ios => PlusConfig.revenueCatIosKey.trim(),
  PlusPlatform.android => PlusConfig.revenueCatAndroidKey.trim(),
  PlusPlatform.web ||
  PlusPlatform.macos ||
  PlusPlatform.windows ||
  PlusPlatform.linux => '',
};
