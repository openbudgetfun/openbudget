import 'dart:typed_data';

/// A decoded native SegWit address.
class SegwitAddress {
  const SegwitAddress({
    required this.hrp,
    required this.version,
    required this.program,
  });

  /// The human-readable part, lowercased (`bc`, `tb` or `bcrt`).
  final String hrp;

  /// The witness version, 0 to 16.
  final int version;

  /// The witness program.
  final Uint8List program;
}

/// The result of decoding a Bech32 or Bech32m string.
class SegwitDecodeResult {
  const SegwitDecodeResult.invalid({this.checksumFailed = false})
    : address = null;

  const SegwitDecodeResult.valid(SegwitAddress this.address)
    : checksumFailed = false;

  /// The decoded address, or null when the input is not valid.
  final SegwitAddress? address;

  /// Whether the failure was a checksum (or checksum-kind) mismatch, which
  /// means one character is probably wrong.
  final bool checksumFailed;
}

const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _bech32Constant = 1;
const _bech32mConstant = 0x2bc830a3;
const _maxLength = 90;

/// Decodes a native SegWit address per BIP 173 and BIP 350.
///
/// Version 0 uses Bech32 and a 20- or 32-byte program. Versions 1 to 16 use
/// Bech32m and a 2- to 40-byte program, as BIP 350 requires.
SegwitDecodeResult decodeSegwitAddress(String input) {
  if (input.length < 8 || input.length > _maxLength) {
    return const SegwitDecodeResult.invalid();
  }
  var hasLower = false;
  var hasUpper = false;
  for (final unit in input.codeUnits) {
    if (unit < 33 || unit > 126) {
      return const SegwitDecodeResult.invalid();
    }
    if (unit >= 97 && unit <= 122) {
      hasLower = true;
    } else if (unit >= 65 && unit <= 90) {
      hasUpper = true;
    }
  }
  if (hasLower && hasUpper) {
    return const SegwitDecodeResult.invalid();
  }
  final lower = input.toLowerCase();
  final separator = lower.lastIndexOf('1');
  if (separator <= 0 || separator + 7 > lower.length) {
    return const SegwitDecodeResult.invalid();
  }
  final hrp = lower.substring(0, separator);
  final data = <int>[];
  for (final unit in lower.substring(separator + 1).codeUnits) {
    final value = _charset.indexOf(String.fromCharCode(unit));
    if (value < 0) {
      return const SegwitDecodeResult.invalid();
    }
    data.add(value);
  }
  final constant = _polymod([..._expandHrp(hrp), ...data]);
  final checksumType = switch (constant) {
    _bech32Constant => _ChecksumType.bech32,
    _bech32mConstant => _ChecksumType.bech32m,
    _ => null,
  };
  if (checksumType == null) {
    return const SegwitDecodeResult.invalid(checksumFailed: true);
  }
  final payload = data.sublist(0, data.length - 6);
  if (payload.isEmpty) {
    return const SegwitDecodeResult.invalid();
  }
  final version = payload.first;
  if (version > 16) {
    return const SegwitDecodeResult.invalid();
  }
  final program = _convertBits(payload.sublist(1), 5, 8);
  if (program == null) {
    return const SegwitDecodeResult.invalid();
  }
  if (version == 0) {
    if (checksumType != _ChecksumType.bech32) {
      return const SegwitDecodeResult.invalid(checksumFailed: true);
    }
    if (program.length != 20 && program.length != 32) {
      return const SegwitDecodeResult.invalid();
    }
  } else {
    if (checksumType != _ChecksumType.bech32m) {
      return const SegwitDecodeResult.invalid(checksumFailed: true);
    }
    if (program.length < 2 || program.length > 40) {
      return const SegwitDecodeResult.invalid();
    }
  }
  return SegwitDecodeResult.valid(
    SegwitAddress(hrp: hrp, version: version, program: program),
  );
}

enum _ChecksumType { bech32, bech32m }

List<int> _expandHrp(String hrp) {
  final expanded = <int>[];
  for (final unit in hrp.codeUnits) {
    expanded.add(unit >> 5);
  }
  expanded.add(0);
  for (final unit in hrp.codeUnits) {
    expanded.add(unit & 31);
  }
  return expanded;
}

int _polymod(List<int> values) {
  const generators = [
    0x3b6a57b2,
    0x26508e6d,
    0x1ea119fa,
    0x3d4233dd,
    0x2a1462b3,
  ];
  var checksum = 1;
  for (final value in values) {
    final top = checksum >> 25;
    checksum = ((checksum & 0x1ffffff) << 5) ^ value;
    for (var index = 0; index < 5; index++) {
      if ((top >> index) & 1 != 0) {
        checksum ^= generators[index];
      }
    }
  }
  return checksum;
}

/// Converts [data] from [fromBits] to [toBits] with no padding, or returns
/// null when the final group has non-zero padding.
Uint8List? _convertBits(List<int> data, int fromBits, int toBits) {
  var accumulator = 0;
  var bits = 0;
  final output = <int>[];
  final maxValue = (1 << toBits) - 1;
  for (final value in data) {
    if (value < 0 || value >> fromBits != 0) return null;
    accumulator = (accumulator << fromBits) | value;
    bits += fromBits;
    while (bits >= toBits) {
      bits -= toBits;
      output.add((accumulator >> bits) & maxValue);
    }
  }
  if (bits >= fromBits) return null;
  if ((accumulator << (toBits - bits)) & maxValue != 0) return null;
  return Uint8List.fromList(output);
}
