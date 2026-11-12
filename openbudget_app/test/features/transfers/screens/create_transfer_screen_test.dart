import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart';

const String _entityId = fixtureEntityId;
const String _otherEntityId = '00000000-0000-0000-0000-0000000000f002';
const String _savingsId = '00000000-0000-0000-0000-0000000000f0c1';
const String _usdAccountId = '00000000-0000-0000-0000-0000000000f0c2';
const String _jpyAccountId = '00000000-0000-0000-0000-0000000000f0c3';
const String _investmentId = '00000000-0000-0000-0000-0000000000f0c4';
const String _otherEntityAccountId = '00000000-0000-0000-0000-0000000000f0c5';

GoRouter _router() => GoRouter(
  initialLocation: createTransferPath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: accountListRoute,
      path: accountListPath,
      builder: (_, _) => const Scaffold(body: Text('Accounts')),
    ),
    GoRoute(
      name: createTransferRoute,
      path: createTransferPath,
      builder: (context, state) =>
          CreateTransferScreen(entityId: state.pathParameters['entityId']!),
    ),
  ],
);

List<Account> _accounts() => [
  testAccount(),
  testAccount(id: _savingsId, name: 'Savings'),
  testAccount(
    id: _usdAccountId,
    name: 'Dollar wallet',
    currencyCode: 'USD',
  ),
  testAccount(
    id: _jpyAccountId,
    name: 'Yen wallet',
    currencyCode: 'JPY',
  ),
  testAccount(
    id: _investmentId,
    name: 'Brokerage',
    kind: AccountKind.investment,
    onBudget: false,
  ),
  testAccount(
    id: _otherEntityAccountId,
    entityId: _otherEntityId,
    name: 'Side business',
  ),
];

class _Harness {
  _Harness(this.client, this.transfers);

  final FakeEndpointClient client;
  final List<TransferInput> transfers;
}

