import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The wallet every holdings fixture belongs to.
const String fixtureWalletId = '00000000-0000-0000-0000-0000000000abc1';

/// A holding on [network] with the fields a test cares about set. Priced
/// live in USD unless told otherwise.
WalletHolding fixtureHolding({
  required WalletNetwork network,
  required String id,
  String assetId = 'native',
  String? symbol,
  String? name,
  int decimals = 18,
  BigInt? quantityRaw,
  HoldingPosition position = HoldingPosition.available,
  SpamVerdict spamVerdict = SpamVerdict.clean,
  PriceQuality priceQuality = PriceQuality.live,
  int? valueMinor,
  int? costBasisMinor,
  DateTime? priceAsOf,
}) => WalletHolding(
  id: UuidValue.fromString(id),
  walletId: UuidValue.fromString(fixtureWalletId),
  network: network,
  assetId: assetId,
  position: position,
  symbol: symbol,
  name: name,
  decimals: decimals,
  quantityRaw: quantityRaw ?? BigInt.from(10).pow(decimals),
  spamVerdict: spamVerdict,
  priceCurrencyCode: 'USD',
  valueMinor: priceQuality == PriceQuality.unpriced ? null : valueMinor,
  priceQuality: priceQuality,
  priceAsOf: priceAsOf,
  costBasisMinor: costBasisMinor,
);

/// One network's read state for the fixture wallet.
WalletNetworkState fixtureNetworkState(
  WalletNetwork network, {
  DateTime? lastReadAt,
  String? lastError,
}) => WalletNetworkState(
  walletId: UuidValue.fromString(fixtureWalletId),
  network: network,
  lastReadAt: lastReadAt,
  lastError: lastError,
);

/// An EVM-style wallet on three networks, read at [now]:
///
/// - Ethereum, read 5 minutes ago: ETH, USDC and ETH staked.
/// - Base, whose read failed after a good one 2 hours ago: ETH priced from
///   a cached quote 3 days old.
/// - Arbitrum One, read 1 hour ago: ARB with unclaimed rewards.
/// - Hidden: a suspected scam token, an unpriced one, and one the person
///   hid.
({List<WalletHolding> holdings, List<WalletNetworkState> states})
fixtureEvmWallet(DateTime now) => (
  holdings: [
    fixtureHolding(
      network: WalletNetwork.ethereumMainnet,
      id: '00000000-0000-0000-0000-000000000e01',
      symbol: 'ETH',
      name: 'Ether',
      valueMinor: 412050,
      costBasisMinor: 350000,
    ),
    fixtureHolding(
      network: WalletNetwork.ethereumMainnet,
      id: '00000000-0000-0000-0000-000000000e02',
      assetId: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
      symbol: 'USDC',
      name: 'USD Coin',
      decimals: 6,
      quantityRaw: BigInt.from(125000000),
      valueMinor: 12500,
    ),
    fixtureHolding(
      network: WalletNetwork.ethereumMainnet,
      id: '00000000-0000-0000-0000-000000000e03',
      symbol: 'ETH',
      name: 'Ether',
      position: HoldingPosition.staked,
      quantityRaw: BigInt.from(10).pow(18) * BigInt.from(2),
      valueMinor: 824100,
    ),
    fixtureHolding(
      network: WalletNetwork.baseMainnet,
      id: '00000000-0000-0000-0000-000000000b01',
      symbol: 'ETH',
      name: 'Ether',
      quantityRaw: BigInt.from(10).pow(17) * BigInt.from(5),
      priceQuality: PriceQuality.cached,
      priceAsOf: now.subtract(const Duration(days: 3)),
      valueMinor: 206025,
    ),
    fixtureHolding(
      network: WalletNetwork.arbitrumOne,
      id: '00000000-0000-0000-0000-000000000a01',
      assetId: '0x912ce59144191c1204e64559fe8253a0e49e6548',
      symbol: 'ARB',
      name: 'Arbitrum',
      quantityRaw: BigInt.from(10).pow(18) * BigInt.from(240),
      valueMinor: 21600,
      costBasisMinor: 30000,
    ),
    fixtureHolding(
      network: WalletNetwork.arbitrumOne,
      id: '00000000-0000-0000-0000-000000000a02',
      assetId: '0x912ce59144191c1204e64559fe8253a0e49e6548',
      symbol: 'ARB',
      name: 'Arbitrum',
      position: HoldingPosition.unclaimedRewards,
      quantityRaw: BigInt.from(10).pow(18) * BigInt.from(12),
      valueMinor: 1080,
    ),
    fixtureHolding(
      network: WalletNetwork.ethereumMainnet,
      id: '00000000-0000-0000-0000-000000000e04',
      assetId: '0x0000000000000000000000000000000000c1a1m',
      symbol: 'CLAIM-USDC.xyz',
      name: 'Visit claim-usdc.xyz',
      spamVerdict: SpamVerdict.suspected,
      valueMinor: 9900000,
    ),
    fixtureHolding(
      network: WalletNetwork.baseMainnet,
      id: '00000000-0000-0000-0000-000000000b02',
      assetId: '0x00000000000000000000000000000000000b0b0b',
      symbol: 'OBSC',
      name: 'Obscure',
      priceQuality: PriceQuality.unpriced,
    ),
    fixtureHolding(
      network: WalletNetwork.arbitrumOne,
      id: '00000000-0000-0000-0000-000000000a03',
      assetId: '0x00000000000000000000000000000000000d0575',
      symbol: 'DUST',
      name: 'Dust',
      spamVerdict: SpamVerdict.hiddenByUser,
      valueMinor: 40,
    ),
  ],
  states: [
    fixtureNetworkState(
      WalletNetwork.ethereumMainnet,
      lastReadAt: now.subtract(const Duration(minutes: 5)),
    ),
    fixtureNetworkState(
      WalletNetwork.baseMainnet,
      lastReadAt: now.subtract(const Duration(hours: 2)),
      lastError: 'Base did not answer in time.',
    ),
    fixtureNetworkState(
      WalletNetwork.arbitrumOne,
      lastReadAt: now.subtract(const Duration(hours: 1)),
    ),
  ],
);
