import 'package:openbudget_core/src/wallets/address/base58.dart';
import 'package:openbudget_core/src/wallets/address/bech32.dart';
import 'package:openbudget_core/src/wallets/address/evm_address.dart';
import 'package:openbudget_core/src/wallets/address/hd_key.dart';
import 'package:openbudget_core/src/wallets/address/ton_friendly_address.dart';
import 'package:openbudget_core/src/wallets/address/wallet_address_family.dart';
import 'package:openbudget_core/src/wallets/address/wallet_address_result.dart';

/// Parses wallet addresses for every launch chain family.
///
/// The parser is pure Dart: it never throws, never touches the network and
/// never logs its input. It returns a [WalletAddressParseResult] that the app
/// can render as the user types and the server can check again before a read.
///
/// The spec is `docs/multichain-wallets.md` section 5.
abstract final class WalletAddressParser {
  /// Parses [input] into a match, a refusal or an invalid result.
  static WalletAddressParseResult parse(String input) {
    final value = input.trim();
    if (value.isEmpty || value.length > _maxInputLength) {
      return const WalletAddressInvalid(_genericHint);
    }

    final refusal = _secretForm(value);
    if (refusal != null) {
      return WalletAddressRefused(refusal);
    }

    final extendedKey = _extendedKey(value);
    if (extendedKey != null) {
      return extendedKey;
    }

    if (value.startsWith('0x') || value.startsWith('0X')) {
      return _evm(value);
    }

    final lower = value.toLowerCase();
    if (lower.startsWith('bc1') ||
        lower.startsWith('tb1') ||
        lower.startsWith('bcrt1')) {
      return _segwit(value);
    }

    if (isTonTestnetAddress(value)) {
      return const WalletAddressRefused(WalletAddressRefusal.testnet);
    }

    final xAddress = _xAddress(value);
    if (xAddress != null) {
      return xAddress;
    }

    final tron = _tron(value);
    if (tron != null) {
      return tron;
    }

    final xrp = _xrpClassic(value);
    if (xrp != null) {
      return xrp;
    }

    final bitcoin = _bitcoinBase58(value);
    if (bitcoin != null) {
      return bitcoin;
    }

    if (_isSolanaAddress(value)) {
      return _solana(value);
    }

    return const WalletAddressInvalid(_genericHint);
  }

  static WalletAddressRefusal? _secretForm(String value) {
    if (_looksLikeRecoveryPhrase(value)) {
      return WalletAddressRefusal.recoveryPhrase;
    }
    if (_looksLikeJsonSecretKey(value)) {
      return WalletAddressRefusal.privateKey;
    }
    if (isRawHexKey(value)) {
      return WalletAddressRefusal.privateKey;
    }
    final lower = value.toLowerCase();
    if (lower.startsWith('0x') && isRawHexKey(value.substring(2))) {
      return WalletAddressRefusal.evmPrivateKey;
    }

    final decoded = base58Decode(value);
    if (decoded != null && decoded.length == 64) {
      return WalletAddressRefusal.privateKey;
    }

    final payload = base58CheckPayload(value);
    if (payload == null) {
      return null;
    }
    if ((payload.length == 33 || payload.length == 34) &&
        (payload.first == 0x80 || payload.first == 0xef)) {
      return WalletAddressRefusal.privateKey;
    }
    if (payload.length == 78) {
      final version = extendedKeyVersion(readUint32(payload, 0));
      if (version != null && version.isPrivate) {
        return WalletAddressRefusal.privateKey;
      }
    }
    return null;
  }

