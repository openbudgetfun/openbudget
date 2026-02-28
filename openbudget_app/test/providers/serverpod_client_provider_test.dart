import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';

void main() {
  group('resolveServerpodApiUrl', () {
    test('uses override when provided and appends trailing slash', () {
      final url = resolveServerpodApiUrl(
        isWeb: false,
        platform: TargetPlatform.android,
        apiUrlOverride: 'http://192.168.1.10:8080',
      );

      expect(url, 'http://192.168.1.10:8080/');
    });

    test('keeps override trailing slash when already present', () {
      final url = resolveServerpodApiUrl(
        isWeb: false,
        platform: TargetPlatform.android,
        apiUrlOverride: 'http://192.168.1.10:8080/',
      );

      expect(url, 'http://192.168.1.10:8080/');
    });

    test('uses Android emulator host when no override is set', () {
      final url = resolveServerpodApiUrl(
        isWeb: false,
        platform: TargetPlatform.android,
        apiUrlOverride: '',
      );

      expect(url, 'http://10.0.2.2:8080/');
    });

    test('uses localhost on non-Android platforms', () {
      final url = resolveServerpodApiUrl(
        isWeb: false,
        platform: TargetPlatform.iOS,
        apiUrlOverride: '',
      );

      expect(url, 'http://localhost:8080/');
    });

    test('uses localhost for web builds', () {
      final url = resolveServerpodApiUrl(
        isWeb: true,
        platform: TargetPlatform.android,
        apiUrlOverride: '',
      );

      expect(url, 'http://localhost:8080/');
    });
  });
}
