import 'package:openbudget_app/src/features/accounts/models/add_wallet_state.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_look_ahead_provider.g.dart';

/// "Look for assets on other chains" for one connected wallet: a fresh
/// `wallet.preview` of its address, which the wallet settings read to offer
/// networks the wallet does not scan yet.
///
/// It lives only while the settings are open, so every visit starts without
/// a stale answer. The address goes to the server and nowhere else.
@riverpod
class WalletLookAhead extends _$WalletLookAhead {
  @override
  WalletPreviewState build(String walletId) => const WalletPreviewState.idle();

  /// Looks at what [address] holds on each of its networks.
  Future<void> look({required String entityId, required String address}) async {
    if (state is WalletPreviewLoading) return;
    state = const WalletPreviewState.loading();
    try {
      final client = ref.read(serverpodClientProvider);
      final preview = await client.wallet.preview(
        UuidValue.fromString(entityId),
        address,
      );
      if (!ref.mounted) return;
      state = WalletPreviewState.loaded(preview);
    } on WalletPreviewRateLimitedException {
      if (!ref.mounted) return;
      state = const WalletPreviewState.failed(WalletPreviewFailure.rateLimited);
    } on Exception {
      if (!ref.mounted) return;
      state = const WalletPreviewState.failed(WalletPreviewFailure.unavailable);
    }
  }
}
