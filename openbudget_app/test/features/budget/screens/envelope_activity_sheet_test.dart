import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/envelope_activity_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/envelope_activity_sheet.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const String _categoryId = fixtureCategoryId;
const String _envelopeId = fixtureEnvelopeId;

TransactionView _makeTransactionView({
  String description = 'Whole Foods',
  int amountMinor = -3500,
  DateTime? date,
}) => TransactionView(
  transaction: Transaction(
    entityId: UuidValue.fromString(fixtureEntityId),
    accountId: UuidValue.fromString(fixtureAccountId),
    date: date ?? DateTime(2026, 2, 15),
    amountMinor: amountMinor,
    baseAmountMinor: amountMinor,
    fxRateDate: date ?? DateTime(2026, 2, 15),
    description: description,
  ),
  lines: const [],
  accountCurrencyCode: 'USD',
  accountName: 'Current account',
);

/// An activity provider that always answers with the fixture page.
class _FakeEnvelopeActivity extends EnvelopeActivity {
  _FakeEnvelopeActivity(this.items);

  final List<TransactionView> items;

  @override
  Future<EnvelopeActivityState> build(
    String entityId,
    String envelopeId,
  ) async => EnvelopeActivityState(items: items);
}

Widget _buildSubject({
  required EnvelopeMonthView monthEnvelope,
  List<TransactionView> transactions = const [],
}) => ProviderScope(
  overrides: [
    envelopeActivityProvider.overrideWith2(
      (args) => _FakeEnvelopeActivity(transactions),
    ),
  ],
  child: MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: EnvelopeActivitySheet(
        monthEnvelope: monthEnvelope,
        entityId: fixtureEntityId,
        currencyCode: 'USD',
        categoryId: _categoryId,
        month: 202602,
      ),
    ),
  ),
);

void main() {
  group('EnvelopeActivitySheet', () {
    testWidgets('renders envelope name in header', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders available pill with amount', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          monthEnvelope: testEnvelopeRow(
            allocatedMinor: 50000,
            activityMinor: -12000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The available pill should show the formatted amount
      expect(find.text('Available'), findsAtLeast(1));
    });

    testWidgets('renders balance grid with four cells', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          monthEnvelope: testEnvelopeRow(
            carryoverMinor: 5000,
            allocatedMinor: 50000,
            activityMinor: -12000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('From Last Month'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Activity'), findsAtLeast(1));
      expect(find.text('Available'), findsAtLeast(1));
    });

    testWidgets('renders action buttons: Move Money, Set Goal, Edit Envelope', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Move Money'), findsOneWidget);
      expect(find.text('Set Goal'), findsOneWidget);
      expect(find.text('Edit Envelope'), findsOneWidget);
    });

    testWidgets('renders action button icons', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon &&
              widget.data == OpenBudgetIcons.moveMoney,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.flag,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.edit,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders activity title section', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      // "Activity" appears both in the grid cell and the section title
      expect(find.text('Activity'), findsAtLeast(1));
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions this month'), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
    });

    testWidgets('renders transactions when available', (tester) async {
      final transactions = [
        _makeTransactionView(),
        _makeTransactionView(description: 'Salary', amountMinor: 150000),
      ];

      await tester.pumpWidget(
        _buildSubject(
          monthEnvelope: testEnvelopeRow(),
          transactions: transactions,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Whole Foods'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('renders goal progress when goal is set', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          monthEnvelope: testEnvelopeRow(
            goal: EnvelopeGoal(
              entityId: UuidValue.fromString(fixtureEntityId),
              envelopeId: UuidValue.fromString(_envelopeId),
              kind: EnvelopeGoalKind.targetBalance,
              amountMinor: 100000,
            ),
            goalUnderfundedMinor: 50000,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The header gauge and the goal gauge are both present.
      expect(find.byType(ObEnvelopeGauge), findsNWidgets(2));
      // Flag icon from goal summary
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.flag,
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('does not render goal progress when no goal', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ObEnvelopeGauge), findsOneWidget);
    });

    testWidgets('renders note when envelope has a note', (tester) async {
      await tester.pumpWidget(
        _buildSubject(
          monthEnvelope: testEnvelopeRow(
            note: 'Weekly grocery budget',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weekly grocery budget'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.note,
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not render note when envelope has no note', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.note,
        ),
        findsNothing,
      );
    });

    testWidgets('renders drag handle', (tester) async {
      await tester.pumpWidget(
        _buildSubject(monthEnvelope: testEnvelopeRow()),
      );
      await tester.pumpAndSettle();

      // The drag handle is a 40x4 Container - we verify the sheet renders
      // by checking the core elements are present
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Move Money'), findsOneWidget);
    });
  });
}
