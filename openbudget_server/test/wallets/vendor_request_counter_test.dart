import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:test/test.dart';

void main() {
  late List<String> captured;
  late StreamSubscription<LogRecord> subscription;

  setUp(() {
    Logger.root.level = Level.ALL;
    captured = <String>[];
    subscription = Logger.root.onRecord.listen((record) {
      captured.add(record.message);
    });
  });

  tearDown(() async {
    await subscription.cancel();
  });

  test('counts per vendor and logs without urls', () {
    final counter = WalletVendorRequestCounter();
    expect(counter.record('esplora'), 1);
    expect(counter.record('esplora'), 2);
    expect(counter.count('esplora'), 2);
    expect(counter.count('alchemy'), 0);

    counter.log();
    expect(captured, contains('wallet.vendor.requests vendor=esplora count=2'));
    for (final line in captured) {
      expect(line.toLowerCase(), isNot(contains('http')));
      expect(line.toLowerCase(), isNot(contains('://')));
    }
  });

  test('reset clears counts', () {
    final counter = WalletVendorRequestCounter();
    // Two-step call is clearer as separate statements; cascade lint is a
    // false positive here.
    // ignore: cascade_invocations
    counter
      ..record('esplora')
      ..reset();
    expect(counter.count('esplora'), 0);
  });
}
