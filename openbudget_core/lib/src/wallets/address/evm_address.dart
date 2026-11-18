import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';

/// Keccak-256, the hash Ethereum uses (not NIST SHA3-256).
Uint8List keccak256(List<int> bytes) {
  final digest = KeccakDigest(256);
  return digest.process(Uint8List.fromList(bytes));
}

/// Encodes the lowercase 40-digit hex [body] with an EIP-55 checksum.
String eip55Checksum(String body) {
  final hash = keccak256(ascii.encode(body));
  final buffer = StringBuffer('0x');
  for (var index = 0; index < body.length; index++) {
    final character = body[index];
    final nibble = (hash[index ~/ 2] >> (index.isEven ? 4 : 0)) & 0x0f;
    buffer.write(nibble >= 8 ? character.toUpperCase() : character);
  }
  return buffer.toString();
}

final _hexBody = RegExp(r'^[0-9a-fA-F]{40}$');
final _hex64 = RegExp(r'^[0-9a-fA-F]{64}$');

/// Whether [value] is a `0x` address body with exactly 40 hex digits.
bool isEvmAddressBody(String value) => _hexBody.hasMatch(value);

/// Whether [value] is 64 hex digits with no `0x` prefix.
bool isRawHexKey(String value) => _hex64.hasMatch(value);
