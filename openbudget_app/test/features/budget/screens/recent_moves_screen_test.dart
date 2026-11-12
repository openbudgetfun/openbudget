import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';

const _entityId = '00000000-0000-0000-0000-000000000111';
const _categoryId = '00000000-0000-0000-0000-000000000222';
const _envelopeGroceriesId = '00000000-0000-0000-0000-000000000333';
const _envelopeClothingId = '00000000-0000-0000-0000-000000000444';

BudgetMonthView _makeMonthView() => testMonthView(
  entityId: _entityId,
  categories: [testCategory(id: _categoryId, name: 'Needs')],
  envelopes: [
    testEnvelopeRow(
      envelopeId: _envelopeGroceriesId,
      categoryId: _categoryId,
      envelopeName: 'Groceries',
      allocatedMinor: 120000,
      activityMinor: -40000,
    ),
    testEnvelopeRow(
      envelopeId: _envelopeClothingId,
      categoryId: _categoryId,
      envelopeName: 'Clothing',
      allocatedMinor: 40000,
      activityMinor: -10000,
    ),
  ],
);

Widget _buildSubject({
  required ProviderContainer container,
  required Widget home,
}) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );

Future<void> _dismissCoachmarkIfVisible(WidgetTester tester) async {
  final gotIt = find.text('Got It!');
  if (gotIt.evaluate().isEmpty) return;
  await tester.tap(gotIt);
  await tester.pumpAndSettle();
}

void main() {
  group('RecentMovesScreen', () {
    testWidgets('renders tabs and filters moved vs assigned events', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          budgetMonthProvider(_entityId).overrideWith(
            (ref) async => _makeMonthView(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildSubject(
          container: container,
          home: const RecentMovesScreen(entityId: _entityId),
        ),
      );
      await tester.pumpAndSettle();

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            entityId: _entityId,
            envelopeId: _envelopeGroceriesId,
            amountMinor: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            entityId: _entityId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountMinor: 3000,
          );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Recent Moves'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);
      expect(find.textContaining(DateTime.now().year.toString()), findsWidgets);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Moved'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('Clothing'), findsOneWidget);

      await tester.tap(find.text('Moved'));
      await tester.pumpAndSettle();
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Ready to Assign'), findsNothing);

      await tester.tap(find.text('Assigned'));
      await tester.pumpAndSettle();
      expect(find.text('Ready to Assign'), findsOneWidget);
    });

    testWidgets('shows envelope-specific move history', (tester) async {
      final container = ProviderContainer(
        overrides: [
          budgetMonthProvider(_entityId).overrideWith(
            (ref) async => _makeMonthView(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(recentMovesProvider.notifier)
          .recordAssigned(
            entityId: _entityId,
            envelopeId: _envelopeGroceriesId,
            amountMinor: 20000,
          );
      container
          .read(recentMovesProvider.notifier)
          .recordMove(
            entityId: _entityId,
            fromEnvelopeId: _envelopeGroceriesId,
            toEnvelopeId: _envelopeClothingId,
            amountMinor: 3000,
          );

      await tester.pumpWidget(
        _buildSubject(
          container: container,
          home: const EnvelopeMovesScreen(
            entityId: _entityId,
            envelopeId: _envelopeGroceriesId,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _dismissCoachmarkIfVisible(tester);

      expect(find.text('Moves'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.back,
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Groceries'), findsWidgets);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.forward,
        ),
        findsWidgets,
      );
    });
  });
}
