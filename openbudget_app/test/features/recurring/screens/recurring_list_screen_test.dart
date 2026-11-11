// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_actions_provider.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_list_provider.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = 'test-budget-id';
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
  int amountMinor = -1499,
  String currencyCode = 'USD',
  String frequency = 'monthly',
  DateTime? nextOccurrence,
  bool isActive = true,
  UuidValue? id,
}) => RecurringTransaction(
  id: id,
  description: description,
  amountMinor: amountMinor,
  currencyCode: currencyCode,
  entityId: _budgetUuid,
  frequency: frequency,
  nextOccurrence: nextOccurrence ?? DateTime(2099, 12, 31),
  isActive: isActive,
);

class _RecordingRecurringActions extends RecurringActions {
  int? createdAmountMinor;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<RecurringTransaction> createRecurring({
    required String description,
    required int amountMinor,
    required String currencyCode,
    required String entityId,
    required String frequency,
    required DateTime nextOccurrence,
    String? envelopeId,
    String? accountId,
    String? payeeId,
    DateTime? endDate,
  }) async {
    createdAmountMinor = amountMinor;
    return _makeRecurring(
      description: description,
      amountMinor: amountMinor,
      currencyCode: currencyCode,
      frequency: frequency,
      nextOccurrence: nextOccurrence,
    );
  }
}

void main() {
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
            home: const RecurringListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
    });

    testWidgets('renders error state with error icon', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, entityId) =>
                  throw Exception('Could not load recurring transactions'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Could not load recurring transactions'),
        findsOneWidget,
      );
      expect(find.byType(ObStatePanel), findsOneWidget);
    });

    testWidgets('renders empty state with add button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, entityId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is WiredDoodle && widget.kind == WiredDoodleKind.sun,
        ),
        findsOneWidget,
      );
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
          amountMinor: -150000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000022'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
              (ref, entityId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
              (ref, entityId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The add action lives in the app bar; the empty state repeats it as
      // a labelled button without an icon.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.add,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders calendar button in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith(
              (ref, entityId) async => <RecurringTransaction>[],
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon &&
              widget.data == OpenBudgetIcons.calendarMonth,
        ),
        findsOneWidget,
      );
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
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
          amountMinor: -150000,
          nextOccurrence: DateTime(2020),
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000061'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountMinor: 500000,
          nextOccurrence: DateTime(2099),
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000062'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
          amountMinor: -280000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000081'),
        ),
        _makeRecurring(
          description: 'Insurance',
          amountMinor: -50000,
          currencyCode: 'EUR',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000082'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountMinor: 800000,
          currencyCode: 'EUR',
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000083'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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
          amountMinor: -150000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000071'),
        ),
        _makeRecurring(
          description: 'Salary',
          amountMinor: 500000,
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000072'),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
            recurringListProvider.overrideWith((ref, entityId) async => items),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RecurringListScreen(entityId: _entityId),
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

  group('add recurring amount entry', () {
    Widget buildSubject(RecurringActions actions) => ProviderScope(
      overrides: [
        budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
        recurringListProvider.overrideWith(
          (ref, entityId) async => <RecurringTransaction>[],
        ),
        recurringActionsProvider.overrideWith(() => actions),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RecurringListScreen(entityId: _entityId),
      ),
    );

    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.byKey(RecurringListScreen.addButtonKey));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Rent');
    }

    testWidgets('saves 12.34 as 1234 minor units', (tester) async {
      final actions = _RecordingRecurringActions();
      await tester.pumpWidget(buildSubject(actions));
      await tester.pumpAndSettle();

      await openDialog(tester);
      await tester.enterText(find.byType(TextField).at(1), '12.34');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(actions.createdAmountMinor, -1234);
    });

    testWidgets('refuses an over-precise amount instead of rounding it', (
      tester,
    ) async {
      final actions = _RecordingRecurringActions();
      await tester.pumpWidget(buildSubject(actions));
      await tester.pumpAndSettle();

      await openDialog(tester);
      await tester.enterText(find.byType(TextField).at(1), '12.345');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(actions.createdAmountMinor, isNull);
    });

    testWidgets('refuses a negative recurring amount', (tester) async {
      final actions = _RecordingRecurringActions();
      await tester.pumpWidget(buildSubject(actions));
      await tester.pumpAndSettle();

      await openDialog(tester);
      await tester.enterText(find.byType(TextField).at(1), '-12.34');
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid amount with at most 2 decimal places'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(actions.createdAmountMinor, isNull);
    });
  });
}
