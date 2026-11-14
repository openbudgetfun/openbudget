import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The network's name in the reader's language.
String walletNetworkLabel(AppLocalizations l10n, WalletNetwork network) =>
    switch (network) {
      WalletNetwork.solanaMainnet => l10n.walletHoldingsNetworkSolana,
      WalletNetwork.solanaDevnet => l10n.walletHoldingsNetworkSolanaDevnet,
      WalletNetwork.bitcoinMainnet => l10n.walletHoldingsNetworkBitcoin,
      WalletNetwork.ethereumMainnet => l10n.walletHoldingsNetworkEthereum,
      WalletNetwork.baseMainnet => l10n.walletHoldingsNetworkBase,
      WalletNetwork.arbitrumOne => l10n.walletHoldingsNetworkArbitrumOne,
      WalletNetwork.opMainnet => l10n.walletHoldingsNetworkOpMainnet,
      WalletNetwork.polygonPos => l10n.walletHoldingsNetworkPolygonPos,
      WalletNetwork.bnbSmartChain => l10n.walletHoldingsNetworkBnbSmartChain,
      WalletNetwork.avalancheCChain =>
        l10n.walletHoldingsNetworkAvalancheCChain,
      WalletNetwork.tronMainnet => l10n.walletHoldingsNetworkTron,
      WalletNetwork.xrplMainnet => l10n.walletHoldingsNetworkXrpl,
      WalletNetwork.hyperliquid => l10n.walletHoldingsNetworkHyperliquid,
      WalletNetwork.dogecoinMainnet => l10n.walletHoldingsNetworkDogecoin,
      WalletNetwork.litecoinMainnet => l10n.walletHoldingsNetworkLitecoin,
      WalletNetwork.cardanoMainnet => l10n.walletHoldingsNetworkCardano,
      WalletNetwork.tonMainnet => l10n.walletHoldingsNetworkTon,
      WalletNetwork.suiMainnet => l10n.walletHoldingsNetworkSui,
      WalletNetwork.aptosMainnet => l10n.walletHoldingsNetworkAptos,
    };

/// How long ago [then] was, as the phrase that follows "Read", "from" and
/// "Showing amounts from": "less than a minute ago", "5 minutes ago",
/// "2 hours ago", "3 days ago".
///
/// A [then] in the future (clock skew) reads as "less than a minute ago".
String walletAgeLabel(AppLocalizations l10n, DateTime then, DateTime now) {
  final age = now.difference(then);
  if (age.inHours >= 24) return l10n.walletHoldingsAgeDays(age.inDays);
  if (age.inMinutes >= 60) return l10n.walletHoldingsAgeHours(age.inHours);
  return l10n.walletHoldingsAgeMinutes(age.isNegative ? 0 : age.inMinutes);
}
