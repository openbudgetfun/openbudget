import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

part 'wallet_holdings_view.freezed.dart';

/// Why a holding sits in the Hidden group rather than in its network's
/// section. A holding has exactly one reason; the first that applies wins.
enum HiddenReason {
  /// The person hid it.
  hiddenByUser,

  /// The spam classifier suspects it.
  suspected,

  /// No usable price, so it adds nothing to the total.
  unpriced,
}

/// One asset on one network, with every position the wallet holds of it.
///
/// [primary] is the spendable holding (or the first position when none is
/// spendable); [positions] are the staked and unclaimed holdings that sit
/// beneath it.
@freezed
abstract class WalletAssetGroup with _$WalletAssetGroup {
  const factory WalletAssetGroup({
    required WalletHolding primary,
    @Default(<WalletHolding>[]) List<WalletHolding> positions,
  }) = _WalletAssetGroup;

  const WalletAssetGroup._();

  /// Every holding in the group, [primary] first.
  List<WalletHolding> get holdings => [primary, ...positions];
}

/// One network's part of a wallet: the holdings that count, their subtotal,
/// and how the last read of the network went.
@freezed
abstract class WalletNetworkSection with _$WalletNetworkSection {
  const factory WalletNetworkSection({
    required WalletNetwork network,
    required List<WalletAssetGroup> groups,

    /// Sum of the counted holdings' `valueMinor`, or null when none counts.
    required int? subtotalMinor,

    /// The currency of [subtotalMinor].
    required String currencyCode,

    /// When the network was last read successfully, if ever.
    DateTime? lastReadAt,

    /// The last read's failure in plain words; null when it succeeded.
    String? lastError,

    /// Whether the network has a read-state row at all.
    @Default(false) bool hasReadState,
  }) = _WalletNetworkSection;

  const WalletNetworkSection._();

  /// Whether the last read of this network failed.
  bool get failed => lastError != null;
}

/// A holding in the Hidden group, with the reason it is there.
@freezed
abstract class HiddenHolding with _$HiddenHolding {
  const factory HiddenHolding({
    required WalletHolding holding,
    required HiddenReason reason,
  }) = _HiddenHolding;
}

/// A wallet's holdings as the screen draws them: one section per network and
/// one Hidden group.
@freezed
abstract class WalletHoldingsView with _$WalletHoldingsView {
  const factory WalletHoldingsView({
    required List<WalletNetworkSection> sections,
    required List<HiddenHolding> hidden,
  }) = _WalletHoldingsView;

  const WalletHoldingsView._();

  /// Whether there is nothing at all to draw.
  bool get isEmpty => sections.isEmpty && hidden.isEmpty;

  /// How many hidden holdings have [reason].
  int hiddenCount(HiddenReason reason) =>
      hidden.where((entry) => entry.reason == reason).length;
}

/// Whether [holding] is priced well enough to count toward net worth.
bool isPricedHolding(WalletHolding holding) =>
    holding.priceQuality != PriceQuality.unpriced && holding.valueMinor != null;

/// Whether the wallet's valuation counts [holding]: priced, and not
/// suspected or hidden.
bool isCountedHolding(WalletHolding holding) =>
    isPricedHolding(holding) &&
    (holding.spamVerdict == SpamVerdict.clean ||
        holding.spamVerdict == SpamVerdict.allowedByUser);

/// The reason [holding] is hidden, or null when it counts.
HiddenReason? hiddenReasonOf(WalletHolding holding) {
  if (holding.spamVerdict == SpamVerdict.hiddenByUser) {
    return HiddenReason.hiddenByUser;
  }
  if (holding.spamVerdict == SpamVerdict.suspected) {
    return HiddenReason.suspected;
  }
  if (!isPricedHolding(holding)) return HiddenReason.unpriced;
  return null;
}

/// Splits [holdings] into network sections and the Hidden group.
///
/// Sections are ordered by subtotal, largest first, with the chain order of
/// [WalletNetwork] breaking ties. A network appears when it has a counted
/// holding, or when its last read failed (its note must show). Within a
/// section the assets are ordered by value, and each asset's staked and
/// unclaimed positions follow its spendable holding.
WalletHoldingsView buildWalletHoldingsView({
  required List<WalletHolding> holdings,
  required List<WalletNetworkState> networkStates,
  required String fallbackCurrencyCode,
}) {
  final stateByNetwork = {
    for (final state in networkStates) state.network: state,
  };
  final countedByNetwork = <WalletNetwork, List<WalletHolding>>{};
  final hidden = <HiddenHolding>[];

  for (final holding in holdings) {
    final reason = hiddenReasonOf(holding);
    if (reason != null) {
      hidden.add(HiddenHolding(holding: holding, reason: reason));
    } else {
      countedByNetwork.putIfAbsent(holding.network, () => []).add(holding);
    }
  }

  final networks = {
    ...countedByNetwork.keys,
    for (final state in networkStates)
      if (state.lastError != null) state.network,
  };

  final sections = [
    for (final network in networks)
      _sectionFor(
        network: network,
        counted: countedByNetwork[network] ?? const [],
        state: stateByNetwork[network],
        fallbackCurrencyCode: fallbackCurrencyCode,
      ),
  ]..sort(_bySubtotalThenChain);

  hidden.sort(
    (a, b) => a.reason.index != b.reason.index
        ? a.reason.index.compareTo(b.reason.index)
        : _byNetworkThenSymbol(a.holding, b.holding),
  );

  return WalletHoldingsView(sections: sections, hidden: hidden);
}

WalletNetworkSection _sectionFor({
  required WalletNetwork network,
  required List<WalletHolding> counted,
  required WalletNetworkState? state,
  required String fallbackCurrencyCode,
}) {
  final byAsset = <String, List<WalletHolding>>{};
  for (final holding in counted) {
    byAsset.putIfAbsent(holding.assetId, () => []).add(holding);
  }
  final groups = [
    for (final positions in byAsset.values) _groupOf(positions),
  ]..sort((a, b) => _assetValue(b).compareTo(_assetValue(a)));

  return WalletNetworkSection(
    network: network,
    groups: groups,
    subtotalMinor: counted.isEmpty
        ? null
        : counted.fold<int>(0, (sum, h) => sum + (h.valueMinor ?? 0)),
    currencyCode: counted.isEmpty
        ? fallbackCurrencyCode
        : counted.first.priceCurrencyCode ?? fallbackCurrencyCode,
    lastReadAt: state?.lastReadAt,
    lastError: state?.lastError,
    hasReadState: state != null,
  );
}

WalletAssetGroup _groupOf(List<WalletHolding> positions) {
  final ordered = [...positions]
    ..sort((a, b) => a.position.index.compareTo(b.position.index));
  return WalletAssetGroup(
    primary: ordered.first,
    positions: ordered.skip(1).toList(),
  );
}

int _assetValue(WalletAssetGroup group) =>
    group.holdings.fold<int>(0, (sum, h) => sum + (h.valueMinor ?? 0));

int _bySubtotalThenChain(WalletNetworkSection a, WalletNetworkSection b) {
  final byValue = (b.subtotalMinor ?? 0).compareTo(a.subtotalMinor ?? 0);
  return byValue != 0 ? byValue : a.network.index.compareTo(b.network.index);
}

int _byNetworkThenSymbol(WalletHolding a, WalletHolding b) {
  final byNetwork = a.network.index.compareTo(b.network.index);
  if (byNetwork != 0) return byNetwork;
  return (a.symbol ?? a.assetId).compareTo(b.symbol ?? b.assetId);
}
