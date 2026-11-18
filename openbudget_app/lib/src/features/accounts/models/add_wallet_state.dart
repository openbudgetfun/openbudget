import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

part 'add_wallet_state.freezed.dart';

/// Why the look-ahead at an address's networks did not come back.
enum WalletPreviewFailure {
  /// The hourly limit on previews was reached.
  rateLimited,

  /// The server could not read the address's networks.
  unavailable,
}

/// The look-ahead at what an address holds on each of its networks, which
/// feeds the network picker (`docs/multichain-wallets.md` section 5.5).
@freezed
sealed class WalletPreviewState with _$WalletPreviewState {
  /// Nothing to look ahead at: no address, or one with a single network.
  const factory WalletPreviewState.idle() = WalletPreviewIdle;

  /// The preview call is in flight.
  const factory WalletPreviewState.loading() = WalletPreviewLoading;

  /// The server's answer.
  const factory WalletPreviewState.loaded(WalletPreview preview) =
      WalletPreviewLoaded;

  /// The call failed. The wallet can still be added without it.
  const factory WalletPreviewState.failed(WalletPreviewFailure reason) =
      WalletPreviewFailed;
}

/// Where adding the wallet has got to.
///
/// None of these states holds what the person pasted: the paste field owns
/// the text, and only an address the parser accepted is ever sent.
@freezed
sealed class AddWalletSubmission with _$AddWalletSubmission {
  /// The form is open.
  const factory AddWalletSubmission.idle() = AddWalletIdle;

  /// The wallet is being connected and read for the first time.
  const factory AddWalletSubmission.reading(List<WalletNetwork> networks) =
      AddWalletReading;

  /// The wallet was created but every network failed to read. [reason] is
  /// the server's plain-words explanation, when there is one.
  const factory AddWalletSubmission.unreadable({
    required Wallet wallet,
    required String accountName,
    required List<WalletNetwork> networks,
    String? reason,
  }) = AddWalletUnreadable;

  /// The wallet is connected and read.
  const factory AddWalletSubmission.added({
    required Wallet wallet,
    required String accountName,
    required List<WalletNetwork> networks,
  }) = AddWalletAdded;

  /// Connecting failed, so no wallet exists. [message] is the server's
  /// plain-words explanation, or null for a transport failure.
  const factory AddWalletSubmission.failed(String? message) = AddWalletFailed;
}

/// The add-a-wallet flow: the look-ahead, the networks picked, and the
/// connect.
@freezed
abstract class AddWalletState with _$AddWalletState {
  const factory AddWalletState({
    @Default(WalletPreviewState.idle()) WalletPreviewState preview,

    /// The networks the wallet will read, in catalogue order.
    @Default(<WalletNetwork>[]) List<WalletNetwork> selected,
    @Default(AddWalletSubmission.idle()) AddWalletSubmission submission,
  }) = _AddWalletState;
}
