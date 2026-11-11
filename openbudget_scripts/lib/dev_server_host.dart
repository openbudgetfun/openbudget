/// Returns the addresses a development client should try, best first.
///
/// Tailscale CGNAT addresses (`100.64.0.0/10`) win, so a phone on the tailnet
/// reaches this machine without a LAN broadcast address. Loopback is ignored.
/// Every other address stays as a fallback in the order the operating system
/// reported it.
Iterable<String> devServerHostCandidates(Iterable<String> addresses) sync* {
  final tailscale = <String>[];
  final fallback = <String>[];

  for (final address in addresses) {
    if (_isLoopback(address)) {
      continue;
    }

    if (isTailscaleIpv4(address)) {
      tailscale.add(address);
    } else {
      fallback.add(address);
    }
  }

  yield* tailscale;
  yield* fallback;
}

/// Returns the best development-server address, or `null` when none exists.
String? selectDevServerHost(Iterable<String> addresses) {
  for (final address in devServerHostCandidates(addresses)) {
    return address;
  }

  return null;
}

/// Whether [address] is inside the Tailscale IPv4 CGNAT range.
bool isTailscaleIpv4(String address) {
  final parts = address.split('.');
  if (parts.length != 4) {
    return false;
  }

  final octets = <int>[];
  for (final part in parts) {
    final octet = int.tryParse(part);
    if (octet == null || octet < 0 || octet > 255) {
      return false;
    }

    octets.add(octet);
  }

  return octets[0] == 100 && octets[1] >= 64 && octets[1] <= 127;
}

bool _isLoopback(String address) =>
    address == '127.0.0.1' || address.startsWith('127.');
