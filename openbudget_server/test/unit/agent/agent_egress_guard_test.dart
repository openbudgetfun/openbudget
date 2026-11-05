import 'dart:io';

import 'package:openbudget_server/src/agent/agent_egress_guard.dart';
import 'package:openbudget_server/src/agent/agent_provider_settings_service.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() => AgentEgressGuard.lookup = InternetAddress.lookup);

  group('Given a provider base URL', () {
    for (final url in [
      'https://localhost/v1',
      'https://api.localhost/v1',
      'https://metadata.internal/v1',
      'https://printer.local/v1',
      'https://127.0.0.1/v1',
      'https://10.1.2.3/v1',
      'https://172.20.0.1/v1',
      'https://192.168.1.1/v1',
      'https://169.254.169.254/latest',
      'https://100.64.0.1/v1',
      'https://0.0.0.0/v1',
      'https://[::1]/v1',
      'https://[fd00::1]/v1',
      'https://[fe80::1]/v1',
      'https://[::ffff:10.0.0.1]/v1',
    ]) {
      test('when it is $url then saving is rejected', () {
        expect(
          () => AgentProviderSettingsService.baseUri(url),
          throwsA(isA<ValidationException>()),
        );
      });
    }

    for (final url in [
      'https://api.openai.com/v1',
      'https://openrouter.ai/api/v1',
      'https://8.8.8.8/v1',
      'https://[2606:4700:4700::1111]/v1',
    ]) {
      test('when it is $url then it is accepted', () {
        expect(AgentProviderSettingsService.baseUri(url).scheme, 'https');
      });
    }
  });

  group('Given a host checked before a call', () {
    test('when it resolves to a public address then it passes', () async {
      AgentEgressGuard.lookup = (_) async => [InternetAddress('8.8.8.8')];

      await AgentEgressGuard.checkResolved(Uri.parse('https://api.test/v1'));
    });

    test('when any address is private then it is refused', () async {
      AgentEgressGuard.lookup = (_) async => [
        InternetAddress('8.8.8.8'),
        InternetAddress('10.0.0.7'),
      ];

      await expectLater(
        AgentEgressGuard.checkResolved(Uri.parse('https://api.test/v1')),
        throwsA(isA<AgentProviderUnavailableException>()),
      );
    });

    test('when it does not resolve then it is refused', () async {
      AgentEgressGuard.lookup = (_) async =>
          throw const SocketException('no such host');

      await expectLater(
        AgentEgressGuard.checkResolved(Uri.parse('https://api.test/v1')),
        throwsA(isA<AgentProviderUnavailableException>()),
      );
    });
  });
}