Future<_Harness> _pumpTransfer(
  WidgetTester tester, {
  List<Account>? accounts,
  FxQuoteView? quote,
}) async {
  final transfers = <TransferInput>[];
  final client = FakeEndpointClient()
    ..handle('account', 'listAll', (_) => accounts ?? _accounts())
    ..handle('budget', 'getMonth', (_) => testMonthView())
    ..handle(
      'fxRate',
      'quote',
      (_) => quote ?? testFxQuote(rate: '1.27'),
    )
    ..handle('transaction', 'createTransfer', (args) {
      transfers.add(args['input'] as TransferInput);
      return <TransactionView>[
        testTransactionView(),
        testTransactionView(),
      ];
    });
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(client)],
  );
  addTearDown(container.dispose);
  await tester.pumpApp(
    const SizedBox.shrink(),
    container: container,
    router: _router(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
  await tester.pumpAndSettle();
  return _Harness(client, transfers);
}

Future<void> _pick(WidgetTester tester, String label, String item) async {
  await tester.tap(
    find.byWidgetPredicate(
      (widget) => widget is ObDropdown<String> && widget.labelText == label,
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(item).last);
  await tester.pumpAndSettle();
}

Future<void> _tapTransfer(WidgetTester tester) async {
  await tester.ensureVisible(find.widgetWithText(ObFilledButton, 'Transfer'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ObFilledButton, 'Transfer'));
  await tester.pumpAndSettle();
}

void main() {
  group('CreateTransferScreen', () {
    testWidgets('opens with the two account pickers and no amount field', (
      tester,
    ) async {
      await _pumpTransfer(tester);

      expect(find.text('From account'), findsOneWidget);
      expect(find.text('To account'), findsOneWidget);
      expect(find.byKey(const Key('transfer-amount-field')), findsNothing);
      expect(find.byKey(const Key('transfer-sent-amount-field')), findsNothing);
    });

    testWidgets('lists every account in every entity', (tester) async {
      final harness = await _pumpTransfer(tester);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> &&
              widget.labelText == 'From account',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current account (GBP)'), findsOneWidget);
      expect(find.text('Side business (GBP)'), findsOneWidget);
      expect(harness.client.callsTo('account', 'listAll'), hasLength(1));
    });

    testWidgets('the destination excludes the chosen source', (tester) async {
      await _pumpTransfer(tester);

      await _pick(tester, 'From account', 'Current account (GBP)');
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> && widget.labelText == 'To account',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Current account (GBP)'), findsOneWidget);
      expect(find.text('Savings (GBP)'), findsOneWidget);
      expect(find.text('Dollar wallet (USD)'), findsOneWidget);
    });

    testWidgets('the source excludes the chosen destination', (tester) async {
      await _pumpTransfer(tester);

      await _pick(tester, 'To account', 'Savings (GBP)');
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> &&
              widget.labelText == 'From account',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Savings (GBP)'), findsOneWidget);
      expect(find.text('Current account (GBP)'), findsOneWidget);
    });

    testWidgets('refuses a malformed or negative amount', (tester) async {
      await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Savings (GBP)');

      final amount = find.byKey(const Key('transfer-amount-field'));
      await tester.enterText(amount, '12.345');
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );

      await tester.enterText(amount, '-12.34');
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );
    });

    testWidgets('sends a same-currency transfer', (tester) async {
      final harness = await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Savings (GBP)');

      expect(find.text('Sent'), findsNothing);
      expect(find.text('Received'), findsNothing);

      await tester.enterText(
        find.byKey(const Key('transfer-amount-field')),
        '12.34',
      );
      await tester.pumpAndSettle();
      await _tapTransfer(tester);

      final input = harness.transfers.single;
      expect(input.fromAccountId.toString(), fixtureAccountId);
      expect(input.toAccountId.toString(), _savingsId);
      expect(input.fromAmountMinor, 1234);
      expect(input.toAmountMinor, isNull);
      expect(input.useMarketRate, isFalse);
      expect(input.envelopeId, isNull);
    });

    testWidgets('shows Sent, Received and the implied rate across currencies', (
      tester,
    ) async {
      await _pumpTransfer(
        tester,
        quote: testFxQuote(
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'USD',
          rate: '1.27',
          rateDate: DateTime.utc(2026, 11, 6),
        ),
      );
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Dollar wallet (USD)');

      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('Received'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('transfer-sent-amount-field')),
        '100',
      );
      await tester.pumpAndSettle();

      final rateLine = find.byKey(const Key('transfer-implied-rate'));
      expect(rateLine, findsOneWidget);
      final text = tester
          .widget<Text>(
            find.descendant(of: rateLine, matching: find.byType(Text)).first,
          )
          .data!;
      expect(text, contains(r'≈ $127.00'));
      expect(text, contains('1 GBP = 1.27 USD'));
      expect(text, contains('6 Nov 2026'));
      expect(text, contains('market'));
      expect(find.text("Use today's rate"), findsOneWidget);
    });

    testWidgets("Use today's rate fills the received amount", (tester) async {
      final harness = await _pumpTransfer(
        tester,
        quote: testFxQuote(
          fromCurrencyCode: 'GBP',
          toCurrencyCode: 'USD',
          rate: '1.27',
        ),
      );
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Dollar wallet (USD)');
      await tester.enterText(
        find.byKey(const Key('transfer-sent-amount-field')),
        '100',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text("Use today's rate"));
      await tester.pumpAndSettle();

      final received = tester.widget<TextField>(
        find.byKey(const Key('transfer-received-amount-field')),
      );
      expect(received.controller!.text, '127.00');

      await _tapTransfer(tester);

      final input = harness.transfers.single;
      expect(input.fromAmountMinor, 10000);
      expect(input.toAmountMinor, 12700);
      expect(input.useMarketRate, isFalse);
    });

    testWidgets(
      'an empty received amount asks the server for the market rate',
      (
        tester,
      ) async {
        final harness = await _pumpTransfer(tester);
        await _pick(tester, 'From account', 'Current account (GBP)');
        await _pick(tester, 'To account', 'Dollar wallet (USD)');
        await tester.enterText(
          find.byKey(const Key('transfer-sent-amount-field')),
          '100',
        );
        await tester.pumpAndSettle();
        await _tapTransfer(tester);

        final input = harness.transfers.single;
        expect(input.toAmountMinor, isNull);
        expect(input.useMarketRate, isTrue);
      },
    );

    testWidgets('the envelope appears when money leaves the plan', (
      tester,
    ) async {
      final harness = await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Brokerage (GBP)');

      expect(find.text('Envelope (money leaves the plan)'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('transfer-amount-field')),
        '50',
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ObDropdown<String> &&
              widget.labelText == 'Envelope (money leaves the plan)',
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Living / Groceries').last);
      await tester.pumpAndSettle();
      await _tapTransfer(tester);

      expect(
        harness.transfers.single.envelopeId.toString(),
        fixtureEnvelopeId,
      );
    });

    testWidgets('a transfer between two on-budget accounts needs no envelope', (
      tester,
    ) async {
      await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Savings (GBP)');

      expect(find.text('Envelope (money leaves the plan)'), findsNothing);
    });

    testWidgets('a cross-entity transfer says where the money goes', (
      tester,
    ) async {
      await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Current account (GBP)');
      await _pick(tester, 'To account', 'Side business (GBP)');

      expect(
        find.textContaining('Transfers between your entities'),
        findsOneWidget,
      );
      expect(find.text('Envelope (money leaves the plan)'), findsOneWidget);
    });

    testWidgets('a zero-decimal source refuses a decimal point', (
      tester,
    ) async {
      await _pumpTransfer(tester);
      await _pick(tester, 'From account', 'Yen wallet (JPY)');
      await _pick(tester, 'To account', 'Savings (GBP)');

      final amount = tester.widget<TextField>(
        find.byKey(const Key('transfer-sent-amount-field')),
      );
      expect(amount.keyboardType.decimal, isFalse);

      await tester.enterText(
        find.byKey(const Key('transfer-sent-amount-field')),
        '12.5',
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a valid amount with at most 0 decimal places'),
        findsOneWidget,
      );
    });
  });
}
