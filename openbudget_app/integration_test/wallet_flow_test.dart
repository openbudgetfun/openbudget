import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/institution_catalog_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/fake_wallet_server.dart';
import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

/// Add a crypto wallet: paste an address, see the chain detected, pick the
/// EVM networks, watch the first read and land on the ADDED postmark. The
/// server is faked, so the flow also asserts what the app sent, and that a
/// recovery phrase sends nothing at all.
void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final theme = themeMode.name;

    patrolWidgetTest('adds an EVM wallet from a pasted address ($theme)', (
      $,
    ) async {
      final tester = $.tester;
      final server = FakeWalletServer()..firstRead = Completer<void>();
      await _pumpFlow(tester, server, themeMode: themeMode);
      final page = AddWalletPage(tester);

      await page.open();
      expect(page.addressField, findsOneWidget);
      expect(page.canAdd, isFalse);
      await captureIntegrationScreenshot(tester, 'wallet-add-paste-$theme');

      // The address is detected and looked ahead at.
      await page.paste(WalletFlowData.evmAddress);
      expect(page.detectedStamp, findsOneWidget);
      expect(page.pickerTitle, findsOneWidget);
      expect(server.callsTo('preview'), hasLength(1));
      // Ethereum and Base hold something, so they start picked.
      expect(find.text(r'$1,240.00'), findsOneWidget);
      expect(find.text(r'$310.00'), findsOneWidget);
      expect(find.text('2 networks selected'), findsOneWidget);
      await captureIntegrationScreenshot(tester, 'wallet-add-picker-$theme');

      // Pick Arbitrum One as well, then add. The first read stays open, so
      // the "Reading…" state is on screen.
      await page.toggleNetwork('arbitrumOne');
      expect(find.text('3 networks selected'), findsOneWidget);
      await page.tapAdd();
      expect(
        find.text('Reading Ethereum, Base and Arbitrum One…'),
        findsOneWidget,
      );
      await captureIntegrationScreenshot(tester, 'wallet-add-reading-$theme');

      // The server answers: the wallet is in, stamped ADDED.
      server.firstRead.complete();
      await tester.pumpAndSettle();
      expect(page.postmark, findsOneWidget);
      expect(find.text('Wallet added'), findsOneWidget);
      expect(find.textContaining(WalletFlowData.evmAccountName), findsWidgets);
      await captureIntegrationScreenshot(tester, 'wallet-add-added-$theme');

      final args = server.callsTo('connect').single.args;
      expect(args['network'], WalletNetwork.ethereumMainnet);
      expect(args['address'], WalletFlowData.evmAddress);
      expect(args['accountName'], WalletFlowData.evmAccountName);
      expect(args['scanNetworks'], [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
        WalletNetwork.arbitrumOne,
      ]);

      // Done returns to the account list.
      await tester.tap(page.doneButton);
      await tester.pumpAndSettle();
      expect(find.text('Account List'), findsOneWidget);
    });

    patrolWidgetTest('refuses a recovery phrase and sends nothing ($theme)', (
      $,
    ) async {
      final tester = $.tester;
      final server = FakeWalletServer();
      await _pumpFlow(tester, server, themeMode: themeMode);
      final page = AddWalletPage(tester);

      await page.open();
      await page.paste(WalletFlowData.recoveryPhrase);

      // The field cleared itself, the refusal says why, and nothing about
      // the phrase is on screen or was sent.
      expect(page.fieldText, isEmpty);
      expect(page.refusalTitle, findsOneWidget);
      expect(find.textContaining('abandon'), findsNothing);
      expect(page.canAdd, isFalse);
      expect(server.workCalls, isEmpty);
      await captureIntegrationScreenshot(tester, 'wallet-add-refused-$theme');
    });
  }

  patrolWidgetTest('connects a zpub as a Bitcoin HD wallet', ($) async {
    final tester = $.tester;
    final server = FakeWalletServer();
    await _pumpFlow(tester, server);
    final page = AddWalletPage(tester);

    await page.open();
    await page.paste(WalletFlowData.zpub);

    // One chain, so no look-ahead: just the BITCOIN ZPUB stamp.
    expect(find.text('BITCOIN'), findsOneWidget);
    expect(find.text('ZPUB'), findsOneWidget);
    expect(page.pickerTitle, findsNothing);
    expect(server.callsTo('preview'), isEmpty);

    await page.tapAdd();
    await tester.pumpAndSettle();

    final args = server.callsTo('connect').single.args;
    expect(args['network'], WalletNetwork.bitcoinMainnet);
    expect(args['address'], WalletFlowData.zpub);
    expect(args['accountName'], WalletFlowData.zpubAccountName);
    expect(args['scanNetworks'], isNull);
    expect(page.postmark, findsOneWidget);
  });

  patrolWidgetTest('offers a retry when every network fails to read', (
    $,
  ) async {
    final tester = $.tester;
    final server = FakeWalletServer()
      ..connectResult = (args) => WalletFlowData.connected(
        network: WalletNetwork.bitcoinMainnet,
        syncStatus: SyncStatus.failed,
        lastSyncError: 'Bitcoin could not be reached (HTTP 503).',
      );
    await _pumpFlow(tester, server);
    final page = AddWalletPage(tester);

    await page.open();
    await page.paste(WalletFlowData.zpub);
    await page.tapAdd();
    await tester.pumpAndSettle();

    expect(page.unreadableTitle, findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(page.postmark, findsNothing);
    await captureIntegrationScreenshot(tester, 'wallet-add-unreadable');
  });
}

Future<void> _pumpFlow(
  WidgetTester tester,
  FakeWalletServer server, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await useScreenshotSurface(tester, ScreenshotSurface.phone);
  final router = GoRouter(
    initialLocation: '/budgets/${WalletFlowData.entityId}/accounts/add',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: '/budgets/:entityId/accounts',
        builder: (_, _) => const Scaffold(body: Text('Account List')),
        routes: [
          GoRoute(
            name: addAccountRoute,
            path: 'add',
            builder: (_, state) =>
                AddAccountScreen(entityId: state.pathParameters['entityId']!),
          ),
        ],
      ),
    ],
  );
  final container = ProviderContainer(
    overrides: [
      serverpodClientProvider.overrideWithValue(server),
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.gbpEntity(),
      ),
      institutionCatalogProvider.overrideWith(
        (ref, locationCode) async => const [],
      ),
      accountListProvider.overrideWith((ref, entityId) async => const []),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  // The add account screen shows two short loading steps first.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 1000));
  await tester.pumpAndSettle();
}
