// UuidValue is needed for constructing test model data.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  final testCategoryId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );
  final testEnvelopeId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000002',
  );

  Envelope makeEnvelope({
    String name = 'Groceries',
    int budgetedAmountMinor = 50000,
    int spentAmountMinor = 20000,
    String? note,
    bool? isHidden,
  }) => Envelope(
    id: testEnvelopeId,
    name: name,
    categoryId: testCategoryId,
    budgetedAmountMinor: budgetedAmountMinor,
    spentAmountMinor: spentAmountMinor,
    currencyCode: 'USD',
    sortOrder: 0,
    note: note,
    isHidden: isHidden,
  );

  EnvelopeGoal makeGoal({
    String goalType = 'target_balance',
    int targetAmountMinor = 100000,
    int? monthlyFundingMinor,
    DateTime? targetDate,
  }) => EnvelopeGoal(
    envelopeId: testEnvelopeId,
    goalType: goalType,
    targetAmountMinor: targetAmountMinor,
    monthlyFundingMinor: monthlyFundingMinor,
    targetDate: targetDate,
  );

  Widget buildSubject({
    required Envelope envelope,
    String currencyCode = 'USD',
    MonthlyEnvelopeData? monthlyData,
    EnvelopeGoal? goal,
    VoidCallback? onQuickBudget,
    bool hideAmounts = false,
    bool hideProgressBars = false,
  }) => ProviderScope(
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: EnvelopeRow(
          envelope: envelope,
          currencyCode: currencyCode,
          onTap: () {},
          onLongPress: () {},
          monthlyData: monthlyData,
          goal: goal,
          onQuickBudget: onQuickBudget,
          hideAmounts: hideAmounts,
          hideProgressBars: hideProgressBars,
        ),
      ),
    ),
  );

  group('EnvelopeRow', () {
    testWidgets('renders envelope name and amounts', (tester) async {
      final envelope = makeEnvelope();
      await tester.pumpWidget(buildSubject(envelope: envelope));
      await tester.pump();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders note when present', (tester) async {
      final envelope = makeEnvelope(note: 'Weekly shopping');
      await tester.pumpWidget(buildSubject(envelope: envelope));
      await tester.pump();

      expect(find.text('Weekly shopping'), findsOneWidget);
    });

    testWidgets('does not render note when absent', (tester) async {
      final envelope = makeEnvelope();
      await tester.pumpWidget(buildSubject(envelope: envelope));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.note,
        ),
        findsNothing,
      );
    });

    testWidgets('renders quick budget button when callback provided', (
      tester,
    ) async {
      final envelope = makeEnvelope();
      await tester.pumpWidget(
        buildSubject(envelope: envelope, onQuickBudget: () {}),
      );
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.quick,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders goal progress bar with underfunded text', (
      tester,
    ) async {
      // Envelope with goal target of $1000, but only $300 available
      final envelope = makeEnvelope(
        budgetedAmountMinor: 30000,
        spentAmountMinor: 0,
      );
      final goal = makeGoal();

      await tester.pumpWidget(buildSubject(envelope: envelope, goal: goal));
      await tester.pump();

      // Should show underfunded text with "needed" label
      expect(find.textContaining('needed'), findsOneWidget);
      // Should show warning icon
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.warning,
        ),
        findsOneWidget,
      );
    });

    testWidgets('does not show underfunded text when fully funded', (
      tester,
    ) async {
      // Envelope with goal target of $1000, and $1000 available
      final envelope = makeEnvelope(
        budgetedAmountMinor: 100000,
        spentAmountMinor: 0,
      );
      final goal = makeGoal();

      await tester.pumpWidget(buildSubject(envelope: envelope, goal: goal));
      await tester.pump();

      // Should not show "needed" text when fully funded
      expect(find.textContaining('needed'), findsNothing);
    });

    testWidgets('renders spending progress bar without goal', (tester) async {
      final envelope = makeEnvelope(spentAmountMinor: 25000);

      await tester.pumpWidget(buildSubject(envelope: envelope));
      await tester.pump();

      // Should render the envelope gauge that fills as money is spent.
      expect(find.byType(ObEnvelopeGauge), findsOneWidget);
    });

    testWidgets('renders carryover indicator when present', (tester) async {
      final envelope = makeEnvelope();
      final monthlyData = MonthlyEnvelopeData(
        envelope: envelope,
        allocatedMinor: 50000,
        spentMinor: 20000,
        availableMinor: 30000,
        carryoverMinor: 5000,
      );

      await tester.pumpWidget(
        buildSubject(envelope: envelope, monthlyData: monthlyData),
      );
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.inflow,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders monthly funding goal underfunded amount', (
      tester,
    ) async {
      // Monthly funding goal: $200/month, but only $50 budgeted
      final envelope = makeEnvelope(
        budgetedAmountMinor: 5000,
        spentAmountMinor: 0,
      );
      final goal = makeGoal(
        goalType: 'monthly_funding',
        targetAmountMinor: 20000,
        monthlyFundingMinor: 20000,
      );

      await tester.pumpWidget(buildSubject(envelope: envelope, goal: goal));
      await tester.pump();

      // Should show underfunded text
      expect(find.textContaining('needed'), findsOneWidget);
    });

    testWidgets('obscures amount text when hide amounts is enabled', (
      tester,
    ) async {
      final envelope = makeEnvelope();
      await tester.pumpWidget(
        buildSubject(envelope: envelope, hideAmounts: true),
      );
      await tester.pump();

      expect(find.text(hiddenAmountPlaceholder), findsOneWidget);
    });

    testWidgets('hides progress bars when toggle is enabled', (tester) async {
      final envelope = makeEnvelope(spentAmountMinor: 25000);

      await tester.pumpWidget(
        buildSubject(envelope: envelope, hideProgressBars: true),
      );
      await tester.pump();

      expect(find.byType(ObEnvelopeGauge), findsNothing);
    });
  });
}
