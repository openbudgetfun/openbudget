import 'package:flutter/foundation.dart';
import 'package:openbudget_app/src/features/plus/models/plus_config.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_checkout_links_provider.g.dart';

/// The URLs Stripe returns to when checkout or the billing portal closes.
@immutable
class PlusCheckoutLinks {
  const PlusCheckoutLinks({
    required this.successUrl,
    required this.cancelUrl,
    required this.portalReturnUrl,
  });

  final String successUrl;
  final String cancelUrl;
  final String portalReturnUrl;
}

/// Return links for the current platform.
///
/// Web comes back to the running app so the success state refreshes in place;
/// desktop returns to the public app page because the browser is outside the
/// app.
@Riverpod(keepAlive: true)
PlusCheckoutLinks plusCheckoutLinks(Ref ref) {
  final platform = ref.watch(plusPlatformProvider);
  final base = platform == PlusPlatform.web
      ? Uri.base
      : Uri.parse(PlusConfig.appUrl);
  String link(String status) => base.resolve('/plus?status=$status').toString();

  return PlusCheckoutLinks(
    successUrl: link('success'),
    cancelUrl: link('cancel'),
    portalReturnUrl: link('manage'),
  );
}