  static WalletAddressParseResult? _extendedKey(String value) {
    final decoded = base58Decode(value);
    if (decoded == null || decoded.length != 82) {
      return null;
    }
    final payload = decoded.sublist(0, 78);
    final checksum = decoded.sublist(78);
    if (!checksumMatches(payload, checksum)) {
      return const WalletAddressInvalid(_checksumHint);
    }
    final version = extendedKeyVersion(readUint32(payload, 0));
    if (version == null) {
      return const WalletAddressInvalid(_unknownKeyHint);
    }
    if (version.isPrivate) {
      return const WalletAddressRefused(WalletAddressRefusal.privateKey);
    }
    if (version.isMultisig) {
      return const WalletAddressRefused(WalletAddressRefusal.multisigKey);
    }
    if (version.isTestnet) {
      return const WalletAddressRefused(WalletAddressRefusal.testnet);
    }
    final xpub = normaliseToXpub(payload);
    final descriptor = descriptorFor(version, xpub);
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.bitcoin,
          networks: const ['bitcoinMainnet'],
          canonical: hdIdentity(descriptor ?? xpub),
          display: _shorten(xpub),
          kind: WalletAddressKind.hdKey,
          hdScriptType: version.scriptType,
        ),
      ],
    );
  }

  static WalletAddressParseResult _evm(String value) {
    final body = value.substring(2);
    if (body.length != 40) {
      return isRawHexKey(body)
          ? const WalletAddressRefused(WalletAddressRefusal.evmPrivateKey)
          : const WalletAddressInvalid(_genericHint);
    }
    if (!isEvmAddressBody(body)) {
      return const WalletAddressInvalid(_genericHint);
    }
    final lower = body.toLowerCase();
    final checksummed = eip55Checksum(lower);
    final allLower = body == lower;
    final allUpper = body == body.toUpperCase();
    if (!allLower && !allUpper && body != checksummed.substring(2)) {
      return const WalletAddressInvalid(_checksumHint);
    }
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.evm,
          networks: _evmNetworks,
          canonical: '0x$lower',
          display: checksummed,
          kind: WalletAddressKind.address,
        ),
      ],
    );
  }

  static WalletAddressParseResult _segwit(String value) {
    final decoded = decodeSegwitAddress(value);
    final address = decoded.address;
    if (address == null) {
      return WalletAddressInvalid(
        decoded.checksumFailed ? _checksumHint : _genericHint,
      );
    }
    if (address.hrp == 'tb' || address.hrp == 'bcrt') {
      return const WalletAddressRefused(WalletAddressRefusal.testnet);
    }
    if (address.hrp != 'bc') {
      return const WalletAddressInvalid(_genericHint);
    }
    final canonical = value.toLowerCase();
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.bitcoin,
          networks: const ['bitcoinMainnet'],
          canonical: canonical,
          display: _shorten(canonical),
          kind: WalletAddressKind.address,
        ),
      ],
    );
  }

  static WalletAddressParseResult? _xAddress(String value) {
    // X-addresses are 35 bytes of Base58, which is 47 or 48 characters. A
    // shorter X- or T-prefixed string may be a Solana address, so leave it
    // for the later check instead of rejecting it here.
    if (value.length < 45) {
      return null;
    }
    final startsMainnet = value.startsWith('X');
    final startsTestnet = value.startsWith('T');
    if (!startsMainnet && !startsTestnet) {
      return null;
    }
    final decoded = base58Decode(value, alphabet: rippleBase58Alphabet);
    if (decoded == null || decoded.length != 35) {
      return const WalletAddressInvalid(_genericHint);
    }
    final payload = decoded.sublist(0, 31);
    final checksum = decoded.sublist(31);
    if (!checksumMatches(payload, checksum)) {
      return const WalletAddressInvalid(_checksumHint);
    }
    final prefix = (payload[0] << 8) | payload[1];
    if (prefix == _xAddressTestnetPrefix) {
      return const WalletAddressRefused(WalletAddressRefusal.testnet);
    }
    if (prefix != _xAddressMainnetPrefix) {
      return const WalletAddressInvalid(_genericHint);
    }
    final flag = payload[22];
    if (flag > 1) {
      return const WalletAddressInvalid(_genericHint);
    }
    final accountId = payload.sublist(2, 22);
    if (flag == 1) {
      for (var index = 27; index < 31; index++) {
        if (payload[index] != 0) {
          return const WalletAddressInvalid(_genericHint);
        }
      }
      return const WalletAddressRefused(WalletAddressRefusal.xAddressWithTag);
    }
    for (var index = 23; index < 31; index++) {
      if (payload[index] != 0) {
        return const WalletAddressInvalid(_genericHint);
      }
    }
    final classic = _xrpClassicFromAccountId(accountId);
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.xrpl,
          networks: const ['xrplMainnet'],
          canonical: classic,
          display: classic,
          kind: WalletAddressKind.address,
        ),
      ],
    );
  }

  static WalletAddressParseResult? _tron(String value) {
    if (value.length == 42 && _hex42.hasMatch(value)) {
      if (value.substring(0, 2).toLowerCase() != '41') {
        return null;
      }
      final bytes = <int>[];
      for (var index = 0; index < value.length; index += 2) {
        bytes.add(int.parse(value.substring(index, index + 2), radix: 16));
      }
      final canonical = base58CheckEncode(bytes);
      return WalletAddressMatch(
        candidates: [
          WalletAddressCandidate(
            family: WalletAddressFamily.tron,
            networks: const ['tronMainnet'],
            canonical: canonical,
            display: canonical,
            kind: WalletAddressKind.address,
          ),
        ],
      );
    }
    if (!value.startsWith('T') || value.length != 34) {
      return null;
    }
    final decoded = base58Decode(value);
    if (decoded == null || decoded.length != 25) {
      return const WalletAddressInvalid(_genericHint);
    }
    final payload = decoded.sublist(0, 21);
    final checksum = decoded.sublist(21);
    if (!checksumMatches(payload, checksum)) {
      return const WalletAddressInvalid(_checksumHint);
    }
    if (payload.first != 0x41) {
      return const WalletAddressInvalid(_genericHint);
    }
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.tron,
          networks: const ['tronMainnet'],
          canonical: value,
          display: value,
          kind: WalletAddressKind.address,
        ),
      ],
    );
  }

  static WalletAddressParseResult? _xrpClassic(String value) {
    if (!value.startsWith('r') || value.length < 25 || value.length > 35) {
      return null;
    }
    final decoded = base58Decode(value, alphabet: rippleBase58Alphabet);
    if (decoded == null || decoded.length != 25) {
      return const WalletAddressInvalid(_genericHint);
    }
    final payload = decoded.sublist(0, 21);
    final checksum = decoded.sublist(21);
    if (!checksumMatches(payload, checksum)) {
      return const WalletAddressInvalid(_checksumHint);
    }
    if (payload.first != 0x00) {
      return const WalletAddressInvalid(_genericHint);
    }
    return WalletAddressMatch(
      candidates: [
        WalletAddressCandidate(
          family: WalletAddressFamily.xrpl,
          networks: const ['xrplMainnet'],
          canonical: value,
          display: value,
          kind: WalletAddressKind.address,
        ),
      ],
    );
  }

  static WalletAddressParseResult? _bitcoinBase58(String value) {
    if (value.length < 26 || value.length > 35) {
      return null;
    }
    final decoded = base58Decode(value);
    if (decoded == null || decoded.length != 25) {
      return null;
    }
    final payload = decoded.sublist(0, 21);
    final checksum = decoded.sublist(21);
    if (!checksumMatches(payload, checksum)) {
      final first = value[0];
      return first == '1' || first == '3' || first == 'm' || first == 'n'
          ? const WalletAddressInvalid(_checksumHint)
          : null;
    }
    return switch (payload.first) {
      0x00 || 0x05 => WalletAddressMatch(
        candidates: [
          WalletAddressCandidate(
            family: WalletAddressFamily.bitcoin,
            networks: const ['bitcoinMainnet'],
            canonical: value,
            display: _shorten(value),
            kind: WalletAddressKind.address,
          ),
        ],
      ),
      0x6f || 0xc4 => const WalletAddressRefused(
        WalletAddressRefusal.testnet,
      ),
      _ => null,
    };
  }

  static WalletAddressParseResult _solana(String value) => WalletAddressMatch(
    candidates: [
      WalletAddressCandidate(
        family: WalletAddressFamily.solana,
        networks: const ['solanaMainnet'],
        canonical: value,
        display: _shorten(value),
        kind: WalletAddressKind.address,
      ),
    ],
  );

  static bool _isSolanaAddress(String value) {
    if (value.length < 32 || value.length > 44) return false;
    var number = BigInt.zero;
    final base = BigInt.from(58);
    for (final unit in value.codeUnits) {
      final digit = base58Alphabet.indexOf(String.fromCharCode(unit));
      if (digit < 0) return false;
      number = number * base + BigInt.from(digit);
    }
    var leadingZeros = 0;
    while (leadingZeros < value.length && value[leadingZeros] == '1') {
      leadingZeros++;
    }
    var byteLength = 0;
    while (number > BigInt.zero) {
      byteLength++;
      number >>= 8;
    }
    return leadingZeros + byteLength == 32;
  }

  static String _xrpClassicFromAccountId(List<int> accountId) {
    final payload = [0x00, ...accountId];
    final checksum = doubleSha256(payload);
    return base58Encode(
      [...payload, ...checksum.take(4)],
      alphabet: rippleBase58Alphabet,
    );
  }

  static String _shorten(String value) {
    if (value.length <= 10) return value;
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  static bool _looksLikeRecoveryPhrase(String value) {
    final words = value.split(RegExp(r'\s+'));
    if (!_recoveryWordCounts.contains(words.length)) return false;
    return words.every(_recoveryWord.hasMatch);
  }

  static bool _looksLikeJsonSecretKey(String value) {
    if (!value.startsWith('[') || !value.endsWith(']')) return false;
    final parts = value.substring(1, value.length - 1).split(',');
    if (parts.length != 64) return false;
    for (final part in parts) {
      final number = int.tryParse(part.trim());
      if (number == null || number < 0 || number > 255) return false;
    }
    return true;
  }
}

const _maxInputLength = 512;
const _genericHint = "That doesn't look like a wallet address.";
const _checksumHint =
    'One character is wrong. Check the address and try again.';
const _unknownKeyHint = "That extended key isn't one OpenBudget recognises.";
const _xAddressMainnetPrefix = 0x0544;
const _xAddressTestnetPrefix = 0x0493;
const _recoveryWordCounts = {12, 15, 18, 21, 24};
const _evmNetworks = [
  'ethereumMainnet',
  'baseMainnet',
  'arbitrumOne',
  'opMainnet',
  'polygonPos',
  'bnbSmartChain',
  'avalancheCChain',
];
final _recoveryWord = RegExp(r'^[a-z]{3,8}$');
final _hex42 = RegExp(r'^[0-9a-fA-F]{42}$');
