// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000011');

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'Test Budget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
  createdAt: DateTime(2026),
);

RecurringTransaction _makeRecurring({
  String description = 'Netflix Subscription',
  int amountCents = -1499,
  String currencyCode = 'USD',
  String frequency = 'monthly',
  DateTime? nextOccurrence,
  bool isActive = true,
  UuidValue? id,
}) => RecurringTransaction(
  id: id,
  description: description,
  amountCents: amountCents,
  currencyCode: currencyCode,
  budgetId: _budgetUuid,
  frequency: frequency,
  nextOccurrence: nextOccurrence ?? DateTime(2099, 12, 31),
  isActive: isActive,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('RecurringListScreen', () {
    testWidgets('renders loading indicator while recurring transactions load', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state with error icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, budgetId) =>
                  throw Exception('Could not load recurring transactions'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Could not load recurring transactions'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders empty state with add button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, budgetId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Recurring Transactions'), findsOneWidget);
      expect(
        find.text(
          'Set up recurring transactions for bills, subscriptions, and regular income',
        ),
        findsOneWidget,
      );
      expect(find.text('Add Recurring'), findsOneWidget);
      expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
    });

    testWidgets('renders recurring list with descriptions', (tester) async {
      final items = [
        _makeRecurring(
          description: 'Netflix',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000020'),
        ),
        _makeRecurring(
          description: 'Spotify',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000021'),
        ),
        _makeRecurring(
          description: 'Rent',
          amountCents: -150000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000022'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('renders frequency for recurring transactions', (tester) async {
      final items = [
        _makeRecurring(
          description: 'Monthly Bill',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000030'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Frequency label is embedded in the subtitle: "Monthly • Next: ..."
      expect(find.textContaining('Monthly \u2022'), findsOneWidget);
    });

    testWidgets('renders next date for recurring transactions', (tester) async {
      final nextDate = DateTime(2026, 3, 15);
      final items = [
        _makeRecurring(
          description: 'Gym Membership',
          nextOccurrence: nextDate,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000040'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('2026-03-15'), findsOneWidget);
    });

    testWidgets('renders app bar with recurring transactions title', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, budgetId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Recurring Transactions'), findsOneWidget);
    });

    testWidgets('renders add button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, budgetId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The add icon appears in the app bar action button (empty state also
      // shows an Add Recurring button).
      expect(find.byIcon(Icons.add), findsWidgets);
    });

    testWidgets('renders calendar button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, budgetId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('renders toggle switch for each recurring item', (
      tester,
    ) async {
      final items = [
        _makeRecurring(
          description: 'Active Bill',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000050'),
        ),
        _makeRecurring(
          description: 'Paused Bill',
          isActive: false,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000051'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('renders summary card and filter chips', (tester) async {
      final items = [
        _makeRecurring(
          description: 'Rent',
          amountCents: -150000,
          nextOccurrence: DateTime(2020),
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000061'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountCents: 500000,
          nextOccurrence: DateTime(2099),
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000062'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsWidgets);
      expect(find.text('Income'), findsWidgets);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('shows multi-currency totals in summary card', (tester) async {
      final items = [
        _makeRecurring(
          description: 'Rent',
          amountCents: -280000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000081'),
        ),
        _makeRecurring(
          description: 'Insurance',
          amountCents: -50000,
          currencyCode: 'EUR',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000082'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountCents: 800000,
          currencyCode: 'EUR',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000083'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('USD'), findsWidgets);
      expect(find.textContaining('EUR'), findsWidgets);
    });

    testWidgets('filters recurring list by selected chip', (tester) async {
      final items = [
        _makeRecurring(
          description: 'Rent',
          amountCents: -150000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000071'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountCents: 500000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000072'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, budgetId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(budgetId: _budgetId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Rent'), findsNothing);
    });
  });
}
