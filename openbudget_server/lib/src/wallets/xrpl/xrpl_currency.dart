/// Decodes and encodes XRP Ledger currency codes.
///
/// A three-character code is returned unchanged; a 40-hex code is decoded to
/// its canonical (usually human-readable) form, stripping trailing zero
/// padding. Encoding the result reproduces the original 40 hex digits, so a
/// 40-hex code round-trips.
class XrplCurrency {
  static final RegExp _hex = RegExp(r'^[0-9A-Fa-f]{40}$');

  static String decode(String code) {
    final trimmed = code.trim();
    if (trimmed.length != 40 || !_hex.hasMatch(trimmed)) {
      return trimmed;
    }
    final bytes = <int>[];
    for (var i = 0; i < trimmed.length; i += 2) {
      bytes.add(int.parse(trimmed.substring(i, i + 2), radix: 16));
    }
    var length = bytes.length;
    while (length > 0 && bytes[length - 1] == 0) {
      length--;
    }
    if (length == 0) return trimmed.toUpperCase();
    for (var i = 0; i < length; i++) {
      final byte = bytes[i];
      if (byte < 0x20 || byte > 0x7E) {
        return trimmed.toUpperCase();
      }
    }
    return String.fromCharCodes(bytes.sublist(0, length));
  }

  static String encode(String code) {
    final trimmed = code.trim();
    if (trimmed.length == 40 && _hex.hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    final bytes = List<int>.filled(20, 0);
    final codeUnits = trimmed.codeUnits;
    for (var i = 0; i < codeUnits.length && i < 20; i++) {
      bytes[i] = codeUnits[i];
    }
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }
}
