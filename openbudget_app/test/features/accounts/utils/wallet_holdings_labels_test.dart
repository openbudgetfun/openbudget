import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/utils/wallet_holdings_labels.dart';
import 'package:openbudget_core/openbudget_core.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final now = DateTime.utc(2026, 11, 13, 12);

  group('walletAgeLabel', () {
    String age(Duration ago) => walletAgeLabel(l10n, now.subtract(ago), now);

    test('counts minutes, hours and days', () {
      expect(age(const Duration(seconds: 20)), 'less than a minute ago');
      expect(age(const Duration(minutes: 1)), '1 minute ago');
      expect(age(const Duration(minutes: 59)), '59 minutes ago');
      expect(age(const Duration(hours: 1)), '1 hour ago');
      expect(age(const Duration(hours: 2)), '2 hours ago');
      expect(age(const Duration(hours: 23, minutes: 59)), '23 hours ago');
      expect(age(const Duration(days: 1)), '1 day ago');
      expect(age(const Duration(days: 3, hours: 5)), '3 days ago');
    });

    test('treats a time in the future as just now', () {
      expect(
        walletAgeLabel(l10n, now.add(const Duration(minutes: 3)), now),
        'less than a minute ago',
      );
    });
  });

  test('every network has a name', () {
    for (final network in WalletNetwork.values) {
      expect(walletNetworkLabel(l10n, network), isNotEmpty);
    }
  });
}
