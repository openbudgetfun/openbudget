import 'package:openbudget_scripts/dev_server_host.dart';
import 'package:test/test.dart';

void main() {
  group('selectDevServerHost', () {
    test('prefers a Tailscale address over a LAN address', () {
      expect(
        selectDevServerHost(['192.168.1.118', '100.123.36.92']),
        '100.123.36.92',
      );
    });

    test('ignores loopback and falls back to the LAN address', () {
      expect(
        selectDevServerHost(['127.0.0.1', '192.168.1.118']),
        '192.168.1.118',
      );
    });

    test('returns null when every address is loopback', () {
      expect(selectDevServerHost(['127.0.0.1', '127.0.0.2']), isNull);
    });
  });

  group('devServerHostCandidates', () {
    test('orders every Tailscale address before the fallback addresses', () {
      expect(
        devServerHostCandidates([
          '192.168.1.118',
          '100.123.36.92',
          '10.0.0.5',
          '100.64.0.2',
        ]),
        ['100.123.36.92', '100.64.0.2', '192.168.1.118', '10.0.0.5'],
      );
    });

    test('drops loopback but keeps duplicate addresses', () {
      expect(
        devServerHostCandidates([
          '127.0.0.1',
          '192.168.1.118',
          '192.168.1.118',
        ]),
        ['192.168.1.118', '192.168.1.118'],
      );
    });
  });

  group('isTailscaleIpv4', () {
    test('accepts the CGNAT range used by Tailscale', () {
      expect(isTailscaleIpv4('100.64.0.1'), isTrue);
      expect(isTailscaleIpv4('100.123.36.92'), isTrue);
      expect(isTailscaleIpv4('100.127.255.254'), isTrue);
    });

    test('rejects addresses outside that range', () {
      expect(isTailscaleIpv4('100.63.255.255'), isFalse);
      expect(isTailscaleIpv4('100.128.0.1'), isFalse);
      expect(isTailscaleIpv4('192.168.1.118'), isFalse);
      expect(isTailscaleIpv4('not-an-ip'), isFalse);
    });

    test('rejects invalid octets', () {
      expect(isTailscaleIpv4('100.64.256.1'), isFalse);
      expect(isTailscaleIpv4('100.64.-1.1'), isFalse);
      expect(isTailscaleIpv4('100.64.0'), isFalse);
      expect(isTailscaleIpv4('100.64.0.1.2'), isFalse);
    });
  });
}
