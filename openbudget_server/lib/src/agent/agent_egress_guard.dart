import 'dart:io';

import 'package:openbudget_server/src/generated/protocol.dart';

/// Keeps user-supplied provider URLs pointed at the public internet.
///
/// A bring-your-own provider makes the server send requests to a host the
/// user chose and feed the reply back to them. Without this guard that host
/// could be the server's own network: loopback, a private range, or a cloud
/// metadata address.
///
/// [checkHostName] rejects names and IP literals that are obviously internal
/// when the URL is saved. [checkResolved] resolves the name before each call
/// and rejects it when any address is internal, so a public name later
/// pointed at a private address is refused too. A DNS answer that changes
/// between the check and the connection is not covered; that needs pinning
/// the connection to the checked address.
abstract final class AgentEgressGuard {
  /// Resolves a host name. Tests replace it to avoid real DNS.
  static Future<List<InternetAddress>> Function(String host) lookup =
      InternetAddress.lookup;

  static const List<String> _internalSuffixes = [
    '.localhost',
    '.local',
    '.internal',
    '.home.arpa',
  ];

  /// Throws [ValidationException] when [host] names an internal destination.
  static void checkHostName(String host) {
    final name = host.toLowerCase();
    if (name == 'localhost' || _internalSuffixes.any(name.endsWith)) {
      throw ValidationException(
        message: 'baseUrl must point at a public host.',
      );
    }
    final literal = InternetAddress.tryParse(_stripBrackets(name));
    if (literal != null && isInternal(literal)) {
      throw ValidationException(
        message: 'baseUrl must point at a public host.',
      );
    }
  }

  /// Throws [AgentProviderUnavailableException] when [uri]'s host resolves
  /// to an internal address or does not resolve at all.
  static Future<void> checkResolved(Uri uri) async {
    checkHostName(uri.host);
    final List<InternetAddress> addresses;
    try {
      addresses = await lookup(_stripBrackets(uri.host));
    } on SocketException {
      throw AgentProviderUnavailableException(
        message: 'The agent provider host could not be resolved.',
      );
    }
    if (addresses.isEmpty || addresses.any(isInternal)) {
      throw AgentProviderUnavailableException(
        message: 'The agent provider host is not a public address.',
      );
    }
  }

  /// Whether [address] is loopback, private, link-local, shared or reserved.
  static bool isInternal(InternetAddress address) {
    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return true;
    }
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      return _isInternalIPv4(bytes);
    }
    // IPv4-mapped IPv6 (::ffff:a.b.c.d) inherits the IPv4 answer.
    final mapped =
        bytes.sublist(0, 10).every((byte) => byte == 0) &&
        bytes[10] == 0xff &&
        bytes[11] == 0xff;
    if (mapped) return _isInternalIPv4(bytes.sublist(12));
    final unspecified = bytes.every((byte) => byte == 0);
    final uniqueLocal = (bytes[0] & 0xfe) == 0xfc; // fc00::/7
    return unspecified || uniqueLocal;
  }

  static bool _isInternalIPv4(List<int> bytes) {
    final a = bytes[0];
    final b = bytes[1];
    return a == 0 || // this network
        a == 10 ||
        a == 127 ||
        (a == 100 && b >= 64 && b <= 127) || // carrier-grade NAT
        (a == 169 && b == 254) || // link-local and cloud metadata
        (a == 172 && b >= 16 && b <= 31) ||
        (a == 192 && b == 168) ||
        (a == 192 && b == 0 && bytes[2] == 0) || // IETF protocol assignments
        (a == 198 && (b == 18 || b == 19)) || // benchmarking
        a >= 224; // multicast and reserved
  }

  static String _stripBrackets(String host) =>
      host.startsWith('[') && host.endsWith(']')
      ? host.substring(1, host.length - 1)
      : host;
}
