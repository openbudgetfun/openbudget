import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/accounts/models/add_wallet_state.dart';
import 'package:openbudget_app/src/features/accounts/providers/add_wallet_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../fixtures/add_wallet_fixtures.dart';

ProviderContainer _containerFor(AddWalletServer server) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(server.client)],
  );
  addTearDown(container.dispose);
  // Keep the flow alive across awaits, as the screen's watch does.
  container.listen(addWalletFlowProvider, (_, _) {});
  return container;
}

void main() {
  group('initialWalletSelection', () {
    test('picks networks with a priced holding, and always the home', () {
      final preview = previewOf([
        previewRow(WalletNetwork.ethereumMainnet),
        previewRow(WalletNetwork.baseMainnet, valueMinor: 31000),
        previewRow(WalletNetwork.arbitrumOne, unpriced: 4),
        previewRow(WalletNetwork.opMainnet, error: 'could not be read'),
      ]);
      expect(initialWalletSelection(preview), [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
      ]);
    });

    test("keeps the preview's order", () {
      final preview = previewOf([
        previewRow(WalletNetwork.ethereumMainnet, valueMinor: 1),
        previewRow(WalletNetwork.polygonPos, valueMinor: 1),
        previewRow(WalletNetwork.baseMainnet, valueMinor: 1),
      ]);
      expect(initialWalletSelection(preview), [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.polygonPos,
        WalletNetwork.baseMainnet,
      ]);
    });
  });

  group('AddWalletFlow', () {
    test('a stale preview never replaces a newer one', () async {
      final slow = Completer<WalletPreview>();
      final server = AddWalletServer();
      var calls = 0;
      server.client.handle('wallet', 'preview', (args) {
        calls++;
        return calls == 1
            ? slow.future
            : Future.value(
                previewOf([
                  previewRow(WalletNetwork.ethereumMainnet),
                  previewRow(WalletNetwork.baseMainnet, valueMinor: 500),
                ]),
              );
      });
      final container = _containerFor(server);
      final flow = container.read(addWalletFlowProvider.notifier);

      final first = flow.loadPreview(
        entityId: fixtureEntityId,
        address: fixtureEvmAddress,
      );
      await flow.loadPreview(
        entityId: fixtureEntityId,
        address: '0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe',
      );
      slow.complete(ethereumBaseArbitrumPreview());
      await first;

      final state = container.read(addWalletFlowProvider);
      expect(state.selected, [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
      ]);
    });

    test('a rate limit is its own failure', () async {
      final server = AddWalletServer(
        preview: () async => throw WalletPreviewRateLimitedException(),
      );
      final container = _containerFor(server);
      await container
          .read(addWalletFlowProvider.notifier)
          .loadPreview(entityId: fixtureEntityId, address: fixtureEvmAddress);

      expect(
        container.read(addWalletFlowProvider).preview,
        const WalletPreviewState.failed(WalletPreviewFailure.rateLimited),
      );
    });

    test('the home network cannot be turned off', () async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
      );
      final container = _containerFor(server);
      final flow = container.read(addWalletFlowProvider.notifier);
      await flow.loadPreview(
        entityId: fixtureEntityId,
        address: fixtureEvmAddress,
      );

      flow.toggleNetwork(WalletNetwork.ethereumMainnet, selected: false);
      expect(container.read(addWalletFlowProvider).selected, [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
      ]);
      flow
        ..toggleNetwork(WalletNetwork.arbitrumOne, selected: true)
        ..toggleNetwork(WalletNetwork.baseMainnet, selected: false);
      expect(container.read(addWalletFlowProvider).selected, [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.arbitrumOne,
      ]);
    });

    test('a wallet that read nothing is unreadable, with the reason', () async {
      final server = AddWalletServer(
        connectResult: (args) async => fixtureWallet(
          network: WalletNetwork.bitcoinMainnet,
          syncStatus: SyncStatus.failed,
          lastSyncError: 'Bitcoin could not be reached.',
        ),
      );
      final container = _containerFor(server);
      await container
          .read(addWalletFlowProvider.notifier)
          .submit(
            entityId: fixtureEntityId,
            address: fixtureZpub,
            network: WalletNetwork.bitcoinMainnet,
            accountName: 'Bitcoin wallet, zpub',
          );

      final submission = container.read(addWalletFlowProvider).submission;
      expect(submission, isA<AddWalletUnreadable>());
      expect(
        (submission as AddWalletUnreadable).reason,
        'Bitcoin could not be reached.',
      );
      expect(submission.networks, [WalletNetwork.bitcoinMainnet]);
    });

    test('the pasted address is sent, but never kept in the state', () async {
      final server = AddWalletServer(
        connectResult: (args) async =>
            fixtureWallet(network: WalletNetwork.bitcoinMainnet),
      );
      final container = _containerFor(server);
      await container
          .read(addWalletFlowProvider.notifier)
          .submit(
            entityId: fixtureEntityId,
            address: fixtureZpub,
            network: WalletNetwork.bitcoinMainnet,
            accountName: 'Bitcoin wallet, zpub',
          );

      expect(server.lastConnect.args['address'], fixtureZpub);
      // The flow's state has the connected wallet (the server's canonical
      // form), and nothing of the pasted key.
      expect(
        container.read(addWalletFlowProvider).toString(),
        isNot(contains(fixtureZpub)),
      );
    });
  });
}
