import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';

void main() {
  group('resolveServerpodApiUrl', () {
    test('uses override when provided and appends trailing slash', () {
      final url = resolveServerpodApiUrl(
        appEnvironmentApiUrl: 'https://api.openbudget.app/',
        apiUrlOverride: 'http://192.168.1.10:8080',
      );

      expect(url, 'http://192.168.1.10:8080/');
    });

    test('keeps override trailing slash when already present', () {
      final url = resolveServerpodApiUrl(
        appEnvironmentApiUrl: 'https://api.openbudget.app/',
        apiUrlOverride: 'http://192.168.1.10:8080/',
      );

      expect(url, 'http://192.168.1.10:8080/');
    });

    test('uses app environment URL when no override is set', () {
      final url = resolveServerpodApiUrl(
        appEnvironmentApiUrl: 'https://api.openbudget.app/',
        apiUrlOverride: '',
      );

      expect(url, 'https://api.openbudget.app/');
    });
  });
}
