/// The chain family a network belongs to: one integration per family.
///
/// A pure function of the network, derived through the network rules and
/// never stored.
enum ChainFamily {
  solana,
  bitcoin,
  evm,
  tron,
  xrpl,
  hyperliquid,
  dogecoin,
  litecoin,
  cardano,
  ton,
  sui,
  aptos,
}
