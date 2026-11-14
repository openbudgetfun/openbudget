import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Whether a refusal is for something secret. The paste field clears itself
/// for these, so the secret never stays on screen.
bool isSecretRefusal(WalletAddressRefusal refusal) => switch (refusal) {
  WalletAddressRefusal.privateKey ||
  WalletAddressRefusal.recoveryPhrase ||
  WalletAddressRefusal.evmPrivateKey => true,
  WalletAddressRefusal.testnet ||
  WalletAddressRefusal.multisigKey ||
  WalletAddressRefusal.xAddressWithTag => false,
};

/// The title and plain words shown for a refused input, in the reader's
/// language. The parser's own English message is never shown.
({String title, String message}) walletRefusalCopy(
  AppLocalizations l10n,
  WalletAddressRefusal refusal,
) => switch (refusal) {
  WalletAddressRefusal.privateKey || WalletAddressRefusal.recoveryPhrase => (
    title: l10n.walletAddRefusedPrivateKeyTitle,
    message: l10n.walletAddRefusedPrivateKeyMessage,
  ),
  WalletAddressRefusal.evmPrivateKey => (
    title: l10n.walletAddRefusedEvmKeyTitle,
    message: l10n.walletAddRefusedEvmKeyMessage,
  ),
  WalletAddressRefusal.testnet => (
    title: l10n.walletAddRefusedTestnetTitle,
    message: l10n.walletAddRefusedTestnetMessage,
  ),
  WalletAddressRefusal.multisigKey => (
    title: l10n.walletAddRefusedMultisigTitle,
    message: l10n.walletAddRefusedMultisigMessage,
  ),
  WalletAddressRefusal.xAddressWithTag => (
    title: l10n.walletAddRefusedExchangeTitle,
    message: l10n.walletAddRefusedExchangeMessage,
  ),
};

/// The inline message for an input the parser called invalid.
///
/// The parser gives a short English hint. Its two specific hints are mapped
/// to their own words, and anything else gets the general one.
String walletInvalidMessage(AppLocalizations l10n, String hint) {
  if (hint.startsWith('One character')) return l10n.walletAddInvalidChecksum;
  if (hint.contains('extended key')) return l10n.walletAddInvalidKey;
  return l10n.walletAddInvalidInput;
}

/// An address cut to its first and last four characters, such as
/// `0xAb…12cD`. A short value is returned whole.
String shortWalletAddress(String address) {
  if (address.length <= 12) return address;
  return '${address.substring(0, 4)}…'
      '${address.substring(address.length - 4)}';
}

/// The kind of an extended public key as its first four letters, such as
/// `zpub`: the form wallets show, and the one a person recognises.
String walletKeyType(String key) {
  final prefix = key.trim();
  return (prefix.length < 4 ? prefix : prefix.substring(0, 4)).toLowerCase();
}

/// A list of networks as a phrase: "Ethereum", "Ethereum and Base",
/// "Ethereum, Base and Arbitrum One", then "Ethereum, Base, Arbitrum One and
/// 4 more".
String walletNetworkListLabel(
  AppLocalizations l10n,
  List<WalletNetwork> networks,
) {
  final names = [for (final n in networks) walletNetworkLabel(l10n, n)];
  return switch (names.length) {
    0 => '',
    1 => names[0],
    2 => l10n.walletAddNamesTwo(names[0], names[1]),
    3 => l10n.walletAddNamesThree(names[0], names[1], names[2]),
    _ => l10n.walletAddNamesMore(
      names[0],
      names[1],
      names[2],
      names.length - 3,
    ),
  };
}

/// The name given to a new wallet's crypto account, so the account list
/// reads in the person's language rather than the server's fallback.
///
/// "Ethereum wallet (0xAb…12cD)" for an address, "Bitcoin wallet, zpub" for
/// an extended public key. [input] is what was pasted; only its public
/// shape is used.
String walletAccountName(
  AppLocalizations l10n, {
  required WalletAddressCandidate candidate,
  required String input,
}) {
  final chain = walletNetworkLabel(l10n, candidate.networks.first);
  if (candidate.isHdKey) {
    return l10n.walletAddAccountNameKey(chain, walletKeyType(input));
  }
  return l10n.walletAddAccountNameAddress(
    chain,
    shortWalletAddress(candidate.display),
  );
}

/// The words a screen reader says for a chain stamp. A filled stamp is
/// "detected" unless [inked] says otherwise.
ObChainStampWords walletStampWords(AppLocalizations l10n, {String? inked}) =>
    ObChainStampWords(
      inked: inked ?? l10n.walletAddStampDetected,
      selected: l10n.walletAddStampIncluded,
      unselected: l10n.walletAddStampLeftOut,
      outline: l10n.walletAddStampLeftOut,
    );

/// What a preview found on one network, in a few words: its priced value,
/// "No price", "Nothing" or "Can't read". Lettered on the network's stamp.
String walletPreviewRowLabel(AppLocalizations l10n, WalletPreviewNetwork row) {
  final value = row.valueMinor;
  if (row.readError != null) return l10n.walletAddNetworkUnreadable;
  if (row.pricedHoldingCount > 0 && value != null) {
    return formatMinorForCode(value, row.valueCurrencyCode ?? 'USD');
  }
  if (row.holdingCount > 0) return l10n.walletAddNetworkNoPrice;
  return l10n.walletAddNetworkNothing;
}
