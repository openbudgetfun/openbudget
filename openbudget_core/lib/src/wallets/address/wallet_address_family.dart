/// The chain family a parsed wallet address belongs to.
///
/// This is the parser's own minimal launch set, kept in the address folder so
/// the address parser can land before the shared chain catalogue. Task W1.1
/// moves the production `ChainFamily` enum into core; when it lands, replace
/// this enum with that one (the names match) and delete this file.
enum WalletAddressFamily {
  /// Solana, including the development network in development builds.
  solana,

  /// Bitcoin mainnet, including single addresses and HD keys.
  bitcoin,

  /// Every EVM network and Hyperliquid, which share the same address form.
  evm,

  /// Tron mainnet.
  tron,

  /// The XRP Ledger.
  xrpl,
}
