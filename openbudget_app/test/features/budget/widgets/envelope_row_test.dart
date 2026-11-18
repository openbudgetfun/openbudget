import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/widgets/envelope_row.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

EnvelopeMonthView _makeRow({
  String envelopeName = 'Groceries',
  String? note,
  int carryoverMinor = 0,
  int allocatedMinor = 50000,
  int activityMinor = -20000,
  EnvelopeGoal? goal,
  int goalUnderfundedMinor = 0,
}) => testEnvelopeRow(
  envelopeName: envelopeName,
  note: note,
  carryoverMinor: carryoverMinor,
  allocatedMinor: allocatedMinor,
  activityMinor: activityMinor,
  goal: goal,
  goalUnderfundedMinor: goalUnderfundedMinor,
);

EnvelopeGoal _makeGoal({
  EnvelopeGoalKind kind = EnvelopeGoalKind.targetBalance,
  int amountMinor = 100000,
}) => EnvelopeGoal(
  entityId: UuidValue.fromString(fixtureEntityId),
  envelopeId: UuidValue.fromString(fixtureEnvelopeId),
  kind: kind,
  amountMinor: amountMinor,
);

void main() {
  Widget buildSubject({
    required EnvelopeMonthView monthEnvelope,
    String currencyCode = 'USD',
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
          monthEnvelope: monthEnvelope,
          currencyCode: currencyCode,
          onTap: () {},
          onLongPress: () {},
          onQuickBudget: onQuickBudget,
          hideAmounts: hideAmounts,
          hideProgressBars: hideProgressBars,
        ),
      ),
    ),
  );

  group('EnvelopeRow', () {
    testWidgets('renders envelope name and amounts', (tester) async {
      final row = _makeRow();
      await tester.pumpWidget(buildSubject(monthEnvelope: row));
      await tester.pump();

      expect(find.text('Groceries'), findsOneWidget);
    });

    testWidgets('renders note when present', (tester) async {
      final row = _makeRow(note: 'Weekly shopping');
      await tester.pumpWidget(buildSubject(monthEnvelope: row));
      await tester.pump();

      expect(find.text('Weekly shopping'), findsOneWidget);
    });

    testWidgets('does not render note when absent', (tester) async {
      final row = _makeRow();
      await tester.pumpWidget(buildSubject(monthEnvelope: row));
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
      final row = _makeRow();
      await tester.pumpWidget(
        buildSubject(monthEnvelope: row, onQuickBudget: () {}),
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
      // Goal target of $1000 with $700 still underfunded.
      final row = _makeRow(
        allocatedMinor: 30000,
        goal: _makeGoal(),
        goalUnderfundedMinor: 70000,
      );

      await tester.pumpWidget(buildSubject(monthEnvelope: row));
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
      // Goal target of $1000, fully funded by the month view.
      final row = _makeRow(
        allocatedMinor: 100000,
        activityMinor: 0,
        goal: _makeGoal(),
      );

      await tester.pumpWidget(buildSubject(monthEnvelope: row));
      await tester.pump();

      // Should not show "needed" text when fully funded
      expect(find.textContaining('needed'), findsNothing);
    });

    testWidgets('renders spending progress bar without goal', (tester) async {
      final row = _makeRow(activityMinor: -25000);

      await tester.pumpWidget(buildSubject(monthEnvelope: row));
      await tester.pump();

      // Should render the envelope gauge that fills as money is spent.
      expect(find.byType(ObEnvelopeGauge), findsOneWidget);
    });

    testWidgets('renders carryover indicator when present', (tester) async {
      final row = _makeRow(carryoverMinor: 5000);

      await tester.pumpWidget(buildSubject(monthEnvelope: row));
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
      // Monthly funding goal: $200/month, with $150 still underfunded.
      final row = _makeRow(
        allocatedMinor: 5000,
        activityMinor: 0,
        goal: _makeGoal(
          kind: EnvelopeGoalKind.monthlyFunding,
          amountMinor: 20000,
        ),
        goalUnderfundedMinor: 15000,
      );

      await tester.pumpWidget(buildSubject(monthEnvelope: row));
      await tester.pump();

      // Should show underfunded text
      expect(find.textContaining('needed'), findsOneWidget);
    });

    testWidgets('obscures amount text when hide amounts is enabled', (
      tester,
    ) async {
      final row = _makeRow();
      await tester.pumpWidget(
        buildSubject(monthEnvelope: row, hideAmounts: true),
      );
      await tester.pump();

      expect(find.text(hiddenAmountPlaceholder), findsOneWidget);
    });

    testWidgets('hides progress bars when toggle is enabled', (tester) async {
      final row = _makeRow(activityMinor: -25000);

      await tester.pumpWidget(
        buildSubject(monthEnvelope: row, hideProgressBars: true),
      );
      await tester.pump();

      expect(find.byType(ObEnvelopeGauge), findsNothing);
    });
  });
}
