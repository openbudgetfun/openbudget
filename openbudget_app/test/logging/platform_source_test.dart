import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/logging/platform_source.dart';

void main() {
  group('detectPlatformSource', () {
    test('returns a non-empty string', () {
      final source = detectPlatformSource();
      expect(source, isNotEmpty);
      expect(source, startsWith('flutter:'));
    });

    test('returns correct platform for current test environment', () {
      final source = detectPlatformSource();
      // In test, defaultTargetPlatform is android by default.
      // kIsWeb is false in dart test.
      expect(source, isNotNull);
    });

    testWidgets('returns macos when platform is macOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final source = detectPlatformSource();
      expect(source, 'flutter:macos');
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('returns windows when platform is Windows', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      final source = detectPlatformSource();
      expect(source, 'flutter:windows');
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('returns linux when platform is Linux', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      final source = detectPlatformSource();
      expect(source, 'flutter:linux');
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
