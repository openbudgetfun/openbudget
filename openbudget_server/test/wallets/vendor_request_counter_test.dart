import 'dart:async';

import 'package:logging/logging.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:test/test.dart';

void main() {
  late List<String> captured;
  late StreamSubscription<LogRecord> subscription;

  setUp(() {
    Logger.root.level = Level.ALL;
    captured = [];
    subscription = Logger.root.onRecord.listen(
      (record) => captured.add(record.message),
    );
  });

  tearDown(() => subscription.cancel());

  List<String> requestLines() => captured
      .where((line) => line.startsWith('wallet.vendor.requests'))
      .toList();

  test('logs one line per vendor, with no url', () async {
    await WalletVendorRequestCounter.track(() async {
      WalletVendorRequestCounter.current!
        ..record('esplora')
        ..record('esplora')
        ..record('coingecko');
    });

    expect(
      requestLines(),
      unorderedEquals([
        'wallet.vendor.requests vendor=esplora count=2',
        'wallet.vendor.requests vendor=coingecko count=1',
      ]),
    );
  });

  test('records nothing outside an operation', () {
    expect(WalletVendorRequestCounter.current, isNull);
  });

  test('logs the counts when the operation throws', () async {
    await expectLater(
      WalletVendorRequestCounter.track<void>(() async {
        WalletVendorRequestCounter.current!.record('xrpl');
        throw StateError('boom');
      }),
      throwsStateError,
    );

    expect(requestLines(), ['wallet.vendor.requests vendor=xrpl count=1']);
  });

  test('concurrent operations each count only their own requests', () async {
    final bothStarted = Completer<void>();
    var started = 0;

    Future<void> operation(String vendor, int requests) =>
        WalletVendorRequestCounter.track(() async {
          if (++started == 2) bothStarted.complete();
          await bothStarted.future;
          for (var i = 0; i < requests; i++) {
            WalletVendorRequestCounter.current!.record(vendor);
            await Future<void>.delayed(Duration.zero);
          }
        });

    await Future.wait([operation('esplora', 3), operation('xrpl', 1)]);

    expect(
      requestLines(),
      unorderedEquals([
        'wallet.vendor.requests vendor=esplora count=3',
        'wallet.vendor.requests vendor=xrpl count=1',
      ]),
    );
  });
}
