import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

/// Section-10 flow: create a GBP entity, add a USD account with an opening
/// balance, and the net worth screen shows the converted GBP total with the
/// "1 USD = 0.79 GBP · Nov 8" rate line and the By currency tab row.
void main() {
  patrolWidgetTest(
    'create entity, add a USD account, and see the converted net worth',
    ($) async {
      final tester = $.tester;
      final createdAccounts = <Account>[];
      const gbpEntity = TestData.gbpEntityId;

      final container = ProviderContainer(
        overrides: [
          entityActionsProvider.overrideWith(
            () => _CreatingEntityActions(entityId: gbpEntity),
          ),
          entityDetailProvider.overrideWith(
            (ref, id) async => TestData.gbpEntity(),
          ),
          entityListProvider.overrideWith(
            (ref) async => [TestData.gbpEntity()],
          ),
          accountListProvider.overrideWith(
            (ref, entityId) async => createdAccounts,
          ),
          accountActionsProvider.overrideWith(
            () => _RecordingAccountActions(createdAccounts),
          ),
          reportingCurrencyProvider.overrideWith((ref) async => 'GBP'),
          netWorthProvider.overrideWith(
            (ref) async => _netWorthFor(createdAccounts),
          ),
          netWorthHistoryProvider.overrideWith(
            (ref, range) async =>
                _historyFor(createdAccounts, range.granularity),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: createEntityPath,
        routes: [
          GoRoute(
            path: createEntityPath,
            builder: (_, _) => const CreateEntityScreen(),
          ),
          GoRoute(
            name: addAccountRoute,
            path: '/budgets/:entityId/accounts/add',
            builder: (_, _) => const AddAccountScreen(entityId: gbpEntity),
          ),
          GoRoute(
            name: netWorthRoute,
            path: '/budgets/:entityId/reflect/net-worth',
            builder: (_, _) => const NetWorthScreen(entityId: gbpEntity),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData.light(useMaterial3: true),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Create the GBP entity; the screen routes into add account.
      final createPage = CreateEntityPage(tester);
      await createPage.create();
      expect(find.byType(AddAccountScreen), findsOneWidget);

      // 2. Add a USD account with an opening balance: nickname, type,
      //    currency and opening amount, then submit.
      await scrollAndTap(
        tester,
        find.byKey(const Key('add-account-add-unlinked-button')),
      );

      await _enterTextWhenVisible(
        tester,
        find.byKey(const Key('add-account-unlinked-nickname-field')),
        TestData.usdCheckingAccountName,
      );
      await _activateListTile(
        tester,
        find.byKey(const Key('add-account-unlinked-type-tile')),
      );
      await _activateListTile(
        tester,
        find.byKey(const ValueKey('add-account-type-option-checking')),
      );
      await tester.pumpAndSettle();

      // The currency defaults to the entity's GBP; switch it to USD. The
      // row shows the bare code; the sheet lists the full display names.
      await scrollIntoView(tester, find.text('GBP'));
      await tester.tap(find.text('GBP'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('US Dollar (USD)'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('US Dollar (USD)'));
      await tester.pumpAndSettle();

      await _enterTextWhenVisible(
        tester,
        find.byKey(const Key('add-account-unlinked-balance-field')),
        '100',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
      expect(find.text('Success!'), findsOneWidget);

      expect(createdAccounts, hasLength(1));
      final created = createdAccounts.single;
      expect(created.currencyCode, 'USD');
      expect(created.kind, AccountKind.checking);
      expect(created.balanceMinor, 10000);

      // 3. Open net worth: the converted total, the rate line and the By
      //    currency row all come from the server view.
      router.goNamed(
        netWorthRoute,
        pathParameters: {'entityId': gbpEntity},
      );
      await tester.pumpAndSettle();

      final netWorth = NetWorthPage(tester);
      expect(netWorth.headline, findsOneWidget);
      // £79.00 = $100.00 at 0.79. The headline and the totals rows all
      // render the converted figure.
      expect(find.text('£79.00'), findsWidgets);
      expect(netWorth.trustLine, findsOneWidget);

      await netWorth.showByCurrency();
      await tester.pumpAndSettle();

      expect(netWorth.currencyRow('USD'), findsOneWidget);
      expect(
        find.textContaining('1 USD = 0.79 GBP'),
        findsOneWidget,
      );
      expect(find.textContaining('Nov 8'), findsOneWidget);
      expect(find.text(r'$100.00'), findsOneWidget);
      expect(find.text('£79.00'), findsWidgets);
    },
  );
}

/// The server-side net worth view recomposed from the accounts the flow
/// created, at the section's fixed rate. The app never does this itself;
/// the fixture stands in for `report.netWorth`.
NetWorthView _netWorthFor(List<Account> accounts) {
  var gbpMinor = 0;
  var usdMinor = 0;
  var usdAccounts = 0;
  var gbpAccounts = 0;
  for (final account in accounts) {
    switch (account.currencyCode) {
      case 'GBP':
        gbpMinor += account.balanceMinor;
        gbpAccounts++;
      case 'USD':
        usdMinor += account.balanceMinor;
        usdAccounts++;
    }
  }
  const rate = '0.79';
  final usdConverted = (usdMinor * 0.79).round();
  final total = gbpMinor + usdConverted;

  return NetWorthView(
    currencyCode: 'GBP',
    asOf: DateTime.utc(2026, 11, 8),
    assetsMinor: total,
    liabilitiesMinor: 0,
    netWorthMinor: total,
    isComplete: true,
    missingCurrencyCodes: const [],
    hasStaleRates: false,
    currencies: [
      if (gbpAccounts > 0)
        NetWorthCurrencyRow(
          currencyCode: 'GBP',
          nativeMinor: gbpMinor,
          convertedMinor: gbpMinor,
          fxRate: '1',
          fxRateDate: DateTime.utc(2026, 11, 8),
          isStale: false,
          accountCount: gbpAccounts,
        ),
      if (usdAccounts > 0)
        NetWorthCurrencyRow(
          currencyCode: 'USD',
          nativeMinor: usdMinor,
          convertedMinor: usdConverted,
          fxRate: rate,
          fxRateDate: DateTime.utc(2026, 11, 8),
          isStale: false,
          accountCount: usdAccounts,
        ),
    ],
    entities: [
      NetWorthEntityRow(
        entityId: UuidValue.fromString(TestData.gbpEntityId),
        name: TestData.entityName,
        kind: EntityKind.individual,
        assetsMinor: total,
        liabilitiesMinor: 0,
        netWorthMinor: total,
        isComplete: true,
      ),
    ],
    accounts: [
      for (final account in accounts)
        NetWorthAccountRow(
          accountId: account.id!,
          entityId: account.entityId,
          name: account.name,
          kind: account.kind,
          currencyCode: account.currencyCode,
          balanceMinor: account.balanceMinor,
          convertedMinor: account.currencyCode == 'USD'
              ? (account.balanceMinor * 0.79).round()
              : account.balanceMinor,
          isLiability: false,
        ),
    ],
  );
}

NetWorthHistoryView _historyFor(
  List<Account> accounts,
  NetWorthGranularity granularity,
) {
  final view = _netWorthFor(accounts);
  return NetWorthHistoryView(
    currencyCode: 'GBP',
    granularity: granularity,
    points: [
      // Mid-way through the week: half the week's final total.
      NetWorthPoint(
        date: DateTime.utc(2026, 11, 4),
        assetsMinor: view.assetsMinor ~/ 2,
        liabilitiesMinor: view.liabilitiesMinor,
        netWorthMinor: view.netWorthMinor ~/ 2,
        isComplete: true,
      ),
      NetWorthPoint(
        date: DateTime.utc(2026, 11, 8),
        assetsMinor: view.netWorthMinor,
        liabilitiesMinor: 0,
        netWorthMinor: view.netWorthMinor,
        isComplete: true,
      ),
    ],
  );
}

class _CreatingEntityActions extends EntityActions {
  _CreatingEntityActions({required this.entityId});

  final String entityId;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<String> create({
    required String name,
    required EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
  }) async {
    expect(baseCurrencyCode, 'GBP');
    expect(countryCode, 'GB');
    return entityId;
  }
}

class _RecordingAccountActions extends AccountActions {
  _RecordingAccountActions(this.created);

  final List<Account> created;

  @override
  FutureOr<void> build() {}

  @override
  Future<Account> createAccount({
    required String name,
    required AccountKind kind,
    required String currencyCode,
    required String entityId,
    AccountBalanceSource? balanceSource,
    String? institutionId,
    String? note,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
  }) async {
    final account = Account(
      id: UuidValue.fromString('00000000-0000-0000-0000-000000000810'),
      name: name,
      kind: kind,
      balanceSource: balanceSource ?? AccountBalanceSource.transactions,
      balanceMinor: openingBalanceMinor ?? 0,
      currencyCode: currencyCode,
      entityId: UuidValue.fromString(entityId),
      onBudget: onBudget ?? true,
      sortOrder: 0,
    );
    created.add(account);
    return account;
  }
}

Future<void> _activateListTile(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 10; attempt++) {
    if (finder.evaluate().isNotEmpty) {
      final tile = tester.widget<ListTile>(finder.first);
      final onTap = tile.onTap;
      if (onTap == null) {
        await tester.tap(finder.first);
        await tester.pumpAndSettle();
        return;
      }
      onTap();
      await tester.pumpAndSettle();
      return;
    }

    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      final scrollOffset = attempt.isEven
          ? const Offset(0, 280)
          : const Offset(0, -280);
      await tester.drag(scrollable.first, scrollOffset, warnIfMissed: false);
      await tester.pumpAndSettle();
      continue;
    }

    await tester.pump(const Duration(milliseconds: 120));
  }

  expect(finder, findsOneWidget);
}

Future<void> _enterTextWhenVisible(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
