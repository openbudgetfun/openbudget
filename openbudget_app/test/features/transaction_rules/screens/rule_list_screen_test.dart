// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/screens/rule_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000001');
final _payeeUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000020');
final _envelopeUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000030',
);
final _categoryUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000040',
);

Budget _makeBudget() {
  return Budget(name: 'Test Budget', currencyCode: 'USD', ownerId: _ownerUuid);
}

Payee _makePayee({String name = 'Test Payee', UuidValue? id}) {
  return Payee(id: id ?? _payeeUuid, name: name, budgetId: _budgetUuid);
}

TransactionRule _makeRule({
  UuidValue? id,
  UuidValue? payeeId,
  UuidValue? targetEnvelopeId,
  bool enabled = true,
}) {
  return TransactionRule(
    id: id,
    budgetId: _budgetUuid,
    payeeId: payeeId ?? _payeeUuid,
    targetEnvelopeId: targetEnvelopeId ?? _envelopeUuid,
    enabled: enabled,
  );
}

Envelope _makeEnvelope({String name = 'Groceries', UuidValue? id}) {
  return Envelope(
    id: id ?? _envelopeUuid,
    name: name,
    budgetedAmountCents: 0,
    spentAmountCents: 0,
    currencyCode: 'USD',
    categoryId: _categoryUuid,
    sortOrder: 0,
  );
}

Category _makeCategory({String name = 'Food'}) {
  return Category(
    id: _categoryUuid,
    name: name,
    budgetId: _budgetUuid,
    sortOrder: 0,
    isHidden: false,
  );
}

BudgetSummary _makeEmptySummary() {
  return BudgetSummary(
    budget: _makeBudget(),
    categories: const [],
    totalIncomeCents: 0,
    totalBudgetedCents: 0,
    readyToAssignCents: 0,
    year: 2026,
    month: 2,
  );
}

BudgetSummary _makeSummaryWithEnvelope({
  String categoryName = 'Food',
  String envelopeName = 'Groceries',
}) {
  final envelope = _makeEnvelope(name: envelopeName);
  final category = _makeCategory(name: categoryName);

  return BudgetSummary(
    budget: _makeBudget(),
    categories: [
      CategoryWithEnvelopes(
        category: category,
        envelopes: [envelope],
        monthlyEnvelopes: const [],
        totalBudgetedCents: 0,
        totalSpentCents: 0,
        totalAvailableCents: 0,
      ),
    ],
    totalIncomeCents: 0,
    totalBudgetedCents: 0,
    readyToAssignCents: 0,
    year: 2026,
    month: 2,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RuleListScreen', () {
    testWidgets('renders loading indicator while rules load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state when rules fail to load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith(
              (ref, budgetId) =>
                  throw Exception('Could not load transaction rules'),
            ),
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load transaction rules'), findsOneWidget);
    });

    testWidgets('renders empty state with add button prompt', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith(
              (ref, budgetId) async => <TransactionRule>[],
            ),
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Rules Yet'), findsOneWidget);
      expect(
        find.text(
          'Create rules to auto-assign envelopes when you select a payee',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.rule_rounded), findsOneWidget);
    });

    testWidgets('renders FAB add button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith(
              (ref, budgetId) async => <TransactionRule>[],
            ),
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders rule list with payee names', (tester) async {
      final payee = _makePayee(name: 'Amazon');
      final rule = _makeRule(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000050'),
        payeeId: payee.id,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith((ref, budgetId) async => [rule]),
            payeeListProvider.overrideWith((ref, budgetId) async => [payee]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Amazon'), findsOneWidget);
    });

    testWidgets('renders rule list with envelope names', (tester) async {
      final payee = _makePayee(name: 'Costco');
      final rule = _makeRule(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000060'),
        payeeId: payee.id,
        targetEnvelopeId: _envelopeUuid,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith((ref, budgetId) async => [rule]),
            payeeListProvider.overrideWith((ref, budgetId) async => [payee]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeSummaryWithEnvelope(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Groceries'), findsOneWidget);
    });

    testWidgets('renders app bar with transaction rules title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith(
              (ref, budgetId) async => <TransactionRule>[],
            ),
            payeeListProvider.overrideWith((ref, budgetId) async => <Payee>[]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transaction Rules'), findsOneWidget);
    });

    testWidgets('renders toggle switch for each rule', (tester) async {
      final payee1 = _makePayee(
        name: 'Netflix',
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000070'),
      );
      final payee2 = _makePayee(
        name: 'Spotify',
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000071'),
      );
      final rules = [
        _makeRule(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000080'),
          payeeId: payee1.id,
        ),
        _makeRule(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000081'),
          payeeId: payee2.id,
          enabled: false,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith((ref, budgetId) async => rules),
            payeeListProvider.overrideWith(
              (ref, budgetId) async => [payee1, payee2],
            ),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('renders disabled label for inactive rule', (tester) async {
      final payee = _makePayee(name: 'Hulu');
      final rule = _makeRule(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000090'),
        payeeId: payee.id,
        enabled: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ruleListProvider.overrideWith((ref, budgetId) async => [rule]),
            payeeListProvider.overrideWith((ref, budgetId) async => [payee]),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _makeEmptySummary(),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RuleListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Disabled'), findsOneWidget);
    });
  });
}
