import 'package:flutter/services.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'store_purchases_provider.g.dart';

/// What happened when a store purchase or restore finished.
enum StorePurchaseOutcome { purchased, cancelled, unavailable, failed }

/// App Store and Play Store purchases, behind an interface so tests never
/// touch RevenueCat.
abstract interface class StorePurchases {
  /// Whether this build has a key and this platform supports store billing.
  bool get isAvailable;

  /// Ties RevenueCat's `app_user_id` to the signed-in OpenBudget user so the
  /// server webhook can record the entitlement against the right account.
  Future<void> identify(String userId);

  /// Buys the current offering's monthly package.
  Future<StorePurchaseOutcome> purchaseMonthly();

  /// Restores purchases already owned by the store account.
  Future<StorePurchaseOutcome> restore();

  /// The store's own subscription management page, when it provides one.
  Future<Uri?> managementUrl();
}

/// RevenueCat implementation of [StorePurchases].
class RevenueCatStorePurchases implements StorePurchases {
  RevenueCatStorePurchases(this._apiKey, {required this.supported});

  /// Whether the current platform supports store billing at all.
  final bool supported;

  final String _apiKey;
  Future<void>? _configured;
  Future<void>? _identifyFuture;
  String? _identifiedUserId;

  @override
  bool get isAvailable => supported && _apiKey.isNotEmpty;

  @override
  Future<void> identify(String userId) {
    if (!isAvailable || _identifiedUserId == userId) {
      return _identifyFuture ?? Future<void>.value();
    }
    return _identifyFuture = _identify(userId);
  }

  Future<void> _identify(String userId) async {
    await _ensureConfigured();
    await Purchases.logIn(userId);
    _identifiedUserId = userId;
  }

  @override
  Future<StorePurchaseOutcome> purchaseMonthly() async {
    if (!isAvailable) return StorePurchaseOutcome.unavailable;

    try {
      await _ensureConfigured();
      await _awaitIdentify();
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.monthly;
      if (package == null) return StorePurchaseOutcome.unavailable;
      await Purchases.purchase(PurchaseParams.package(package));
      return StorePurchaseOutcome.purchased;
    } on PlatformException catch (error) {
      return _outcomeFor(error);
    } on Exception {
      return StorePurchaseOutcome.failed;
    }
  }

  @override
  Future<StorePurchaseOutcome> restore() async {
    if (!isAvailable) return StorePurchaseOutcome.unavailable;

    try {
      await _ensureConfigured();
      await _awaitIdentify();
      await Purchases.restorePurchases();
      return StorePurchaseOutcome.purchased;
    } on PlatformException catch (error) {
      return _outcomeFor(error);
    } on Exception {
      return StorePurchaseOutcome.failed;
    }
  }

  @override
  Future<Uri?> managementUrl() async {
    if (!isAvailable) return null;

    try {
      await _ensureConfigured();
      await _awaitIdentify();
      final customerInfo = await Purchases.getCustomerInfo();
      final url = customerInfo.managementURL;
      return url == null ? null : Uri.tryParse(url);
    } on Exception {
      return null;
    }
  }

  Future<void> _ensureConfigured() =>
      _configured ??= Purchases.configure(PurchasesConfiguration(_apiKey));

  /// Waits for the signed-in user's id to reach RevenueCat before a purchase.
  ///
  /// Without this, a person who taps buy immediately after signing in can
  /// purchase under the anonymous id, and the webhook cannot credit them.
  Future<void> _awaitIdentify() => _identifyFuture ?? Future<void>.value();

  StorePurchaseOutcome _outcomeFor(PlatformException error) {
    final PurchasesErrorCode code;
    try {
      code = PurchasesErrorHelper.getErrorCode(error);
    } on FormatException {
      return StorePurchaseOutcome.failed;
    }
    return switch (code) {
      PurchasesErrorCode.purchaseCancelledError =>
        StorePurchaseOutcome.cancelled,
      PurchasesErrorCode.productNotAvailableForPurchaseError =>
        StorePurchaseOutcome.unavailable,
      PurchasesErrorCode.purchaseNotAllowedError =>
        StorePurchaseOutcome.unavailable,
      _ => StorePurchaseOutcome.failed,
    };
  }
}

/// Store purchases for the current platform.
@Riverpod(keepAlive: true)
StorePurchases storePurchases(Ref ref) {
  final platform = ref.watch(plusPlatformProvider);
  return RevenueCatStorePurchases(
    ref.watch(revenueCatApiKeyProvider),
    supported: platform == PlusPlatform.ios || platform == PlusPlatform.android,
  );
}
