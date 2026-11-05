import 'package:flutter/foundation.dart';

/// The platform the user is on, which decides the payment rails we offer.
enum PlusPlatform { ios, android, web, macos, windows, linux }

/// One way a person can pay for OpenBudget Plus.
enum PlusRail { stripe, store, solana }

/// Resolves [PlusPlatform] from the web flag and the Flutter target platform.
///
/// Kept as a pure function so widget tests and provider tests can pin the
/// platform without touching the host machine's real target.
PlusPlatform resolvePlusPlatform({
  required bool isWeb,
  required TargetPlatform platform,
}) {
  if (isWeb) return PlusPlatform.web;

  return switch (platform) {
    TargetPlatform.iOS => PlusPlatform.ios,
    TargetPlatform.android => PlusPlatform.android,
    TargetPlatform.macOS => PlusPlatform.macos,
    TargetPlatform.windows => PlusPlatform.windows,
    TargetPlatform.linux => PlusPlatform.linux,
    TargetPlatform.fuchsia => PlusPlatform.linux,
  };
}

/// The rails a platform may offer, in the order the screen shows them.
///
/// Store rules drive this: App Store and Play purchases never appear next to
/// Stripe or Solana, and desktop browsers use Stripe only.
List<PlusRail> plusRailsFor(PlusPlatform platform) => switch (platform) {
  PlusPlatform.ios || PlusPlatform.android => const [PlusRail.store],
  PlusPlatform.web => const [PlusRail.stripe, PlusRail.solana],
  PlusPlatform.macos ||
  PlusPlatform.windows ||
  PlusPlatform.linux => const [PlusRail.stripe],
};
