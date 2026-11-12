import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/transaction_rules/screens/rule_list_screen.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../../../fixtures/transactions.dart';
import '../../../support/fake_endpoint_client.dart';

const String _entityId = fixtureEntityId;
const String _secondRuleId = '00000000-0000-0000-0000-0000000000f0f2';

GoRouter _router() => GoRouter(
  initialLocation: transactionRulesPath.replaceFirst(':entityId', _entityId),
  routes: [
    GoRoute(
      name: moreRoute,
      path: morePath,
      builder: (_, _) => const Scaffold(body: Text('More Route')),
    ),
    GoRoute(
      name: transactionRulesRoute,
      path: transactionRulesPath,
      builder: (context, state) =>
          RuleListScreen(entityId: state.pathParameters['entityId']!),
    ),
  ],
);

class _Harness {
  _Harness(this.client);

  final FakeEndpointClient client;
}

Future<_Harness> _pumpRules(
  WidgetTester tester, {
  List<TransactionRule>? rules,
  List<Payee>? payees,
  bool failToLoad = false,
}) async {
  final client = FakeEndpointClient()
    ..handle('transactionRule', 'list', (_) {
      if (failToLoad) throw StateError('offline');
      return rules ?? [testRule()];
    })
    ..handle('payee', 'list', (_) => payees ?? [testPayee()])
    ..handle('budget', 'getMonth', (_) => testMonthView())
    ..handle('transactionRule', 'update', (_) => testRule())
    ..handle('transactionRule', 'delete', (_) => testRule())
    ..handle(
      'transactionRule',
      'create',
      (_) => testRule(
        id: '00000000-0000-0000-0000-0000000000f0f9',
      ),
    );
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
  return _Harness(client);
}

void main() {
  group('RuleListScreen', () {
    testWidgets('renders the loading panel while rules load', (tester) async {
      await tester.pumpApp(
        const RuleListScreen(entityId: _entityId),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
      await tester.pump();

      expect(find.text('Loading rules'), findsOneWidget);
    });

    testWidgets('renders the problem panel when rules fail to load', (
      tester,
    ) async {
      await _pumpRules(tester, failToLoad: true);

      expect(find.text('Could not load transaction rules'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders the empty state with its add prompt', (tester) async {
      await _pumpRules(tester, rules: const []);

      expect(find.byKey(ruleListEmptyKey), findsOneWidget);
      expect(find.text('No Rules Yet'), findsOneWidget);
      expect(
        find.text(
          'Create rules to auto-assign envelopes when you select a payee',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the title, the back action and the FAB', (
      tester,
    ) async {
      await _pumpRules(tester);

      expect(find.text('Transaction Rules'), findsWidgets);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Add Rule'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('More Route'), findsOneWidget);
    });

    testWidgets('lists payee and envelope names', (tester) async {
      await _pumpRules(tester);

      expect(find.text('Tesco'), findsOneWidget);
      expect(find.text('Living / Groceries'), findsOneWidget);
      expect(find.text('Enabled'), findsWidgets);
    });

    testWidgets('falls back to unknown payee and envelope', (tester) async {
      await _pumpRules(
        tester,
        rules: [
          testRule(
            payeeId: '00000000-0000-0000-0000-0000000000f0f8',
            envelopeId: '00000000-0000-0000-0000-0000000000f0f7',
          ),
        ],
        payees: [testPayee()],
      );

      expect(find.text('Unknown payee'), findsOneWidget);
      expect(find.text('Unknown envelope'), findsOneWidget);
    });

    testWidgets('toggles a rule through update', (tester) async {
      final harness = await _pumpRules(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      final call = harness.client.callsTo('transactionRule', 'update').single;
      expect(call.args['ruleId'].toString(), fixtureRuleId);
      expect(call.args['enabled'], isFalse);
    });

    testWidgets('shows the disabled label for an inactive rule', (
      tester,
    ) async {
      await _pumpRules(
        tester,
        rules: [
          testRule(enabled: false),
          testRule(id: _secondRuleId),
        ],
      );

      expect(find.text('Disabled'), findsWidgets);
    });

    testWidgets('shows the summary card and filters by disabled', (
      tester,
    ) async {
      await _pumpRules(
        tester,
        rules: [
          testRule(enabled: false),
          testRule(id: _secondRuleId),
        ],
      );

      expect(find.text('2 total'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Enabled'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Disabled'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Disabled'));
      await tester.pumpAndSettle();

      expect(find.text('Tesco'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('the add dialog creates a rule for a payee and envelope', (
      tester,
    ) async {
      final harness = await _pumpRules(tester);

      await tester.tap(find.byTooltip('Add Rule'));
      await tester.pumpAndSettle();

      expect(find.text('When payee is'), findsOneWidget);
      expect(find.text('Assign to envelope'), findsOneWidget);

      await tester.tap(find.text('When payee is'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tesco').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assign to envelope'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Living / Groceries').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ObFilledButton, 'Save'));
      await tester.pumpAndSettle();

      final call = harness.client.callsTo('transactionRule', 'create').single;
      expect(call.args['payeeId'].toString(), fixturePayeeId);
      expect(call.args['envelopeId'].toString(), fixtureEnvelopeId);
      expect(find.text('Rule created'), findsOneWidget);
    });

    testWidgets('deletes a rule after confirmation', (tester) async {
      final harness = await _pumpRules(tester);

      await tester.tap(find.byTooltip('Delete').first);
      await tester.pumpAndSettle();
      expect(
        find.text('Are you sure you want to delete this?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(
        harness.client
            .callsTo('transactionRule', 'delete')
            .single
            .args['ruleId']
            .toString(),
        fixtureRuleId,
      );
    });
  });
}
