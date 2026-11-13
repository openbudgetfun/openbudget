import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:openbudget_core/src/wallets/address/wallet_address_family.dart';

part 'wallet_address_result.freezed.dart';

/// The outcome of a wallet address parse.
///
/// The parser returns one of three shapes: a match with one or more
/// candidates, a deliberate refusal (a secret or a form OpenBudget does not
/// accept), or an invalid input with a short hint. It never throws.
@freezed
sealed class WalletAddressParseResult with _$WalletAddressParseResult {
  const WalletAddressParseResult._();

  /// An accepted address or HD key. More than one candidate means the input
  /// is ambiguous; the caller previews each one and asks the user.
  const factory WalletAddressParseResult.match({
    required List<WalletAddressCandidate> candidates,
  }) = WalletAddressMatch;

  /// Input the app must not use, carrying the user-facing reason.
  const factory WalletAddressParseResult.refused(
    WalletAddressRefusal refusal,
  ) = WalletAddressRefused;

  /// Input that is not a known address form, with a short hint.
  const factory WalletAddressParseResult.invalid(String hint) =
      WalletAddressInvalid;
}

/// One way to read a parsed address.
@freezed
abstract class WalletAddressCandidate with _$WalletAddressCandidate {
  const factory WalletAddressCandidate({
    required WalletAddressFamily family,

    /// The serialized `WalletNetwork` names this candidate can be read on.
    ///
    /// Task W1.1 moves `WalletNetwork` into core. Until it lands, the parser
    /// uses the names it will serialise as, so it does not create a second
    /// network enum.
    required List<String> networks,

    /// The form to store, per `docs/multichain-wallets.md` section 5.2.
    required String canonical,

    /// The form to show in the app.
    required String display,
    required WalletAddressKind kind,

    /// The HD key's script type, or null when a bare `xpub` still has to be
    /// probed for one (section 5.4).
    WalletAddressHdScriptType? hdScriptType,
  }) = _WalletAddressCandidate;
}

/// Whether a candidate is one address or an HD key.
enum WalletAddressKind {
  /// A single address that can be read directly.
  address,

  /// An extended public key whose addresses are derived.
  hdKey,
}

/// The script type an HD key describes.
///
/// The names mirror the output descriptors in BIP 380 and BIP 386. A bare
/// `xpub` has no script type until the server probes the chain.
enum WalletAddressHdScriptType {
  /// `pkh(xpub…/<0;1>/*)`.
  pkh,

  /// `sh(wpkh(xpub…/<0;1>/*))`.
  shWpkh,

  /// `wpkh(xpub…/<0;1>/*)`.
  wpkh,
}

/// Why the parser deliberately refused an input.
enum WalletAddressRefusal {
  /// A WIF key, an extended private key, a raw 32-byte key or a recovery
  /// phrase. The message is shared so the app never says which form matched.
  privateKey(
    "That's a private key. OpenBudget never needs it. Clear it, and don't "
    'share it with anyone.',
  ),

  /// Twelve, fifteen, eighteen, twenty-one or twenty-four words that look
  /// like a recovery phrase.
  recoveryPhrase(
    "That's a private key. OpenBudget never needs it. Clear it, and don't "
    'share it with anyone.',
  ),

  /// A testnet address or extended key. OpenBudget values mainnet assets
  /// only, and a testnet address cannot hold them.
  testnet('OpenBudget only supports mainnet addresses.'),

  /// A multisig extended key (`Ypub` or `Zpub`). Every co-signer's key is
  /// needed, which is a later feature.
  multisigKey("Multisig keys aren't supported yet."),

  /// An XRP Ledger X-address carrying a destination tag. Its balance belongs
  /// to the exchange account, not to the person who pasted it.
  xAddressWithTag(
    'That X-address points at an exchange account. '
    'Use the address for your own account.',
  ),

  /// A `0x` followed by 64 hex digits. It may be a private key until Sui and
  /// Aptos addresses are supported.
  evmPrivateKey(
    'That looks like a private key, not an address. '
    'OpenBudget never needs it.',
  );

  const WalletAddressRefusal(this.message);

  /// A plain-English explanation the app can show.
  final String message;
}

/// Convenience accessors that read like the rest of the wallet model.
extension WalletAddressCandidateX on WalletAddressCandidate {
  /// Whether this candidate is an HD key rather than one address.
  bool get isHdKey => kind == WalletAddressKind.hdKey;

  /// Whether this is a bare `xpub` whose script type still needs probing.
  bool get isScriptTypeAmbiguous => isHdKey && hdScriptType == null;
}

/// Convenience accessors for the matched result.
extension WalletAddressMatchX on WalletAddressMatch {
  /// The only candidate, for the common unambiguous case.
  WalletAddressCandidate get candidate => candidates.single;
}
