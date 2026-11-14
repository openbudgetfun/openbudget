import 'package:openbudget_app/src/features/accounts/models/add_wallet_state.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_wallet_provider.g.dart';

/// The networks an EVM address starts out reading, from what the preview
/// found (`docs/multichain-wallets.md` section 5.5).
///
/// A network with any priced holding starts selected. The home network
/// always does, because a wallet always reads it, so an address with nothing
/// anywhere still reads Ethereum. The result keeps the preview's order.
List<WalletNetwork> initialWalletSelection(WalletPreview preview) => [
  for (final row in preview.networks)
    if (row.network == preview.network ||
        (row.readError == null && row.pricedHoldingCount > 0))
      row.network,
];

/// The add-a-wallet flow.
///
/// It holds the look-ahead at an address's networks, the networks picked and
/// the connect. It never holds what the person pasted: the paste field owns
/// the text, and only an address the core parser accepted is passed in,
/// where it goes to the server and nowhere else.
@riverpod
class AddWalletFlow extends _$AddWalletFlow {
  /// Previews already fetched this visit, so pasting the same address twice
  /// does not spend one of the hour's twenty.
  final Map<String, WalletPreview> _previews = {};
  String? _pendingKey;

  @override
  AddWalletState build() => const AddWalletState();

  /// Looks ahead at what [address] holds on each of its networks.
  Future<void> loadPreview({
    required String entityId,
    required String address,
  }) async {
    final key = address.toLowerCase();
    if (_pendingKey == key && state.preview is WalletPreviewLoading) return;
    _pendingKey = key;

    final cached = _previews[key];
    if (cached != null) {
      _showPreview(cached);
      return;
    }

    state = state.copyWith(
      preview: const WalletPreviewState.loading(),
      selected: const [],
    );
    try {
      final client = ref.read(serverpodClientProvider);
      final preview = await client.wallet.preview(
        UuidValue.fromString(entityId),
        address,
      );
      _previews[key] = preview;
      if (!ref.mounted || _pendingKey != key) return;
      _showPreview(preview);
    } on WalletPreviewRateLimitedException {
      _failPreview(key, WalletPreviewFailure.rateLimited);
    } on Exception {
      _failPreview(key, WalletPreviewFailure.unavailable);
    }
  }

  /// Drops the look-ahead, for input that is no longer a multi-network
  /// address.
  void clearPreview() {
    _pendingKey = null;
    if (state.preview is WalletPreviewIdle && state.selected.isEmpty) return;
    state = state.copyWith(
      preview: const WalletPreviewState.idle(),
      selected: const [],
    );
  }

  /// Turns [network] on or off. The home network stays on.
  void toggleNetwork(WalletNetwork network, {required bool selected}) {
    final preview = state.preview;
    if (preview is! WalletPreviewLoaded) return;
    if (network == preview.preview.network) return;
    final next = {...state.selected};
    if (selected) {
      next.add(network);
    } else {
      next.remove(network);
    }
    state = state.copyWith(
      selected: [
        for (final row in preview.preview.networks)
          if (next.contains(row.network)) row.network,
      ],
    );
  }

  /// Connects the wallet at [address] on [network] and reads it for the
  /// first time. The server reads before it answers, so the state stays
  /// [AddWalletReading] until then.
  ///
  /// [accountName] is the localised name for the wallet's crypto account.
  Future<void> submit({
    required String entityId,
    required String address,
    required WalletNetwork network,
    required String accountName,
  }) async {
    if (state.submission is AddWalletReading) return;
    final scan =
        state.preview is WalletPreviewLoaded && state.selected.isNotEmpty
        ? state.selected
        : null;
    final networks = scan ?? [network];
    state = state.copyWith(submission: AddWalletSubmission.reading(networks));
    try {
      final wallet = await ref
          .read(walletActionsProvider.notifier)
          .connect(
            entityId: entityId,
            network: network,
            address: address,
            accountName: accountName,
            scanNetworks: scan,
          );
      if (!ref.mounted) return;
      state = state.copyWith(
        submission: wallet.syncStatus == SyncStatus.failed
            ? AddWalletSubmission.unreadable(
                wallet: wallet,
                accountName: accountName,
                networks: networks,
                reason: wallet.lastSyncError,
              )
            : AddWalletSubmission.added(
                wallet: wallet,
                accountName: accountName,
                networks: networks,
              ),
      );
    } on ValidationException catch (error) {
      _failSubmission(error.message);
    } on Exception {
      _failSubmission(null);
    }
  }

  /// Reads a wallet whose first read failed on every network.
  Future<void> retryRead({required String entityId}) async {
    final current = state.submission;
    if (current is! AddWalletUnreadable) return;
    state = state.copyWith(
      submission: AddWalletSubmission.reading(current.networks),
    );
    try {
      final result = await ref
          .read(walletActionsProvider.notifier)
          .sync(walletId: current.wallet.id!.uuid, entityId: entityId);
      if (!ref.mounted) return;
      state = state.copyWith(
        submission: result.readNetworks.isEmpty
            ? current
            : AddWalletSubmission.added(
                wallet: current.wallet,
                accountName: current.accountName,
                networks: current.networks,
              ),
      );
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(submission: current);
    }
  }

  /// Dismisses a failed connect and returns to the form.
  void dismissFailure() {
    if (state.submission is! AddWalletFailed) return;
    state = state.copyWith(submission: const AddWalletSubmission.idle());
  }

  /// Starts over for another wallet.
  void reset() {
    _pendingKey = null;
    state = const AddWalletState();
  }

  void _showPreview(WalletPreview preview) {
    state = state.copyWith(
      preview: WalletPreviewState.loaded(preview),
      selected: initialWalletSelection(preview),
    );
  }

  void _failPreview(String key, WalletPreviewFailure reason) {
    if (!ref.mounted || _pendingKey != key) return;
    state = state.copyWith(
      preview: WalletPreviewState.failed(reason),
      selected: const [],
    );
  }

  void _failSubmission(String? message) {
    if (!ref.mounted) return;
    state = state.copyWith(submission: AddWalletSubmission.failed(message));
  }
}
