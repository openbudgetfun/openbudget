// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testCategoryId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000001',
  );
  final testEnvelopeId = UuidValue.fromString(
    '00000000-0000-0000-0000-000000000002',
  );

  Envelope makeEnvelope({
    String name = 'Groceries',
    int budgetedAmountCents = 50000,
    int spentAmountCents = 20000,
    String? note,
    bool? isHidden,
  }) => Envelope(
    id: testEnvelopeId,
    name: name,
    categoryId: testCategoryId,
    budgetedAmountCents: budgetedAmountCents,
    spentAmountCents: spentAmountCents,
    currencyCode: 'USD',
    sortOrder: 0,
    note: note,
    isHidden: isHidden,
  );

  EnvelopeGoal makeGoal({
    String goalType = 'target_balance',
    int targetAmountCents = 100000,
    int? monthlyFundingCents,
    DateTime? targetDate,
  }) => EnvelopeGoal(
    envelopeId: testEnvelopeId,
    goalType: goalType,
    targetAmountCents: targetAmountCents,
    monthlyFundingCents: monthlyFundingCents,
    targetDate: targetDate,
  );

  Widget buildSubject({
    required Envelope envelope,
    CurrencyCode currencyCode = CurrencyCode.usd,
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

      expect(find.byIcon(Icons.sticky_note_2_outlined), findsNothing);
    });

    testWidgets('renders quick budget button when callback provided', (
      tester,
    ) async {
      final envelope = makeEnvelope();
      await tester.pumpWidget(
        buildSubject(envelope: envelope, onQuickBudget: () {}),
      );
      await tester.pump();

      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
    });

    testWidgets('renders goal progress bar with underfunded text', (
      tester,
    ) async {
      // Envelope with goal target of $1000, but only $300 available
      final envelope = makeEnvelope(
        budgetedAmountCents: 30000,
        spentAmountCents: 0,
      );
      final goal = makeGoal();

      await tester.pumpWidget(buildSubject(envelope: envelope, goal: goal));
      await tester.pump();

      // Should show underfunded text with "needed" label
      expect(find.textContaining('needed'), findsOneWidget);
      // Should show warning icon
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('does not show underfunded text when fully funded', (
      tester,
    ) async {
      // Envelope with goal target of $1000, and $1000 available
      final envelope = makeEnvelope(
        budgetedAmountCents: 100000,
        spentAmountCents: 0,
      );
      final goal = makeGoal();

      await tester.pumpWidget(buildSubject(envelope: envelope, goal: goal));
      await tester.pump();

      // Should not show "needed" text when fully funded
      expect(find.textContaining('needed'), findsNothing);
    });

    testWidgets('renders spending progress bar without goal', (tester) async {
      final envelope = makeEnvelope(spentAmountCents: 25000);

      await tester.pumpWidget(buildSubject(envelope: envelope));
      await tester.pump();

      // Should render a LinearProgressIndicator (spending bar)
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders carryover indicator when present', (tester) async {
      final envelope = makeEnvelope();
      final monthlyData = MonthlyEnvelopeData(
        envelope: envelope,
        allocatedCents: 50000,
        spentCents: 20000,
        availableCents: 30000,
        carryoverCents: 5000,
      );

      await tester.pumpWidget(
        buildSubject(envelope: envelope, monthlyData: monthlyData),
      );
      await tester.pump();

      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('renders monthly funding goal underfunded amount', (
      tester,
    ) async {
      // Monthly funding goal: $200/month, but only $50 budgeted
      final envelope = makeEnvelope(
        budgetedAmountCents: 5000,
        spentAmountCents: 0,
      );
      final goal = makeGoal(
        goalType: 'monthly_funding',
        targetAmountCents: 20000,
        monthlyFundingCents: 20000,
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
      final envelope = makeEnvelope(spentAmountCents: 25000);

      await tester.pumpWidget(
        buildSubject(envelope: envelope, hideProgressBars: true),
      );
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
