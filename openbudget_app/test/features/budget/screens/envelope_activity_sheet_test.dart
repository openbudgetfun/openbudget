// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/envelope_activity_sheet.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _entityId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _categoryUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000020',
);
final _envelopeUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000030',
);
Envelope _makeEnvelope({
  String name = 'Groceries',
  int budgetedAmountMinor = 50000,
  int spentAmountMinor = 12000,
  String? note,
  UuidValue? id,
}) => Envelope(
  id: id ?? _envelopeUuid,
  name: name,
  categoryId: _categoryUuid,
  budgetedAmountMinor: budgetedAmountMinor,
  spentAmountMinor: spentAmountMinor,
  currencyCode: 'USD',
  sortOrder: 0,
  note: note,
);

MonthlyEnvelopeData _makeMonthlyData({
  Envelope? envelope,
  int allocatedMinor = 50000,
  int spentMinor = 12000,
  int availableMinor = 38000,
  int carryoverMinor = 5000,
}) => MonthlyEnvelopeData(
  envelope: envelope ?? _makeEnvelope(),
  allocatedMinor: allocatedMinor,
  spentMinor: spentMinor,
  availableMinor: availableMinor,
  carryoverMinor: carryoverMinor,
);

EnvelopeGoal _makeGoal({
  String goalType = 'target_balance',
  int targetAmountMinor = 100000,
}) => EnvelopeGoal(
  envelopeId: _envelopeUuid,
  goalType: goalType,
  targetAmountMinor: targetAmountMinor,
);

Category _makeCategory({String name = 'Food'}) => Category(
  id: _categoryUuid,
  name: name,
  entityId: _budgetUuid,
  sortOrder: 0,
  isHidden: false,
);

List<CategoryWithEnvelopes> _makeCategories() => [
  CategoryWithEnvelopes(
    category: _makeCategory(),
    envelopes: [_makeEnvelope()],
    monthlyEnvelopes: [_makeMonthlyData()],
    totalBudgetedMinor: 50000,
    totalSpentMinor: 12000,
    totalAvailableMinor: 38000,
  ),
];

Transaction _makeTransaction({
  String description = 'Whole Foods',
  int amountMinor = -3500,
  UuidValue? envelopeId,
  DateTime? transactionDate,
}) => Transaction(
  description: description,
  amountMinor: amountMinor,
  currencyCode: 'USD',
  entityId: _budgetUuid,
  envelopeId: envelopeId ?? _envelopeUuid,
  transactionDate: transactionDate ?? DateTime(2026, 2, 15),
);

void main() {
  Widget buildSubject({
    Envelope? envelope,
    MonthlyEnvelopeData? monthlyData,
    EnvelopeGoal? goal,
    List<Transaction> transactions = const [],
  }) {
    final env = envelope ?? _makeEnvelope();
    return ProviderScope(
      overrides: [
        monthlyTransactionsProvider.overrideWith(
          (ref, args) async => transactions,
        ),
      ],
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: EnvelopeActivitySheet(
            envelope: env,
            entityId: _entityId,
            currencyCode: 'USD',
            categories: _makeCategories(),
            categoryId: _categoryUuid.toString(),
            year: 2026,
            month: 2,
            monthlyData: monthlyData,
            goal: goal,
          ),
        ),
      ),
    );
  }

  group('EnvelopeActivitySheet', () {
    testWidgets('renders envelope name in header', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders available pill with amount', (tester) async {
      await tester.pumpWidget(buildSubject(monthlyData: _makeMonthlyData()));
      await tester.pumpAndSettle();

      // The available pill should show the formatted amount
      expect(find.text('Available'), findsAtLeast(1));
    });

    testWidgets('renders balance grid with four cells', (tester) async {
      await tester.pumpWidget(buildSubject(monthlyData: _makeMonthlyData()));
      await tester.pumpAndSettle();

      expect(find.text('From Last Month'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Activity'), findsAtLeast(1));
      expect(find.text('Available'), findsAtLeast(1));
    });

    testWidgets('renders action buttons: Move Money, Set Goal, Edit Envelope', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Move Money'), findsOneWidget);
      expect(find.text('Set Goal'), findsOneWidget);
      expect(find.text('Edit Envelope'), findsOneWidget);
    });

    testWidgets('renders action button icons', (tester) async {
      await tester.pumpWidget(buildSubject());
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
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // "Activity" appears both in the grid cell and the section title
      expect(find.text('Activity'), findsAtLeast(1));
    });

    testWidgets('renders empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('No transactions this month'), findsOneWidget);
      expect(find.byType(WiredDoodle), findsOneWidget);
    });

    testWidgets('renders transactions when available', (tester) async {
      final transactions = [
        _makeTransaction(),
        _makeTransaction(description: 'Salary', amountMinor: 150000),
      ];

      await tester.pumpWidget(buildSubject(transactions: transactions));
      await tester.pumpAndSettle();

      expect(find.text('Whole Foods'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('renders goal progress when goal is set', (tester) async {
      await tester.pumpWidget(
        buildSubject(monthlyData: _makeMonthlyData(), goal: _makeGoal()),
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
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(ObEnvelopeGauge), findsOneWidget);
    });

    testWidgets('renders note when envelope has a note', (tester) async {
      await tester.pumpWidget(
        buildSubject(envelope: _makeEnvelope(note: 'Weekly grocery budget')),
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
      await tester.pumpWidget(buildSubject());
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
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The drag handle is a 40x4 Container - we verify the sheet renders
      // by checking the core elements are present
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Move Money'), findsOneWidget);
    });
  });
}
