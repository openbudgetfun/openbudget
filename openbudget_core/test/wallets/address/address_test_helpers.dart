import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The Bitcoin, Tron and X-address alphabet.
const base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

Uint8List base58Decode(String input, {String alphabet = base58Alphabet}) {
  var number = BigInt.zero;
  final base = BigInt.from(alphabet.length);
  for (final unit in input.codeUnits) {
    final digit = alphabet.indexOf(String.fromCharCode(unit));
    if (digit < 0) {
      throw FormatException('character outside the alphabet', input);
    }
    number = number * base + BigInt.from(digit);
  }
  final littleEndian = <int>[];
  final byteMask = BigInt.from(0xff);
  while (number > BigInt.zero) {
    littleEndian.add((number & byteMask).toInt());
    number >>= 8;
  }
  var leadingZeros = 0;
  while (leadingZeros < input.length && input[leadingZeros] == alphabet[0]) {
    leadingZeros++;
  }
  final bytes = Uint8List(leadingZeros + littleEndian.length);
  for (var index = 0; index < littleEndian.length; index++) {
    bytes[bytes.length - 1 - index] = littleEndian[index];
  }
  return bytes;
}

String base58Encode(List<int> bytes, {String alphabet = base58Alphabet}) {
  var number = BigInt.zero;
  final base = BigInt.from(alphabet.length);
  for (final byte in bytes) {
    number = number * BigInt.from(256) + BigInt.from(byte);
  }
  final digits = <int>[];
  while (number > BigInt.zero) {
    digits.add((number % base).toInt());
    number ~/= base;
  }
  var leadingZeros = 0;
  while (leadingZeros < bytes.length && bytes[leadingZeros] == 0) {
    leadingZeros++;
  }
  final buffer = StringBuffer();
  for (var index = 0; index < leadingZeros; index++) {
    buffer.write(alphabet[0]);
  }
  for (var index = digits.length - 1; index >= 0; index--) {
    buffer.write(alphabet[digits[index]]);
  }
  return buffer.toString();
}

Uint8List doubleSha256(List<int> bytes) {
  final first = sha256.convert(bytes).bytes;
  return Uint8List.fromList(sha256.convert(first).bytes);
}

String base58CheckEncode(List<int> payload) {
  final checksum = doubleSha256(payload);
  return base58Encode([...payload, ...checksum.take(4)]);
}

/// Replaces the version bytes of a 111-character extended key and fixes the
/// checksum. Used to build SLIP-132 test vectors from a BIP 32 xpub/xprv.
String reVersionExtendedKey(String key, int version) {
  final decoded = base58Decode(key);
  if (decoded.length != 82) {
    throw ArgumentError.value(key, 'key', 'not an extended key');
  }
  final payload = List<int>.from(decoded.sublist(0, 78));
  payload[0] = (version >> 24) & 0xff;
  payload[1] = (version >> 16) & 0xff;
  payload[2] = (version >> 8) & 0xff;
  payload[3] = version & 0xff;
  return base58CheckEncode(payload);
}

/// Builds a TON user-friendly address with a CRC16-XMODEM checksum.
String tonFriendlyAddress({
  required int tag,
  required int workchain,
  required List<int> accountHash,
}) {
  final bytes = [tag, workchain, ...accountHash];
  final checksum = _crc16Xmodem(bytes);
  bytes
    ..add((checksum >> 8) & 0xff)
    ..add(checksum & 0xff);
  return base64Encode(bytes);
}

int _crc16Xmodem(List<int> bytes) {
  var crc = 0;
  for (final byte in bytes) {
    crc ^= (byte & 0xff) << 8;
    for (var bit = 0; bit < 8; bit++) {
      crc = crc & 0x8000 != 0
          ? ((crc << 1) ^ 0x1021) & 0xffff
          : (crc << 1) & 0xffff;
    }
  }
  return crc;
}
