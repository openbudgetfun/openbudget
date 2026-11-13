import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:openbudget_core/src/wallets/address/base58.dart';
import 'package:openbudget_core/src/wallets/address/wallet_address_result.dart';

/// SLIP-132 extended key version bytes used by the launch parser.
enum ExtendedKeyVersion {
  xpub(0x0488b21e),
  ypub(0x049d7cb2),
  zpub(0x04b24746),
  multisigYpub(0x0295b43f),
  multisigZpub(0x02aa7ed3),
  tpub(0x043587cf),
  vpub(0x045f1cf6),
  upub(0x044a5262),
  xprv(0x0488ade4),
  yprv(0x049d7878),
  zprv(0x04b2430c),
  tprv(0x04358394),
  uprv(0x044a4e28),
  vprv(0x045f18bc);

  const ExtendedKeyVersion(this.version);

  /// The four version bytes as a big-endian integer.
  final int version;

  /// Whether this version holds a private key.
  bool get isPrivate => switch (this) {
    xprv || yprv || zprv || tprv || uprv || vprv => true,
    _ => false,
  };

  /// Whether this version belongs on a test network.
  bool get isTestnet => switch (this) {
    tpub || vpub || upub || tprv || uprv || vprv => true,
    _ => false,
  };

  /// Whether this version describes a multisig account.
  bool get isMultisig => switch (this) {
    multisigYpub || multisigZpub => true,
    _ => false,
  };

  /// The script type for a mainnet single-signature key, or null when the
  /// version does not fix one (a bare `xpub`).
  WalletAddressHdScriptType? get scriptType => switch (this) {
    ypub => WalletAddressHdScriptType.shWpkh,
    zpub => WalletAddressHdScriptType.wpkh,
    _ => null,
  };
}

/// Looks up an extended key version, or returns null for a version the
/// parser does not know.
ExtendedKeyVersion? extendedKeyVersion(int version) {
  for (final value in ExtendedKeyVersion.values) {
    if (value.version == version) return value;
  }
  return null;
}

/// Replaces the version bytes of the 78-byte [payload] with `xpub` and
/// returns the canonical key string.
String normaliseToXpub(Uint8List payload) {
  final copy = Uint8List.fromList(payload);
  writeUint32(copy, 0, ExtendedKeyVersion.xpub.version);
  return base58CheckEncode(copy);
}

/// The canonical BIP 380 descriptor for a single-signature key, or null for
/// a bare `xpub`, whose script type still has to be probed.
String? descriptorFor(ExtendedKeyVersion version, String xpub) =>
    switch (version) {
      ExtendedKeyVersion.ypub => 'sh(wpkh($xpub/<0;1>/*))',
      ExtendedKeyVersion.zpub => 'wpkh($xpub/<0;1>/*)',
      _ => null,
    };

/// `hd:` plus the first 40 hex digits of SHA-256 of [basis].
///
/// For `ypub` and `zpub` the basis is the canonical descriptor. For a bare
/// `xpub` it is the normalised key string, because the descriptor's script
/// type is not known until the server probes the chain (section 5.4).
String hdIdentity(String basis) {
  final digest = sha256.convert(utf8.encode(basis)).toString();
  return 'hd:${digest.substring(0, 40)}';
}
