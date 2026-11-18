import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The Bitcoin, Tron and XRP Ledger X-address alphabet.
const base58Alphabet =
    '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';

/// The XRP Ledger classic address alphabet.
const rippleBase58Alphabet =
    'rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz';

/// The double SHA-256 checksum used by Base58Check.
Uint8List doubleSha256(List<int> bytes) {
  final first = sha256.convert(bytes).bytes;
  return Uint8List.fromList(sha256.convert(first).bytes);
}

/// Whether [checksum] is the first four bytes of the double SHA-256 of
/// [payload].
bool checksumMatches(List<int> payload, List<int> checksum) {
  if (checksum.length != 4) return false;
  final expected = doubleSha256(payload);
  var difference = 0;
  for (var index = 0; index < 4; index++) {
    difference |= expected[index] ^ checksum[index];
  }
  return difference == 0;
}

/// Decodes [input] with [alphabet], or returns null when a character is not
/// in the alphabet.
///
/// Leading zero characters decode to leading zero bytes, which is what makes
/// the all-ones Solana system address round-trip.
Uint8List? base58Decode(
  String input, {
  String alphabet = base58Alphabet,
}) {
  if (input.isEmpty) return Uint8List(0);
  var number = BigInt.zero;
  final base = BigInt.from(alphabet.length);
  for (final unit in input.codeUnits) {
    final digit = alphabet.indexOf(String.fromCharCode(unit));
    if (digit < 0) return null;
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

/// Encodes [bytes] with [alphabet].
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

/// Appends the Base58Check checksum and encodes [payload].
String base58CheckEncode(List<int> payload) {
  final checksum = doubleSha256(payload);
  return base58Encode([...payload, ...checksum.take(4)]);
}

/// Decodes a Base58Check string and returns its payload without the checksum.
///
/// Returns null for a bad character, a short input or a checksum mismatch.
Uint8List? base58CheckPayload(String input) {
  final decoded = base58Decode(input);
  if (decoded == null || decoded.length < 5) return null;
  final payload = decoded.sublist(0, decoded.length - 4);
  final checksum = decoded.sublist(decoded.length - 4);
  return checksumMatches(payload, checksum) ? payload : null;
}

/// Reads a big-endian unsigned integer from [bytes].
int readUint32(List<int> bytes, int offset) =>
    (bytes[offset] << 24) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3];

/// Writes a big-endian unsigned integer into [bytes] at [offset].
void writeUint32(List<int> bytes, int offset, int value) {
  bytes[offset] = (value >> 24) & 0xff;
  bytes[offset + 1] = (value >> 16) & 0xff;
  bytes[offset + 2] = (value >> 8) & 0xff;
  bytes[offset + 3] = value & 0xff;
}
