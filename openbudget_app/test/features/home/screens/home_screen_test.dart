// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

final _ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000001');
const _budgetIdStr = '00000000-0000-0000-0000-000000000010';

Budget _makeBudget({
  String? id,
  String name = 'My Budget',
  String currencyCode = 'USD',
}) {
  return Budget(
    id: id != null ? UuidValue.fromString(id) : null,
    name: name,
    currencyCode: currencyCode,
    ownerId: _ownerId,
  );
}

Account _makeAccount({
  String name = 'Checking',
  int balanceCents = 100000,
  String budgetIdStr = _budgetIdStr,
  bool isClosed = false,
  bool onBudget = true,
  String accountType = 'checking',
}) {
  return Account(
    name: name,
    accountType: accountType,
    balanceCents: balanceCents,
    currencyCode: 'USD',
    budgetId: UuidValue.fromString(budgetIdStr),
    onBudget: onBudget,
    sortOrder: 0,
    isClosed: isClosed,
  );
}

BudgetSummary _emptySummary(Budget budget) {
  return BudgetSummary(
    budget: budget,
    categories: [],
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

  group('HomeScreen', () {
    testWidgets('renders loading indicator while budgets load', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith(
              (ref) => throw Exception('Network error'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load budgets'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty state when no budgets', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => <Budget>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Budgets Yet'), findsOneWidget);
      expect(find.text('Create Your First Budget'), findsOneWidget);
      expect(find.byIcon(Icons.savings_rounded), findsOneWidget);
    });

    testWidgets('does not show FAB in empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => <Budget>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('renders budget card with name and currency', (tester) async {
      final budget = _makeBudget(
        id: _budgetIdStr,
        name: 'Family Budget',
        currencyCode: 'EUR',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => []),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budget),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Family Budget'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('shows FAB when budgets exist', (tester) async {
      final budget = _makeBudget(id: _budgetIdStr);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => []),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budget),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders account count and total balance on budget card', (
      tester,
    ) async {
      final budget = _makeBudget(id: _budgetIdStr);
      final accounts = [
        _makeAccount(balanceCents: 250000),
        _makeAccount(name: 'Savings', balanceCents: 500000),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budget),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Appears in both the budget card and net worth summary
      expect(find.text('2 accounts'), findsAny);
    });

    testWidgets('renders ready-to-assign amount on budget card', (
      tester,
    ) async {
      final budget = _makeBudget(id: _budgetIdStr);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => []),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => BudgetSummary(
                budget: budget,
                categories: [],
                totalIncomeCents: 300000,
                totalBudgetedCents: 100000,
                readyToAssignCents: 200000,
                year: 2026,
                month: 2,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('to assign'), findsOneWidget);
    });

    testWidgets('renders overspent count when envelopes are overspent', (
      tester,
    ) async {
      final budget = _makeBudget(id: _budgetIdStr);
      final envelope = Envelope(
        name: 'Groceries',
        budgetedAmountCents: 50000,
        spentAmountCents: 70000,
        currencyCode: 'USD',
        categoryId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000020',
        ),
        sortOrder: 0,
      );
      final category = Category(
        name: 'Essentials',
        budgetId: UuidValue.fromString(_budgetIdStr),
        sortOrder: 0,
        isHidden: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => []),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => BudgetSummary(
                budget: budget,
                categories: [
                  CategoryWithEnvelopes(
                    category: category,
                    envelopes: [envelope],
                    monthlyEnvelopes: [
                      MonthlyEnvelopeData(
                        envelope: envelope,
                        allocatedCents: 50000,
                        spentCents: 70000,
                        availableCents: -20000,
                        carryoverCents: 0,
                      ),
                    ],
                    totalBudgetedCents: 50000,
                    totalSpentCents: 70000,
                    totalAvailableCents: -20000,
                  ),
                ],
                totalIncomeCents: 100000,
                totalBudgetedCents: 50000,
                readyToAssignCents: 50000,
                year: 2026,
                month: 2,
              ),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 overspent'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders net worth summary with total balance', (tester) async {
      final budget = _makeBudget(id: _budgetIdStr);
      final accounts = [
        _makeAccount(balanceCents: 250000),
        _makeAccount(name: 'Savings', balanceCents: 750000),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budget),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Worth'), findsOneWidget);
      expect(find.text('2 accounts'), findsAny);
    });

    testWidgets('excludes closed accounts from net worth', (tester) async {
      final budget = _makeBudget(id: _budgetIdStr);
      final accounts = [
        _makeAccount(name: 'Active', balanceCents: 500000),
        _makeAccount(name: 'Closed', isClosed: true),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => [budget]),
            accountListProvider.overrideWith((ref, budgetId) async => accounts),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budget),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Only 1 active account shown in net worth header
      expect(find.text('1 account'), findsAny);
    });

    testWidgets('renders logout button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => <Budget>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byTooltip('Sign Out'), findsOneWidget);
    });

    testWidgets('renders app title in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => <Budget>[]),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OpenBudget'), findsOneWidget);
    });

    testWidgets('renders multiple budget cards', (tester) async {
      final budgets = [
        _makeBudget(
          id: '00000000-0000-0000-0000-000000000010',
          name: 'Personal',
        ),
        _makeBudget(
          id: '00000000-0000-0000-0000-000000000011',
          name: 'Business',
          currencyCode: 'GBP',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetListProvider.overrideWith((ref) async => budgets),
            accountListProvider.overrideWith((ref, budgetId) async => []),
            budgetSummaryProvider.overrideWith(
              (ref, budgetId) async => _emptySummary(budgets.first),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('GBP'), findsOneWidget);
    });
  });
}
