import 'dart:convert';
import 'dart:typed_data';

/// Whether [input] is a valid TON user-friendly address with the testnet-only
/// flag set.
///
/// TON is a later chain, but its testnet form is one of the inputs section
/// 5.3 refuses. A user-friendly address is 36 bytes encoded as 48 base64 or
/// base64url characters: a tag, a workchain, a 32-byte account hash and a
/// CRC16-XMODEM checksum. The top bit of the tag marks a testnet-only address.
bool isTonTestnetAddress(String input) {
  if (input.length != 48) return false;
  final bytes = _decodeBase64(input);
  if (bytes == null || bytes.length != 36) return false;
  final tag = bytes[0];
  if (tag & 0x80 == 0) return false;
  final mainnetTag = tag & 0x7f;
  if (mainnetTag != 0x11 && mainnetTag != 0x51) return false;
  final expected = (bytes[34] << 8) | bytes[35];
  return crc16Xmodem(bytes.sublist(0, 34)) == expected;
}

Uint8List? _decodeBase64(String input) {
  try {
    return base64.decode(input);
  } on FormatException {
    try {
      return base64Url.decode(input);
    } on FormatException {
      return null;
    }
  }
}

/// The CRC16-XMODEM checksum TON uses for user-friendly addresses.
int crc16Xmodem(List<int> bytes) {
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
